defmodule Campbot.Crawler do
  alias Campbot.Crawler.CampSite

  @root_url "https://www.recreation.gov"
  @cookie_url "https://www.recreation.gov"
  @filter_url "https://www.recreation.gov/campsiteSearch.do"

  def get_campsites(start_date, park_id, page \\ 0) do
    cookies = get_cookies()
    get_campsite_html(start_date, park_id, page, cookies)
    set_filters(park_id, cookies)
    html = get_campsite_html(start_date, park_id, page, cookies)

    html
    |> Floki.find("#csitecalendar > table#calendar > tbody > tr:not(.separator)")
    |> Floki.find("td.status.a")
    |> parse()
  end

  def parse(html) do
    html
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.map(&(CampSite.new(@root_url, &1)))
  end

  defp set_filters(park_id, cookies) do
    form = [
      {:contractCode, "NRSO"},
      {:parkId, park_id},
      {:availStatus, ""},
      {:submitSiteForm, "true"},
      {:search, "site"},
      {:currentMaximumWindow, "12"},
      {:loop, ""},
      {:siteCode, ""},
      {:lookingFor, ""},
      {:camping_common_218, ""},
      {:camping_common_3012, ""},
      {:camping_common_3013, 30}
    ]

    HTTPoison.post!(@filter_url, {:form, form}, [], hackney: [cookie: cookies])
  end

  defp get_cookies() do
    %HTTPoison.Response{headers: headers} = HTTPoison.get!(@cookie_url)
    IO.inspect(headers)
    Enum.filter(headers, fn
      {"Set-Cookie", _ } -> true
      _ -> false
    end)
    |> Enum.map(fn {_, cookie} -> cookie end)
    |> Enum.map(fn cookie ->
      [head | _] = String.split(cookie, ";")
      head
    end)
    |> Enum.join("; ")
  end

  defp get_campsite_html(start_date, park_id, page, cookies) do
    url = build_url(start_date, park_id, page)
    %HTTPoison.Response{:body => body} = HTTPoison.get!(url, [], hackney: [cookie: cookies])
    body
  end

  def is_last_page(_body, _page) do
    # last page is page > 0
    # and a[id^="resultPrevious"] has class "disabled"
  end

  defp build_url(start_date, park_id, page) do
    page_index = page * 25
    """
    #{@root_url}/campsiteCalendar.do\
    ?page=matrix\
    &calarvdate=#{start_date}\
    &contractCode=NRSO\
    &parkId=#{park_id}\
    &sitepage=true\
    &startIdx=#{page_index}\
    """
  end
end
