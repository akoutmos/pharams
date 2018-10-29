defmodule ExamplesWeb.AddressValidator do
  use Ecto.Schema

  import Ecto.Changeset

  @all_fields ~w(street_line_1 street_line_2 city state zip_code)a
  @required_fields ~w(street_line_1 city state zip_code)a

  @usa_states ~w(
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
  )

  @primary_key false
  embedded_schema do
    field(:street_line_1, :string)
    field(:street_line_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:zip_code, :string)
  end

  def changeset(changeset, params) do
    changeset
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> validate_format(:zip_code, ~r/^\d{5}$/)
    |> validate_inclusion(:state, @usa_states, message: "is an invalid state abbreviation")
  end
end
