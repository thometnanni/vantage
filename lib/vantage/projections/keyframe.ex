defmodule Vantage.Projections.Keyframe do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "keyframes" do
    field :position, {:array, :float}
    field :time, :float
    field :range, {:array, :float}
    field :rotation, {:array, :float}
    field :fov, :float
    field :projection_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keyframe, attrs) do
    keyframe
    |> cast(attrs, [:time, :position, :rotation, :range, :fov])
    |> validate_required([:time, :position, :rotation, :range, :fov])
  end
end