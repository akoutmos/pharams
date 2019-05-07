defmodule Pharams.Types.SimpleField do
  @moduledoc """
  This module defines a struct which is used to encapsulate all the information
  regarding a simple field.
  """

  alias __MODULE__
  alias Pharams.Types.Maybe

  defstruct name: nil,
            type: nil,
            required: nil,
            default: %Maybe{},
            description: nil,
            validators: []

  @doc """
  Generate a new simgple field struct
  """
  def build, do: %SimpleField{}

  @doc """
  Set the name field
  """
  def set_name(%SimpleField{} = simple_field, name) do
    %SimpleField{simple_field | name: name}
  end

  @doc """
  Set the type field
  """
  def set_type(%SimpleField{} = simple_field, type) do
    %SimpleField{simple_field | type: type}
  end

  @doc """
  Set the required field
  """
  def set_required(%SimpleField{} = simple_field, required) do
    %SimpleField{simple_field | required: required}
  end

  @doc """
  Set the default field
  """
  def set_default(%SimpleField{} = simple_field, default) do
    %SimpleField{simple_field | default: Maybe.build(default)}
  end

  @doc """
  Set the description field
  """
  def set_description(%SimpleField{} = simple_field, description) do
    %SimpleField{simple_field | description: description}
  end

  @doc """
  Sets the field validators
  """
  def set_validators(%SimpleField{} = simple_field, validators) do
    %SimpleField{simple_field | validators: validators}
  end

  @doc """
  Adds to the simple field validators
  """
  def add_output_definition(
        %SimpleField{validators: validators} = simple_field,
        simple_field_validator
      ) do
    %SimpleField{simple_field | validators: [simple_field_validator | validators]}
  end
end
