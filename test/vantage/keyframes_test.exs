defmodule Vantage.KeyframesTest do
  use Vantage.DataCase

  alias Vantage.Keyframes

  describe "keyframes" do
    alias Vantage.Keyframes.Keyframe

    import Vantage.KeyframesFixtures

    @invalid_attrs %{position: nil, time: nil, rotation: nil, far: nil, fov: nil}

    test "list_keyframes/0 returns all keyframes" do
      keyframe = keyframe_fixture()
      assert Keyframes.list_keyframes() == [keyframe]
    end

    test "get_keyframe!/1 returns the keyframe with given id" do
      keyframe = keyframe_fixture()
      assert Keyframes.get_keyframe!(keyframe.id) == keyframe
    end

    test "create_keyframe/1 with valid data creates a keyframe" do
      valid_attrs = %{position: [], time: 120.5, rotation: [], far: 120.5, fov: 120.5}

      assert {:ok, %Keyframe{} = keyframe} = Keyframes.create_keyframe(valid_attrs)
      assert keyframe.position == []
      assert keyframe.time == 120.5
      assert keyframe.rotation == []
      assert keyframe.far == 120.5
      assert keyframe.fov == 120.5
    end

    test "create_keyframe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Keyframes.create_keyframe(@invalid_attrs)
    end

    test "update_keyframe/2 with valid data updates the keyframe" do
      keyframe = keyframe_fixture()
      update_attrs = %{position: [], time: 456.7, rotation: [], far: 456.7, fov: 456.7}

      assert {:ok, %Keyframe{} = keyframe} = Keyframes.update_keyframe(keyframe, update_attrs)
      assert keyframe.position == []
      assert keyframe.time == 456.7
      assert keyframe.rotation == []
      assert keyframe.far == 456.7
      assert keyframe.fov == 456.7
    end

    test "update_keyframe/2 with invalid data returns error changeset" do
      keyframe = keyframe_fixture()
      assert {:error, %Ecto.Changeset{}} = Keyframes.update_keyframe(keyframe, @invalid_attrs)
      assert keyframe == Keyframes.get_keyframe!(keyframe.id)
    end

    test "delete_keyframe/1 deletes the keyframe" do
      keyframe = keyframe_fixture()
      assert {:ok, %Keyframe{}} = Keyframes.delete_keyframe(keyframe)
      assert_raise Ecto.NoResultsError, fn -> Keyframes.get_keyframe!(keyframe.id) end
    end

    test "change_keyframe/1 returns a keyframe changeset" do
      keyframe = keyframe_fixture()
      assert %Ecto.Changeset{} = Keyframes.change_keyframe(keyframe)
    end
  end
end
