defmodule Pharams.ASTParsers.Query do
  @moduledoc """
  The module extracts and parses the query portion of the pharams
  block if it is available.
  """

  alias Pharams.ASTParsers.Utils

  def parse(pharams_block, caller) do
    pharams_block
    |> Utils.find_block_in_ast(:query)
    |> case do
      {:query, _line, thing} ->
        [query: 1]

      _ ->
        []
    end
  end
end
