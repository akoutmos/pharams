defmodule Pharams.ValidationUtils do
  alias Pharams.Utils

  def generate_group_field_schema_changeset_entries(
        {_, _, [sub_schema_name, count, [do: {:__block__, [], block_contents}]]},
        parent
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
    root_validations = Utils.generate_basic_field_validations(block_contents)

    root_sub_schema_casts =
      Utils.generate_group_field_schema_casts(block_contents, changeset_root_name)

    group_schema_changesets =
      Utils.generate_group_field_schema_changesets(
        block_contents,
        changeset_root_name
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
        parent
      ) do
    generate_group_field_schema_changeset_entries(
      {required, line, [sub_schema_name, count, [do: {:__block__, [], [single_ast]}]]},
      parent
    )
  end

  def generate_group_field_schema_cast_entries(
        {required, _line, [field, _quantity, _opts]},
        parent
      ) do
    required = required == :required
    field_name = Atom.to_string(field)

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

  def generate_changeset_validation_entries({_, _, [field_name, _type, opts]}) do
    Enum.map(
      opts,
      fn
        # Ecto.Changeset.validate_acceptance
        {:acceptance, opts} ->
          generate_validate_acceptance(field_name, opts)

        # Ecto.Changeset.validate_exclusion
        {:change, [metadata, validator]} when is_tuple(validator) ->
          generate_validate_change(field_name, metadata, validator)

        {:change, validator} ->
          generate_validate_change(field_name, validator)

        # Ecto.Changeset.validate_confirmation
        {:confirmation, opts} ->
          generate_validate_confirmation(field_name, opts)

        # Ecto.Changeset.validate_exclusion
        {:exclusion, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_exclusion(field_name, data, opts)

        {:exclusion, data} ->
          generate_validate_exclusion(field_name, data, [])

        # Ecto.Changeset.validate_format
        {:format, [format, opts]} when is_list(format) and is_list(opts) ->
          generate_validate_format(field_name, format, opts)

        {:format, format} ->
          generate_validate_format(field_name, format, [])

        # Ecto.Changeset.validate_inclusion
        {:inclusion, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_inclusion(field_name, data, opts)

        {:inclusion, data} ->
          generate_validate_inclusion(field_name, data, [])

        # Ecto.Changeset.validate_length
        {:length, opts} ->
          generate_validate_length(field_name, opts)

        # Ecto.Changeset.validate_number
        {:number, opts} ->
          generate_validate_number(field_name, opts)

        # Ecto.Changeset.validate_subset
        {:subset, [data, opts]} when is_list(data) and is_list(opts) ->
          generate_validate_subset(field_name, data, opts)

        {:subset, data} ->
          generate_validate_subset(field_name, data, [])

        # Unsupported validation method
        _ ->
          nil
      end
    )
  end

  def generate_changeset_validation_entries({_, _, [_field_name, _type]}) do
    nil
  end

  defp generate_validate_acceptance(field_name, opts) do
    "|> validate_acceptance(#{inspect(field_name)}, #{inspect(opts)})"
  end

  defp generate_validate_change(field_name, validator) do
    validator = Macro.to_string(validator)

    "|> validate_change(#{inspect(field_name)}, #{validator})"
  end

  defp generate_validate_change(field_name, metadata, validator) do
    validator = Macro.to_string(validator)

    "|> validate_change(#{inspect(field_name)}, #{inspect(metadata)}, #{validator})"
  end

  defp generate_validate_confirmation(field_name, opts) do
    "|> validate_confirmation(#{inspect(field_name)}, #{inspect(opts)})"
  end

  defp generate_validate_exclusion(field_name, data, opts) when is_tuple(data) do
    data = Macro.to_string(data)

    "|> validate_exclusion(#{inspect(field_name)}, #{data}, #{inspect(opts)})"
  end

  defp generate_validate_exclusion(field_name, data, opts) do
    "|> validate_exclusion(#{inspect(field_name)}, #{inspect(data)}, #{inspect(opts)})"
  end

  defp generate_validate_format(field_name, format, opts) do
    format =
      format
      |> Macro.to_string()
      |> Macro.unescape_string()

    "|> validate_format(#{inspect(field_name)}, #{format}, #{inspect(opts)})"
  end

  defp generate_validate_inclusion(field_name, data, opts) when is_tuple(data) do
    data = Macro.to_string(data)

    "|> validate_inclusion(#{inspect(field_name)}, #{data}, #{inspect(opts)})"
  end

  defp generate_validate_inclusion(field_name, data, opts) do
    "|> validate_inclusion(#{inspect(field_name)}, #{inspect(data)}, #{inspect(opts)})"
  end

  defp generate_validate_length(field_name, opts) do
    "|> validate_length(#{inspect(field_name)}, #{inspect(opts)})"
  end

  defp generate_validate_number(field_name, opts) do
    "|> validate_number(#{inspect(field_name)}, #{inspect(opts)})"
  end

  defp generate_validate_subset(field_name, data, opts) when is_tuple(data) do
    data = Macro.to_string(data)

    "|> validate_subset(#{inspect(field_name)}, #{data}, #{inspect(opts)})"
  end

  defp generate_validate_subset(field_name, data, opts) do
    "|> validate_subset(#{inspect(field_name)}, #{inspect(data)}, #{inspect(opts)})"
  end
end