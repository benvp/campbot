defmodule Campbot.Crawler.Job do
  use GenServer

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
    Process.send_after(self(), :work, 10 * 1000) # 5 minutes
  end

  defp process_campsites(park_id, date, page) do
    case Crawler.get_campsites(date, park_id, page) do
      [] -> nil
      campsites ->
        Bot.notify_users(campsites)
        process_campsites(park_id, date, page + 1)
    end
  end
end
