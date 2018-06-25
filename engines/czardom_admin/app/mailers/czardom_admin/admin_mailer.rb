module CzardomAdmin
  class AdminMailer < ApplicationMailer
    
    def account_confirmation(user, token, status, host)
      @user = user
      @status = status
      @host = host
      @token = token
       mail(:to => @user.email, :subject => "Registration Confirmation")
    end

  end
end
