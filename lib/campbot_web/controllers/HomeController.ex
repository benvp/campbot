defmodule CampbotWeb.HomeController do
  use CampbotWeb, :controller

  def index(conn, _args) do
    conn
    |> json(%{error: "Go away! There's nothing here. 🤞"})
  end
end
