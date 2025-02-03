defmodule Vantage.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :file, :string
      add :investigation_id, references(:investigations, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:models, [:investigation_id])
  end
end
