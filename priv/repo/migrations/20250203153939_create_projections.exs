defmodule Vantage.Repo.Migrations.CreateProjections do
  use Ecto.Migration

  def change do
    create table(:projections, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :file, :string
      add :orthographic, :boolean, default: false, null: false
      add :time, :float
      add :investigation_id, references(:investigations, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:projections, [:investigation_id])
  end
end
