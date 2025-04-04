defmodule Vantage.Keyframes.Keyframe do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "keyframes" do
    field :position_x, :float, default: 0.0
    field :position_y, :float, default: 1.5
    field :position_z, :float, default: 0.0
    field :time, :float, default: 0.0
    field :rotation_x, :float, default: 0.0
    field :rotation_y, :float, default: 0.0
    field :rotation_z, :float, default: 0.0
    field :far, :float, default: 150.0
    field :fov, :float, default: 60.0
    field :opacity, :float, default: 1.0
    belongs_to :projection, Vantage.Projections.Projection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keyframe, attrs) do
    keyframe
    |> cast(attrs, [
      :time,
      :position_x,
      :position_y,
      :position_z,
      :rotation_x,
      :rotation_y,
      :rotation_z,
      :far,
      :fov,
      :opacity,
      :projection_id
    ])
    |> validate_required([
      :time,
      :position_x,
      :position_y,
      :position_z,
      :rotation_x,
      :rotation_y,
      :rotation_z,
      :far,
      :fov,
      :opacity,
      :projection_id
    ])
  end
end
