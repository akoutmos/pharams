defmodule Pharams.ErrorView do
  @moduledoc false

  @doc """
  Error view is used to display errors found with body params
  """
  def render("body_errors.json", %Ecto.Changeset{} = changeset) do
    %{
      description: "Invalid body parameter(s)",
      errors: translate_errors(changeset)
    }
  end

  @doc """
  Error view is used to display errors found with query params
  """
  def render("query_errors.json", %Ecto.Changeset{} = changeset) do
    %{
      description: "Invalid query parameter(s)",
      errors: translate_errors(changeset)
    }
  end

  @doc """
  Error view is used to display errors found with path params
  """
  def render("path_errors.json", %Ecto.Changeset{} = changeset) do
    %{
      description: "Invalid path parameter(s)",
      errors: translate_errors(changeset)
    }
  end

  defp translate_errors(changeset) do
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
end
