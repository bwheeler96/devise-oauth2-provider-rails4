require 'devise'
require 'rack/oauth2'
require 'devise/oauth2/engine'
require 'devise/oauth2/expirable_token'
require 'devise/oauth2/strategies/oauth2_providable_strategy'
require 'devise/oauth2/strategies/oauth2_password_grant_type_strategy'
require 'devise/oauth2/strategies/oauth2_refresh_token_grant_type_strategy'
require 'devise/oauth2/strategies/oauth2_authorization_code_grant_type_strategy'
require 'devise/oauth2/models/oauth2_providable'
require 'devise/oauth2/models/oauth2_password_grantable'
require 'devise/oauth2/models/oauth2_refresh_token_grantable'
require 'devise/oauth2/models/oauth2_authorization_code_grantable'

module Devise
  module Oauth2
    CLIENT_ENV_REF = 'oauth2.client'
    REFRESH_TOKEN_ENV_REF = "oauth2.refresh_token"

    class << self
      def random_id
        SecureRandom.hex
      end
      def table_name_prefix
        'oauth2_'
      end
    end
  end
end

Devise.add_module(:oauth2,
  :strategy => true,
  :model => 'devise/oauth2/models/oauth2_providable')
Devise.add_module(:oauth2_password_grantable,
  :strategy => true,
  :model => 'devise/oauth2/models/oauth2_password_grantable')
Devise.add_module(:oauth2_refresh_token_grantable,
  :strategy => true,
  :model => 'devise/oauth2/models/oauth2_refresh_token_grantable')
Devise.add_module(:oauth2_authorization_code_grantable,
  :strategy => true,
  :model => 'devise/oauth2/models/oauth2_authorization_code_grantable')
