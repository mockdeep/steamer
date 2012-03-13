require 'spec_helper'
require 'fakeweb'

describe Steamer do

  before :each do
    @steamer = Steamer.new
  end

  describe '#check' do
    context 'when config file exists' do
      before :each do
        File.stub(:exist?).and_return(true)
      end

      it 'returns true' do
        @steamer.stub(:puts)
        @steamer.check.should be_true
      end

      it 'prints a message' do
        Steamer.any_instance.should_receive(:puts).with('profile exists')
        @steamer.check
      end
    end

    context 'when config file does not exist' do
      before :each do
        File.stub(:exist?).and_return(false)
        @steamer.stub(:gets).and_return('blah')
        @steamer.stub(:puts)
        @steamer.stub(:download_games_list)
      end

      it 'returns false' do
        @steamer.check.should be_false
      end

      it 'requests a steam id' do
        @steamer.should_receive(:puts).with('please enter your steam id')
        @steamer.check
      end

      it 'gets user input' do
        @steamer.should_receive(:gets).and_return('blah')
        @steamer.check
      end

      it 'parses the id' do
        @steamer.should_receive(:parse_id).with('blah')
        @steamer.check
      end

      it 'downloads the profile' do
        @steamer.should_receive(:download_games_list)
        @steamer.check
      end

      it 'writes the steamer config file' do
        @steamer.should_receive(:write_config)
        @steamer.check
      end
    end
  end

  describe '#update' do
    context 'when config file exists' do
      before :each do
        File.stub(:exist?).and_return(true)
        @steamer.stub(:download_games_list)
      end

      it 'loads the config file' do
        @steamer.should_receive(:load_config)
        @steamer.update
      end

      it 'downloads the profile' do
        @steamer.should_receive(:download_games_list)
        @steamer.update
      end

      it 'merges the downloaded profile into the config' do
      end
    end

    context 'when config file does not exist' do
      before :each do
        File.stub(:exist?).and_return(false)
      end

      it 'runs #check' do
        @steamer.should_receive(:check)
        @steamer.update
      end
    end
  end

  describe '#parse_id' do
    context 'when given a vanity url' do
      before :each do
        @steamer.parse_id('http://steamcommunity.com/id/pooper/')
      end

      it 'finds the username' do
        @steamer.steam_id.should == 'pooper'
      end

      it 'sets the id_type to vanity' do
        @steamer.steam_id_type.should == :vanity
      end
    end

    context 'when given a profile url' do
      before :each do
        @steamer.parse_id('http://steamcommunity.com/profiles/76561198003000123/')
      end

      it 'finds the profile id' do
        @steamer.steam_id.should == '76561198003000123'
      end

      it 'sets the id_type to profile' do
        @steamer.steam_id_type.should == :profile
      end
    end

    context 'when given a profile id' do
      before :each do
        @steamer.parse_id('76561198003000123')
      end

      it 'finds the profile id' do
        @steamer.steam_id.should == '76561198003000123'
      end

      it 'sets the id_type to profile' do
        @steamer.steam_id_type.should == :profile
      end
    end

    context 'when given a vanity id' do
      before :each do
        @steamer.parse_id('pooper')
      end

      it 'finds the username' do
        @steamer.steam_id.should == 'pooper'
      end

      it 'sets the id_type to vanity' do
        @steamer.steam_id_type.should == :vanity
      end
    end
  end

  describe '#download_games_list' do
    before :each do
      @steamer.stub(:puts)
      yaml = YAML.load(File.read('spec/fixtures/defaults.yml'))
      @steamer.stub(:default_games).and_return(yaml)
      @url = 'http://steamcommunity.com/id/lobati/games/?xml=1'
      @steamer.stub(:games_url).and_return(@url)
    end

    context 'when steam id is valid' do
      before :each do
        options = {
          :body => File.read('spec/fixtures/games.xml'),
          :content_type => 'application/xml',
        }
        FakeWeb.register_uri(:get, @url, options)
      end

      it 'prints a message' do
        @steamer.should_receive(:puts).with('games list downloaded')
        @steamer.download_games_list
      end

      it 'sets the games' do
        @steamer.download_games_list
        actual_games = @steamer.games.keys
        expected_games = [ 'Age of Chivalry', 'Bastion', 'Prototype' ]
        actual_games.should == expected_games
      end

      it 'adds paths for games listed' do
        @steamer.download_games_list
        actual_paths = @steamer.games.collect { |h1, h2| h2[:path] }
        expected_paths = [ 'where/ev/er', '/some/where', nil ]
        actual_paths.should == expected_paths
      end

      it 'adds special instructions for games' do
        @steamer.download_games_list
        actual_instructions = @steamer.games.collect { |h1, h2| h2[:instructions] }
        expected_instructions = [ nil, 'hop on one foot', nil ]
        actual_instructions.should == expected_instructions
      end
    end

    context 'when steam id is invalid' do
      before :each do
        options = {
          :body => File.read('spec/fixtures/error.xml'),
          :content_type => 'application/xml',
        }
        FakeWeb.register_uri(:get, @url, options)
      end

      it 'aborts with an error message' do
        @steamer.should_receive(:abort).with('invalid steam profile')
        @steamer.download_games_list
      end
    end
  end

  describe '#write_config' do
    before :each do
      @steamer.parse_id('poo')
      @games_hash = {
        'Bastion' => {
          :path => 'blah',
          :instructions => nil,
        },
        'Prototype' => {
          :path => nil,
          :instructions => 'stuff',
        },
      }
      @steamer.games = @games_hash
    end

    it 'writes the games hash and metadata' do
      expected_hash = {
        :steam_id => 'poo',
        :steam_id_type => :vanity,
        :games => @games_hash,
      }
      File.any_instance.should_receive(:write).with(expected_hash.to_yaml)
      @steamer.write_config
    end
  end

  describe '#games_url' do
    context 'when the id is a vanity string' do
      before :each do
        @steamer.steam_id = 'wah!'
        @steamer.steam_id_type = :vanity
      end

      it 'returns a vanity url' do
        url = 'http://steamcommunity.com/id/wah!/games/?xml=1'
        @steamer.games_url.should == url
      end
    end

    context 'when the id is a profile id' do
      before :each do
        @steamer.steam_id = 'wah!'
        @steamer.steam_id_type = :profile
      end

      it 'returns a profiles url' do
        url = 'http://steamcommunity.com/profiles/wah!/games/?xml=1'
        @steamer.games_url.should == url
      end
    end
  end

end
