defmodule Vantage.ProjectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vantage.Projections` context.
  """

  @doc """
  Generate a projection.
  """
  def projection_fixture(attrs \\ %{}) do
    {:ok, projection} =
      attrs
      |> Enum.into(%{
        file: "some file",
        name: "some name",
        orthographic: true,
        time: 120.5
      })
      |> Vantage.Projections.create_projection()

    projection
  end
end
