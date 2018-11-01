defmodule ExamplesWeb.RegexValidator do
  @moduledoc """
  Some shared regex expressions
  """

  def zip_code, do: ~r/^\d{5}$/

  def phone_number, do: ~r/\d{7}/
end
