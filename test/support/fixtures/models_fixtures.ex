defmodule Vantage.ModelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vantage.Models` context.
  """

  @doc """
  Generate a model.
  """
  def model_fixture(attrs \\ %{}) do
    {:ok, model} =
      attrs
      |> Enum.into(%{
        file: "some file",
        name: "some name"
      })
      |> Vantage.Models.create_model()

    model
  end
end
