require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = generate_grid(10)
    @start_time = Time.now
    session[:name] = "Ryan"
    #session[:results] = nil
  end

  def score
    @shot = params[:shot]
    @grid = params[:grid].split(" ")
    @start_time = Time.parse(params[:time])
    @end_time = Time.now
    @result = run_game(@shot, @grid, @start_time, @end_time)
    (session[:results] ||= []) << @result[:score]
  end

  private

  def generate_grid(grid_size)
    # ["Q", "F", "M", "R", "K", "L", "I", "T", "P"]
    array = []
    grid_size.times do
      array  << (65 + rand(25)).chr
    end

    return array
  end

  def attempt_in_grid?(attempt, grid)
    attempt_check = attempt.upcase.chars
    attempt_check.each do |x|
      if grid.include?(x)
        grid.delete_at(grid.index(x) || grid.length)
      else
        return false
      end
    end
    return true
  end


  def run_game(attempt, grid, start_time, end_time)
    hash = { time: end_time - start_time }

    if attempt_in_grid?(attempt, grid)
      tradu_hash = JSON.parse(open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read)

      if tradu_hash["Error"] == "NoTranslation"
        return hash.merge(message: "not an english word", translation: nil, score: 0)

      else
        tradu_word = tradu_hash["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
        score = (attempt.length.fdiv(9) * 1.fdiv(hash[:time]) *1_000).round
        return hash.merge(translation: tradu_word, score: score, message: "well done")
      end

    else
      return hash.merge(message: "not in the grid", score: 0)
    end
  end

end
