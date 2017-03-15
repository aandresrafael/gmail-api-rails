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

  class GmailClient
    def initialize(api_client, user_id)
      @api_client = api_client
      @gmail =  api_client.discovered_api( 'gmail', 'v1' )
      @user_id = user_id
    end

    def inbox_messages_ids
      result =  @api_client.execute!(
          api_method: @gmail.users.messages.list,
          parameters:{
            userId: @user_id,
            labelIds: 'INBOX',
            maxResults: 10
          }
        )

      messages = result.data.messages
      messages.map(&:id)
    end

    def inbox_messages_grouped
      messages = []
      inbox_messages_ids.each do |message_id|
        message = @api_client.execute!(
          api_method: @gmail.users.messages.get,
          parameters:{
            userId: @user_id,
            id: message_id
          }
        )
        headers = message.data.payload.headers
        from = headers.find { |h| h.name == 'From' }.value
        to = headers.find { |h| h.name == 'To'}.value
        subject = headers.find { |h| h.name == 'Subject'}.value

        messages <<  { from: from, to: to, subject: subject }
      end
      grouped = messages.group_by{|h| h[:from] }

      result = []
      grouped.each { |from, data| result << { from: from, items: data } }
      result
    end
  end
end