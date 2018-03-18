defmodule CampbotWeb.CampbotController do
  use CampbotWeb, :controller

  def verify(conn, %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge}) do
    verify_token = Application.get_env(:campbot, :facebook_messenger_verify_token)

    cond do
      mode == "subscribe" and token == verify_token ->
        send_challenge(conn, challenge)
      true -> send_unauthorized(conn)
    end
  end

  def receive(conn, %{"object" => object, "entry" => entries}) when object === "page" do
    Enum.each(entries, fn entry ->
      %{"message" => %{"text" => text}, "sender" => %{"id" => sender_psid}} = entry |> Map.get("messaging") |> List.first()
        case text do
          "hello" -> send_message(sender_psid, "hallo zurueck")
          "subscribe" ->

            ## RentBot.Subscribers.create_subscriber(%{psid: sender_psid})
            send_message(sender_psid, "You are now subscribed to my updates! :)")
          _ -> send_message(sender_psid, ~s{Sorry, I'm not very clever. 😑 I only understand "subscribe"})
        end
    end)

    send_event_received(conn)
  end
  def receive(conn, _), do: send_not_found(conn)

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

  def send_event_received(conn) do
    send_resp(conn, 200, "EVENT_RECEIVED")
  end

  def send_not_found(conn) do
    send_resp(conn, 404, "NOT_FOUND")
  end

  def send_challenge(conn, challenge) do
    send_resp(conn, 200, challenge)
  end

  def send_unauthorized(conn) do
    send_resp(conn, 401, "Unauthorized")
  end
end
