defmodule Vantage.Investigations.Investigation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "investigations" do
    field :name, :string
    field :time, :utc_datetime_usec
    field :description, :string
    field :longitude, :float
    field :latitude, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(investigation, attrs) do
    investigation
    |> cast(attrs, [:name, :description, :longitude, :latitude, :time])
    |> validate_required([:name, :description, :longitude, :latitude, :time])
  end
end