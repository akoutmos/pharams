defmodule ExamplesWeb.Router do
  use ExamplesWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", ExamplesWeb do
    pipe_through(:api)

    resources("/users", UserController, only: [:create, :index, :show, :delete])
    resources("/orders", OrderController, only: [:create, :index, :show, :delete, :update])
  end
end
