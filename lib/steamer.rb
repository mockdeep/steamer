require 'yaml'

class Steamer
  include HTTParty
  attr_accessor :steam_id, :steam_id_type, :games

  def check(update = false)
    if File.exist?(File.join(File.expand_path('~'), '.steamer'))
      puts 'profile exists'
      if update
        load_config
        download_games_list
        write_config
      end
      true
    else
      puts 'please enter your steam id'
      parse_id(gets.chomp)
      download_games_list
      write_config
      false
    end
  end

  def update
    check(true)
  end

  def parse_id(mystery_id)
    case mystery_id
    when /steamcommunity\.com\/id\/(\w*)/
      self.steam_id = $1
      self.steam_id_type = :vanity
    when /(\d{17})/
      self.steam_id = $1
      self.steam_id_type = :profile
    else
      self.steam_id = mystery_id
      self.steam_id_type = :vanity
    end
  end

  def download_games_list
    response = self.class.get(games_url).parsed_response
    if response['response'] && response['response']['error'] =~ /could not be found/
      abort('invalid steam profile')
    else
      puts 'games list downloaded'
      self.games ||= {}
      games_array = response['gamesList']['games']['game']
      games_array.each do |game_hash|
        game_name = game_hash['name']
        self.games[game_name] ||= {}
        if default_game = default_games[game_name]
          self.games[game_name][:path] ||= default_game[:path]
          self.games[game_name][:instructions] ||= default_game[:instructions]
        else
          self.games[game_name][:path] ||= nil
          self.games[game_name][:instructions] ||= nil
        end
      end
      self.games = Hash[games.sort]
    end
  end

  def write_config
    metadata = {
      :steam_id => steam_id,
      :steam_id_type => steam_id_type,
      :games => games,
    }
    file = File.open(File.expand_path('~/.steamer'), 'w')
    file.write(metadata.to_yaml)
    file.close
  end

  def load_config
  end

  def games_url
    case steam_id_type
    when :vanity
      url = "http://steamcommunity.com/id/#{steam_id}/games/?xml=1"
    when :profile
      url = "http://steamcommunity.com/profiles/#{steam_id}/games/?xml=1"
    end
  end

  def default_games
    @default_games ||= begin
      yaml = File.read(File.dirname(File.expand_path(__FILE__)) + '/defaults.yml')
      YAML.load(yaml)
    end
  end
end
