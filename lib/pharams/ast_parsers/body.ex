defmodule Pharams.ASTParsers.Body do
  @moduledoc """
  The module extracts and parses the body portion of the pharams
  block if it is available.
  """

  alias Pharams.ASTParsers.{Field, Utils}

  def parse(pharams_block, caller) do
    pharams_block
    |> Utils.find_block_in_ast(:body)
    |> case do
      {:body, _line, block} ->
        block
        |> Utils.extract_do_block()
        |> parse_body_block(caller)

      _ ->
        []
    end
  end

  defp parse_body_block(block, caller) do
    block
    |> Enum.map(fn field ->
      Field.parse(field, caller)
    end)
  end
end
