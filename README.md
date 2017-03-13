# Welcome to SaneBox

You should have received a request to share a repository on BitBucket.  Please
accept it, and set up your computer to access BitBucket.

After you do checkout the repository:

    git clone https://$YOUR_BITBUCKET_USERNAME@bitbucket.org:/sanebox/interview-%{email_url}.git

The repository you cloned contains the set up for your programming test.

You are not necessarily expected to finish the test in the alloted time, but
try to get as far as possible.

If you are running a recent version of Mac OSX, you may need to install the v8
gem manually. You can do this by executing:

    gem install libv8 -v '3.16.14.7' -- --with-system-v8

This repository is set up to use Bundler.  If you would like to add any
gems to the project just list it in the Gemfile and run:

    bundle install

You may install and use any 3rd party gems that you find to be useful.

# Your Task

Using the [Gmail REST API][1], and the [Ruby Google API client][2], construct a
web service that will list the contents of the users **INBOX**.

The messages should be neatly displayed (Bootstrap 3 has been thoughtfully
included) and grouped by **From** address.  Use your own judgement for the
final formatting, but don't get too caught up on making it pretty.

    First Last <email@addre.ss>

      To: <me@somewhere.com>
      Subject: Subject 1

      To: <other@address.com>
      Cc: <team@member.com>
      Subject: Subject 2

    Sender Number Two <other@person.com>

      To: <me@somewhere.com>
      Subject: Subject 3

      To: <another@address.com>
      Subject: Subject 4

When you're done, just push your code to the repository using your typical git
commands and drop me a note!

Some things to consider:

  * What can be done with lazy one-time initialization?
  * How many messages does a single call to the API fetch?  What if the INBOX has more than that?

Remember, we're interested in evalulating your ability in Ruby and Rails.
While you may solve some aspects of the problem using other technologies /
languages, **your solution should primarily be written in Ruby**.

# Some helpful hints

The Google API Client uses [Signet::OAuth2][3] to handle the OAuth2 exchange.

There is already a Project setup in the Google Developer Console for this task.
The registered callback URI is http://localhost:3000/google/oauth2/callback.
If, for some reason, you need a different URI please let me know.

You may initialize the client using the following code:

    require 'google/api_client'
    require 'google/api_client/client_secrets'
    
    api_client = Google::APIClient.new( 
      :application_name => 'SaneBox Interview',
      :application_version => '0.0.1' ) 
    client_secrets = Google::APIClient::ClientSecrets.load(
      Rails.root.join( 'config/client_secret.json' ) )
    api_client.authorization = client_secrets.to_authorization
    api_client.authorization.scope = 
      'https://www.googleapis.com/auth/gmail.readonly ' \
      'openid email profile'

Familiarity with OAuth2 will be helpful with this task, so its best to take
some time to understand [this document][4].

**You will be populating the two endpoints in OauthController to handle the
Oauth2 exchange.**

When you *do not have an access token*, you may redirect the user to the
following url: 

    auth = api_client.authorization.dup
    auth.redirect_uri = your_oauth2_callback_endpoint_url
      # i.e. http://localhost:3000/google/oauth2/callback
    auth.update_token!( empty_hash_or_saved_oauth2_credentials )
    redirect_to auth.authorization_uri.to_s

In your OauthController#callback you can get an access token using the
following snippet:

    auth = api_client.authorization.dup
    auth.redirect_uri = your_oauth2_callback_endpoint_url
    auth.update!( params )
    auth.fetch_access_token!

You may wish to save some data from the `auth` at this point into the
`empty_hash_or_saved_oauth2_credentials`:

    empty_hash_or_saved_oauth2_credentials.merge \
      access_token: auth.access_token
      refresh_token: auth.refresh_token
      expires_in: auth.expires_in
      issued_at: auth.issued_at

You might find that the `session` is a good place to store this information.

Finally, to determine who just authenticated:

    identity = MultiJson.load( auth.fetch_protected_resource( :uri =>
      'https://www.googleapis.com/plus/v1/people/me/openIdConnect' ).body )

Once you have completed the OAuth2 credential exchange you can make API
requests using the Gmail API:

    gmail = api_client.discovered_api( 'gmail', 'v1' )
    response = MultiJson.load( api_client.execute( 
      :api_method => gmail.users.labels.list,
      :parameters => { :userId => identity[ 'email' ] },
      :authorization => auth ).body )

Good luck! If you get stuck, **please** feel free to ask me for help.  There
may be several additional pointers we can provide if you find yourself stuck
with some aspect of the OAuth2 credential exchange or API usage.

Best wishes,  
Peter

PS. If you're experiencing long delays when interacting with the Google API,
its possible that your IPv6 settings are somehow interfering.  On OSX we've
found that [this discussion thread][5] helped us work around the error:

    networksetup -listallnetworkservices
    networksetup -setv6off wi-fi

[1]: https://developers.google.com/gmail/api/
[2]: https://developers.google.com/api-client-library/ruby/
[3]: https://github.com/google/signet
[4]: https://developers.google.com/accounts/docs/OAuth2#webserver
[5]: https://discussions.apple.com/thread/5852494

