defmodule Vantage.Models.Model do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "models" do
    field :name, :string
    field :file, :string
    belongs_to :investigation, Vantage.Investigations.Investigation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:name, :file, :investigation_id])
    |> validate_required([:name, :file, :investigation_id])
  end
end
