defmodule ExamplesWeb.PaginationValidator do
  use Ecto.Schema

  import Ecto.Changeset

  @all_fields ~w(page page_size)a

  @primary_key false
  embedded_schema do
    field(:page, :integer)
    field(:page_size, :integer)
  end

  def changeset(changeset, params) do
    changeset
    |> cast(params, @all_fields)
    |> validate_number(:page, greater_than: 0)
    |> validate_number(:page_size, greater_than: 0)
  end
end
