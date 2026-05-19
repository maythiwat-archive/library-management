require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'validations' do
    it 'is invalid without a name' do
      a = build(:author, name: nil)
      expect(a).not_to be_valid
      expect(a.errors[:name]).to be_present
    end
  end

  describe 'associations' do
    it 'cannot be deleted while books exist due to DB foreign-key constraints' do
      author = create(:author)
      create(:book, author: author)
      expect { author.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end
