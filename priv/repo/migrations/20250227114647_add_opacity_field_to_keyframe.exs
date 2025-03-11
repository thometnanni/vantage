defmodule Vantage.Repo.Migrations.AddOpacityFieldToKeyframe do
  use Ecto.Migration

  def change do
    alter table(:keyframes) do
      add :opacity, :float, null: false, default: 1.0
    end
  end
end
