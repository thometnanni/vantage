defmodule Vantage.Repo.Migrations.UpdateInvestigations do
  use Ecto.Migration

  def change do
    alter table(:investigations) do
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end
  end
end
