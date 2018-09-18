defmodule Pharams do
  @moduledoc """
  Documentation for Pharams.
  """

  def recusrive_map_from_struct(map) do
    map
    |> Map.from_struct()
    |> Enum.map(fn
      {key, %{__struct__: _} = value} -> {key, recusrive_map_from_struct(value)}
      key_val -> key_val
    end)
    |> Map.new()
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
            |> Pharams.recusrive_map_from_struct()

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
    IO.inspect(block_contents)

    {basic_fields, group_fields} =
      Enum.split_with(block_contents, fn {_req, _line, [_field, _type, opts]} ->
        not Keyword.has_key?(opts, :do)
      end)
      |> IO.inspect(label: "Fields")

    root_field_declarations = Enum.map(basic_fields, &Pharams.SchemaUtils.generate_schema_entry/1)

    root_fields =
      Enum.map(basic_fields, fn {_req, _line, [field, _type, _opts]} ->
        field
      end)

    root_required_fields =
      basic_fields
      |> Enum.filter(fn
        {:required, _line, [_field, _type, opts]} when is_list(opts) -> true
        _ -> false
      end)
      |> Enum.map(fn {_req, _line, [field, _type, _opts]} ->
        field
      end)

    root_validations =
      basic_fields
      |> Enum.map(&Pharams.ValidationUtils.generate_changeset_validation_entries/1)
      |> List.flatten()
      |> Enum.reject(fn entry -> entry == nil end)

    root_sub_schema_casts = []
    # Enum.map(group_fields, fn ->
    #  nil
    # end)

    group_schema_changesets = []
    root_group_declarations = []

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

    module
    |> Code.format_string!()
    |> IO.puts()

    module
    |> Code.string_to_quoted!()
  end

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
