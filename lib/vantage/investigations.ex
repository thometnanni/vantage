defmodule Vantage.Investigations do
  @moduledoc """
  The Investigations context.
  """

  import Ecto.Query, warn: false
  alias Vantage.Repo

  alias Vantage.Investigations.Investigation

  @doc """
  Returns the list of investigations.

  ## Examples

      iex> list_investigations()
      [%Investigation{}, ...]

  """
  def list_investigations do
    Repo.all(Investigation)
  end

  @doc """
  Gets a single investigation.

  Raises `Ecto.NoResultsError` if the Investigation does not exist.

  ## Examples

      iex> get_investigation!(123)
      %Investigation{}

      iex> get_investigation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_investigation!(id), do: Repo.get!(Investigation, id)

  @doc """
  Creates a investigation.

  ## Examples

      iex> create_investigation(%{field: value})
      {:ok, %Investigation{}}

      iex> create_investigation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_investigation(attrs \\ %{}) do
    %Investigation{}
    |> Investigation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a investigation.

  ## Examples

      iex> update_investigation(investigation, %{field: new_value})
      {:ok, %Investigation{}}

      iex> update_investigation(investigation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_investigation(%Investigation{} = investigation, attrs) do
    investigation
    |> Investigation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a investigation.

  ## Examples

      iex> delete_investigation(investigation)
      {:ok, %Investigation{}}

      iex> delete_investigation(investigation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_investigation(%Investigation{} = investigation) do
    Repo.delete(investigation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking investigation changes.

  ## Examples

      iex> change_investigation(investigation)
      %Ecto.Changeset{data: %Investigation{}}

  """
  def change_investigation(%Investigation{} = investigation, attrs \\ %{}) do
    Investigation.changeset(investigation, attrs)
  end
end
