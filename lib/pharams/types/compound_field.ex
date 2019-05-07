defmodule Pharams.Types.CompoundField do
  @moduledoc """
  This module defines a struct which is used to encapsulate all the information
  regarding a compound field.
  """

  alias __MODULE__

  defstruct name: nil,
            cardinality: nil,
            required: nil,
            fields: []

  @doc """
  Generate a new simgple field struct
  """
  def build, do: %CompoundField{}

  @doc """
  Set the name field
  """
  def set_name(%CompoundField{} = compound_field, name) do
    %CompoundField{compound_field | name: name}
  end

  @doc """
  Set the cardinality field
  """
  def set_cardinality(%CompoundField{} = compound_field, :one) do
    %CompoundField{compound_field | cardinality: :one}
  end

  def set_cardinality(%CompoundField{} = compound_field, :many) do
    %CompoundField{compound_field | cardinality: :many}
  end

  def set_cardinality(%CompoundField{} = compound_field, cardinality) do
    raise "Invalid cardinality value of #{inspect(cardinality)}"
  end

  @doc """
  Set the required field
  """
  def set_required(%CompoundField{} = compound_field, required) do
    %CompoundField{compound_field | required: required}
  end

  @doc """
  Sets the fields
  """
  def set_fields(%CompoundField{} = compound_field, fields) do
    %CompoundField{compound_field | fields: fields}
  end

  @doc """
  Adds to the fields
  """
  def add_field(
        %CompoundField{fields: fields} = compound_field,
        field
      ) do
    %CompoundField{compound_field | fields: [field | fields]}
  end
end
