defmodule Pharams.ValidationUtils do
  @moduledoc false

  alias Pharams.Utils

  def generate_group_field_schema_changeset_entries(
        {_, _, [sub_schema_name, _count, [do: {:__block__, [], block_contents}]]},
        parent,
        caller
      ) do
    schema_name = Atom.to_string(sub_schema_name)

    changeset_root_name =
      if parent do
        "#{parent}_#{schema_name}"
      else
        "#{schema_name}"
      end

    root_fields = Utils.get_all_basic_fields(block_contents)
    root_required_fields = Utils.get_required_basic_fields(block_contents)
    root_validations = Utils.generate_basic_field_validations(block_contents, caller)

    root_sub_schema_casts =
      Utils.generate_group_field_schema_casts(block_contents, changeset_root_name)

    group_schema_changesets =
      Utils.generate_group_field_schema_changesets(
        block_contents,
        changeset_root_name,
        caller
      )

    [
      "def #{changeset_root_name}_changeset(schema, params) do",
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
  end

  def generate_group_field_schema_changeset_entries(
        {required, line, [sub_schema_name, count, [do: single_ast]]},
        parent,
        caller
      ) do
    generate_group_field_schema_changeset_entries(
      {required, line, [sub_schema_name, count, [do: {:__block__, [], [single_ast]}]]},
      parent,
      caller
    )
  end

  def generate_group_field_schema_changeset_entries(_, _parent, _caller), do: []

  def generate_group_field_schema_cast_entries(
        {required, _line, [field, _quantity, opts]},
        parent
      )
      when is_list(opts) do
    required = required == :required

    changeset_root_name =
      if parent do
        "#{parent}_#{field}"
      else
        "#{field}"
      end

    "|> cast_embed(#{inspect(field)}, with: &#{changeset_root_name}_changeset/2, required: #{
      required
    })"
  end

  def generate_group_field_schema_cast_entries(
        {required, _line, [field, _quantity, opts]},
        _parent
      )
      when is_tuple(opts) do
    required = required == :required

    "|> cast_embed(#{inspect(field)}, required: #{required})"
  end

  def generate_changeset_validation_entries({_, _, [field_name, _type, opts]}, caller) do
    field_name = Macro.to_string(field_name)

    Enum.map(
      opts,
      fn
        # Ecto.Changeset.validate_acceptance
        {:acceptance, opts} ->
          generate_validate_acceptance(field_name, opts, caller)

        # Ecto.Changeset.validate_exclusion
        {:change, [metadata, validator]} when is_tuple(validator) ->
          generate_validate_change(field_name, metadata, validator, caller)

        {:change, validator} ->
          generate_validate_change(field_name, validator, caller)

        # Ecto.Changeset.validate_confirmation
        {:confirmation, opts} ->
          generate_validate_confirmation(field_name, opts, caller)

        # Ecto.Changeset.validate_exclusion
        {:exclusion, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_exclusion(field_name, data, opts, caller)

        {:exclusion, data} ->
          generate_validate_exclusion(field_name, data, [], caller)

        # Ecto.Changeset.validate_format
        # FIXME This doesn't look right is_list ?
        {:format, [format, opts]} when is_list(format) and is_list(opts) ->
          generate_validate_format(field_name, format, opts, caller)

        {:format, format} ->
          generate_validate_format(field_name, format, [], caller)

        # Ecto.Changeset.validate_inclusion
        {:inclusion, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_inclusion(field_name, data, opts, caller)

        {:inclusion, data} ->
          generate_validate_inclusion(field_name, data, [], caller)

        # Ecto.Changeset.validate_length
        {:length, opts} ->
          generate_validate_length(field_name, opts, caller)

        # Ecto.Changeset.validate_number
        {:number, opts} ->
          generate_validate_number(field_name, opts, caller)

        # Ecto.Changeset.validate_subset
        {:subset, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_subset(field_name, data, opts, caller)

        {:subset, data} ->
          generate_validate_subset(field_name, data, [], caller)

        # Unsupported validation method
        _ ->
          nil
      end
    )
  end

  def generate_changeset_validation_entries({_, _, [_field_name, _type]}, _caller) do
    nil
  end

  defp generate_validate_acceptance(field_name, opts, caller) do
    opts = normalize_opts(opts, caller)

    "|> validate_acceptance(#{field_name}, #{opts})"
  end

  defp generate_validate_change(field_name, validator, caller) do
    validator = normalize_opt(validator, caller)

    "|> validate_change(#{field_name}, #{validator})"
  end

  defp generate_validate_change(field_name, metadata, validator, caller) do
    metadata = Macro.to_string(metadata)
    validator = normalize_opt(validator, caller)

    "|> validate_change(#{field_name}, #{metadata}, #{validator})"
  end

  defp generate_validate_confirmation(field_name, opts, caller) do
    "|> validate_confirmation(#{field_name}, #{normalize_opts(opts, caller)})"
  end

  defp generate_validate_exclusion(field_name, data, opts, caller) do
    data = normalize_opt(data, caller)
    opts = normalize_opts(opts, caller)

    "|> validate_exclusion(#{field_name}, #{data}, #{opts})"
  end

  defp generate_validate_format(field_name, format, opts, caller) do
    format = normalize_opt(format, caller)
    opts = normalize_opts(opts, caller)

    "|> validate_format(#{field_name}, #{format}, #{opts})"
  end

  defp generate_validate_inclusion(field_name, data, opts, caller) do
    data = normalize_opt(data, caller)
    opts = normalize_opts(opts, caller)

    "|> validate_inclusion(#{field_name}, #{data}, #{opts})"
  end

  defp generate_validate_length(field_name, opts, caller) do
    opts = normalize_opts(opts, caller)

    "|> validate_length(#{field_name}, #{opts})"
  end

  defp generate_validate_number(field_name, opts, caller) do
    opts = normalize_opts(opts, caller)

    "|> validate_number(#{field_name}, #{opts})"
  end

  defp generate_validate_subset(field_name, data, opts, caller) do
    data = normalize_opt(data, caller)
    opts = normalize_opts(opts, caller)

    "|> validate_subset(#{field_name}, #{data}, #{opts})"
  end

  defp normalize_opts(opts, caller) do
    normalized_opts =
      opts
      |> Enum.map(fn {opt_key, opt_val} ->
        "#{opt_key}: #{normalize_opt(opt_val, caller)}"
      end)
      |> Enum.join(", ")

    "[#{normalized_opts}]"
  end

  defp normalize_opt(
         {{:., _, [{:__aliases__, _, _module} = mod_alias, function]}, _, []},
         caller
       ) do
    func_call =
      mod_alias
      |> Macro.expand(caller)
      |> Macro.to_string()
      |> Module.concat(function)

    "#{func_call}()"
  end

  defp normalize_opt(
         {:&, _,
          [{:/, _, [{{:., _, [{:__aliases__, _, _module} = mod_alias, function]}, _, []}, arity]}]},
         caller
       ) do
    func_call =
      mod_alias
      |> Macro.expand(caller)
      |> Macro.to_string()
      |> Module.concat(function)

    "&#{func_call}/#{arity}"
  end

  defp normalize_opt(opt, _caller) do
    opt
    |> Macro.to_string()
    |> Macro.unescape_string()
  end
end
