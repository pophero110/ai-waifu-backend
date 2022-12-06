require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'class method' do
    context 'authenticate_by' do
      it 'returns user with corrent attributes' do
        email = 'test@gmail.com'
        password = 'test'
        User.create(email: email, password: password)
        expect(
          User.authenticate_by(email: email, password: password)
        ).to_not eq nil
        expect(
          User.authenticate_by(email: email, password: password).email
        ).to eq email
      end

      it 'returns nil with wrong attributes' do
        email = 'test@gmail.com'
        password = 'test'
        User.create(email: email, password: password)

        expect(User.authenticate_by(email: email, password: 'wrong')).to eq nil
      end
    end
  end

  describe 'instance method' do
    context 'confirmable_email' do
      let(:user_attributes) do
        {
          email: 'test@gmail.com',
          password: 'test',
          unconfirmed_email: 'new@gmail.com'
        }
      end
      it 'returns email address' do
        user = User.create(user_attributes)
        expect(user.confirmable_email).to eq user_attributes[:unconfirmed_email]

        user.update(unconfirmed_email: nil)
        expect(user.confirmable_email).to eq user_attributes[:email]
      end
    end

    context 'unconfirmed?' do
      it 'returns boolean' do
        user = User.create(email: 'test@gmail.com', password: 'test')

        expect(user.unconfirmed?).to eq true

        user.update(confirmed_at: Time.current)

        expect(user.unconfirmed?).to eq false
      end
    end

    context 'confirmed?' do
      it 'returns boolean' do
        user = User.create(email: 'test@gmail.com', password: 'test')

        expect(user.confirmed?).to eq false

        user.update(confirmed_at: Time.current)

        expect(user.confirmed?).to eq true
      end
    end

    context 'confirmed!' do
      it 'updates confirmed_at in databse' do
        user =
          User.create(
            email: 'test@gmail.com',
            password: 'test',
            confirmed_at: nil
          )

        result = user.confirms_email?
        debugger
        expect(user.confirmed_at).to_not eq nil
      end

      it 'updates email and confirmed_at when unconfirmed_email present' do
        user =
          User.create(
            email: 'test@gmail.com',
            password: 'test',
            unconfirmed_email: 'new@gmail.com',
            confirmed_at: nil
          )

        expect(user.confirms_email?).to eq true

        expect(user.confirmed_at).to_not eq nil
        expect(user.email).to eq 'new@gmail.com'
      end
    end
  end
end
