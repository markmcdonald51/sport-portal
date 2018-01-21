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

RSpec.describe EventsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # adjust the attributes here as well.

  let(:valid_event_attributes) {
    FactoryBot.build(:event, owner: @user, max_teams: 20).attributes
  }

  let(:invalid_event_attributes) {
    FactoryBot.build(:event, name: nil).attributes
  }

  let(:valid_tournament_attributes) {
    FactoryBot.build(:tournament, owner: @user, max_teams: 20).attributes
  }

  let(:invalid_tournament_attributes) {
    FactoryBot.build(:tournament, name: nil).attributes
  }

  let(:valid_league_attributes) {
    FactoryBot.build(:league, owner: @user, max_teams: 20, game_mode: League.game_modes[:round_robin]).attributes
  }

  let(:invalid_league_attributes) {
    FactoryBot.build(:league, name: nil).attributes
  }

  let(:valid_rankinglist_attributes) {
    FactoryBot.build(:rankinglist, owner: @user, max_teams: 20).attributes
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # EventsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before(:each) do
    @user = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:admin)
    @event = FactoryBot.build(:event)
    @team = FactoryBot.create(:team)
    @team.owners << @user
    @event.owner = @user
    sign_in @user
  end

  after(:each) do
    Match.delete_all
    Event.delete_all
    @user.destroy
    @other_user.destroy
    @admin.destroy
  end

  describe "GET #index" do
    it "returns a success response if not signed in" do
      event = Event.create! valid_event_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end

    it "should allow normal user to view page" do
      get :index, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      event = Event.create! valid_event_attributes
      get :show, params: { id: event.to_param }, session: valid_session
      expect(response).to be_success
    end

    it "should allow normal user to view page" do
      event = Event.create! valid_event_attributes
      get :show, params: { id: event.to_param }
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a unauthorized response when not signed in" do
      sign_out @user
      get :new, params: {}, session: valid_session
      expect(response).to be_unauthorized
    end

    it "should allow normal user to view page" do
      get :new, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a unauthorized response" do
      sign_out @user
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }, session: valid_session
      expect(response).to be_unauthorized
    end

    it "should allow normal user to edit his created event" do
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }
      expect(response).to be_success
    end

    it "should not allow normal user to edit others created event" do
      sign_out @user
      sign_in @other_user
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }
      expect(response).to_not be_success
    end

    it "should allow admin to edit others created event" do
      sign_out @user
      sign_in @admin
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:league_params) {
        {
            event: valid_league_attributes,
            type: League
        }
      }
      let(:tournament_params) {
        {
            event: FactoryBot.build(:tournament, owner: @user).attributes,
            type: Tournament
        }
      }
      it "creates a new Event" do
        expect {
          post :create, params: league_params
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: league_params, session: valid_session
        expect(response).to redirect_to(Event.last)
      end

      it "should allow normal user to create a league" do
        post :create, params: league_params
        expect(response).to redirect_to(Event.last)
      end

      it "should allow normal user to create a tournament" do
        post :create, params: tournament_params
        expect(response).to redirect_to(Event.last)
      end
    end
    context "with invalid params" do
      let(:league_params) {
        {
            event: invalid_league_attributes,
            type: League
        }
      }
      let(:tournament_params) {
        {
            event: FactoryBot.build(:tournament, owner: @user, name: nil).attributes,
            type: Tournament
        }
      }
      it "returns success when creating a league" do
        post :create, params: league_params, session: valid_session
        expect(response).to be_success
      end

      it "returns success when creating a tournament" do
        post :create, params: tournament_params, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            deadline: Date.new(2017, 11, 20),
            startdate: Date.new(2017, 11, 21),
            enddate: Date.new(2017, 11, 22)
        }
      }

      it "updates the requested event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: new_attributes }, session: valid_session
        event.reload
        expect(event.deadline).to eq(Date.new(2017, 11, 20))
        expect(event.startdate).to eq(Date.new(2017, 11, 21))
        expect(event.enddate).to eq(Date.new(2017, 11, 22))
      end

      it "redirects to the event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }, session: valid_session
        expect(response).to redirect_to(event)
      end

      it "should allow normal user to update his created event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }
        expect(response).to redirect_to(event)
      end

      it "should not allow normal user to update others created events" do
        sign_out @user
        sign_in @other_user
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }
        expect(response).to_not be_success
      end
    end
    context "with invalid params" do
      it "returns success" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: invalid_event_attributes }
        expect(response).to be_success
      end
    end
  end

  shared_examples "a joinable single event" do
    it "adds the user as participant to the event" do
      event = Event.create! event_attributes
      put :join, params: { id: event.to_param }, session: valid_session
      expect(event).to have_participant(@user)
    end
  end

  shared_examples "a joinable team event" do
    let(:new_attributes) {
      {
          teams: @team
      }
    }
    it "adds the user as participant to the event" do
      event = Event.create! team_event_attributes
      put :join, params: { id: event.to_param, event: new_attributes }, session: valid_session
      expect(event).to have_participant(@user)
    end
  end

  describe "PUT #join" do
    context "League" do
      let(:event_attributes) { FactoryBot.build(:league, owner: @user, max_teams: 20, player_type: Event.player_types[:single]).attributes }
      include_examples "a joinable single event"
    end

    context "League" do
      let(:team_event_attributes) { FactoryBot.build(:league, owner: @user, max_teams: 20, player_type: Event.player_types[:team]).attributes }
      include_examples "a joinable team event"
    end

    context "Tournament" do
      let(:event_attributes) { FactoryBot.build(:tournament, owner: @user, max_teams: 20, player_type: Event.player_types[:single]).attributes }
      include_examples "a joinable single event"
    end

    context "Tournament" do
      let(:team_event_attributes) { FactoryBot.build(:tournament, owner: @user, max_teams: 20, player_type: Event.player_types[:team]).attributes }
      include_examples "a joinable team event"
    end

    context "Rankinglist" do
      let(:event_attributes) { FactoryBot.build(:rankinglist, owner: @user).attributes }
      include_examples "a joinable single event"
    end
  end

  describe "GET #team_join" do
    let(:attributes_multi_player_team) { FactoryBot.build(:event, owner: @user, max_teams: 20, player_type: Event.player_types[:team]).attributes }
    it "returns javascript for the modal" do
      event = Event.create! attributes_multi_player_team
      get :team_join, xhr: true, params: { id: event.to_param }, session: valid_session, format: :js
      expect(response.content_type).to eq "text/javascript"
    end
  end

  describe "PUT #leave" do
    let(:event_attributes) { FactoryBot.build(:league, owner: @user, max_teams: 20, player_type: Event.player_types[:single]).attributes }
    it "removes the user as participant of the event" do
      event = Event.create! event_attributes
      sign_in @user
      put :join, params: { id: event.to_param }, session: valid_session
      put :leave, params: { id: event.to_param }, session: valid_session
      expect(event).not_to have_participant(@user)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to be_redirect
      event.destroy
    end

    it "redirects to the events list" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }, session: valid_session
      expect(response).to redirect_to(events_url)
    end

    it "should not allow normal user to destroy events created by others" do
      sign_out @user
      sign_in @other_user
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to be_forbidden
    end

    it "should allow normal user to destroy his created event" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to redirect_to(events_url)
    end
  end

  describe "GET League#schedule" do
    it "should generate schedule if not existing" do
      event = League.create! valid_league_attributes
      event.add_participant(@user)
      event.add_participant(@other_user)
      event.generate_schedule
      get :schedule, params: { id: event.to_param }, session: valid_session
      expect(event.matches).not_to be_empty
    end

    it "returns a success response" do
      event = League.create! valid_league_attributes
      get :schedule, params: { id: event.to_param }, session: valid_session
      expect(response).to be_success
    end
  end

  shared_examples 'an event' do
    it 'should calculate an empty ranking when no participant has joined the event' do
      get :ranking, params: { id: event.to_param }, session: valid_session
      ranking_entries = controller.instance_variable_get(:@ranking_entries)
      expect(ranking_entries).to be_empty
    end
    describe 'when teams have joined the event' do
      describe 'when no match has been played yet' do
        it 'should calculate a lexicographically sorted zero-filled ranking' do
          team1 = FactoryBot.create(:team)
          team2 = FactoryBot.create(:team)
          event.add_team(team1)
          event.add_team(team2)
          get :ranking, params: { id: event.to_param }, session: valid_session
          ranking_entries = controller.instance_variable_get(:@ranking_entries)
          expect(ranking_entries.first.name).to be < ranking_entries.second.name
        end
      end
      describe 'when at least two matches have been played already' do
        before (:each) do
          @event = event

          @team1 = FactoryBot.create(:team)
          @team2 = FactoryBot.create(:team)
          @team3 = FactoryBot.create(:team)

          @event.add_team(@team1)
          @event.add_team(@team2)
          @event.add_team(@team3)

          @match1 = Match.new(team_home: @team1, team_away: @team2, gameday: 1,
                              score_home: 10, score_away: 0,
                              points_home: 3, points_away: 0)
          @event.matches << @match1
          @team1.home_matches << @match1
          @team2.away_matches << @match1

          @match2 = Match.new(team_home: @team2, team_away: @team1, gameday: 2,
                              score_home: 10, score_away: 10,
                              points_home: 1, points_away: 1)
          @event.matches << @match2
          @team2.home_matches << @match2
          @team1.away_matches << @match2

          @match3 = Match.new(team_home: @team1, team_away: @team3, gameday: 3,
                              score_home: 0, score_away: 1,
                              points_home: 0, points_away: 3)
          @event.matches << @match3
          @team1.home_matches << @match3
          @team3.away_matches << @match3

          @match4 = Match.new(team_home: @team2, team_away: @team3, gameday: 4,
                              score_home: 0, score_away: 0,
                              points_home: 1, points_away: 1)
          @event.matches << @match4
          @team2.home_matches << @match4
          @team3.away_matches << @match4

          get :ranking, params: { id: @event.to_param }, session: valid_session
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
    describe 'when users have joined the event' do
      describe 'when no match has been played yet' do
        it 'should calculate a lexicographically sorted zero-filled ranking' do
          user1 = FactoryBot.create(:user)
          user2 = FactoryBot.create(:user)
          event.add_participant(user1)
          event.add_participant(user2)
          get :ranking, params: { id: event.to_param }, session: valid_session
          ranking_entries = controller.instance_variable_get(:@ranking_entries)
          expect(ranking_entries.first.name).to be < ranking_entries.second.name
        end
      end
    end
  end

  describe 'GET League#ranking' do
    it_should_behave_like 'an event' do
      let (:event) { League.create! valid_league_attributes }
    end
  end

  describe 'GET Tournament#ranking' do
    it_should_behave_like 'an event' do
      let (:event) { Tournament.create! valid_tournament_attributes }
    end
  end

  describe 'GET Rankinglist#ranking' do
    it_should_behave_like 'an event' do
      let (:event) { Rankinglist.create! valid_rankinglist_attributes }
    end
  end

  describe "GET #overview" do
    it "returns a success response" do
      tournament = Tournament.create! valid_tournament_attributes
      get :overview, params: { id: tournament.to_param }, session: valid_session
      expect(response).to be_success
    end
  end

end
