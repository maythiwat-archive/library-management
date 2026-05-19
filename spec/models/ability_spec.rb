require 'rails_helper'

RSpec.describe Ability, type: :model do
  it 'assigns full permissions to admin' do
    user = create(:user)
    user.add_role(:admin)
    ability = Ability.new(user)
    expect(ability.can?(:manage, Book)).to be(true)
  end

  it 'assigns librarian permissions' do
    user = create(:user)
    user.add_role(:librarian)
    ability = Ability.new(user)
    expect(ability.can?(:manage, Author)).to be(true)
    expect(ability.can?(:read, User)).to be(true)
  end

  it 'assigns default read permissions' do
    user = create(:user)
    ability = Ability.new(user)
    expect(ability.can?(:read, Book)).to be(true)
    expect(ability.can?(:manage, Book)).to be(false)
  end
end
