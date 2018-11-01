defmodule ExamplesWeb.Functions do
  @moduledoc """
  Some shared validation functions
  """

  def bar_validator(:bar, bar) do
    if bar == "bar" do
      [bar: "cannot be bar"]
    else
      []
    end
  end
end
