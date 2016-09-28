class UserMailer < ActionMailer::Base
  default from: "mail@movierama.com"

  def vote_notification_email(user_uid, voter_uid, movie_id, like)
    @user  = User.find(uid: user_uid).first
    @voter = User.find(uid: voter_uid).first
    @movie = Movie[movie_id]
    @like  = like
    return unless @user.email

    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(to: email_with_name, subject: "Someone likes or hates your movie")
  end
end
