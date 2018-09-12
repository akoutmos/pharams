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

      def init(opts), do: IO.inspect(opts)

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

  defp generate_validation do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key false
      embedded_schema do
        field(:page, :integer)
        field(:rawr, :integer)
      end

      def changeset(schema, params) do
        schema
        |> cast(params, [:page, :rawr])
        |> validate_required([:page])
        |> validate_number(:page, greater_than: 0)
      end
    end
  end

  defmacro pharams(controller_action, do: _block) do
    camel_action =
      controller_action
      |> Atom.to_string()
      |> Macro.camelize()

    calling_module = __CALLER__.module

    # Create validation module
    validation_module_name = Module.concat([calling_module, PharamsValidator, camel_action])
    validation_module_ast = generate_validation()
    Module.create(validation_module_name, validation_module_ast, Macro.Env.location(__ENV__))

    # Create Plug module
    plug_module_name = Module.concat([calling_module, PharamsPlug, camel_action])
    plug_module_ast = generate_plug(validation_module_name, calling_module)
    Module.create(plug_module_name, plug_module_ast, Macro.Env.location(__ENV__))

    # Insert the validation plug
    quote do
      plug(unquote(plug_module_name) when var!(action) == unquote(controller_action))
    end
  end
end
