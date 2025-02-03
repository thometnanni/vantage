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
        time: ~U[2025-02-02 15:37:00.000000Z]
      })
      |> Vantage.Investigations.create_investigation()

    investigation
  end

  @doc """
  Generate a investigation_collaborator.
  """
  def investigation_collaborator_fixture(attrs \\ %{}) do
    {:ok, investigation_collaborator} =
      attrs
      |> Enum.into(%{
        role: "some role"
      })
      |> Vantage.Investigations.create_investigation_collaborator()

    investigation_collaborator
  end
end
