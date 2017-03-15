require 'google/api_client'
require 'google/api_client/client_secrets'

module SaneBox
  class GClient
    REDIRECT_URL = 'http://localhost:3000/google/oauth2/callback'

    class << self
      #Initialize the Google Apli Client with authorization
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

      #Initialize the Google Apli Client.
      def get_client
        Google::APIClient.new(
          application_name: 'SaneBox Interview',
          application_version: '0.0.1' )
      end

    end
  end

  class GmailClient
    attr_accessor :next_page, :messages_ids
    def initialize(api_client, user_id, next_page)
      @api_client = api_client
      @gmail =  api_client.discovered_api( 'gmail', 'v1' )
      @user_id = user_id
      @next_page = next_page
    end

    #Make the api call to get the messages lists ids according the page
    # @return [Array] of messages ids.
    def inbox_messages_ids
      parameters = { userId: @user_id, labelIds: 'INBOX' }
      parameters[:pageToken] = @next_page if @next_page

      result =  @api_client.execute!(
        api_method: @gmail.users.messages.list,
        parameters: parameters
      )

      @next_page = result.next_page_token
      result.data.messages.map(&:id)
    end

    #Perform the api call for each message
    # @param messages_ids [Array] of  messages ids.
    # @return [Array] of hashes with from, to and subject grouped by 'from'
    def inbox_messages_grouped(messages_ids)
      messages = []
      messages_ids.each do |message_id|
        message = @api_client.execute!(
          api_method: @gmail.users.messages.get,
          parameters:{
            userId: @user_id,
            id: message_id
          }
        )
        headers = message.data.payload.headers
        from = headers.find { |h| h.name == 'From' }.try(:value)
        to = headers.find { |h| h.name == 'To'}.try(:value)
        subject = headers.find { |h| h.name == 'Subject'}.try(:value)

        messages <<  { from: from, to: to, subject: subject }
      end
      grouped = messages.group_by{|h| h[:from] }

      result = []
      grouped.each { |from, data| result << { from: from, items: data } }
      result
    end
  end
end