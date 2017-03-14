class MessagesController < ApplicationController

  def index
    return unless session[:google_access_token]

    api_client = SaneBox::GClient.get_client
    auth = api_client.authorization.dup
    auth.update_token!(session[:google_access_token])
    api_client.authorization = auth

    gmail =  api_client.discovered_api( 'gmail', 'v1' )
    user_id = session[:google_access_token]['user_id']


    result =  api_client.execute!(
        api_method: gmail.users.messages.list,
        parameters:{
          userId: user_id,
          labelIds: 'INBOX',
          maxResults: 2
        }
      )

    messages = result.data.messages
    messages_ids = messages.map(&:id)

    @messages = []
    messages_ids.each do |message_id|
      message = api_client.execute!(
        api_method: gmail.users.messages.get,
        parameters:{
          userId: user_id,
          id: message_id
        }
      )
      headers = message.data.payload.headers
      from = headers.find { |h| h.name == 'From' }.value
      to = headers.find { |h| h.name == 'To'}.value
      subject = headers.find { |h| h.name == 'Subject'}.value
      @messages <<  [from, to, subject]
    end

  end

end
