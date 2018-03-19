defmodule Campbot.Crawler do
  alias Campbot.Crawler.CampSite

  @root_url "https://www.recreation.gov"
  @cookie_url "https://www.recreation.gov"
  @filter_url "https://www.recreation.gov/campsiteSearch.do"

  def get_campsites(start_date, park_id, page \\ 0) do
    cookies = get_cookies()

    # we have to get campsite_html twice to initialise the session properly
    get_campsite_html(start_date, park_id, page, cookies)
    set_filters(park_id, cookies)

    # when last page return empty list, otherwise get next page
    html = get_campsite_html(start_date, park_id, page, cookies)
    cond do
      is_last_page(html) -> []
      true ->
        html
        |> get_site_rows_dom()
        # BUG: here is a bug as the site_row_dom contains all rows
        # this will lead to incorrect site numbers
        |> parse_row()
        |> filter_campsites_to_date(start_date)
    end
  end

  defp is_last_page(html) do
    # a[id^="resultNext"] has class "disabled"
    case Floki.find(html, ~s{a[id^="resultNext"].disabled}) do
      [] -> false
      _ -> true
    end
  end

  defp get_site_rows_dom(html) do
    Floki.find(html, "#csitecalendar > table#calendar > tbody > tr:not(.separator)")
  end

  defp parse_row(site_row_dom) do
    site_row_dom
    |> Floki.find("td.status.a > a")
    |> Enum.map(&(CampSite.new(@root_url, site_row_dom, &1)))
  end

  defp get_cookies() do
    %HTTPoison.Response{headers: headers} = HTTPoison.get!(@cookie_url)
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

  defp filter_campsites_to_date(campsites, date) do
    campsites
    |> Enum.filter(&(&1.arrival_date === date))
  end
end
