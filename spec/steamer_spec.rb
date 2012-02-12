require 'spec_helper'
require 'fakeweb'

describe Steamer do

  before :each do
    url = 'http://steamcommunity.com/id/lobati/games/?xml=1'
    options = {
      :body => File.read('spec/games.xml'),
      :content_type => 'application/xml',
    }
    FakeWeb.register_uri(:get, url, options)
    @steamer = Steamer.new('lobati')
  end

  describe '#game_names' do
    context 'given a valid steam_id' do
      it 'returns a sorted array of game names' do
        games = @steamer.game_names
        games.should == [ 'Age of Chivalry', 'Bastion', 'Prototype' ]
      end
    end
  end

  describe '#games_and_ids' do
    context 'given a valid steam_id' do
      it 'returns a sorted array of games and their store ids' do
        pairs = @steamer.games_and_ids
        pairs.should == [
          ['Age of Chivalry', '17510'],
          ['Bastion', '107100'],
          ['Prototype', '10150'],
        ]
      end
    end
  end

  context 'on run' do
    it 'looks for ~/.steamer'

    context 'when ~/.steamer is missing' do
      it 'asks for a steam id'
      it 'accepts a steam profile id'
      it 'accepts a steam custom url'
      it 'gets list of steam games'
      it 'tries to locate user directory'
      it 'writes ~/.steamer'
      it 'gets list of steam games'
    end
  end

  context 'when backing up files' do
    context 'if user path is missing' do
      it 'displays an error message'
    end

    context 'if file exists' do
      it 'confirms before overwriting'
      it 'displays timestamps for comparison'
    end
  end

  context 'when restoring files' do
    context 'if user path is missing' do
      it 'displays an error message'
    end

    context 'if file exists' do
      it 'confirms before overwriting'
      it 'displays timestamps for comparison'
    end
  end
end
