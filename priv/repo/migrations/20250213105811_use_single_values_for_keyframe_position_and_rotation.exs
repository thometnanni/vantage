defmodule Vantage.Repo.Migrations.UseSingleValuesForKeyframePositionAndRotation do
  use Ecto.Migration

  def change do
    alter table(:keyframes) do
      add :position_x, :float
      add :position_y, :float
      add :position_z, :float

      add :rotation_x, :float
      add :rotation_y, :float
      add :rotation_z, :float

      remove :position
      remove :rotation
    end
  end
end
