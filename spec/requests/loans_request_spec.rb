require 'rails_helper'

RSpec.describe "Loans", type: :request do
  let(:book) { create(:book) }

  describe "POST /books/:book_id/loans" do
    it "requires authentication" do
      post book_loans_path(book_id: book.id)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects when book not found" do
      user = create(:user)
      sign_in user
      post book_loans_path(book_id: 999_999)
      expect(response).to redirect_to(books_path)
      follow_redirect!
      expect(response.body).to include("Book not found")
    end

    it "rejects when book not available" do
      user = create(:user)
      create(:loan, book: book, returned_at: nil)
      sign_in user
      post book_loans_path(book_id: book.id)
      expect(response).to redirect_to(book_path(book))
      follow_redirect!
      expect(response.body).to include("currently on loan")
    end

    it "rejects when user has 3 active loans" do
      user = create(:user)
      3.times { create(:loan, user: user, returned_at: nil, book: create(:book)) }
      sign_in user
      post book_loans_path(book_id: book.id)
      expect(response).to redirect_to(book_path(book))
      follow_redirect!
      expect(response.body).to include("You can only have 3 active loans")
    end

    # The controller checks availability first and will redirect with
    # "This book is currently on loan." before the "You already have this book"
    # branch, so the specific "already have" message is unreachable in practice.

    it "creates a loan when allowed" do
      user = create(:user)
      sign_in user
      post book_loans_path(book_id: book.id)
      expect(response).to redirect_to(book_path(book))
      follow_redirect!
      expect(response.body).to include("Loaned successfully")
    end

    it "handles loan save failure gracefully" do
      user = create(:user)
      sign_in user
      allow_any_instance_of(Loan).to receive(:save).and_return(false)
      post book_loans_path(book_id: book.id)
      expect(response).to redirect_to(book_path(book))
      follow_redirect!
      expect(response.body).to include('Could not process loan')
    end
  end
end
