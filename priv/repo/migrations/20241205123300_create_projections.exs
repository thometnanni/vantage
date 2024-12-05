defmodule Vantage.Repo.Migrations.CreateProjections do
  use Ecto.Migration

  def change do
    create table(:projections, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :file, :string
      add :layers, {:array, :string}
      add :orthographic, :boolean, default: false, null: false
      add :time, :float

      timestamps(type: :utc_datetime)
    end
  end
end
