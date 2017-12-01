# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  kind_of_sport :string
#  private     :boolean          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    kind_of_sport "Football"
    description "This team is awesome"
    private false

    after(:build) do |team|
      team.owners << build_list(:user, 1)
    end
  end

  trait :with_two_owners do
    after(:build) do |team|
      team.owners << build_list(:user, 1)
    end
  end

  trait :with_five_members do
    after(:build) do |team|
      team.members << build_list(:user, 4)
    end
  end

  trait :private do
    private true
  end
end
