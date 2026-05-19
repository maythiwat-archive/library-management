require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:author) { create(:author) }
  let(:book) { create(:book, author: author) }

  describe 'validations' do
    it 'is valid with a name' do
      expect(book).to be_valid
    end

    it 'is invalid without a name' do
      b = build(:book, name: nil)
      expect(b).not_to be_valid
      expect(b.errors[:name]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to an author' do
      expect(book.author).to eq(author)
    end

    it 'has many tags through book_tags' do
      tag = create(:tag)
      book.tags << tag
      expect(book.tags).to include(tag)
    end
  end

  describe '#available?' do
    it 'returns true when there are no active loans' do
      expect(book.available?).to be(true)
    end

    it 'returns false when a loan exists without returned_at' do
      create(:loan, book: book, user: create(:user), returned_at: nil)
      expect(book.available?).to be(false)
    end

    it 'returns true when loans are returned' do
      create(:loan, book: book, user: create(:user), returned_at: Time.current)
      expect(book.available?).to be(true)
    end
  end
end
