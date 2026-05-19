require 'rails_helper'

RSpec.describe Loan, type: :model do
  let(:loan) { build(:loan) }

  describe 'validations' do
    it 'is invalid without loaned_at' do
      loan.loaned_at = nil
      expect(loan).not_to be_valid
      expect(loan.errors[:loaned_at]).to be_present
    end

    it 'is invalid without due_at' do
      loan.due_at = nil
      expect(loan).not_to be_valid
      expect(loan.errors[:due_at]).to be_present
    end
  end
end
