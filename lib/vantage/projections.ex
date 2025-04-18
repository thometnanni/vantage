defmodule Vantage.Projections do
  @moduledoc """
  The Projections context.
  """

  import Ecto.Query, warn: false
  alias Vantage.Repo

  alias Vantage.Projections.Projection
  alias Vantage.Keyframes.Keyframe
  alias Vantage.Investigations

  @doc """
  Returns the list of projections belonging to the specified investigation.

  ## Examples

      iex> list_projections()
      [%Projection{}, ...]

  """
  def list_projections(investigation_id) do
    query =
      from p in Projection,
        where: p.investigation_id == ^investigation_id,
        order_by: p.list_position

    Repo.all(query)
  end

  @doc """
  Returns the list of projections belonging to the specified investigation with keyframe associations

  ## Examples

      iex> list_projections()
      [%Projection{}, ...]

  """
  def list_projections_with_keyframes(investigation_id) do
    query =
      from p in Projection,
        where: p.investigation_id == ^investigation_id,
        order_by: p.list_position

    Repo.all(query) |> Repo.preload(keyframes: from(k in Keyframe, order_by: k.time))
  end

  @doc """
  Returns the highest value of p.time + p.duration from all projections with the given investigation_id.

  ## Examples

      iex> get_max_time(123)
      120.5

  """
  def get_max_time(investigation_id) do
    query =
      from p in Projection,
        where: p.investigation_id == ^investigation_id,
        select: max(p.time + p.duration)

    Repo.one(query) || 0.0
  end

  @doc """
  Returns the lowest value of p.time from all projections with the given investigation_id.

  ## Examples

      iex> get_min_time(123)
      0.0

  """
  def get_min_time(investigation_id) do
    query =
      from p in Projection,
        where: p.investigation_id == ^investigation_id,
        select: min(p.time)

    Repo.one(query) || 0.0
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
  Gets a single projection.

  Raises `Ecto.NoResultsError` if the Projection does not exist.

  ## Examples

      iex> get_projection!(123)
      %Projection{}

      iex> get_projection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_projection_with_keyframes!(id),
    do:
      Repo.get!(Projection, id) |> Repo.preload(keyframes: from(k in Keyframe, order_by: k.time))

  @doc """
  Creates a projection.

  ## Examples

      iex> create_projection(%{field: value})
      {:ok, %Projection{}}

      iex> create_projection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_projection(attrs \\ %{}) do
    case %Projection{}
         |> Projection.changeset(attrs)
         |> Repo.insert() do
      {:ok, projection} ->
        Investigations.touch_investigation_by_id(projection.investigation_id)
        {:ok, projection}

      error ->
        error
    end
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
    case projection
         |> Projection.changeset(attrs)
         |> Repo.update() do
      {:ok, projection} ->
        Investigations.touch_investigation_by_id(projection.investigation_id)
        {:ok, projection}

      error ->
        error
    end
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
    case Repo.delete(projection) do
      {:ok, projection} ->
        Investigations.touch_investigation_by_id(projection.investigation_id)
        {:ok, projection}

      error ->
        error
    end
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

  @doc """
  sets the list position of a projection and updates the list positions of all other projections in the same investigation.
  """
  def set_projection_list_position(%Projection{} = projection, new_position) do
    # Get the current list position of the projection
    current_position = projection.list_position

    # Update the list positions of all other projections in the same investigation
    from(p in Projection,
      where: p.investigation_id == ^projection.investigation_id,
      update: [
        set: [
          list_position:
            fragment(
              """
              CASE
                WHEN list_position = ? THEN ?
                WHEN list_position >= ? AND list_position < ? THEN list_position + 1
                WHEN list_position > ? AND list_position <= ? THEN list_position - 1
                ELSE list_position
              END
              """,
              ^current_position,
              ^new_position,
              ^new_position,
              ^current_position,
              ^current_position,
              ^new_position
            )
        ]
      ]
    )
    |> Repo.update_all([])

    Investigations.touch_investigation_by_id(projection.investigation_id)

    {:ok, projection}
  end
end
