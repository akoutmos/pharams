defmodule Pharams.ASTParsers.Root do
  @moduledoc """
  This module parses the root of the pharams definition block AST,
  creates the required struct and does some error checking.
  """

  alias Pharams.Types.EndpointDefinition
  alias Pharams.ASTParsers.{Body, Path, Query, Utils}

  @valid_root_elements ~w(description path query body output)a

  @doc """
  The parse function is the entry point of turning a pharams ast block
  into the required struct representation. This struct will then be used
  to generate the necessary validation module, validation plug, swagger docs,
  and json schema validator used for test assertions.
  """
  def parse(controller_function, pharams_block, caller, opts \\ [])

  def parse(controller_function, {:__block__, [], pharams_block}, caller, opts) do
    check_for_invalid_keywords(pharams_block, caller)

    # Expand all aliases so that the individual parses don't have to
    # TODO: Move this to a utility module
    pharams_block =
      pharams_block
      |> Macro.prewalk(fn
        {:__aliases__, opts, _module_def} = alias_def ->
          expanded_alias =
            alias_def
            |> Macro.expand(caller)
            |> Module.split()
            |> Enum.map(&String.to_atom/1)

          {:__alias__, opts, expanded_alias}

        node ->
          node
      end)

    %EndpointDefinition{
      description: get_description(pharams_block, caller),
      controller_module: caller.module,
      controller_function: controller_function,
      key_type: get_key_type_opt(opts, caller),
      drop_nil_fields: get_drop_nil_fields_opts(opts, caller),
      error_view_module: get_error_view_module_opt(opts, caller),
      error_view_template: get_error_view_template_opt(opts, caller),
      error_status: get_error_status_opt(opts, caller),
      path_fields: Path.parse(pharams_block, caller),
      query_fields: Query.parse(pharams_block, caller),
      body_fields: Body.parse(pharams_block, caller),
      output_definitions: []
    }
    |> IO.inspect(label: "ENDPOINT DEFINITION")
  end

  def parse(controller_function, block, caller, opts) do
    parse(controller_function, {:__block__, [], [block]}, caller, opts)
  end

  defp get_description(pharams_block, caller) do
    pharams_block
    |> Utils.find_block_in_ast(:description)
    |> case do
      {:description, _line, [description]} ->
        description

      _ ->
        calling_module = Utils.get_calling_module(caller)
        line = caller.line
        raise "Pharams block starting at #{calling_module}:#{line} requires a description field."
    end
  end

  def get_key_type_opt(opts, caller) do
    Keyword.get(opts, :key_type, :controller_defined)
  end

  def get_drop_nil_fields_opts(opts, caller) do
    Keyword.get(opts, :drop_nil_fields, :controller_defined)
  end

  def get_error_view_module_opt(opts, caller) do
    Keyword.get(opts, :view_module, :controller_defined)
  end

  def get_error_view_template_opt(opts, caller) do
    Keyword.get(opts, :view_template, :controller_defined)
  end

  def get_error_status_opt(opts, caller) do
    Keyword.get(opts, :error_status, :controller_defined)
  end

  defp check_for_invalid_keywords(pharams_block, caller) do
    pharams_block
    |> Enum.each(fn ast_node ->
      block = Utils.get_block_from_ast(ast_node)

      if block not in @valid_root_elements do
        string_keyword = Atom.to_string(block)
        string_line_number = Utils.get_line_number_from_ast(ast_node)
        calling_module = Utils.get_calling_module(caller)

        raise "Invalid Pharams macro block. Block \"#{block}\" found at #{calling_module}:#{string_line_number} is not permitted at the root of a Pharams block."
      end
    end)
  end
end
