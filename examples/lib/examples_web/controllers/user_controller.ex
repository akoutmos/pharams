defmodule ExamplesWeb.UserController do
  use ExamplesWeb, :controller
  use Pharams

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  pharams :create do
    required(:terms_conditions, :boolean, acceptance: [])
    required(:password, :string, confirmation: [], length: [min: 8, max: 16])
    required(:password_confirmation, :string)
    required(:age, :integer, number: [greater_than: 16, less_than: 110])

    optional(:interests, {:array, :string},
      subset: ["art", "music", "technology"],
      length: [max: 2]
    )

    optional(:favorite_programming_language, :string,
      exclusion: ~w(Java Perl PHP),
      default: "Elixir"
    )

    required(:type, :string, inclusion: ["super_admin", "admin", "regular"])

    required :addresses, :one do
      required :billing_address, :one do
        required(:street_line_1, :string)
        optional(:street_line_2, :string)
        required(:zip_code, :string, format: ~r/\d{5}/)

        required :coordinates, :one do
          required(:lat, :float,
            number: [greater_than_or_equal_to: -90, less_than_or_equal_to: 90]
          )

          required(:long, :float,
            number: [greater_than_or_equal_to: -180, less_than_or_equal_to: 180]
          )
        end
      end

      required :shipping_address, :one do
        required(:street_line_1, :string)
        optional(:street_line_2, :string)
        required(:zip_code, :string, format: ~r/\d{5}/)

        required :coordinates, :one do
          required(:lat, :float,
            number: [greater_than_or_equal_to: -90, less_than_or_equal_to: 90]
          )

          required(:long, :float,
            number: [greater_than_or_equal_to: -180, less_than_or_equal_to: 180]
          )
        end
      end
    end
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
