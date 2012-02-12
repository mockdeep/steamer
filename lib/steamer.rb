class Steamer
  include HTTParty

  def initialize(steam_id)
    @steam_id = steam_id
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

end
