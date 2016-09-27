class UserMailer < ActionMailer::Base
  default from: "mail@movierama.com"

  def like_hate_notification_email(user_uid)
    @user = User.find(uid: user_uid).first
    return unless @user

    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(to: email_with_name, subject: "Someone likes or hates your movie")
  end
end
