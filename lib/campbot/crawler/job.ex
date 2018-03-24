defmodule Campbot.Crawler.Job do
  use GenServer

  require Logger

  alias Campbot.Bot
  alias Campbot.Crawler

  def start_link([name: name, park_id: park_id, date: date]) do
    GenServer.start_link(
      __MODULE__,
      %{park_id: park_id, date: date, page: 0},
      name: name
    )
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, %{park_id: park_id, date: date, page: page} = state) do
    process_campsites(park_id, date, page)

    schedule_work()
    {:noreply, %{state | page: page + 1}}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 10 * 60 * 1000) # 10 minutes
  end

  defp process_campsites(park_id, date, page) do
    metadata = [park_id: park_id, date: date]
    Logger.info("Searching for a free campspot...", metadata)
    case Crawler.get_campsites(date, park_id, page) do
      [] ->
        Logger.info("No campsites for campground #{park_id} available.", metadata)
        nil
      campsites ->
        Logger.info("Found available campsites for campground #{park_id}.", metadata)
        Bot.notify_users(campsites)
        process_campsites(park_id, date, page + 1)
    end
  end
end
