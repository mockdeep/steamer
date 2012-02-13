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
    Steamer.any_instance.stub(:puts)
  end

  describe '#game_names' do
    before :each do
      Steamer.any_instance.
        should_receive(:gets).
        and_return('lobati')
      @steamer = Steamer.new
    end

    context 'given a valid steam_id' do
      it 'returns a sorted array of game names' do
        games = @steamer.game_names
        games.should == [ 'Age of Chivalry', 'Bastion', 'Prototype' ]
      end
    end
  end

  describe '#games_and_ids' do
    before :each do
      Steamer.any_instance.
        should_receive(:gets).
        and_return('lobati')
      @steamer = Steamer.new
    end

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

  describe '#initialize' do
    context 'starting out' do
      it 'loads the config file' do
        Steamer.any_instance.should_receive(:load_config)
        Steamer.new
      end
    end
  end

  describe '#load_config' do
    context 'when the config file does not exist' do
      it 'calls #set_up_new_user' do
        File.should_receive(:exist?).and_return(false)
        Steamer.any_instance.should_receive(:set_up_new_user)
        Steamer.new
      end
    end
  end

  describe '#set_up_new_user' do
    context 'when getting the user id' do
      before :each do
        Steamer.any_instance.should_receive(:puts).
          with("Please enter your Steam profile id or custom url")
        Steamer.any_instance.should_receive(:gets).and_return('poo')
      end

      it 'prompts the user for a steam id' do
        steamer = Steamer.new
      end

      it 'parses the id' do
        Steamer.any_instance.should_receive(:parse_id).with('poo')
        steamer = Steamer.new
      end
    end
  end

  describe '#parse_id' do
    context 'when given a vanity url' do
      before :each do
        Steamer.any_instance.
          should_receive(:gets).
          and_return('http://steamcommunity.com/id/pooper/')
        @steamer = Steamer.new
      end

      it 'finds the username' do
        @steamer.steam_id.should == 'pooper'
      end

      it 'sets the id_type to vanity' do
        @steamer.id_type.should == :vanity
      end
    end

    context 'when given a profile url' do
      before :each do
        Steamer.any_instance.
          should_receive(:gets).
          and_return('http://steamcommunity.com/profiles/76561198003000123/')
        @steamer = Steamer.new
      end

      it 'finds the profile id' do
        @steamer.steam_id.should == '76561198003000123'
      end

      it 'sets the id_type to profile' do
        @steamer.id_type.should == :profile
      end
    end

    context 'when given a profile id' do
      before :each do
        Steamer.any_instance.
          should_receive(:gets).
          and_return('76561198003000123')
        @steamer = Steamer.new
      end

      it 'finds the profile id' do
        @steamer.steam_id.should == '76561198003000123'
      end

      it 'sets the id_type to profile' do
        @steamer.id_type.should == :profile
      end
    end

    context 'when given a vanity id' do
      before :each do
        Steamer.any_instance.
          should_receive(:gets).
          and_return('pooper')
        @steamer = Steamer.new
      end

      it 'finds the username' do
        @steamer.steam_id.should == 'pooper'
      end

      it 'sets the id_type to vanity' do
        @steamer.id_type.should == :vanity
      end
    end
  end

  context 'on run' do
    context 'when ~/.steamer is missing' do
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
