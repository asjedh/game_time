require 'sinatra'
require 'csv'
require 'pry'


###FIRST DEFINE METHODS TO BE USED

def import_games_from_csv(file_path)
  games = []
  CSV.foreach(file_path, :headers => true, :header_converters => :symbol) do |game|
    games << game.to_hash
  end
  games # returns an array of hashes
end

def construct_leaderboard(games_array)
  leaderboard = Hash.new{ |hash, key| hash[key] = {wins: 0, losses:0} }
  games_array.each do |game|
    if game[:home_score].to_i > game[:away_score].to_i
      leaderboard[game[:home_team]][:wins] += 1
      leaderboard[game[:away_team]][:losses] += 1
    else
      leaderboard[game[:away_team]][:wins] += 1
      leaderboard[game[:home_team]][:losses] += 1
    end
  end
  leaderboard # this is returning a hash of hashes. {each_team => {wins,losses}, etc...}
end

def sort_leaderboard(leaderboard_hash)
  sorted_leaderboard_hash = Hash.new(0)
  leaderboard_array = leaderboard_hash.sort_by { |name, info| [-info[:wins], info[:losses]] }
  leaderboard_array.map { |team| sorted_leaderboard_hash[team[0]] = team[1] }
  sorted_leaderboard_hash
end

def games_of_team(team_name,games_array)
  games_of_team = []
  games_array.each do |game|
    games_of_team << game if game[:home_team] == team_name || game[:away_team] == team_name
  end
  games_of_team
end

### END OF METHODS, BEGINNING OF GETS


get '/leaderboard' do
  all_games = import_games_from_csv('games.csv')
  unsorted_leaderboard = construct_leaderboard(all_games)
  @sorted_leaderboard = sort_leaderboard(unsorted_leaderboard)
  erb :'leaderboard/show', layout: :'leaderboard/layout'
end

get '/teams/:team_name' do
  @team_name = params[:team_name]
  all_games = import_games_from_csv('games.csv')
  unsorted_leaderboard = construct_leaderboard(all_games)
  @sorted_leaderboard = sort_leaderboard(unsorted_leaderboard) #this will be used to show W-L record
  @teams_games = games_of_team(@team_name,all_games) #this will be used to show all games played
  erb :'teams/show', layout: :'teams/layout'
end

get '/' do
  redirect '/leaderboard'
end

get '/:something' do
  redirect '/leaderboard'
end
