defmodule Vantage.Models.Model do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "models" do
    field :name, :string
    field :file, :string
    field :investigation_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:name, :file])
    |> validate_required([:name, :file])
  end
end
