class WelcomeMailer < ApplicationMailer
  def welcome(user)
    subject = "Welcome to Czardom"
    mail(:to => user.email, :subject => subject )
  end
end