defmodule ExamplesWeb.UserController do
  use ExamplesWeb, :controller
  use Pharams, error_status: 400

  alias ExamplesWeb.{RegexValidator, Functions}
  alias ExamplesWeb.SportsType, as: Sports

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{})
  end

  #
  #  pharams :create do
  #    required(:terms_conditions, :boolean,
  #      acceptance: [message: ExamplesWeb.Messages.terms_conditions_acceptance()]
  #    )
  #
  #    required(:password, :string,
  #      confirmation: [required: true, message: ExamplesWeb.Messages.pass_confirmation()],
  #      length: [min: 8, max: 16]
  #    )
  #
  #    required(:foo, :string,
  #      change: fn :foo, foo -> if foo == "foo", do: [foo: "cannot be foo"], else: [] end
  #    )
  #
  #    required(:bar, :string, change: [:metadata, &Functions.bar_validator/2])
  #
  #    required(:password_confirmation, :string)
  #    required(:age, :integer, number: [greater_than: 16, less_than: 110])
  #    optional(:phone_number, :string, format: RegexValidator.phone_number())
  #    optional(:zip_code, :string, format: RegexValidator.zip_code())
  #    optional(:hobbies, {:array, Sports})
  #    optional(:hobbies_2, {:array, ExamplesWeb.SportsType})
  #
  #    optional(:interests, {:array, :string},
  #      subset: ["art", "music", "technology"],
  #      length: [max: 2]
  #    )
  #
  #    optional(:favorite_programming_language, :string,
  #      exclusion: ~w(Java Perl PHP),
  #      default: "Elixir"
  #    )
  #
  #    required(:type, :string, inclusion: ["super_admin", "admin", "regular"])
  #
  #    required :addresses, :one do
  #      required :billing_address, :one do
  #        optional(:default, :boolean, default: false)
  #        required(:street_line_1, :string)
  #        optional(:street_line_2, :string)
  #        required(:zip_code, :string, format: ~r/\d{5}/)
  #
  #        required :coordinates, :one do
  #          required(:lat, :float,
  #            number: [greater_than_or_equal_to: -90, less_than_or_equal_to: 90]
  #          )
  #
  #          required(:long, :float,
  #            number: [greater_than_or_equal_to: -180, less_than_or_equal_to: 180]
  #          )
  #        end
  #      end
  #
  #      required :shipping_address, :one do
  #        required(:street_line_1, :string)
  #        optional(:street_line_2, :string)
  #        required(:zip_code, :string, format: ~r/\d{5}/)
  #
  #        required :coordinates, :one do
  #          required(:lat, :float,
  #            number: [greater_than_or_equal_to: -90, less_than_or_equal_to: 90]
  #          )
  #
  #          required(:long, :float,
  #            number: [greater_than_or_equal_to: -180, less_than_or_equal_to: 180]
  #          )
  #        end
  #      end
  #    end
  #  end

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
