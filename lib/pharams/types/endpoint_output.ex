defmodule Pharams.Types.EndpointOutput do
  @moduledoc """
  This module defines a struct which is used to encapsulate all the information
  regarding an individual controller endpoint handler.
  """

  alias __MODULE__
  alias Plug.Conn.Status

  defstruct status_code: nil,
            fields: []

  @doc """
  Generate a new endpoint output struct
  """
  def build, do: %EndpointOutput{}

  @doc """
  Sets the status code for the given endpoint output
  """
  def set_status_code(%EndpointOutput{} = endpoint_output, code) when is_atom(code) do
    %EndpointOutput{endpoint_output | status_code: Status.code(code)}
  end

  def set_status_code(%EndpointOutput{} = endpoint_output, code) when is_integer(code) do
    %EndpointOutput{endpoint_output | status_code: code}
  end

  def set_status_code(_, code) do
    raise "Invalid status code value of #{inspect(code)}"
  end

  @doc """
  Set the fields for the endpoint output
  """
  def set_fields(%EndpointOutput{} = endpoint_output, fields) do
    %EndpointOutput{endpoint_output | fields: fields}
  end

  @doc """
  Push an additional field into the fields list
  """
  def add_field(%EndpointOutput{fields: fields} = endpoint_output, new_field) do
    %EndpointOutput{endpoint_output | fields: [new_field | fields]}
  end
end
