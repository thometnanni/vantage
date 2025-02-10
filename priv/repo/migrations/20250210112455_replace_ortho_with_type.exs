defmodule Vantage.Repo.Migrations.ReplaceOrthoWithType do
  use Ecto.Migration

  def change do
    alter table(:projections) do
      add :projection_type, :string
      remove :orthographic
    end
  end
end
