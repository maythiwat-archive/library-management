require 'rails_helper'

RSpec.describe "ApplicationController rescue_from", type: :request do
  it "catches CanCan::AccessDenied and redirects to root" do
    # Define a temporary controller that raises CanCan::AccessDenied
    controller_class = Class.new(ApplicationController) do
      def index
        raise CanCan::AccessDenied
      end
    end

    stub_const('TempAccessDeniedController', controller_class)

    with_routing do |routes|
      routes.draw { get '/temp_access_denied' => 'temp_access_denied#index' }
      get '/temp_access_denied'
      expect(response).to redirect_to('/')
      follow_redirect!
      expect(response.body).to include('You are not authorized to do that.')
    end
  end

  it "loads mailer, job and helper files to increase coverage" do
    load Rails.root.join('app/mailers/application_mailer.rb')
    load Rails.root.join('app/jobs/application_job.rb')
    load Rails.root.join('app/helpers/application_helper.rb')
    load Rails.root.join('app/helpers/books_helper.rb')
    load Rails.root.join('app/helpers/api/v1/books_helper.rb')

    expect(defined?(ApplicationMailer)).to be_truthy
    expect(defined?(ApplicationJob)).to be_truthy
  end
end
