defmodule CampbotWeb.Router do
  use CampbotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CampbotWeb do
    pipe_through :api
  end
end
