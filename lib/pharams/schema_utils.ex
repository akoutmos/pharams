defmodule Pharams.SchemaUtils do
  @moduledoc false

  alias Pharams.Utils

  def generate_schema_entry(
        {_, _, [sub_schema_name, :many, [do: {:__block__, [], block_contents}]]},
        caller
      ) do
    module_name =
      sub_schema_name
      |> Atom.to_string()
      |> Macro.camelize()

    [
      "embeds_many #{inspect(sub_schema_name)}, #{module_name}, primary_key: false do",
      Utils.generate_basic_field_schema_definitions(block_contents, caller),
      Utils.generate_group_field_schema_definitions(block_contents, caller),
      "end"
    ]
    |> List.flatten()
  end

  def generate_schema_entry(
        {_, _, [sub_schema_name, :one, [do: {:__block__, [], block_contents}]]},
        caller
      ) do
    module_name =
      sub_schema_name
      |> Atom.to_string()
      |> Macro.camelize()

    [
      "embeds_one #{inspect(sub_schema_name)}, #{module_name}, primary_key: false  do",
      Utils.generate_basic_field_schema_definitions(block_contents, caller),
      Utils.generate_group_field_schema_definitions(block_contents, caller),
      "end"
    ]
    |> List.flatten()
  end

  def generate_schema_entry({required, line, [sub_schema_name, count, [do: single_ast]]}, caller) do
    generate_schema_entry(
      {required, line, [sub_schema_name, count, [do: {:__block__, [], [single_ast]}]]},
      caller
    )
  end

  def generate_schema_entry({_, _, [field_name, type, opts]}, caller) when is_list(opts) do
    default = Keyword.get(opts, :default)

    if default != nil do
      "field(#{inspect(field_name)}, #{normalize_field_type(type, caller)}, default: #{
        inspect(default)
      })"
    else
      "field(#{inspect(field_name)}, #{normalize_field_type(type, caller)})"
    end
  end

  def generate_schema_entry({_, _, [sub_schema_name, :one, opts]}, caller) when is_tuple(opts) do
    module_name = normalize_field_type(opts, caller)

    "embeds_one #{inspect(sub_schema_name)}, #{module_name}"
  end

  def generate_schema_entry({_, _, [sub_schema_name, :many, opts]}, caller) when is_tuple(opts) do
    module_name = normalize_field_type(opts, caller)

    "embeds_many #{inspect(sub_schema_name)}, #{module_name}"
  end

  def generate_schema_entry({_, _, [field_name, type]}, caller) do
    "field(#{inspect(field_name)}, #{normalize_field_type(type, caller)})"
  end

  defp normalize_field_type({:__aliases__, _line_info, _module_type} = alias_field, caller) do
    Macro.expand(alias_field, caller)
  end

  defp normalize_field_type(
         {type, {:__aliases__, _line_info, _module_type} = alias_field},
         caller
       ) do
    Macro.to_string({type, Macro.expand(alias_field, caller)})
  end

  defp normalize_field_type(type, _caller) do
    "#{inspect(type)}"
  end
end
