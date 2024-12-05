defmodule Vantage.Projections.Projection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projections" do
    field :name, :string
    field :type, Ecto.Enum, values: [:image, :video]
    field :time, :float
    field :file, :string
    field :layers, {:array, Ecto.Enum}, values: [:terrain, :buildings, :plane]
    field :orthographic, :boolean, default: false
    belongs_to :investigation, Vantage.Investigations.Investigation
    has_many :keyframes, Vantage.Projections.Keyframe

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(projection, attrs) do
    projection
    |> cast(attrs, [:name, :type, :file, :layers, :orthographic, :time, :investigation_id])
    |> validate_required([:name, :type, :file, :layers, :orthographic, :time, :investigation_id])
  end
end
