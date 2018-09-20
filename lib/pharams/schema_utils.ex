defmodule Pharams.SchemaUtils do
  @moduledoc false

  alias Pharams.Utils

  def generate_schema_entry(
        {_, _, [sub_schema_name, :many, [do: {:__block__, [], block_contents}]]}
      ) do
    module_name =
      sub_schema_name
      |> Atom.to_string()
      |> Macro.camelize()

    [
      "embeds_many #{inspect(sub_schema_name)}, #{module_name}, primary_key: false do",
      Utils.generate_basic_field_schema_definitions(block_contents),
      Utils.generate_group_field_schema_definitions(block_contents),
      "end"
    ]
    |> List.flatten()
  end

  def generate_schema_entry(
        {_, _, [sub_schema_name, :one, [do: {:__block__, [], block_contents}]]}
      ) do
    module_name =
      sub_schema_name
      |> Atom.to_string()
      |> Macro.camelize()

    [
      "embeds_one #{inspect(sub_schema_name)}, #{module_name}, primary_key: false  do",
      Utils.generate_basic_field_schema_definitions(block_contents),
      Utils.generate_group_field_schema_definitions(block_contents),
      "end"
    ]
    |> List.flatten()
  end

  def generate_schema_entry({required, line, [sub_schema_name, count, [do: single_ast]]}) do
    generate_schema_entry(
      {required, line, [sub_schema_name, count, [do: {:__block__, [], [single_ast]}]]}
    )
  end

  def generate_schema_entry({_, _, [field_name, type, opts]}) do
    default = Keyword.get(opts, :default)

    if default do
      "field(#{inspect(field_name)}, #{normalize_field_type(type)}, default: #{inspect(default)})"
    else
      "field(#{inspect(field_name)}, #{normalize_field_type(type)})"
    end
  end

  def generate_schema_entry({_, _, [field_name, type]} = thing) do
    "field(#{inspect(field_name)}, #{normalize_field_type(type)})"
  end

  defp normalize_field_type({:__aliases__, _line_info, module_type}) do
    "#{inspect(Module.concat(module_type))}"
  end

  defp normalize_field_type(type), do: "#{inspect(type)}"
end
