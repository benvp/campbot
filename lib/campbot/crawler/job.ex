defmodule Campbot.Crawler.Job do
  alias Campbot.Bot
  alias Campbot.Crawler

  def process_campsites(parkId, date, page \\ 0) do
    case Crawler.get_campsites(date, parkId, page) do
      [] -> nil
      campsites ->
        Bot.notify_users(campsites)
        process_campsites(parkId, date, page + 1)
    end
  end
end
