defmodule Pharams.ErrorView do
  @moduledoc false

  @doc """
  Traverses changeset errors.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        try do
          String.replace(acc, "%{#{key}}", to_string(value))
        rescue
          _err -> String.replace(acc, "%{#{key}}", "#{inspect(value)}")
        end
      end)
    end)
  end

  def render("errors.json", %Ecto.Changeset{} = changeset) do
    %{
      errors: translate_errors(changeset)
    }
  end
end
