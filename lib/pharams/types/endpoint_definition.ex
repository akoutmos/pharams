defmodule Pharams.Types.EndpointDefinition do
  @moduledoc """
  This module defines a struct which is used to encapsulate all the information
  regarding an individual controller endpoint handler.
  """

  alias __MODULE__

  @enforce_keys ~w(
    description
    controller_function
    controller_module
    key_type
    drop_nil_fields
    error_view_module
    error_view_template
    error_status
    path_fields
    query_fields
    body_fields
    output_definitions
  )a

  defstruct description: nil,
            controller_module: nil,
            controller_function: nil,
            key_type: nil,
            drop_nil_fields: nil,
            error_view_module: nil,
            error_view_template: nil,
            error_status: nil,
            path_fields: [],
            query_fields: [],
            body_fields: [],
            output_definitions: []

  @doc """
  Sets the description
  """
  def set_description(%EndpointDefinition{} = endpoint_definition, description) do
    %EndpointDefinition{endpoint_definition | description: description}
  end

  @doc """
  Sets the controller function
  """
  def set_controller_function(%EndpointDefinition{} = endpoint_definition, controller_function) do
    %EndpointDefinition{endpoint_definition | controller_function: controller_function}
  end

  @doc """
  Sets the key type
  """
  def set_key_type(%EndpointDefinition{} = endpoint_definition, key_type) do
    %EndpointDefinition{endpoint_definition | key_type: key_type}
  end

  @doc """
  Sets the drop nil fields flag
  """
  def set_drop_nil_fields(%EndpointDefinition{} = endpoint_definition, drop_nil_fields) do
    %EndpointDefinition{endpoint_definition | drop_nil_fields: drop_nil_fields}
  end

  @doc """
  Sets the error view module
  """
  def set_error_view_module(%EndpointDefinition{} = endpoint_definition, error_view_module) do
    %EndpointDefinition{endpoint_definition | error_view_module: error_view_module}
  end

  @doc """
  Sets the error view template
  """
  def set_error_view_template(%EndpointDefinition{} = endpoint_definition, error_view_template) do
    %EndpointDefinition{endpoint_definition | error_view_template: error_view_template}
  end

  @doc """
  Sets the error status
  """
  def set_error_status(%EndpointDefinition{} = endpoint_definition, error_status) do
    %EndpointDefinition{endpoint_definition | error_status: error_status}
  end

  @doc """
  Sets the path schema
  """
  def set_path_fields(%EndpointDefinition{} = endpoint_definition, path_fields) do
    %EndpointDefinition{endpoint_definition | path_fields: path_fields}
  end

  @doc """
  Adds to the path fields list
  """
  def add_path_field(%EndpointDefinition{path_fields: path_fields} = endpoint_definition, new_path_field) do
    %EndpointDefinition{endpoint_definition | path_fields: [new_path_field | path_fields]}
  end

  @doc """
  Sets the query schema
  """
  def set_query_fields(%EndpointDefinition{} = endpoint_definition, query_fields) do
    %EndpointDefinition{endpoint_definition | query_fields: query_fields}
  end

  @doc """
  Adds to the query fields list
  """
  def add_query_field(%EndpointDefinition{query_fields: query_fields} = endpoint_definition, new_query_field) do
    %EndpointDefinition{endpoint_definition | query_fields: [new_query_field | query_fields]}
  end

  @doc """
  Sets the body schema
  """
  def set_body_fields(%EndpointDefinition{} = endpoint_definition, body_fields) do
    %EndpointDefinition{endpoint_definition | body_fields: body_fields}
  end

  @doc """
  Adds to the body fields list
  """
  def add_body_field(%EndpointDefinition{body_fields: body_fields} = endpoint_definition, new_body_field) do
    %EndpointDefinition{endpoint_definition | body_fields: [new_body_field | body_fields]}
  end

  @doc """
  Sets the output schemas
  """
  def set_output_definitions(%EndpointDefinition{} = endpoint_definition, output_definitions) do
    %EndpointDefinition{endpoint_definition | output_definitions: output_definitions}
  end

  @doc """
  Adds to the output definition list
  """
  def add_output_definition(
        %EndpointDefinition{output_definitions: output_definitions} = endpoint_definition,
        new_output_definition
      ) do
    %EndpointDefinition{endpoint_definition | output_definitions: [new_output_definition | output_definitions]}
  end
end
