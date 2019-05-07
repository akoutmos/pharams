defmodule Pharams.ASTParsers.Field do
  @moduledoc """
  This module generates a simple or compound field
  struct depending on the AST passed in.
  """

  alias Pharams.ASTParsers.Utils
  alias Pharams.Types.{CompoundField, Function, FunctionRef, Maybe, SimpleField}

  @doc """
  Parse a field entry and extract if it is required or not
  """
  def parse({status, opts, required_field_details}, caller) when status in [:required, :req] do
    required_field_details
    |> parse_required_field(caller)
    |> case do
      {:ok, field} ->
        field

      {:error, message} ->
        mod_line = Utils.generate_module_line_number(caller, opts)
        raise "Error at #{mod_line}: #{message}"
    end
  end

  def parse({status, _opts, optional_field_details}, caller) when status in [:optional, :opt] do
    parse_optional_field(optional_field_details, caller)
  end

  def parse({status, opts, _field_details}, caller) do
    mod_line = Utils.generate_module_line_number(caller, opts)

    raise "Invalid field defined at #{mod_line} starting with: #{status}"
  end

  # -------- Required field functions --------
  defp parse_required_field([field_name, cardinality, [do: {:__block__, _opts, complex_block}]], caller)
       when cardinality in [:many, :one]
       when is_atom(field_name) do
    complex_field = %CompoundField{
      name: field_name,
      cardinality: cardinality,
      required: true,
      fields: Enum.map(complex_block, fn field -> parse(field, caller) end)
    }

    {:ok, complex_field}
  end

  defp parse_required_field([field_name, cardinality, [do: _complex_block]], caller) when is_atom(field_name) do
    {:error, "Compound field #{inspect(field_name)} has invalid cardinality value of #{inspect(cardinality)}"}
  end

  defp parse_required_field([field_name, cardinality, [do: _complex_block]], caller) do
    {:error, "Compound field #{inspect(field_name)} is not a valid atom"}
  end

  defp parse_required_field([field_name, type], caller) do
    simple_field = %SimpleField{
      name: field_name,
      type: type,
      required: true
    }

    {:ok, simple_field}
  end

  defp parse_required_field([field_name, type, opts], caller) do
    normalized_opts = normalize_opts(opts, caller)

    simple_field = %SimpleField{
      name: field_name,
      type: type,
      required: true,
      description: get_description(normalized_opts),
      default: get_default(normalized_opts),
      validators: get_validators(normalized_opts)
    }

    {:ok, simple_field}
  end

  # -------- Optional field functions --------
  defp parse_optional_field(_, _caller) do
    {:ok, nil}
  end

  # -------- Helper functions --------
  defp get_default(normalized_opts) do
    normalized_opts
    |> Keyword.get(:default)
    |> case do
      nil -> %Maybe{}
      value -> Maybe.build(value)
    end
  end

  defp get_description(normalized_opts) do
    Keyword.get(normalized_opts, :description)
  end

  defp get_validators(normalized_opts) do
    normalized_opts
    |> Enum.filter(fn {key, _val} ->
      # TODO: This should go elsewhere
      key in ~w(
        acceptance
        change
        confirmation
        exclusion
        format
        inclusion
        length
        number
        subset
      )a
    end)
  end

  defp normalize_opts(opts, caller) do
    opts
    |> Enum.map(fn val ->
      normalize_opt(val, caller)
    end)
  end

  defp normalize_opt({{:., _opts, [mod_alias, function]}, _opts, args}, caller) do
    %Function{
      module: mod_alias,
      function: function,
      args: normalize_opts(args, caller)
    }
  end

  defp normalize_opt({:&, _, [{:/, _, [{{:., _, [mod_alias, function]}, _, _}, arity]}]}, caller) do
    %FunctionRef{
      module: mod_alias,
      function: function,
      arity: arity
    }
  end

  defp normalize_opt({key, val}, caller) do
    {key, normalize_opt(val, caller)}
  end

  defp normalize_opt(val, caller) when is_list(val) do
    val
    |> Enum.map(fn entry ->
      normalize_opt(entry, caller)
    end)
  end

  defp normalize_opt(val, caller) do
    Macro.expand(val, caller)
  end
end
