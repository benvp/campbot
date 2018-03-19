defmodule Campbot.Bot do
  alias Campbot.Bot.Subscribers

  defdelegate add_subscriber(psid), to: Subscribers, as: :add
  defdelegate get_subscribers(), to: Subscribers, as: :get_all

  def notify_users(campsites) do
    # build message
    # send message
  end

  def process_message(message) do
    %{"message" => %{"text" => text}, "sender" => %{"id" => sender_psid}} = message |> Map.get("messaging") |> List.first()

    case text |> String.downcase() do
      "subscribe" -> process_subscribe(sender_psid)
      _ -> send_message(sender_psid, ~s{Sorry, I'm not very clever. 😑 I only understand "subscribe"})
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

  def send_message(psid, message) do
    page_access_token = Application.get_env(:campbot, :facebook_messenger_page_access_token)
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{page_access_token}"
    headers = [{"Content-type", "application/json"}]
    body = %{
      recipient: %{id: psid},
      message: %{text: message}
    }

    HTTPoison.post!(url, Poison.encode!(body), headers)
  end
end
