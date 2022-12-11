require 'rails_helper'

RSpec.describe EmailVerification do
  describe 'send_email' do
    let(:user) { build(:user) }
    let(:mailer) { double }
    let(:action) { -> { described_class.send_email(user, reason: reason) } }
    before(:each) { allow(mailer).to receive(:deliver_now) }
    context 'send_confirmation_email!' do
      before(:each) do
        allow_any_instance_of(User).to receive(
          :generate_confirmation_token
        ).and_return('foo')
      end
      let(:reason) { EmailVerification::REASON[:email_confirmation] }
      it 'call UserMailer.confirmation with correct arguments' do
        expect(UserMailer).to receive(:email_confirmation).with(
          user,
          'foo'
        ).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        action.call
      end
    end

    context 'send_password_reset_email' do
      before(:each) do
        allow_any_instance_of(User).to receive(
          :generate_password_reset_token
        ).and_return('foo')
      end
      let(:reason) { EmailVerification::REASON[:password_reset] }
      it 'call UserMailer.confirmation with correct arguments' do
        expect(UserMailer).to receive(:password_reset).with(
          user,
          'foo'
        ).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        action.call
      end
    end
  end
end
