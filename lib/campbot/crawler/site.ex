defmodule Campbot.Crawler.CampSite do
  alias Campbot.Crawler.CampSite

  defstruct [:id, :site_no, :park_id, :arrival_date, :href, :status]

  def new(root_url, site_row_dom, row_td_dom) do
    reservation_url = URI.merge(root_url, extract_reservation_url(row_td_dom)) |> to_string()
    query = query_map(row_td_dom)

    IO.inspect(query)

    %CampSite{
      id: query["siteId"],
      site_no: site_no(site_row_dom),
      park_id: query["parkId"],
      href: reservation_url,
      arrival_date: query["arvdate"],
      status: :available,
    }
  end

  def site_no(site_row_dom) do
    site_row_dom
    |> Floki.find("td.sn > div.siteListLabel > a")
    |> Floki.text(deep: false)
  end

  def extract_reservation_url(row_td_dom) do
    row_td_dom
    |> IO.inspect()
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> List.first()
  end

  def query_map(row_td_dom) do
    row_td_dom
    |> extract_reservation_url()
    |> to_query_map()
  end

  def to_query_map(url) when is_binary(url) do
    url
    |> URI.parse()
    |> Map.get(:query)
    |> URI.decode_query()
  end
end
