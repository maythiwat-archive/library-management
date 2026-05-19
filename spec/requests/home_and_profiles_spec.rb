require 'rails_helper'

RSpec.describe "Home and Profiles", type: :request do
  it "renders the home page" do
    create(:book)
    get root_path
    expect(response).to have_http_status(:ok)
  end

  context "profiles" do
    let(:user) { create(:user, :with_member_profile) }

    before { sign_in user }

    it "shows profile" do
      get profile_path
      expect(response).to have_http_status(:ok)
    end

    it "edits and updates profile" do
      get edit_profile_path
      expect(response).to have_http_status(:ok)
      patch profile_path, params: { member_profile: { name: 'New Name' } }
      expect(response).to redirect_to(profile_path)
      follow_redirect!
      expect(response.body).to include('Profile updated')
    end
  end
end
