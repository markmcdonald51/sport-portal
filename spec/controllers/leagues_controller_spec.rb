require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe LeaguesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # League. As you add validations to Event, be sure to
  # adjust the attributes here as well.

  let(:valid_league_attributes) {
    FactoryBot.build(:league, owner: @user, max_teams: 20, game_mode: League.game_modes[:round_robin]).attributes
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LeaguesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before(:each) do
    @user = FactoryBot.create(:user)
    @league = League.create! valid_league_attributes
    @league.owner = @user
    sign_in @user
  end

  after(:each) do
    Match.destroy_all
    Event.destroy_all
    @user.destroy
  end

  describe 'a League' do
    it 'should calculate an empty ranking when no participant has joined the league' do
      get :ranking, params: { id: @league.to_param }, session: valid_session
      ranking_entries = controller.instance_variable_get(:@ranking_entries)
      expect(ranking_entries).to be_empty
    end
    describe 'when teams have joined the @league' do
      describe 'when no match has been played yet' do
        it 'should calculate a lexicographically sorted zero-filled ranking' do
          team1 = FactoryBot.create(:team)
          team2 = FactoryBot.create(:team)
          @league.add_team(team1)
          @league.add_team(team2)
          get :ranking, params: { id: @league.to_param }, session: valid_session
          ranking_entries = controller.instance_variable_get(:@ranking_entries)
          expect(ranking_entries.first.name).to be < ranking_entries.second.name
        end
      end
      describe 'when at least two matches have been played already' do
        before (:each) do
          @team1 = FactoryBot.create(:team)
          @team2 = FactoryBot.create(:team)
          @team3 = FactoryBot.create(:team)

          @league.add_team(@team1)
          @league.add_team(@team2)
          @league.add_team(@team3)

          @match1 = Match.new(team_home: @team1, team_away: @team2, gameday: 1,
                              points_home: 3, points_away: 0)
          @result1 = FactoryBot.build(:game_result, score_home: 10, score_away: 0)
          @match1.game_results << @result1
          @league.matches << @match1
          @team1.home_matches << @match1
          @team2.away_matches << @match1

          @match2 = Match.new(team_home: @team2, team_away: @team1, gameday: 2,
                              points_home: 1, points_away: 1)
          @result2 = FactoryBot.build(:game_result, score_home: 10, score_away: 10)
          @match2.game_results << @result2
          @league.matches << @match2
          @team2.home_matches << @match2
          @team1.away_matches << @match2

          @match3 = Match.new(team_home: @team1, team_away: @team3, gameday: 3,
                              points_home: 0, points_away: 3)
          @result3 = FactoryBot.build(:game_result, score_home: 0, score_away: 1)
          @match3.game_results << @result3
          @league.matches << @match3
          @team1.home_matches << @match3
          @team3.away_matches << @match3

          @match4 = Match.new(team_home: @team2, team_away: @team3, gameday: 4,
                              points_home: 1, points_away: 1)
          @result4 = FactoryBot.build(:game_result, score_home: 1, score_away: 1)
          @match4.game_results << @result4
          @league.matches << @match4
          @team2.home_matches << @match4
          @team3.away_matches << @match4

          get :ranking, params: { id: @league.to_param }, session: valid_session
          @ranking_entries = controller.instance_variable_get(:@ranking_entries)
        end

        it 'should calculate the rank of a participant based on his points correctly' do
          expect(@ranking_entries.second.points).to be > @ranking_entries.third.points
          expect(@ranking_entries.second.rank).to be < @ranking_entries.third.rank
        end

        it "should pass on the participant's name correctly" do
          expect(@ranking_entries.first.name).to eq(@team1.name)
        end
        it 'should sum up the number of played games of a participant correctly' do
          expect(@ranking_entries.first.match_count).to eq(3)
        end
        it 'should sum up the number of won games of a participant correctly' do
          expect(@ranking_entries.first.won_count).to eq(1)
        end
        it 'should sum up the number of drawn games of a participant correctly' do
          expect(@ranking_entries.first.draw_count).to eq(1)
        end
        it 'should sum up the number of lost games of a participant correctly' do
          expect(@ranking_entries.first.lost_count).to eq(1)
        end
        it 'should sum up the own goals of a participant correctly' do
          expect(@ranking_entries.first.goals).to eq(20)
        end
        it 'should sum up the goals for the other side of a participant correctly' do
          expect(@ranking_entries.first.goals_against).to eq(11)
        end
        it 'should calculate the number of points of a participant correctly' do
          expect(@ranking_entries.first.points).to eq(4)
        end
        it 'should calculate the rank of two participants with the same points based on the number of goals correctly' do
          expect(@ranking_entries.first.points).to be == @ranking_entries.second.points
          expect(@ranking_entries.first.goals).to be > @ranking_entries.second.goals
          expect(@ranking_entries.first.rank).to be < @ranking_entries.second.rank
        end
      end
    end
    describe 'when users have joined the League' do
      describe 'when no match has been played yet' do
        it 'should calculate a lexicographically sorted zero-filled ranking' do
          user1 = FactoryBot.create(:user)
          user2 = FactoryBot.create(:user)
          @league.add_participant(user1)
          @league.add_participant(user2)
          get :ranking, params: { id: @league.to_param }, session: valid_session
          ranking_entries = controller.instance_variable_get(:@ranking_entries)
          expect(ranking_entries.first.name).to be < ranking_entries.second.name
        end
      end
    end
  end
end