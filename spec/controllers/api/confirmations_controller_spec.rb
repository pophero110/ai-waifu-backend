require "rails_helper"

RSpec.describe Api::ConfirmationsController, :type => :controller do
  describe "user is found" do
    let!(:user) { User.create(email: "test@gmail.com", password: "test") }
    context "email is unconfirmed" do
      it "return 200" do
        confirmation_token = user.generate_confirmation_token
        get :edit, :params => { :use_route => "api/confirmations", :confirmation_token => confirmation_token }
        expect(response).to have_http_status(:success)
        expect(user.reload.confirmed_at).to_not eq(nil)
      end
    end
    context "email is confirmed" do
      it "return 422" do
        confirmation_token = user.generate_confirmation_token
        user.update(confirmed_at: Time.current)
        get :edit, :params => { :use_route => "api/confirmations", :confirmation_token => confirmation_token }
        expect(response).to have_http_status(422)
        expect(JSON(response.body)["error"]).to eq("Your email address has been confirmed")
      end
    end
  end

  describe "user is not found" do
    it "return 422" do
      get :edit, :params => { :use_route => "api/confirmations", :confirmation_token => "test_token" }
      expect(response).to have_http_status(422)
      expect(JSON(response.body)["error"]).to eq("Invalid Token")
    end
  end
end
