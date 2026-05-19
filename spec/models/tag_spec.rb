require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it 'is invalid without a name' do
      t = build(:tag, name: nil)
      expect(t).not_to be_valid
      expect(t.errors[:name]).to be_present
    end
  end

  describe 'associations' do
    it 'can be attached to books through book_tags' do
      tag = create(:tag)
      book = create(:book)
      book.tags << tag
      expect(book.tags).to include(tag)
    end
  end
end
