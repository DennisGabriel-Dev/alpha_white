class UserMailer < ApplicationMailer
  default from: 'Acme <onboarding@resend.dev>' # TODO: change me
  def welcome_email
    @user = params[:user]
    @url = 'http://example.com/login' # TODO: change me
    mail(to: ["delivered@resend.dev"], subject: 'hello world') # TODO: change me
  end
end
