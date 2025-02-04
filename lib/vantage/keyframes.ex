defmodule Vantage.Keyframes do
  @moduledoc """
  The Keyframes context.
  """

  import Ecto.Query, warn: false
  alias Vantage.Repo

  alias Vantage.Keyframes.Keyframe

  @doc """
  Returns the list of keyframes.

  ## Examples

      iex> list_keyframes()
      [%Keyframe{}, ...]

  """
  def list_keyframes(projection_id) do
    query =
      from k in Keyframe,
        where: k.projection_id == ^projection_id

    Repo.all(query)
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
