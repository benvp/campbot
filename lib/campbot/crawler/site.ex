defmodule Campbot.Crawler.CampSite do
  alias Campbot.Crawler.CampSite

  defstruct [:arrival_date, :href, :status]

  def new(root_url, relative_url) do
    u = URI.parse(relative_url).query |> URI.decode_query

    %CampSite{
      href: URI.merge(URI.parse(root_url), relative_url) |> to_string,
      arrival_date: u["arvdate"],
      status: :available
    }
  end
end
