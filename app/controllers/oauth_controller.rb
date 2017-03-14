class OauthController < ApplicationController
  before_filter :init_client
  include SaneBox

  def index
    auth = @api_client.authorization.dup
    auth.redirect_uri = 'http://localhost:3000/google/oauth2/callback'

    auth.update_token!(empty_hash_or_saved_oauth2_credentials)
    redirect_to auth.authorization_uri.to_s
  end

  def callback
    auth = @api_client.authorization.dup
    auth.redirect_uri = 'http://localhost:3000/google/oauth2/callback'
    auth.update!( params )
    auth.fetch_access_token!

    empty_hash_or_saved_oauth2_credentials.merge!(
      access_token: auth.access_token,
      refresh_token: auth.refresh_token,
      expires_in: auth.expires_in,
      issued_at: auth.issued_at,
    )
    session[:google_access_token] = empty_hash_or_saved_oauth2_credentials
    set_user_id(auth)

    redirect_to root_path
  end


  protected
  def init_client
    @api_client = SaneBox::GClient.client
  end

  def empty_hash_or_saved_oauth2_credentials
    @empty_hash_or_saved_oauth2_credentials ||= {}
  end

  def set_user_id(auth)
    identity = MultiJson.load(
      auth.fetch_protected_resource(
        uri: 'https://www.googleapis.com/plus/v1/people/me/openIdConnect'
      ).body
    )

    session[:google_access_token].merge!(user_id: identity['email'])
  end
end
