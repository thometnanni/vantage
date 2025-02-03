defmodule Vantage.KeyframesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vantage.Keyframes` context.
  """

  @doc """
  Generate a keyframe.
  """
  def keyframe_fixture(attrs \\ %{}) do
    {:ok, keyframe} =
      attrs
      |> Enum.into(%{
        far: 120.5,
        fov: 120.5,
        position: [],
        rotation: [],
        time: 120.5
      })
      |> Vantage.Keyframes.create_keyframe()

    keyframe
  end
end
