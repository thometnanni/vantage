defmodule Vantage.Repo.Migrations.CreateInvestigations do
  use Ecto.Migration

  def change do
    create table(:investigations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :longitude, :float
      add :latitude, :float
      add :time, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end
  end
end
