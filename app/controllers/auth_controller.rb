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