defmodule Pharams.PlugUtils do
  @moduledoc """
  This module is used to generate pharams validation plug modules
  """

  alias Pharams.ValidationUtils

  @doc """
  Creates the plug validation module
  """
  def create_plug_module(controller_action, env, caller) do
    validation_module_name = ValidationUtils.generate_validation_module_name(controller_action, caller)
    plug_module_name = generate_plug_module_name(controller_action, caller)
    plug_module_ast = generate_plug_module(validation_module_name, caller)

    Module.create(plug_module_name, plug_module_ast, Macro.Env.location(env))
  end

  @doc """
  Generates the module name for the given validation plug module
  """
  def generate_plug_module_name(controller_action, caller) do
    camel_action =
      controller_action
      |> Atom.to_string()
      |> Macro.camelize()

    Module.concat([caller.module, PharamsPlug, camel_action])
  end

  @doc """
  Generates the plug validation module
  """
  def generate_plug_module(validation_module, caller) do
    controller_module = caller.module

    quote do
      @moduledoc false

      use Phoenix.Controller

      import Plug.Conn
      import Ecto.Changeset

      alias Pharams.PlugUtils

      def init(opts), do: opts

      def call(conn, opts \\ []) do
        validator = unquote(validation_module)
        controller = unquote(controller_module)

        # Get the individual route options, or fallback to controller options
        key_type = Keyword.get(opts, :key_type, controller.pharams_key_type())
        drop_nil_fields = Keyword.get(opts, :drop_nil_fields, controller.pharams_drop_nil_fields?())
        error_view_module = Keyword.get(opts, :view_module, controller.pharams_error_view_module())
        error_view_template = Keyword.get(opts, :view_template, controller.pharams_error_view_template())
        error_status = Keyword.get(opts, :error_status, controller.pharams_error_status())

        changeset =
          validator
          |> struct()
          |> validator.changeset(conn.params)

        if changeset.valid? do
          new_params =
            changeset
            |> apply_changes()
            |> convert_key_type(key_type)
            |> prune_empty_fields(drop_nil_fields)

          %{conn | params: new_params}
        else
          conn
          |> put_status(error_status)
          |> put_view(error_view_module)
          |> render(error_view_template, changeset)
          |> halt()
        end
      end

      defp convert_key_type(data, :atom = _key_type), do: PlugUtils.schema_to_atom_map(data)
      defp convert_key_type(data, :string = _key_type), do: PlugUtils.schema_to_string_map(data)

      defp convert_key_type(_data, _invalid_key_type) do
        raise "Pharams: Invalid key_type. Valid options are :string and :atom"
      end

      defp prune_empty_fields(data, false = _drop_nil_fields), do: data
      defp prune_empty_fields(data, true = _drop_nil_fields), do: PlugUtils.drop_nil_fields(data)

      defp prune_empty_fields(data, _invalid_drop_nil_fields) do
        raise "Pharams: Invalid drop_nil_fields. Valid options are true and false"
      end
    end
  end

  @doc """
  Takes a nested struct data structure and turns it into a map with
  atoms as keys.
  """
  def schema_to_atom_map(map) when is_map(map) do
    map
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Enum.map(fn
      {key, %{__struct__: _} = value} ->
        {key, schema_to_atom_map(value)}

      {key, val} when is_list(val) ->
        {key,
         Enum.map(val, fn entry ->
           schema_to_atom_map(entry)
         end)}

      key_val ->
        key_val
    end)
    |> Map.new()
  end

  def schema_to_atom_map(val) do
    val
  end

  @doc """
  Takes a nested struct data structure and turns it into a map with
  strings as keys
  """
  def schema_to_string_map(map) when is_map(map) do
    map
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Enum.map(fn
      {key, %{__struct__: _} = value} ->
        {Atom.to_string(key), schema_to_string_map(value)}

      {key, val} when is_list(val) ->
        {Atom.to_string(key),
         Enum.map(val, fn entry ->
           schema_to_string_map(entry)
         end)}

      {key, val} ->
        {Atom.to_string(key), val}
    end)
    |> Map.new()
  end

  def schema_to_string_map(val) do
    val
  end

  @doc """
  Go through the map of values and remove all fields which are nil
  """
  def drop_nil_fields(map) when is_map(map) do
    map
    |> Enum.reduce(
      %{},
      fn {key, val}, acc ->
        val = drop_nil_fields(val)

        if empty?(val) do
          acc
        else
          Map.put(acc, key, val)
        end
      end
    )
  end

  def drop_nil_fields(list) when is_list(list) do
    list
    |> Enum.reduce([], fn elem, acc ->
      elem = drop_nil_fields(elem)

      if empty?(elem) do
        acc
      else
        [elem | acc]
      end
    end)
    |> Enum.reverse()
  end

  def drop_nil_fields(val), do: val

  defp empty?(val), do: val in [nil, %{}, "", []]
end
