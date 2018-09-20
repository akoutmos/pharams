defmodule Pharams do
  @moduledoc """
  Functions and macros for validating requests to Phoenix
  Controllers.
  """

  alias Pharams.Utils

  @doc """
  Takes a nested struct data structure and turns it into a map
  """
  def pharams_schema_to_map(map) when is_map(map) do
    map
    |> Map.from_struct()
    |> Enum.map(fn
      {key, %{__struct__: _} = value} ->
        {key, pharams_schema_to_map(value)}

      {key, val} when is_list(val) ->
        {key,
         Enum.map(val, fn entry ->
           pharams_schema_to_map(entry)
         end)}

      key_val ->
        key_val
    end)
    |> Map.new()
  end

  def pharams_schema_to_map(val) do
    val
  end

  defmacro __using__(opts) do
    error_module = Keyword.get(opts, :view_module, Pharams.ErrorView)
    error_template = Keyword.get(opts, :view_template, "errors.json")
    error_status = Keyword.get(opts, :error_status, :unprocessable_entity)

    quote do
      import Pharams, only: [pharams: 2]

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
        changeset = validation_module.changeset(struct(validation_module), conn.params)

        if changeset.valid? do
          new_params =
            changeset
            |> apply_changes()
            |> Pharams.pharams_schema_to_map()

          %{conn | params: new_params}
        else
          controller_module = unquote(controller_module)

          view_module = controller_module.pharams_error_view_module
          view_template = controller_module.pharams_error_view_template
          error_status = controller_module.pharams_error_status

          conn
          |> put_status(error_status)
          |> render(view_module, view_template, changeset)
          |> halt()
        end
      end
    end
  end

  defp generate_validation({:__block__, [], block_contents}) do
    root_field_declarations = Utils.generate_basic_field_schema_definitions(block_contents)
    root_fields = Utils.get_all_basic_fields(block_contents)
    root_required_fields = Utils.get_required_basic_fields(block_contents)
    root_validations = Utils.generate_basic_field_validations(block_contents)

    root_group_declarations = Utils.generate_group_field_schema_definitions(block_contents)
    root_sub_schema_casts = Utils.generate_group_field_schema_casts(block_contents)
    group_schema_changesets = Utils.generate_group_field_schema_changesets(block_contents)

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
      |> Enum.join("\n")

    Code.string_to_quoted!(module)
  end

  defp generate_validation(ast) do
    generate_validation({:__block__, [], [ast]})
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
    validation_module_ast = generate_validation(block)
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
