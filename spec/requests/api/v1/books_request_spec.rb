require 'rails_helper'

RSpec.describe "API::V1::Books", type: :request do
  describe "GET /api/v1/books" do
    it "returns JSON with books" do
      book = create(:book)
      get api_v1_books_path
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['books'].any? { |b| b['id'] == book.id }).to be(true)
    end
  end

  describe "GET /api/v1/books/:id" do
    it "returns a book and active_loan" do
      book = create(:book)
      get api_v1_book_path(book)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['book']['id']).to eq(book.id)
      expect(json['active_loan']).to be_nil
    end

    it "returns 404 when not found" do
      get api_v1_book_path(id: 999_999)
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Book not found.')
    end
  end
end
