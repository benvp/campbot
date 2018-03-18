defmodule CampbotWeb.Router do
  use CampbotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CampbotWeb do
    pipe_through :api

    get "/webhook", CampbotController, :verify
    post "/webhook", CampbotController, :receive
  end
end
