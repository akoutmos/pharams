defmodule Pharams.Types.Maybe do
  @moduledoc """
  This module defines a struct which can be used as a very simple monad to
  differentiate between nil and no value.
  """

  alias __MODULE__

  defstruct id: :nothing,
            value: nil

  @doc """
  Generate a Maybe struct with a value
  """
  def build(value) do
    %Maybe{id: :just, value: value}
  end
end
