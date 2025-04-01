defmodule Vantage.Projections.Projection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projections" do
    field :name, :string
    field :time, :float, default: 0.0
    field :duration, :float, default: 0.0
    field :file, :string
    field :list_position, :integer, default: 0

    field :projection_type, Ecto.Enum,
      values: [:perspective, :orthographic, :map],
      default: :perspective

    belongs_to :investigation, Vantage.Investigations.Investigation
    has_many :keyframes, Vantage.Keyframes.Keyframe

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(projection, attrs) do
    projection
    |> cast(attrs, [
      :name,
      :file,
      :projection_type,
      :time,
      :investigation_id,
      :duration,
      :list_position
    ])
    |> validate_required([
      :name,
      :file,
      :projection_type,
      :time,
      :investigation_id,
      :duration,
      :list_position
    ])
  end
end
