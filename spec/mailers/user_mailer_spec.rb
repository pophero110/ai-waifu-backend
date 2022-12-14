require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'email_confirmation' do
    let(:user) { build(:user) }
    let(:mail) do
      UserMailer.email_confirmation(user.confirmable_email, confirmation_token)
    end
    let(:confirmation_token) { 'foo' }
    it 'renders the headers' do
      expect(mail.subject).to eq 'Email Confirmation Instructions'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq [User::MAILER_FROM_EMAIL]
    end

    it 'renders the body' do
      expect(
        mail.html_part.body.decoded[/http(.*?)foo/]
      ).to eq verify_api_email_confirmations_url(
           confirmation_token: confirmation_token
         )
      expect(
        mail.text_part.body.decoded[/http(.*?)foo/]
      ).to eq verify_api_email_confirmations_url(
           confirmation_token: confirmation_token
         )
    end

    it 'delivers email' do
      expect { mail.deliver_now }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end
  end

  describe 'password_reset' do
    let(:user) { build(:user) }
    let(:mail) { UserMailer.password_reset(user.email, password_reset_token) }
    let(:password_reset_token) { 'foo' }
    it 'renders the headers' do
      expect(mail.subject).to eq 'Password Reset Instructions'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq [User::MAILER_FROM_EMAIL]
    end

    it 'renders the body' do
      expect(
        mail.html_part.body.decoded[/http(.*?)foo/]
      ).to eq verify_api_password_resets_url(
           password_reset_token: password_reset_token
         )
      expect(
        mail.text_part.body.decoded[/http(.*?)foo/]
      ).to eq verify_api_password_resets_url(
           password_reset_token: password_reset_token
         )
    end
    it 'delivers email' do
      expect { mail.deliver_now }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end
  end
end
