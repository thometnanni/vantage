defmodule Vantage.InvestigationsTest do
  use Vantage.DataCase

  alias Vantage.Investigations

  describe "investigations" do
    alias Vantage.Investigations.Investigation

    import Vantage.InvestigationsFixtures

    @invalid_attrs %{name: nil, time: nil, description: nil, longitude: nil, latitude: nil}

    test "list_investigations/0 returns all investigations" do
      investigation = investigation_fixture()
      assert Investigations.list_investigations() == [investigation]
    end

    test "get_investigation!/1 returns the investigation with given id" do
      investigation = investigation_fixture()
      assert Investigations.get_investigation!(investigation.id) == investigation
    end

    test "create_investigation/1 with valid data creates a investigation" do
      valid_attrs = %{name: "some name", time: ~U[2025-02-02 15:37:00.000000Z], description: "some description", longitude: 120.5, latitude: 120.5}

      assert {:ok, %Investigation{} = investigation} = Investigations.create_investigation(valid_attrs)
      assert investigation.name == "some name"
      assert investigation.time == ~U[2025-02-02 15:37:00.000000Z]
      assert investigation.description == "some description"
      assert investigation.longitude == 120.5
      assert investigation.latitude == 120.5
    end

    test "create_investigation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investigations.create_investigation(@invalid_attrs)
    end

    test "update_investigation/2 with valid data updates the investigation" do
      investigation = investigation_fixture()
      update_attrs = %{name: "some updated name", time: ~U[2025-02-03 15:37:00.000000Z], description: "some updated description", longitude: 456.7, latitude: 456.7}

      assert {:ok, %Investigation{} = investigation} = Investigations.update_investigation(investigation, update_attrs)
      assert investigation.name == "some updated name"
      assert investigation.time == ~U[2025-02-03 15:37:00.000000Z]
      assert investigation.description == "some updated description"
      assert investigation.longitude == 456.7
      assert investigation.latitude == 456.7
    end

    test "update_investigation/2 with invalid data returns error changeset" do
      investigation = investigation_fixture()
      assert {:error, %Ecto.Changeset{}} = Investigations.update_investigation(investigation, @invalid_attrs)
      assert investigation == Investigations.get_investigation!(investigation.id)
    end

    test "delete_investigation/1 deletes the investigation" do
      investigation = investigation_fixture()
      assert {:ok, %Investigation{}} = Investigations.delete_investigation(investigation)
      assert_raise Ecto.NoResultsError, fn -> Investigations.get_investigation!(investigation.id) end
    end

    test "change_investigation/1 returns a investigation changeset" do
      investigation = investigation_fixture()
      assert %Ecto.Changeset{} = Investigations.change_investigation(investigation)
    end
  end

  describe "investigation_collaborators" do
    alias Vantage.Investigations.InvestigationCollaborator

    import Vantage.InvestigationsFixtures

    @invalid_attrs %{role: nil}

    test "list_investigation_collaborators/0 returns all investigation_collaborators" do
      investigation_collaborator = investigation_collaborator_fixture()
      assert Investigations.list_investigation_collaborators() == [investigation_collaborator]
    end

    test "get_investigation_collaborator!/1 returns the investigation_collaborator with given id" do
      investigation_collaborator = investigation_collaborator_fixture()
      assert Investigations.get_investigation_collaborator!(investigation_collaborator.id) == investigation_collaborator
    end

    test "create_investigation_collaborator/1 with valid data creates a investigation_collaborator" do
      valid_attrs = %{role: "some role"}

      assert {:ok, %InvestigationCollaborator{} = investigation_collaborator} = Investigations.create_investigation_collaborator(valid_attrs)
      assert investigation_collaborator.role == "some role"
    end

    test "create_investigation_collaborator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investigations.create_investigation_collaborator(@invalid_attrs)
    end

    test "update_investigation_collaborator/2 with valid data updates the investigation_collaborator" do
      investigation_collaborator = investigation_collaborator_fixture()
      update_attrs = %{role: "some updated role"}

      assert {:ok, %InvestigationCollaborator{} = investigation_collaborator} = Investigations.update_investigation_collaborator(investigation_collaborator, update_attrs)
      assert investigation_collaborator.role == "some updated role"
    end

    test "update_investigation_collaborator/2 with invalid data returns error changeset" do
      investigation_collaborator = investigation_collaborator_fixture()
      assert {:error, %Ecto.Changeset{}} = Investigations.update_investigation_collaborator(investigation_collaborator, @invalid_attrs)
      assert investigation_collaborator == Investigations.get_investigation_collaborator!(investigation_collaborator.id)
    end

    test "delete_investigation_collaborator/1 deletes the investigation_collaborator" do
      investigation_collaborator = investigation_collaborator_fixture()
      assert {:ok, %InvestigationCollaborator{}} = Investigations.delete_investigation_collaborator(investigation_collaborator)
      assert_raise Ecto.NoResultsError, fn -> Investigations.get_investigation_collaborator!(investigation_collaborator.id) end
    end

    test "change_investigation_collaborator/1 returns a investigation_collaborator changeset" do
      investigation_collaborator = investigation_collaborator_fixture()
      assert %Ecto.Changeset{} = Investigations.change_investigation_collaborator(investigation_collaborator)
    end
  end
end
