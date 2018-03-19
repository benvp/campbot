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
    Enum.each(entries, &Campbot.Bot.process_message/1)
    send_event_received(conn)
  end
  def receive(conn, _), do: send_not_found(conn)

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
