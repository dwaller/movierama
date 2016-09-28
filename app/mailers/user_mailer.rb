class UserMailer < ActionMailer::Base
  default from: "mail@movierama.com"

  def vote_notification_email(voter_uid, movie_id, like)
    @voter = User.find(uid: voter_uid).first
    @movie = Movie[movie_id]
    @user  = @movie.user
    @like  = like
    return unless @user.email

    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(to: email_with_name, subject: "Someone likes or hates your movie")
  end
end
