defmodule Pharams.ASTParsers.Utils do
  @moduledoc """
  General utils used across all the parsers
  """

  @doc """
  Get the block portion of an AST node
  """
  def get_block_from_ast(ast), do: elem(ast, 0)

  @doc """
  Get the line number if it is available in the AST node
  """
  def get_line_number_from_ast(ast) do
    ast
    |> elem(1)
    |> get_line_number_from_opts()
  end

  @doc """
  Get the line number if it is available in options
  """
  def get_line_number_from_opts(opts) do
    opts
    |> Keyword.get(:line, 0)
    |> Integer.to_string()
  end

  @doc """
  """
  def generate_module_line_number(%Macro.Env{} = caller, opts) do
    "#{get_calling_module(caller)}:#{get_line_number_from_opts(opts)}"
  end

  @doc """
  Given a Macro Env struct extract the calling module
  """
  def get_calling_module(%Macro.Env{} = caller) do
    caller.module
    |> Atom.to_string()
    |> String.replace_leading("Elixir.", "")
  end

  @doc """
  Find a particular block in the provided AST node
  """
  def find_block_in_ast(block_contents, identifier) do
    block_contents
    |> Enum.find(:not_found, fn ast_node ->
      get_block_from_ast(ast_node) == identifier
    end)
  end

  @doc """
  Given an AST node it looks for the shallowest "do" block in the tree
  and returns that
  TODO: This should be more robust
  """
  def extract_do_block([[do: do_block]]) do
    {:__block__, _opts, block_contents} = do_block

    block_contents
  end
end
