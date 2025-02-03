defmodule Vantage.Repo.Migrations.CreateKeyframes do
  use Ecto.Migration

  def change do
    create table(:keyframes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :time, :float
      add :position, {:array, :float}
      add :rotation, {:array, :float}
      add :far, :float
      add :fov, :float
      add :projection_id, references(:projections, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:keyframes, [:projection_id])
  end
end
