class Steamer
  include HTTParty
  attr_reader :steam_id, :id_type

  def initialize
    load_config
  end

  def game_names
    games_and_ids.collect(&:first)
  end

  def games_and_ids
    @games_and_ids ||= begin
      url = "http://steamcommunity.com/id/#{@steam_id}/games/?xml=1"
      response = self.class.get(url)
      games_array = response.parsed_response['gamesList']['games']['game']
      pairs = games_array.collect { |h| [ h['name'], h['appID'] ] }
      pairs.sort { |a, b| a.first.downcase <=> b.first.downcase }
    end
  end

  def load_config
    if File.exist?(File.join(File.expand_path('~'), '.steamer'))
      puts 'yay!'
    else
      set_up_new_user
    end
  end

  def set_up_new_user
    puts 'Please enter your Steam profile id or custom url'
    mystery_id = gets.chomp
    parse_id(mystery_id)
  end

  def parse_id(mystery_id)
    case mystery_id
    when /steamcommunity\.com\/id\/(\w*)/
      @steam_id = $1
      @id_type = :vanity
    when /(\d{17})/
      @steam_id = $1
      @id_type = :profile
    else
      @steam_id = mystery_id
      @id_type = :vanity
    end
  end

end
