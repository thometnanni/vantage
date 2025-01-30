defmodule Vantage.Investigations.Investigation do
  use Ecto.Schema
  import Ecto.Changeset
  import DateTime

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "investigations" do
    field :name, :string, default: "Untitled Investigation"
    field :time, :utc_datetime_usec
    field :description, :string
    field :longitude, :float
    field :latitude, :float
    # field :user_id, :binary_id
    field :model, :string
    has_many :investigation_collaborators, Vantage.Investigations.InvestigationCollaborator
    has_many :projections, Vantage.Projections.Projection
    belongs_to :user, Vantage.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(investigation, attrs) do
    investigation
    |> cast(attrs, [:name, :description, :longitude, :latitude, :time, :model])
    |> validate_required([:name])
  end
end
