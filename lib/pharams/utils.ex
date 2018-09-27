defmodule Pharams.Utils do
  @moduledoc false

  alias Pharams.{SchemaUtils, ValidationUtils}

  def split_basic_and_group_fields(ast) do
    Enum.split_with(ast, fn
      {_req, _line, [_field, _type, opts]} when is_list(opts) ->
        not Keyword.has_key?(opts, :do)

      {_req, _line, [_field, _type, opts]} when is_tuple(opts) ->
        false

      {_req, _line, [_field, _type]} ->
        true
    end)
  end

  def get_basic_field_asts(ast) do
    {basic_fields, _group_fields} = split_basic_and_group_fields(ast)

    basic_fields
  end

  def get_group_field_asts(ast) do
    {_basic_fields, group_fields} = split_basic_and_group_fields(ast)

    group_fields
  end

  def get_all_basic_fields(ast) do
    ast
    |> get_basic_field_asts()
    |> Enum.map(fn
      {_req, _line, [field, _type, _opts]} ->
        field

      {_req, _line, [field, _type]} ->
        field
    end)
  end

  def get_required_basic_fields(ast) do
    ast
    |> get_basic_field_asts()
    |> Enum.filter(fn
      {:required, _line, [_field, _type, opts]} when is_list(opts) -> true
      {:required, _line, [_field, _type]} -> true
      _ -> false
    end)
    |> Enum.map(fn
      {_req, _line, [field, _type, _opts]} ->
        field

      {_req, _line, [field, _type]} ->
        field
    end)
  end

  def generate_basic_field_schema_definitions(ast) do
    ast
    |> get_basic_field_asts()
    |> Enum.map(&SchemaUtils.generate_schema_entry/1)
  end

  def generate_group_field_schema_definitions(ast) do
    ast
    |> get_group_field_asts()
    |> Enum.map(&SchemaUtils.generate_schema_entry/1)
  end

  def generate_group_field_schema_casts(ast, parent \\ nil) do
    ast
    |> get_group_field_asts()
    |> Enum.map(fn entry ->
      ValidationUtils.generate_group_field_schema_cast_entries(entry, parent)
    end)
  end

  def generate_group_field_schema_changesets(ast, parent \\ nil) do
    ast
    |> get_group_field_asts()
    |> Enum.map(fn entry ->
      ValidationUtils.generate_group_field_schema_changeset_entries(entry, parent)
    end)
  end

  def generate_basic_field_validations(ast) do
    ast
    |> get_basic_field_asts()
    |> Enum.map(&ValidationUtils.generate_changeset_validation_entries/1)
    |> List.flatten()
    |> Enum.reject(fn entry -> entry == nil end)
  end
end
