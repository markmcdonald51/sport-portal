require 'rails_helper'

describe "Event model", type: :model do

    it "should not validate without name" do
        league = FactoryBot.build(:league)
        league.name = nil

        expect(league.valid?).to eq(false)
    end

    it "should not validate without discipline" do
        league = FactoryBot.build(:league)
        league.discipline = nil

        expect(league.valid?).to eq(false)
    end

    it "should not validate without game_mode" do
        league = FactoryBot.build(:league)
        league.game_mode = nil

        expect(league.valid?).to eq(false)
    end

end