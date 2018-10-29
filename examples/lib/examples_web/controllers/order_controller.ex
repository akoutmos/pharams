defmodule ExamplesWeb.OrderController do
  use ExamplesWeb, :controller
  use Pharams

  alias ExamplesWeb.AddressValidator
  alias Ecto.UUID

  #  pharams :index do
  #    optional(:page, :one, ExamplesWeb.PaginationValidator)
  #
  #    optional :price, :one do
  #      optional(:gte, :float, number: [greater_than: 16, less_than: 110])
  #      optional(:gt, :float, number: [greater_than_or_equal_to: 0])
  #      optional(:eq, :float, number: [greater_than_or_equal_to: 0])
  #      optional(:lte, :float, number: [greater_than_or_equal_to: 0])
  #      optional(:lt, :float, number: [greater_than_or_equal_to: 0])
  #    end
  #
  #    optional :date, :one do
  #      optional(:gte, :naive_datetime)
  #      optional(:gt, :naive_datetime)
  #      optional(:eq, :naive_datetime)
  #      optional(:lte, :naive_datetime)
  #      optional(:lt, :naive_datetime)
  #    end
  #  end

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  pharams :create do
    required :items, :many do
      required(:quantity, :integer, number: [greater_than: 0, less_than: 100])
      required(:item_id, UUID)
    end

    required(:price, :float, number: [greater_than_or_equal_to: 0])
    required(:shipping_method, :string, inclusion: ["ground", "2_day_air", "1_day_air"])

    required :addresses, :one do
      required(:shipping_address, :one, AddressValidator)
      required(:billing_address, :one, AddressValidator)
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  # pharams :delete do
  #  required(:id, Ecto.UUID)
  # end

  def delete(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  # pharams :show do
  #  required(:id, Ecto.UUID)
  # end

  def show(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end
end
