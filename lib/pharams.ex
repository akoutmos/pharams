defmodule Pharams do
  @moduledoc """
  Functions and macros for validating requests to Phoenix
  Controllers.
  """

  alias Pharams.Utils

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

  defmacro __using__(opts) do
    key_type = Keyword.get(opts, :key_type, :atom)
    drop_nil_fields = Keyword.get(opts, :drop_nil_fields, false)
    error_module = Keyword.get(opts, :view_module, Pharams.ErrorView)
    error_template = Keyword.get(opts, :view_template, "errors.json")
    error_status = Keyword.get(opts, :error_status, :unprocessable_entity)

    quote do
      import Pharams, only: [pharams: 2, pharams: 3]

      # TODO: This is a bit hacky, move these over to module attributes
      def pharams_key_type, do: unquote(key_type)
      def pharams_drop_nil_fields?, do: unquote(drop_nil_fields)
      def pharams_error_view_module, do: unquote(error_module)
      def pharams_error_view_template, do: unquote(error_template)
      def pharams_error_status, do: unquote(error_status)
    end
  end

  defp generate_plug(validation_module, controller_module) do
    quote do
      @moduledoc false

      use Phoenix.Controller

      import Plug.Conn
      import Ecto.Changeset

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

      defp convert_key_type(data, :atom = _key_type), do: Pharams.schema_to_atom_map(data)
      defp convert_key_type(data, :string = _key_type), do: Pharams.schema_to_string_map(data)

      defp convert_key_type(_data, _invalid_key_type) do
        raise "Pharams: Invalid key_type. Valid options are :string and :atom"
      end

      defp prune_empty_fields(data, false = _drop_nil_fields), do: data
      defp prune_empty_fields(data, true = _drop_nil_fields), do: Pharams.drop_nil_fields(data)

      defp prune_empty_fields(data, _invalid_drop_nil_fields) do
        raise "Pharams: Invalid drop_nil_fields. Valid options are true and false"
      end
    end
  end

  defp generate_validation({:__block__, [], block_contents}, caller) do
    root_field_declarations = Utils.generate_basic_field_schema_definitions(block_contents, caller)
    root_fields = Utils.get_all_basic_fields(block_contents)
    root_required_fields = Utils.get_required_basic_fields(block_contents)
    root_validations = Utils.generate_basic_field_validations(block_contents, caller)
    root_group_declarations = Utils.generate_group_field_schema_definitions(block_contents, caller)
    root_sub_schema_casts = Utils.generate_group_field_schema_casts(block_contents, nil)
    group_schema_changesets = Utils.generate_group_field_schema_changesets(block_contents, nil, caller)

    module =
      [
        "@moduledoc false",
        "",
        "use Ecto.Schema",
        "import Ecto.Changeset",
        "",
        "@primary_key false",
        "embedded_schema do",
        root_field_declarations,
        root_group_declarations,
        "end",
        "",
        "def changeset(schema, params) do",
        "schema",
        "|> cast(params, #{inspect(root_fields)})",
        "|> validate_required(#{inspect(root_required_fields)})",
        root_validations,
        root_sub_schema_casts,
        "end",
        "",
        group_schema_changesets
      ]
      |> List.flatten()

    formatted_module =
      module
      |> Enum.join("\n")
      |> Code.format_string!()

    module =
      (module ++
         [
           "",
           "def dump do",
           "\"\"\"",
           "#{formatted_module}",
           "\"\"\"",
           "end"
         ])
      |> Enum.join("\n")

    Code.string_to_quoted!(module)
  end

  defp generate_validation(ast, caller) do
    generate_validation({:__block__, [], [ast]}, caller)
  end

  @doc """
  This macro provides the ability to define validation schemas for use in Phoenix controllers

  ## Example
  ```elixir
  use Pharams, view_module: Pharams.ErrorView, view_template: "errors.json", error_status: :unprocessable_entity

  pharams :index do
    required :terms_conditions, :boolean
    required :password, :string
    required :password_confirmation, :string
    optional :age, :integer
  end

  def index(conn, params) do
    # You will only get into this function if the request
    # parameters have passed the above validator. The params
    # variable is now just a map with atoms as keys.

    render(conn, "index.html")
  end
  ```
  """
  defmacro pharams(controller_action, do: block) do
    camel_action =
      controller_action
      |> Atom.to_string()
      |> Macro.camelize()

    calling_module = __CALLER__.module

    # Create validation module
    validation_module_name = Module.concat([calling_module, PharamsValidator, camel_action])
    validation_module_ast = generate_validation(block, __CALLER__)
    Module.create(validation_module_name, validation_module_ast, Macro.Env.location(__ENV__))

    # Create plug module
    plug_module_name = Module.concat([calling_module, PharamsPlug, camel_action])
    plug_module_ast = generate_plug(validation_module_name, calling_module)
    Module.create(plug_module_name, plug_module_ast, Macro.Env.location(__ENV__))

    # Insert the validation plug into the controller
    quote do
      plug(unquote(plug_module_name) when var!(action) == unquote(controller_action))
    end
  end

  defmacro pharams(controller_action, opts, do: block) do
    camel_action =
      controller_action
      |> Atom.to_string()
      |> Macro.camelize()

    calling_module = __CALLER__.module

    # Create validation module
    validation_module_name = Module.concat([calling_module, PharamsValidator, camel_action])
    validation_module_ast = generate_validation(block, __CALLER__)
    Module.create(validation_module_name, validation_module_ast, Macro.Env.location(__ENV__))

    # Create plug module
    plug_module_name = Module.concat([calling_module, PharamsPlug, camel_action])
    plug_module_ast = generate_plug(validation_module_name, calling_module)
    Module.create(plug_module_name, plug_module_ast, Macro.Env.location(__ENV__))

    # Insert the validation plug into the controller
    quote do
      plug(
        unquote(plug_module_name),
        unquote(opts) when var!(action) == unquote(controller_action)
      )
    end
  end
end
