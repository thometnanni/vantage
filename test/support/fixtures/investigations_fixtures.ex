defmodule Vantage.InvestigationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vantage.Investigations` context.
  """

  @doc """
  Generate a investigation.
  """
  def investigation_fixture(attrs \\ %{}) do
    {:ok, investigation} =
      attrs
      |> Enum.into(%{
        description: "some description",
        latitude: 120.5,
        longitude: 120.5,
        name: "some name",
        time: ~U[2024-12-04 10:13:00.000000Z]
      })
      |> Vantage.Investigations.create_investigation()

    investigation
  end
end
