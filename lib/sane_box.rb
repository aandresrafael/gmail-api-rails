require 'google/api_client'
require 'google/api_client/client_secrets'

module SaneBox
  class GClient
    class << self
      def client
        api_client = get_client
        client_secrets = Google::APIClient::ClientSecrets.load(client_credentials)

        api_client.authorization = client_secrets.to_authorization
        api_client.authorization.scope =
          'https://www.googleapis.com/auth/gmail.readonly ' \
          'openid email profile'
        api_client
      end

      def client_credentials
        Rails.root.join( 'config/client_secret.json' )
      end

      def get_client
        Google::APIClient.new(
          application_name: 'SaneBox Interview',
          application_version: '0.0.1' )
      end
    end
  end
end