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
  def pharams_schema_to_atom_map(map) when is_map(map) do
    map
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Enum.map(fn
      {key, %{__struct__: _} = value} ->
        {key, pharams_schema_to_atom_map(value)}

      {key, val} when is_list(val) ->
        {key,
         Enum.map(val, fn entry ->
           pharams_schema_to_atom_map(entry)
         end)}

      key_val ->
        key_val
    end)
    |> Map.new()
  end

  def pharams_schema_to_atom_map(val) do
    val
  end

  @doc """
  Takes a nested struct data structure and turns it into a map with
  strings as keys
  """
  def pharams_schema_to_string_map(map) when is_map(map) do
    map
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Enum.map(fn
      {key, %{__struct__: _} = value} ->
        {Atom.to_string(key), pharams_schema_to_string_map(value)}

      {key, val} when is_list(val) ->
        {Atom.to_string(key),
         Enum.map(val, fn entry ->
           pharams_schema_to_string_map(entry)
         end)}

      {key, val} ->
        {Atom.to_string(key), val}
    end)
    |> Map.new()
  end

  def pharams_schema_to_string_map(val) do
    val
  end

  defmacro __using__(opts) do
    key_type = Keyword.get(opts, :key_type, :atom)
    error_module = Keyword.get(opts, :view_module, Pharams.ErrorView)
    error_template = Keyword.get(opts, :view_template, "errors.json")
    error_status = Keyword.get(opts, :error_status, :unprocessable_entity)

    quote do
      import Pharams, only: [pharams: 2]

      # TODO: This is a bit hacky, move these over to module attributes
      def pharams_key_type, do: unquote(key_type)
      def pharams_error_view_module, do: unquote(error_module)
      def pharams_error_view_template, do: unquote(error_template)
      def pharams_error_status, do: unquote(error_status)
    end
  end

  defp generate_plug(validation_module, controller_module) do
    quote do
      use Phoenix.Controller

      import Plug.Conn
      import Ecto.Changeset

      def init(opts), do: opts

      def call(conn, key) do
        validation_module = unquote(validation_module)
        controller_module = unquote(controller_module)
        changeset = validation_module.changeset(struct(validation_module), conn.params)

        if changeset.valid? do
          new_params = prepare_params(changeset, controller_module.pharams_key_type())

          %{conn | params: new_params}
        else
          view_module = controller_module.pharams_error_view_module()
          view_template = controller_module.pharams_error_view_template()
          error_status = controller_module.pharams_error_status()

          conn
          |> put_status(error_status)
          |> put_view(view_module)
          |> render(view_template, changeset)
          |> halt()
        end
      end

      defp prepare_params(changeset, :atom = _key_type) do
        changeset
        |> apply_changes()
        |> Pharams.pharams_schema_to_atom_map()
      end

      defp prepare_params(changeset, :string = _key_type) do
        changeset
        |> apply_changes()
        |> Pharams.pharams_schema_to_string_map()
      end

      defp prepare_params(changeset, _invalid_key_type) do
        raise "Pharams: Invalid key_type. Valid options are :string and :atom"
      end
    end
  end

  defp generate_validation({:__block__, [], block_contents}, caller) do
    root_field_declarations =
      Utils.generate_basic_field_schema_definitions(block_contents, caller)

    root_fields = Utils.get_all_basic_fields(block_contents)
    root_required_fields = Utils.get_required_basic_fields(block_contents)
    root_validations = Utils.generate_basic_field_validations(block_contents, caller)

    root_group_declarations =
      Utils.generate_group_field_schema_definitions(block_contents, caller)

    root_sub_schema_casts = Utils.generate_group_field_schema_casts(block_contents, nil)

    group_schema_changesets =
      Utils.generate_group_field_schema_changesets(block_contents, nil, caller)

    module =
      [
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
end
