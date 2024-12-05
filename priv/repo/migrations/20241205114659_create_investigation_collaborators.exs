defmodule Vantage.Repo.Migrations.CreateInvestigationCollaborators do
  use Ecto.Migration

  def change do
    create table(:investigation_collaborators, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :investigation_id, references(:investigations, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:investigation_collaborators, [:user_id])
    create index(:investigation_collaborators, [:investigation_id])
  end
end
