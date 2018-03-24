defmodule Campbot.Bot do
  alias Campbot.Bot.Subscribers

  defdelegate add_subscriber(psid), to: Subscribers, as: :add
  defdelegate get_subscribers(), to: Subscribers, as: :get_all

  def notify_users(campsites) do
    for subscriber_id <- Subscribers.get_all(),
        site <- campsites do
      send_campsite_message(subscriber_id, site)
    end
  end

  def process_message(message) do
    msg = message |> Map.get("messaging") |> List.first()

    case msg do
      %{"message" => %{"text" => text}, "sender" => %{"id" => sender_psid}} ->
        case text |> String.downcase() do
          "subscribe" -> process_subscribe(sender_psid)
          _ -> send_dunno(sender_psid)
        end
      %{"sender" => %{"id" => sender_psid}} -> send_dunno(sender_psid)
      _ -> nil
    end
  end

  def process_subscribe(psid) do
    cond do
      already_subscribed?(psid) -> send_message(psid, "You are subscribed already! 🎉")
      true ->
        Campbot.Bot.add_subscriber(psid)
        send_message(psid, "Yeah, I'll let you know if I find a free campspot. 🍻")
    end
  end

  def already_subscribed?(psid) do
    get_subscribers()
    |> Enum.member?(psid)
  end

  def send_campsite_message(psid, campsite) do
    send_message(psid, campsite_message(campsite))
  end

  def send_dunno(psid) do
    send_message(psid, ~s{Sorry, I'm not very clever. 😑 I only understand "subscribe"})
  end

  def send_message(psid, message) do
    page_access_token = Application.get_env(:campbot, :facebook_messenger_page_access_token)
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{page_access_token}"
    headers = [{"Content-type", "application/json"}]
    body = %{
      recipient: %{id: psid},
      message: %{text: message},
      notification_type: "REGULAR"
    }

    HTTPoison.post!(url, Poison.encode!(body), headers)
  end

  defp campsite_message(campsite) do
    """
    G'day mate. 👋 Just wanted to let you know that there is a campsite available! Here are the details:
    Campsite: #{campsite.park_id}
    Date: #{campsite.arrival_date}
    Book here: #{campsite.href}

    Hope you enjoy your stay. Cheers! 🍻
    """
  end
end
