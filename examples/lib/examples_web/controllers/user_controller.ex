defmodule ExamplesWeb.UserController do
  use ExamplesWeb, :controller
  use Pharams

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  def create(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  def delete(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  def show(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end
end
