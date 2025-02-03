defmodule Vantage.Projections.Projection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projections" do
    field :name, :string
    field :time, :float
    field :file, :string
    field :orthographic, :boolean, default: false
    belongs_to :investigation, Vantage.Investigations.Investigation
    has_many :keyframes, Vantage.Keyframes.Keyframe

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(projection, attrs) do
    projection
    |> cast(attrs, [:name, :file, :orthographic, :time, :investigation_id])
    |> validate_required([:name, :file, :orthographic, :time, :investigation_id])
  end
end
