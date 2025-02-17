defmodule Vantage.Repo.Migrations.AddDurationFieldToProjection do
  use Ecto.Migration

  def change do
    alter table(:projections) do
      add :duration, :float
    end
  end
end
