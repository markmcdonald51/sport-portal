# == Schema Information
#
# Table name: events
#
#  name                         :string
#  description                  :text
#  discipline                   :string
#  player_type                  :integer
#  max_teams                    :integer
#  game_mode                    :integer         not null
#  type                         :string
#  created_at                   :datetime        not null
#  deadline                     :date
#  startdate                    :date
#  enddate                      :date
#
#  updated_at                   :datetime        not null
#  index_events_on_game_mode    :index ["game_mode"]
#  index_events_on_player_type  :index ["player_type"]
#

class Event < ApplicationRecord
  has_many :matches, -> { order 'gameday ASC' }, dependent: :delete_all
  has_and_belongs_to_many :teams

  validates :name, :discipline, :game_mode, :player_type, presence: true
  validates :deadline, :startdate, :enddate, presence: true
  validates :max_teams, :numericality => { :greater_than_or_equal_to => 0 } # this validation will be moved to League.rb once leagues are being created and not general event objects
  validate :end_after_start
  enum player_types: [:single, :team]

  def self.types
    %w(Tournament League)
  end

  has_many :organizers
  has_many :editors, :through => :organizers, :source => 'user'

  scope :active, -> { where('deadline >= ?', Date.current) }

  has_and_belongs_to_many :users

  def duration
    return if enddate.blank? || startdate.blank?
    enddate - startdate + 1
  end

  def end_after_start
    return if enddate.blank? || startdate.blank?
    if enddate < startdate
      errors.add(:enddate, "must be after startdate.")
    end
  end

  # Everything below this is leagues only code and will be moved to Leagues.rb once there is an actual option to create Leagues AND Tourneys, etc.

  def add_test_teams
    (max_teams - teams.length).times do |index|
      teams << Team.new(name: "Team #{index}", private: false)
    end
  end

  #Joining a single Player for a single Player Event
  def add_Player_for_single_team(user)
    if teams.length < max_teams
      teams << Team.new(name: "#{user.first_name} #{user.last_name}"  , private: false)
      return [{ :success => "true" }]
    end
  end

  def delete_all_matches
    matches.delete_all
  end
  def generate_schedule
    calculate_gamedays
  end

  def gamedays
    size = teams.length
    size.even? ? size - 1 : size
  end

  def calculate_gamedays
    teams1 = teams.to_a
    teams2 = teams1.reverse
    team_len = teams.length
    gamedays.times do |gameday|
      matched_teams = []
      (team_len).times do |teamindex|
        team_1 = teams1[teamindex]
        team_2 = teams2[(gameday + teamindex) % team_len]
        unless team_1 == team_2 or matched_teams.include? team_1 or matched_teams.include? team_2
          matches << Match.new(team_home: team_1, team_away: team_2, gameday: gameday)
        end
        matched_teams << team_1
        matched_teams << team_2
      end
    end
    self.save
  end
end
