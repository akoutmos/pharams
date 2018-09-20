defmodule Pharams.ErrorView do
  @moduledoc false

  @doc """
  Traverses changeset errors.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def render("errors.json", %Ecto.Changeset{} = changeset) do
    %{
      errors: translate_errors(changeset)
    }
  end
end
