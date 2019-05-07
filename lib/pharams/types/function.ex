defmodule Pharams.Types.Function do
  @moduledoc """
  This module is responsible for parsing function s and creating structs which
  can later on be used in generated modules.
  """

  @enforce_keys ~w(module function args)a

  defstruct module: nil,
            function: nil,
            args: []
end
