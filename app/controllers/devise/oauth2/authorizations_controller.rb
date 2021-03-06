module Devise
  module Oauth2
    class AuthorizationsController < ApplicationController

      before_action :authenticate_anyone!
      include Devise::Oauth2::Authorization

      before_action "authenticate_#{Rails.application.config.devise_oauth2_rails4.devise_scope}!"
      around_action :perform_callbacks

      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        @error = e
        render :error, :status => e.status
      end

      def new
        authorize_endpoint
      end

      def create
        authorize_endpoint(:allow_approval)
      end

      private

      def respond(status, header, response)
        ["WWW-Authenticate"].each do |key|
          headers[key] = header[key] if header[key].present?
        end
        if response.redirect?
          redirect_to header['Location']
        else
          render :new
        end
      end

      def authorize_endpoint(allow_approval = false)
        authorization = Rack::OAuth2::Server::Authorize.new do |req, res|
          @client = Client.find_by_identifier(req.client_id) || req.bad_request!

          if @client
            res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uri)

            if allow_approval || @client.passthrough?
              if params[:approve].present? || @client.passthrough?
                case req.response_type
                  when :code
                    authorization_code = current_anything.authorization_codes.create!(:client => @client)
                    res.code = authorization_code.token
                  when :token
                    access_token = current_anything.access_tokens.create!(:client => @client, permissions: requested_permissions).token
                    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(:access_token => access_token)
                    res.access_token = bearer_token
                    # res.uid = current_user.id
                end
                after_allowed_authorization if defined? after_allowed_authorization
                return if performed?
                res.approve!
              else
                after_denied_authorization if defined? after_denied_authorization
                return if performed?
                req.access_denied!
              end
            else
              @response_type = req.response_type
            end
          end
        end

        respond *authorization.call(request.env)
      end

      def requested_permissions
        params[:permissions] || @client.default_permissions
      end

      def perform_callbacks

        before_authorize if defined? before_authorize
        return if performed?
        yield
        after_authorize if defined? after_authorize
      end

    end
  end
end
