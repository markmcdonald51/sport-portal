FactoryBot.define do
  factory :tournament do
    name "Weitwurfmeisterschaften"
    description "Throw! Throw! Record!"
    discipline "Kokosnussweitwurf"
    player_type Event.player_types[:single]
    max_teams 8
    game_mode Tournament.game_modes[:double_elimination]
  end
end