require 'oystercard'

describe Oystercard do
  it 'initializes a balance' do
    expect(subject.balance).to eq 0
  end
  it { is_expected.to respond_to(:top_up).with(1).argument }
  it { is_expected.to respond_to(:touch_out) }
  it { is_expected.to respond_to(:touch_in).with(1).argument  }

  describe 'card balance' do
    maximum_balance = Oystercard::MAX_BALANCE
    minimum_fare = Oystercard::MIN_FARE
    it 'tops up a card' do
      expect{ subject.top_up(10) }.to change{ subject.balance }.by 10
    end
    it 'cannot have a balance exceeding the maximum' do
      subject.top_up(maximum_balance)
      expect{ subject.top_up(1) }.to raise_error "Maxmimum card balance is £#{maximum_balance}"
    end
    it 'deducts the journey fare' do
      subject.top_up(30)
      expect{ subject.touch_out }.to change{ subject.balance }.by -minimum_fare
    end
  end

  describe 'card status' do
    let(:station) { double(:station) }
    it 'declines cards that do not have the minimum balance' do
      expect{ subject.touch_in(station) }.to raise_error "Insufficient funds: please top up"
    end
    it 'shows if in journey' do
      expect(subject).not_to be_in_journey
    end
  end

  describe 'card location' do
    let(:station) { double(:station) }
    before do
      subject.top_up(2)
      subject.touch_in(station)
    end
    it 'touches in' do
      expect(subject).to be_in_journey
    end
    it 'stores the name of the entry station' do
      expect(subject.entry_station).to eq station
    end
    it 'touches out' do
      subject.touch_out
      expect(subject).to_not be_in_journey
    end
    it 'resets the entry station' do
      subject.touch_out
      expect(subject.entry_station).to eq nil
    end
  end

end
