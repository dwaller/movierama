require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'vote_notification_email' do
    let(:author) { double(uid:   'github|12345',
                          name:  'Bob',
                          email: 'bob@example.com') }
    let(:movie) { double(id:           '3456',
                         title:        'Empire strikes back',
                         description:  'Who\'s scruffy-looking?',
                         date:         '1980-05-21',
                         user:         author) }
    let(:voter) { double(uid:   'github|45678',
                         name:  'Alice',
                         email: 'alice@example.com') }
    let(:mail) { described_class.vote_notification_email(voter.uid,
                                                         movie.id,
                                                         like?).deliver }

    before do
      allow(User).to receive(:find).with(uid: voter.uid).and_return([voter])
      allow(Movie).to receive(:[]).with(movie.id).and_return(movie)
    end

    context 'for a like' do
      let(:like?) { true }

      it 'renders the subject' do
        expect(mail.subject).to eq('Someone likes or hates your movie')
      end

      it 'sets from/to email addresses' do
        expect(mail.from).to eq(['mail@movierama.com'])
        expect(mail.to).to eq([author.email])
      end

      it 'renders the body' do
        expect(mail.html_part.body.encoded).to include("A kindred spirit!  Alice likes Empire strikes back too.")
        expect(mail.text_part.body.encoded).to include("A kindred spirit!  Alice likes Empire strikes back too.")
      end
    end

    context 'for a hate' do
      let(:like?) { false }

      it 'renders the subject' do
        expect(mail.subject).to eq('Someone likes or hates your movie')
      end

      it 'sets from/to email addresses' do
        expect(mail.from).to eq(['mail@movierama.com'])
        expect(mail.to).to eq([author.email])
      end

      it 'renders the body' do
        expect(mail.html_part.body.encoded).to include("How rude!  Alice hates Empire strikes back.")
        expect(mail.text_part.body.encoded).to include("How rude!  Alice hates Empire strikes back.")
      end
    end

    context 'when the author has no email' do
      let(:author) { double(uid:   'github|12345',
                            name:  'Bob',
                            email: nil) }
      let(:like?) { true }

      it 'does not deliver an email' do
        expect(mail).to be_nil
      end
    end
  end
end
