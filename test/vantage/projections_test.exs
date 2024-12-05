defmodule Vantage.ProjectionsTest do
  use Vantage.DataCase

  alias Vantage.Projections

  describe "projections" do
    alias Vantage.Projections.Projection

    import Vantage.ProjectionsFixtures

    @invalid_attrs %{name: nil, type: nil, time: nil, file: nil, layers: nil, orthographic: nil}

    test "list_projections/0 returns all projections" do
      projection = projection_fixture()
      assert Projections.list_projections() == [projection]
    end

    test "get_projection!/1 returns the projection with given id" do
      projection = projection_fixture()
      assert Projections.get_projection!(projection.id) == projection
    end

    test "create_projection/1 with valid data creates a projection" do
      valid_attrs = %{
        name: "some name",
        type: "image",
        time: 120.5,
        file: "some file",
        layers: ["terrain", "buildings"],
        orthographic: true
      }

      assert {:ok, %Projection{} = projection} = Projections.create_projection(valid_attrs)
      assert projection.name == "some name"
      assert projection.type == "image"
      assert projection.time == 120.5
      assert projection.file == "some file"
      assert projection.layers == ["terrain", "buildings"]
      assert projection.orthographic == true
    end

    test "create_projection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projections.create_projection(@invalid_attrs)
    end

    test "update_projection/2 with valid data updates the projection" do
      projection = projection_fixture()

      update_attrs = %{
        name: "some updated name",
        type: "video",
        time: 456.7,
        file: "some updated file",
        layers: ["buildings"],
        orthographic: false
      }

      assert {:ok, %Projection{} = projection} =
               Projections.update_projection(projection, update_attrs)

      assert projection.name == "some updated name"
      assert projection.type == "video"
      assert projection.time == 456.7
      assert projection.file == "some updated file"
      assert projection.layers == ["buildings"]
      assert projection.orthographic == false
    end

    test "update_projection/2 with invalid data returns error changeset" do
      projection = projection_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Projections.update_projection(projection, @invalid_attrs)

      assert projection == Projections.get_projection!(projection.id)
    end

    test "delete_projection/1 deletes the projection" do
      projection = projection_fixture()
      assert {:ok, %Projection{}} = Projections.delete_projection(projection)
      assert_raise Ecto.NoResultsError, fn -> Projections.get_projection!(projection.id) end
    end

    test "change_projection/1 returns a projection changeset" do
      projection = projection_fixture()
      assert %Ecto.Changeset{} = Projections.change_projection(projection)
    end
  end
end
