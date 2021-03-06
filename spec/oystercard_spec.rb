require 'oystercard'

describe Oystercard do

  subject(:oystercard) { described_class.new }
  let(:station) { double(:station) }

  before do |example|
    unless example.metadata[:skip_before]
      oystercard.top_up(20)
      oystercard.touch_in(station)
    end
  end

  describe "#initialize" do

    it "initializes with a balance of zero", :skip_before do
      expect(oystercard.balance).to be_zero
    end

    it "initializes with an empty array of journeys" do
      expect(oystercard.journey_history).to eq []
    end

  end

  describe "#top_up" do

    it "adds a given amount to the card" do
      expect{ oystercard.top_up(10) }.to change { oystercard.balance }.by 10
    end

    it "raises an error if the default limit is reached", :skip_before do
      oystercard.top_up(Oystercard::DEFAULT_LIMIT)
      expect{ oystercard.top_up(1) }.to raise_error "You have reached a top up limit of £#{Oystercard::DEFAULT_LIMIT}"
    end

  end

  describe "#touch_in" do

    it "should return entry station and nil in the journeys array" do
      oystercard.touch_in(station)
      expect(oystercard.journey_history).to include({:entry_station => station, :exit_station => nil})
    end

    it "should charge a penalty fare if the card hasnt been touched out" do
      expect { oystercard.touch_in(station) }.to change { oystercard.balance }.by -Journey::PENALTY
    end

    it "stores the start station in instance variable" do
      expect(oystercard.entry_station).to eq(station)
    end

    it "raises an error when attempting to touch in with balance of < £#{Oystercard::DEFAULT_MINIMUM}", :skip_before do
      expect {oystercard.touch_in(station) }.to raise_error "Insufficient balance for journey"
    end


  end

  describe "#touch_out" do

    before do
      oystercard.touch_in(station)
    end

     it "deducts a given amount when touched out" do
       expect { oystercard.touch_out(station) }.to change{ oystercard.balance }.by(-Journey::MINIMUM_FARE)
     end

     it "removes the entry station from the instance variable" do
       expect { oystercard.touch_out(station) }.to change{ oystercard.entry_station }.to eq nil
     end
  end

  describe "#update_journey_history" do

    before do
      oystercard.touch_in(station)
      oystercard.touch_out(station)
    end

    it "pushes the journey hash into the journeys array" do
      expect(oystercard.journey_history).to include({:entry_station => station, :exit_station => station})
    end
  end

end
