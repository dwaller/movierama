require 'rails_helper'
require 'capybara/rails'
require 'capybara/email/rspec'
require 'support/pages/movie_list'
require 'support/pages/movie_new'
require 'support/with_user'
require 'sidekiq/testing'

RSpec.describe 'vote on movies', type: :feature do

  let(:page) { Pages::MovieList.new }
  let(:author_email_address) { 'bob@example.com' }

  before do
    Sidekiq::Testing.inline!
    clear_emails

    author = User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: author_email_address
    )
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author
    )
  end

  context 'when logged out' do
    it 'cannot vote' do
      page.open
      expect {
        page.like('Empire strikes back')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'when logged in' do
    with_logged_in_user

    before { page.open }

    it 'can like' do
      page.like('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'like triggers notification email' do
      page.like('Empire strikes back')
      open_email(author_email_address)
      expect(current_email).to_not be_nil
    end

    it 'can hate' do
      page.hate('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'can unlike' do
      page.like('Empire strikes back')
      page.unlike('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'can unhate' do
      page.hate('Empire strikes back')
      page.unhate('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'cannot like twice' do
      expect {
        2.times { page.like('Empire strikes back') }
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot like own movies' do
      Pages::MovieNew.new.open.submit(
        title:       'The Party',
        date:        '1969-08-13',
        description: 'Birdy nom nom')
      page.open
      expect {
        page.like('The Party')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

end



