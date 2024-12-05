defmodule Vantage.Investigations.InvestigationCollaborator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "investigation_collaborators" do
    field :role, Ecto.Enum, values: [:owner, :writer, :reader]
    belongs_to :user, Vantage.Accounts.User
    belongs_to :investigation, Vantage.Investigations.Investigation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(investigation_collaborator, attrs) do
    investigation_collaborator
    |> cast(attrs, [:role, :user_id, :investigation_id])
    |> validate_required([:role, :user_id, :investigation_id])
  end
end
