##Using Omni Auth

Step-by-step creation instructions to enable oAuth based authentication using the omni auth gem.

####create app

```
rails new omniauth_test -T -d postgresql
cd omniauth_test
```

####Generate model

```
rails g model user auth_hash:string email:string name:string
```
* auth_hash - the hash we get from the oauth provider (eg facebook, twitter, etc)
* Which oauth provider we're using (eg facebook, twitter, etc)


####Create database and tables

(remember to run `postgres.app` first)

```
rake db:create
rake db:migrate
```

####Quickly test your model

```
rails c
User.all
```

####Add omni auth gems

in Gemfile:

```
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
```

add `omniauth` and then the strategy gem for each oauth provider you want to support. In the example above I'm doing facebook, twitter, and google. [Full list of supported strategies](https://github.com/intridea/omniauth/wiki/List-of-Strategies).

After updating the gem file remember to run `bundle install`.

####Init omni auth

create a new file:  `config/initializers/omniauth.rb`

Add an initlizer for each strategy / provider you want to support.

```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end
```

####Create apps with providers

Now you need to go to facebook, twitter, google, etc and create an app. This will allow you to get the key/secret for each service which you can set in your environment variable in one of two ways:

* globally in your `~/.zshrc`
* locally in a `.env` file. Run your app using `foreman run rails s`

**NOTE:** remember to add `.env` to your `.gitignore` file to avoid exposing your keys on github.

**Quicklinks for API key creation**

* [Facebook](https://developers.facebook.com/apps/)
* [Twitter](https://apps.twitter.com/)
* [Google](https://console.developers.google.com/project)

####Create auth routes

Like many things in rails OmniAuth uses convention over configuration so it has pre-defined routes that you are expected to use.

* /auth/:provider -- login route, created for us, redirects user to the appropriate provider.
* /auth/failure -- user is sent here on authentication failure
* /auth/:provider/callback -- callback url. This is where the user is redirected after they come back from the provider.
 
**add to `config/routes.rb`**

```
get 'auth/logout' => 'auth#logout'
get 'auth/failure' => 'auth#failure'
get 'auth/:provider/callback' => 'auth#callback'
```

**create auth controller `auth_controller.rb`**

```
class AuthController < ApplicationController

    def callback
        provider_user = request.env['omniauth.auth']

        @user = User.find_or_create_by(auth_hash: provider_user['uid'], provider:params[:provider])

        if provider_user['info'] && provider_user['info']['name']
            @user.name=provider_user['info']['name']
            @user.save
        end
        session[:user_id] = @user.id
        redirect_to root_path
    end

    def logout
        session[:user_id]=nil
        redirect_to root_path
    end

    def failure
        #TODO: render a page with a failure message
        render plain: "this is a failure"
    end
   
end
```

##Views

Create links for login / logout. See `views/pages/index.html.erb`
