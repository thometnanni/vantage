defmodule Vantage.Projections do
  @moduledoc """
  The Projections context.
  """

  import Ecto.Query, warn: false
  alias Vantage.Repo

  alias Vantage.Projections.Projection

  @doc """
  Returns the list of projections.

  ## Examples

      iex> list_projections()
      [%Projection{}, ...]

  """
  def list_projections do
    Repo.all(Projection)
  end

  @doc """
  Gets a single projection.

  Raises `Ecto.NoResultsError` if the Projection does not exist.

  ## Examples

      iex> get_projection!(123)
      %Projection{}

      iex> get_projection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_projection!(id), do: Repo.get!(Projection, id)

  @doc """
  Creates a projection.

  ## Examples

      iex> create_projection(%{field: value})
      {:ok, %Projection{}}

      iex> create_projection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_projection(attrs \\ %{}) do
    %Projection{}
    |> Projection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a projection.

  ## Examples

      iex> update_projection(projection, %{field: new_value})
      {:ok, %Projection{}}

      iex> update_projection(projection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_projection(%Projection{} = projection, attrs) do
    projection
    |> Projection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a projection.

  ## Examples

      iex> delete_projection(projection)
      {:ok, %Projection{}}

      iex> delete_projection(projection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_projection(%Projection{} = projection) do
    Repo.delete(projection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking projection changes.

  ## Examples

      iex> change_projection(projection)
      %Ecto.Changeset{data: %Projection{}}

  """
  def change_projection(%Projection{} = projection, attrs \\ %{}) do
    Projection.changeset(projection, attrs)
  end
end
