defmodule Pharams do
  @moduledoc """
  Functions and macros for validating requests to Phoenix
  Controllers.
  """

  alias Pharams.{ASTParsers.Root, PlugUtils, Utils, ValidationUtils}

  defmacro __using__(opts) do
    key_type = Keyword.get(opts, :key_type, :atom)
    drop_nil_fields = Keyword.get(opts, :drop_nil_fields, false)
    error_module = Keyword.get(opts, :view_module, Pharams.ErrorView)
    error_template = Keyword.get(opts, :view_template, "body_errors.json")
    error_status = Keyword.get(opts, :error_status, :unprocessable_entity)

    quote do
      import Pharams, only: [pharams: 2, pharams: 3]

      def pharams_key_type, do: unquote(key_type)
      def pharams_drop_nil_fields?, do: unquote(drop_nil_fields)
      def pharams_error_view_module, do: unquote(error_module)
      def pharams_error_view_template, do: unquote(error_template)
      def pharams_error_status, do: unquote(error_status)
    end
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
    # Create validation module
    Root.parse(controller_action, block, __CALLER__)
    ValidationUtils.create_validation_module(controller_action, block, __ENV__, __CALLER__)

    # Create plug module
    plug_module_name = PlugUtils.generate_plug_module_name(controller_action, __CALLER__)
    PlugUtils.create_plug_module(controller_action, __ENV__, __CALLER__)

    # Insert the validation plug into the controller
    quote do
      plug(unquote(plug_module_name) when var!(action) == unquote(controller_action))
    end
  end

  defmacro pharams(controller_action, opts, do: block) do
    # Create validation module
    Root.parse(controller_action, block, __CALLER__, opts)
    ValidationUtils.create_validation_module(controller_action, block, __ENV__, __CALLER__)

    # Create plug module
    plug_module_name = PlugUtils.generate_plug_module_name(controller_action, __CALLER__)
    PlugUtils.create_plug_module(controller_action, __ENV__, __CALLER__)

    # Insert the validation plug into the controller
    quote do
      plug(
        unquote(plug_module_name),
        unquote(opts) when var!(action) == unquote(controller_action)
      )
    end
  end
end
