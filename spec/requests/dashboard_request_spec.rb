require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  let(:admin) { create(:user) }

  before do
    admin.add_role(:admin)
    sign_in admin
  end

  it "renders overview" do
    get dashboard_root_path
    expect(response).to have_http_status(:ok)
  end

  context "books management" do
    it "lists books and shows new/create/edit/destroy/trash/restore flows" do
      author = create(:author)
      tag = create(:tag)
      get dashboard_books_path
      expect(response).to have_http_status(:ok)

      get new_dashboard_book_path
      expect(response).to have_http_status(:ok)

      post dashboard_books_path, params: { book: { name: 'X', author_id: author.id, tag_ids: [ tag.id ] } }
      expect(response).to redirect_to(dashboard_books_path)
      book = Book.find_by(name: 'X')

      get edit_dashboard_book_path(book)
      expect(response).to have_http_status(:ok)

      patch dashboard_book_path(book), params: { book: { name: 'Y' } }
      expect(response).to redirect_to(edit_dashboard_book_path(book))

        # create versions and ensure edit loads @versions and @version_users
        book.update!(name: 'Y2')
        book.update!(name: 'Y3')
        get edit_dashboard_book_path(book)
        expect(response).to have_http_status(:ok)

      delete dashboard_book_path(book)
      expect(response).to redirect_to(dashboard_books_path)

      get trash_dashboard_books_path
      expect(response).to have_http_status(:ok)

      patch restore_dashboard_book_path(book)
      expect(response).to redirect_to(dashboard_books_path)
    end

    it "hits dashboard book show redirect to edit" do
      book = create(:book)
      get dashboard_book_path(book)
      expect(response).to redirect_to(edit_dashboard_book_path(book))
    end
  end

  it "manages authors" do
    get dashboard_authors_path
    expect(response).to have_http_status(:ok)
    post dashboard_authors_path, params: { author: { name: 'Auth1' } }
    expect(response).to redirect_to(dashboard_authors_path)
    author = Author.find_by(name: 'Auth1')
    delete dashboard_author_path(author)
    expect(response).to redirect_to(dashboard_authors_path)
    # failure path
    post dashboard_authors_path, params: { author: { name: '' } }
    expect(response.status).to eq(422)
  end

  it "hits authors new and update success" do
    get new_dashboard_author_path
    expect(response).to have_http_status(:ok)

    author = create(:author, name: 'Old')
    patch dashboard_author_path(author), params: { author: { name: 'New' } }
    expect(response).to redirect_to(dashboard_authors_path)
  end

  it "renders edit author and handles update failure and missing author" do
    author = create(:author, name: 'A1')
    get edit_dashboard_author_path(author)
    expect(response).to have_http_status(:ok)

    patch dashboard_author_path(author), params: { author: { name: '' } }
    expect(response.status).to eq(422)

    get edit_dashboard_author_path(id: 999_999)
    expect(response).to redirect_to(dashboard_authors_path)
    follow_redirect!
    expect(response.body).to include('Author not found')
  end

  it "handles missing book edit and restore" do
    # edit with missing id
    get edit_dashboard_book_path(id: 999_999)
    expect(response).to redirect_to(dashboard_books_path)
    follow_redirect!
    expect(response.body).to include('Book not found')

    # restore with missing deleted book
    patch restore_dashboard_book_path(id: 999_999)
    expect(response).to redirect_to(trash_dashboard_books_path)
    follow_redirect!
    expect(response.body).to include('Book not found in trash')
  end

  it "handles book update/create failures" do
    author = create(:author)
    # create failure
    post dashboard_books_path, params: { book: { name: '', author_id: '' } }
    expect(response.status).to eq(422)

    # update failure
    post dashboard_books_path, params: { book: { name: 'Temp', author_id: author.id } }
    book = Book.find_by(name: 'Temp')
    patch dashboard_book_path(book), params: { book: { name: '' } }
    expect(response.status).to eq(422)
  end

  it "manages tags" do
    get dashboard_tags_path
    expect(response).to have_http_status(:ok)
    post dashboard_tags_path, params: { tag: { name: 'T1' } }
    expect(response).to redirect_to(dashboard_tags_path)
    tag = Tag.find_by(name: 'T1')
    delete dashboard_tag_path(tag)
    expect(response).to redirect_to(dashboard_tags_path)
    # failure path
    post dashboard_tags_path, params: { tag: { name: '' } }
    expect(response.status).to eq(422)
  end

  it "hits tags new and update success" do
    get new_dashboard_tag_path
    expect(response).to have_http_status(:ok)

    tag = create(:tag, name: 'OldT')
    patch dashboard_tag_path(tag), params: { tag: { name: 'NewT' } }
    expect(response).to redirect_to(dashboard_tags_path)
  end

  it "handles tag edit missing and update failure" do
    tag = create(:tag, name: 'T1')
    get edit_dashboard_tag_path(tag)
    expect(response).to have_http_status(:ok)
    patch dashboard_tag_path(tag), params: { tag: { name: '' } }
    expect(response.status).to eq(422)

    get edit_dashboard_tag_path(id: 999_999)
    expect(response).to redirect_to(dashboard_tags_path)
    follow_redirect!
    expect(response.body).to include('Tag not found')
  end

  context "loans management" do
    it "lists, creates, deletes and returns loans" do
      get dashboard_loans_path
      expect(response).to have_http_status(:ok)

      get new_dashboard_loan_path
      expect(response).to have_http_status(:ok)

      book = create(:book)
      user = create(:user, :with_member_profile)
      post dashboard_loans_path, params: { loan: { book_id: book.id, user_id: user.id, loaned_at: Date.today, due_at: Date.today + 7.days } }
      expect(response).to redirect_to(dashboard_loans_path)
      loan = Loan.last

      delete dashboard_loan_path(loan)
      expect(response).to redirect_to(dashboard_loans_path)

      # create again to test return_book
      post dashboard_loans_path, params: { loan: { book_id: book.id, user_id: user.id, loaned_at: Date.today, due_at: Date.today + 7.days } }
      loan = Loan.last
      patch return_book_dashboard_loan_path(loan)
      expect(response).to redirect_to(dashboard_loans_path)
    end
  end

  it "handles loan create failure on dashboard" do
    # missing params should render new with 422
    post dashboard_loans_path, params: { loan: { book_id: nil, user_id: nil } }
    expect(response.status).to eq(422)
  end

  it "handles dashboard user not found" do
    get dashboard_user_path(id: 999_999)
    expect(response).to redirect_to(dashboard_users_path)
    follow_redirect!
    expect(response.body).to include('User not found')
  end

  it "manages users index/show/update/destroy" do
    get dashboard_users_path
    expect(response).to have_http_status(:ok)
    u = create(:user, :with_member_profile)
    get dashboard_user_path(u)
    expect(response).to have_http_status(:ok)
    patch dashboard_user_path(u), params: { roles: [ 'admin' ] }
    expect(response).to redirect_to(dashboard_user_path(u))
    # remove role path
    patch dashboard_user_path(u), params: { roles: [] }
    expect(response).to redirect_to(dashboard_user_path(u))
    delete dashboard_user_path(u)
    expect(response).to redirect_to(dashboard_users_path)
  end

  it "redirects when dashboard access is unauthorized" do
    sign_out admin
    user = create(:user)
    sign_in user
    get dashboard_root_path
    expect(response).to redirect_to('/')
    follow_redirect!
    expect(response.body).to include('You are not authorized to access the dashboard.')
  end
end
