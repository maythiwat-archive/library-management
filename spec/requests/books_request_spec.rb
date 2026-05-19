require 'rails_helper'

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    it "renders index and shows books" do
      book = create(:book)
      get books_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(book.name)
    end

    it "filters by query param" do
      a = create(:author, name: "UniqueAuthor")
      book = create(:book, name: "SomeTitle", author: a)
      get books_path, params: { q: 'UniqueAuthor' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(book.name)
    end
  end

  describe "GET /books/:id" do
    it "shows a book" do
      book = create(:book)
      get book_path(book)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(book.name)
    end

    it "redirects to index when not found" do
      get book_path(id: 999999)
      expect(response).to redirect_to(books_path)
      follow_redirect!
      expect(response.body).to include("Book not found")
    end
  end
end
