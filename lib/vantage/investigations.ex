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

  alias Vantage.Investigations.InvestigationCollaborator

  @doc """
  Returns the list of investigation_collaborators.

  ## Examples

      iex> list_investigation_collaborators()
      [%InvestigationCollaborator{}, ...]

  """
  def list_investigation_collaborators do
    Repo.all(InvestigationCollaborator)
  end

  @doc """
  Gets a single investigation_collaborator.

  Raises `Ecto.NoResultsError` if the Investigation collaborator does not exist.

  ## Examples

      iex> get_investigation_collaborator!(123)
      %InvestigationCollaborator{}

      iex> get_investigation_collaborator!(456)
      ** (Ecto.NoResultsError)

  """
  def get_investigation_collaborator!(id), do: Repo.get!(InvestigationCollaborator, id)

  @doc """
  Creates a investigation_collaborator.

  ## Examples

      iex> create_investigation_collaborator(%{field: value})
      {:ok, %InvestigationCollaborator{}}

      iex> create_investigation_collaborator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_investigation_collaborator(attrs \\ %{}) do
    %InvestigationCollaborator{}
    |> InvestigationCollaborator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a investigation_collaborator.

  ## Examples

      iex> update_investigation_collaborator(investigation_collaborator, %{field: new_value})
      {:ok, %InvestigationCollaborator{}}

      iex> update_investigation_collaborator(investigation_collaborator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_investigation_collaborator(%InvestigationCollaborator{} = investigation_collaborator, attrs) do
    investigation_collaborator
    |> InvestigationCollaborator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a investigation_collaborator.

  ## Examples

      iex> delete_investigation_collaborator(investigation_collaborator)
      {:ok, %InvestigationCollaborator{}}

      iex> delete_investigation_collaborator(investigation_collaborator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_investigation_collaborator(%InvestigationCollaborator{} = investigation_collaborator) do
    Repo.delete(investigation_collaborator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking investigation_collaborator changes.

  ## Examples

      iex> change_investigation_collaborator(investigation_collaborator)
      %Ecto.Changeset{data: %InvestigationCollaborator{}}

  """
  def change_investigation_collaborator(%InvestigationCollaborator{} = investigation_collaborator, attrs \\ %{}) do
    InvestigationCollaborator.changeset(investigation_collaborator, attrs)
  end
end
