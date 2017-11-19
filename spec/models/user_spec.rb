# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid when produced by a factory' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end

  describe 'self#from_omniauth' do
    it 'should return an existing user' do
      user = FactoryBot.create :user, provider: 'mock', uid: '1234567890'
      autohash = OmniAuth::AuthHash.new(provider: 'mock', uid: '1234567890')
      expect(User.from_omniauth(autohash).id).to eq(user.id)
    end

    it 'should return nil without an existing user' do
      user = FactoryBot.create :user
      autohash = OmniAuth::AuthHash.new(provider: 'mock', uid: '1234567890')
      expect(User.from_omniauth(autohash)).to be_nil
    end
  end

  describe '#has_omniauth' do
    it 'should return return true iff the user has an omniauth provider and uid' do
      user = FactoryBot.create :user, provider: 'mock', uid: '1234567890'
      expect(user.has_omniauth).to be(true)
    end

    it 'should return return false if the user does not have a provider or an uid' do
      user = FactoryBot.create :user
      expect(user.has_omniauth).to be(false)
      user.uid = '10'
      expect(user.has_omniauth).to be(false)
      user.uid = nil
      user.provider = 'mock'
      expect(user.has_omniauth).to be(false)
    end
  end
end
