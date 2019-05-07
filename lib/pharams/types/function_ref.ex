defmodule Pharams.Types.FunctionRef do
  @moduledoc """
  This module is responsible for parsing functions and creating structs which
  can later on be used in generated modules.
  """

  @enforce_keys ~w(module function arity)a

  defstruct module: nil,
            function: nil,
            arity: nil
end
