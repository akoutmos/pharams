defmodule Pharams.ASTParsers.Path do
  @moduledoc """
  The module extracts and parses the path portion of the pharams
  block if it is available.
  """

  alias Pharams.ASTParsers.Utils

  def parse(pharams_block, caller) do
    pharams_block
    |> Utils.find_block_in_ast(:path)
    |> case do
      {:path, _line, thing} ->
        [path: 1]

      _ ->
        []
    end
  end
end
