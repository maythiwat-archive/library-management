require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with an email and password' do
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = FactoryBot.build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe 'associations' do
    it 'has a dependent member_profile association' do
      association = described_class.reflect_on_association(:member_profile)

      expect(association.macro).to eq(:has_one)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has loans and books associations' do
      loans_association = described_class.reflect_on_association(:loans)
      books_association = described_class.reflect_on_association(:books)

      expect(loans_association.macro).to eq(:has_many)
      expect(books_association.macro).to eq(:has_many)
      expect(books_association.options[:through]).to eq(:loans)
    end

    it 'destroys the member profile when the user is destroyed' do
      user = create(:user, :with_member_profile)
      profile = user.member_profile

      expect { user.destroy }.to change(MemberProfile, :count).by(-1)
      expect(MemberProfile.exists?(profile.id)).to be(false)
    end
  end
end
