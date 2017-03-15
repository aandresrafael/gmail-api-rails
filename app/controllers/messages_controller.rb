class MessagesController < ApplicationController

  def index
    return unless session[:google_access_token]

    api_client = SaneBox::GClient.get_client
    @auth = api_client.authorization.dup
    @auth.update_token!(session[:google_access_token])

    api_client.authorization = @auth

    user_id = session[:google_access_token]['user_id']
    gmail_client = SaneBox::GmailClient.new(api_client, user_id)

    @data = {messages: gmail_client.inbox_messages_grouped }
  end

end
