defmodule Vantage.Repo.Migrations.AddProjectionListPosition do
  use Ecto.Migration

  def change do
    alter table(:projections) do
      add :list_position, :integer, default: 0
    end

    # First create regular index
    create index(:projections, [:list_position])

    # Execute raw SQL to update existing records
    execute """
            WITH numbered_projections AS (
              SELECT id,
                     ROW_NUMBER() OVER (PARTITION BY investigation_id ORDER BY inserted_at) - 1 as new_position
              FROM projections
            )
            UPDATE projections
            SET list_position = numbered_projections.new_position
            FROM numbered_projections
            WHERE projections.id = numbered_projections.id
            """,
            ""

    # Create unique index after updating the positions
    create index(:projections, [:investigation_id, :list_position])
  end
end
