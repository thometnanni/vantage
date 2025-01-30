defmodule Vantage.Repo.Migrations.UploadFilesToInvestigation do
  use Ecto.Migration

  def change do
    alter table(:investigations) do
      add :model, :string
    end
  end
end
