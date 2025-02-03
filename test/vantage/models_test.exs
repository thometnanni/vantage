defmodule Vantage.ModelsTest do
  use Vantage.DataCase

  alias Vantage.Models

  describe "models" do
    alias Vantage.Models.Model

    import Vantage.ModelsFixtures

    @invalid_attrs %{name: nil, file: nil}

    test "list_models/0 returns all models" do
      model = model_fixture()
      assert Models.list_models() == [model]
    end

    test "get_model!/1 returns the model with given id" do
      model = model_fixture()
      assert Models.get_model!(model.id) == model
    end

    test "create_model/1 with valid data creates a model" do
      valid_attrs = %{name: "some name", file: "some file"}

      assert {:ok, %Model{} = model} = Models.create_model(valid_attrs)
      assert model.name == "some name"
      assert model.file == "some file"
    end

    test "create_model/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Models.create_model(@invalid_attrs)
    end

    test "update_model/2 with valid data updates the model" do
      model = model_fixture()
      update_attrs = %{name: "some updated name", file: "some updated file"}

      assert {:ok, %Model{} = model} = Models.update_model(model, update_attrs)
      assert model.name == "some updated name"
      assert model.file == "some updated file"
    end

    test "update_model/2 with invalid data returns error changeset" do
      model = model_fixture()
      assert {:error, %Ecto.Changeset{}} = Models.update_model(model, @invalid_attrs)
      assert model == Models.get_model!(model.id)
    end

    test "delete_model/1 deletes the model" do
      model = model_fixture()
      assert {:ok, %Model{}} = Models.delete_model(model)
      assert_raise Ecto.NoResultsError, fn -> Models.get_model!(model.id) end
    end

    test "change_model/1 returns a model changeset" do
      model = model_fixture()
      assert %Ecto.Changeset{} = Models.change_model(model)
    end
  end
end
