defmodule Pharams.SchemaUtils do
  def generate_schema_entry({_, _, [field_name, type, opts]}) do
    default = Keyword.get(opts, :default)

    if default do
      "field(#{inspect(field_name)}, #{normalize_field_type(type)}, default: #{inspect(default)})"
    else
      "field(#{inspect(field_name)}, #{normalize_field_type(type)})"
    end
  end

  defp normalize_field_type({:__aliases__, _line_info, module_type}) do
    "#{inspect(Module.concat(module_type))}"
  end

  defp normalize_field_type(type), do: "#{inspect(type)}"
end
