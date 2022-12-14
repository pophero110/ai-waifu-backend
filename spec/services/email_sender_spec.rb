require 'rails_helper'

RSpec.describe EmailSender do
  describe 'class methods' do
    let(:user) { build(:user) }
    let(:mailer) { double }
    before(:each) { allow(mailer).to receive(:deliver_now) }
    context 'email_confirmation' do
      before(:each) do
        allow_any_instance_of(User).to receive(
          :generate_confirmation_token
        ).and_return('foo')
      end
      let(:action) { -> { described_class.email_confirmation(user) } }
      it 'call UserMailer.confirmation with correct arguments' do
        expect(UserMailer).to receive(:email_confirmation).with(
          user.confirmable_email,
          'foo'
        ).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        action.call
      end
    end

    context 'password_reset' do
      before(:each) do
        allow_any_instance_of(User).to receive(
          :generate_password_reset_token
        ).and_return('foo')
      end
      let(:action) { -> { described_class.password_reset(user) } }
      it 'call UserMailer.confirmation with correct arguments' do
        expect(UserMailer).to receive(:password_reset).with(
          user.email,
          'foo'
        ).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        action.call
      end
    end
  end
end
