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

  alias Vantage.Projections.Keyframe

  @doc """
  Returns the list of keyframes.

  ## Examples

      iex> list_keyframes()
      [%Keyframe{}, ...]

  """
  def list_keyframes do
    Repo.all(Keyframe)
  end

  @doc """
  Gets a single keyframe.

  Raises `Ecto.NoResultsError` if the Keyframe does not exist.

  ## Examples

      iex> get_keyframe!(123)
      %Keyframe{}

      iex> get_keyframe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_keyframe!(id), do: Repo.get!(Keyframe, id)

  @doc """
  Creates a keyframe.

  ## Examples

      iex> create_keyframe(%{field: value})
      {:ok, %Keyframe{}}

      iex> create_keyframe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_keyframe(attrs \\ %{}) do
    %Keyframe{}
    |> Keyframe.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a keyframe.

  ## Examples

      iex> update_keyframe(keyframe, %{field: new_value})
      {:ok, %Keyframe{}}

      iex> update_keyframe(keyframe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_keyframe(%Keyframe{} = keyframe, attrs) do
    keyframe
    |> Keyframe.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a keyframe.

  ## Examples

      iex> delete_keyframe(keyframe)
      {:ok, %Keyframe{}}

      iex> delete_keyframe(keyframe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_keyframe(%Keyframe{} = keyframe) do
    Repo.delete(keyframe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking keyframe changes.

  ## Examples

      iex> change_keyframe(keyframe)
      %Ecto.Changeset{data: %Keyframe{}}

  """
  def change_keyframe(%Keyframe{} = keyframe, attrs \\ %{}) do
    Keyframe.changeset(keyframe, attrs)
  end
end
