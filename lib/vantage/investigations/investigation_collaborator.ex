defmodule Vantage.Investigations.InvestigationCollaborator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "investigation_collaborators" do
    field :role, :string
    field :user_id, :binary_id
    field :investigation_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(investigation_collaborator, attrs) do
    investigation_collaborator
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
