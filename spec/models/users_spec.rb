require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    let(:user) { build(:user, email: 'test.com') }
    context 'email' do
      it 'checks email format' do
        expect(user.valid?).to eq false
        expect(user.errors.messages[:email][0]).to eq 'is invalid'
      end

      it 'checks email presence' do
        user.email = nil
        expect(user.valid?).to eq false
        expect(user.errors.messages[:email]).to eq [
             'is invalid',
             "can't be blank"
           ]
      end
    end
  end
  describe 'callback' do
    let(:user) { create(:user, email: 'TEST@gmail.com') }
    context 'before_save' do
      it 'downcases email address' do
        expect(user.email).to eq 'test@gmail.com'
      end

      it 'downcases unconfirmed_email address' do
        user.update(unconfirmed_email: 'ABC@gmail.com')

        expect(user.unconfirmed_email).to eq 'abc@gmail.com'
      end
    end
  end
  describe 'class method' do
    let(:password) { 'test' }
    let!(:user) { create(:user, password: password) }
    context 'authenticate_by' do
      it 'returns user with corrent attributes' do
        expect(
          User.authenticate_by(email: user.email, password: password).email
        ).to eq user.email
      end

      it 'returns nil with wrong attributes' do
        expect(
          User.authenticate_by(email: user.email, password: 'wrong')
        ).to eq nil
      end
    end
  end

  describe 'instance method' do
    let(:unconfirmed_email) { 'unconfirmed@test.com' }
    let(:user) { build(:user, unconfirmed_email: unconfirmed_email) }
    context 'confirmable_email' do
      context 'when unconfirmed_email exist' do
        it 'returns unconfirmed_email address' do
          expect(user.confirmable_email).to eq unconfirmed_email
        end
      end
      context 'when unconfirmed does not exist' do
        let(:unconfirmed_email) { nil }
        it 'returns email address' do
          expect(user.confirmable_email).to eq user.email
        end
      end
    end

    context 'unconfirmed?' do
      let(:user) { build(:user) }
      it 'returns boolean' do
        expect(user.unconfirmed?).to eq true

        user.confirmed_at = Time.current

        expect(user.unconfirmed?).to eq false
      end
    end

    context 'confirmed?' do
      let(:user) { build(:user) }
      it 'returns boolean' do
        expect(user.confirmed?).to eq false

        user.confirmed_at = Time.current

        expect(user.confirmed?).to eq true
      end
    end

    context 'confirms_email?' do
      let(:unconfirmed_email) { 'new@gmail.com' }
      let(:user) do
        build(:user, confirmed_at: nil, unconfirmed_email: unconfirmed_email)
      end
      it 'updates confirmed_at' do
        expect(user.confirms_email?).to eq true
        expect(user.confirmed_at).to_not eq nil
      end

      it 'replace email with unconfirmed_email' do
        user.confirms_email?
        expect(user.email).to eq unconfirmed_email
        expect(user.unconfirmed_email).to eq nil
      end
    end

    describe 'send_email' do
      let(:user) { build(:user) }
      let(:mailer) { double }
      before(:each) { allow(mailer).to receive(:deliver_now) }
      context 'send_confirmation_email!' do
        before(:each) do
          allow_any_instance_of(User).to receive(
            :generate_confirmation_token
          ).and_return('foo')
        end
        it 'call UserMailer.confirmation with correct arguments' do
          expect(UserMailer).to receive(:email_confirmation).with(
            user,
            'foo'
          ).and_return(mailer)
          expect(mailer).to receive(:deliver_now)

          user.send_confirmation_email!
        end
      end

      context 'send_password_reset_email' do
        before(:each) do
          allow_any_instance_of(User).to receive(
            :generate_password_reset_token
          ).and_return('foo')
        end
        it 'call UserMailer.confirmation with correct arguments' do
          expect(UserMailer).to receive(:password_reset).with(
            user,
            'foo'
          ).and_return(mailer)
          expect(mailer).to receive(:deliver_now)

          user.send_password_reset_email!
        end
      end
    end

    describe 'generate token' do
      let(:user) { create(:user) }
      context 'generate_confirmation_token' do
        let(:confirmation_token) { user.generate_confirmation_token }
        it 'find_signed user' do
          found = User.find_signed(confirmation_token, purpose: :confirm_email)

          expect(found).to_not eq nil
          expect(found.id).to eq user.id
        end
      end

      context 'generate_password_reset_token' do
        let(:password_reset_token) { user.generate_password_reset_token }
        it 'find_signed user' do
          found =
            User.find_signed(password_reset_token, purpose: :reset_password)

          expect(found).to_not eq nil
          expect(found.id).to eq user.id
        end
      end
    end
  end
end
