require 'rails_helper'

RSpec.describe MemberProfile, type: :model do
  it 'belongs to a user' do
    user = create(:user, :with_member_profile)
    expect(user.member_profile).to be_present
    expect(user.member_profile.user).to eq(user)
  end
end
