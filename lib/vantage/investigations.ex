defmodule Vantage.Investigations do
  @moduledoc """
  The Investigations context.
  """

  import Ecto.Query, warn: false
  alias Vantage.Repo

  alias Vantage.Investigations.Investigation
  alias Vantage.Investigations.InvestigationCollaborator

  @doc """
  Returns the list of investigations.

  ## Examples

      iex> list_investigations()
      [%Investigation{}, ...]

  """
  def list_investigations do
    query =
      from i in Investigation,
        order_by: [desc: i.updated_at]

    Repo.all(query)
  end

  @doc """
  Return the list of investigations a user has access to

  ## Examples
      iex> list_investigations(123)
      [%Investigation{}, ...]


  """

  def list_investigations(user_id) do
    allowed_roles = [:writer, :owner, :reader]

    query =
      from i in Investigation,
        join: ic in InvestigationCollaborator,
        on: ic.investigation_id == i.id,
        where: ic.user_id == ^user_id and ic.role in ^allowed_roles,
        order_by: [desc: i.updated_at],
        select: i

    Repo.all(query)
  end

  def get_user_role_for_investigation(user_id, investigation_id) do
    InvestigationCollaborator
    |> where([ic], ic.user_id == ^user_id and ic.investigation_id == ^investigation_id)
    |> select([ic], ic.role)
    |> Repo.one()
  end

  def get_user_roles_for_investigation(investigation_id) do
    from(ic in InvestigationCollaborator,
      join: u in assoc(ic, :user),
      where: ic.investigation_id == ^investigation_id,
      select: %{
        user_id: u.id,
        email: u.email,
        role: ic.role,
        investigation_collaborator_id: ic.id
      }
    )
    |> Repo.all()
  end

  def remove_user_from_investigation(investigation_id, user_id) do
    InvestigationCollaborator
    |> where([ic], ic.investigation_id == ^investigation_id and ic.user_id == ^user_id)
    |> Repo.delete_all()
  end

  def update_user_role_in_investigation(investigation_id, user_id, role) do
    InvestigationCollaborator
    |> where([ic], ic.investigation_id == ^investigation_id and ic.user_id == ^user_id)
    |> Repo.update_all(set: [role: role])
  end

  def add_user_to_investigation(investigation_id, email) do
    case Vantage.Accounts.get_user_by_email(email) do
      nil ->
        {:error, :user_not_found}

      user ->
        %InvestigationCollaborator{}
        |> InvestigationCollaborator.changeset(%{
          user_id: user.id,
          investigation_id: investigation_id,
          role: :reader
        })
        |> Repo.insert()
    end
  end

  @spec get_investigation!(any()) :: any()
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
  def create_investigation(user, attrs \\ %{}) do
    %Investigation{}
    |> Investigation.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, investigation} ->
        create_investigation_collaborator(user, %{
          role: :owner,
          investigation_id: investigation.id
        })

        {:ok, investigation}

      error ->
        {:error, error}
    end
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
  def create_investigation_collaborator(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:investigation_collaborators)
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
  def update_investigation_collaborator(
        %InvestigationCollaborator{} = investigation_collaborator,
        attrs
      ) do
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
  def change_investigation_collaborator(
        %InvestigationCollaborator{} = investigation_collaborator,
        attrs \\ %{}
      ) do
    InvestigationCollaborator.changeset(investigation_collaborator, attrs)
  end

  def touch_investigation_by_id(id) do
    get_investigation!(id)
    |> Investigation.changeset(%{})
    # |> Map.put(:force, true)
    |> Repo.update(force: true)
  end
end
