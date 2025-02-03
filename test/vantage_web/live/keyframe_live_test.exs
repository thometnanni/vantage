defmodule VantageWeb.KeyframeLiveTest do
  use VantageWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vantage.KeyframesFixtures

  @create_attrs %{position: [], time: 120.5, rotation: [], far: 120.5, fov: 120.5}
  @update_attrs %{position: [], time: 456.7, rotation: [], far: 456.7, fov: 456.7}
  @invalid_attrs %{position: [], time: nil, rotation: [], far: nil, fov: nil}

  defp create_keyframe(_) do
    keyframe = keyframe_fixture()
    %{keyframe: keyframe}
  end

  describe "Index" do
    setup [:create_keyframe]

    test "lists all keyframes", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/keyframes")

      assert html =~ "Listing Keyframes"
    end

    test "saves new keyframe", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/keyframes")

      assert index_live |> element("a", "New Keyframe") |> render_click() =~
               "New Keyframe"

      assert_patch(index_live, ~p"/keyframes/new")

      assert index_live
             |> form("#keyframe-form", keyframe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#keyframe-form", keyframe: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/keyframes")

      html = render(index_live)
      assert html =~ "Keyframe created successfully"
    end

    test "updates keyframe in listing", %{conn: conn, keyframe: keyframe} do
      {:ok, index_live, _html} = live(conn, ~p"/keyframes")

      assert index_live |> element("#keyframes-#{keyframe.id} a", "Edit") |> render_click() =~
               "Edit Keyframe"

      assert_patch(index_live, ~p"/keyframes/#{keyframe}/edit")

      assert index_live
             |> form("#keyframe-form", keyframe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#keyframe-form", keyframe: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/keyframes")

      html = render(index_live)
      assert html =~ "Keyframe updated successfully"
    end

    test "deletes keyframe in listing", %{conn: conn, keyframe: keyframe} do
      {:ok, index_live, _html} = live(conn, ~p"/keyframes")

      assert index_live |> element("#keyframes-#{keyframe.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#keyframes-#{keyframe.id}")
    end
  end

  describe "Show" do
    setup [:create_keyframe]

    test "displays keyframe", %{conn: conn, keyframe: keyframe} do
      {:ok, _show_live, html} = live(conn, ~p"/keyframes/#{keyframe}")

      assert html =~ "Show Keyframe"
    end

    test "updates keyframe within modal", %{conn: conn, keyframe: keyframe} do
      {:ok, show_live, _html} = live(conn, ~p"/keyframes/#{keyframe}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Keyframe"

      assert_patch(show_live, ~p"/keyframes/#{keyframe}/show/edit")

      assert show_live
             |> form("#keyframe-form", keyframe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#keyframe-form", keyframe: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/keyframes/#{keyframe}")

      html = render(show_live)
      assert html =~ "Keyframe updated successfully"
    end
  end
end
