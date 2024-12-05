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
      valid_attrs = %{name: "some name", time: ~U[2024-12-04 10:13:00.000000Z], description: "some description", longitude: 120.5, latitude: 120.5}

      assert {:ok, %Investigation{} = investigation} = Investigations.create_investigation(valid_attrs)
      assert investigation.name == "some name"
      assert investigation.time == ~U[2024-12-04 10:13:00.000000Z]
      assert investigation.description == "some description"
      assert investigation.longitude == 120.5
      assert investigation.latitude == 120.5
    end

    test "create_investigation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investigations.create_investigation(@invalid_attrs)
    end

    test "update_investigation/2 with valid data updates the investigation" do
      investigation = investigation_fixture()
      update_attrs = %{name: "some updated name", time: ~U[2024-12-05 10:13:00.000000Z], description: "some updated description", longitude: 456.7, latitude: 456.7}

      assert {:ok, %Investigation{} = investigation} = Investigations.update_investigation(investigation, update_attrs)
      assert investigation.name == "some updated name"
      assert investigation.time == ~U[2024-12-05 10:13:00.000000Z]
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
end
