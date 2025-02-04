defmodule Vantage.Keyframes.Keyframe do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "keyframes" do
    field :position, {:array, :float}
    field :time, :float
    field :rotation, {:array, :float}
    field :far, :float
    field :fov, :float
    belongs_to :projection, Vantage.Projections.Projection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keyframe, attrs) do
    keyframe
    |> cast(attrs, [:time, :position, :rotation, :far, :fov, :projection_id])
    |> validate_required([:time, :projection_id])
  end
end
