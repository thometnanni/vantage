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
        layers: ["option1", "option2"],
        name: "some name",
        orthographic: true,
        time: 120.5,
        type: "some type"
      })
      |> Vantage.Projections.create_projection()

    projection
  end

  @doc """
  Generate a keyframe.
  """
  def keyframe_fixture(attrs \\ %{}) do
    {:ok, keyframe} =
      attrs
      |> Enum.into(%{
        fov: 120.5,
        position: [],
        range: [],
        rotation: [],
        time: 120.5
      })
      |> Vantage.Projections.create_keyframe()

    keyframe
  end
end
