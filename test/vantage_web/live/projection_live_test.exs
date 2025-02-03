defmodule VantageWeb.ProjectionLiveTest do
  use VantageWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vantage.ProjectionsFixtures

  @create_attrs %{name: "some name", time: 120.5, file: "some file", orthographic: true}
  @update_attrs %{name: "some updated name", time: 456.7, file: "some updated file", orthographic: false}
  @invalid_attrs %{name: nil, time: nil, file: nil, orthographic: false}

  defp create_projection(_) do
    projection = projection_fixture()
    %{projection: projection}
  end

  describe "Index" do
    setup [:create_projection]

    test "lists all projections", %{conn: conn, projection: projection} do
      {:ok, _index_live, html} = live(conn, ~p"/projections")

      assert html =~ "Listing Projections"
      assert html =~ projection.name
    end

    test "saves new projection", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/projections")

      assert index_live |> element("a", "New Projection") |> render_click() =~
               "New Projection"

      assert_patch(index_live, ~p"/projections/new")

      assert index_live
             |> form("#projection-form", projection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#projection-form", projection: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/projections")

      html = render(index_live)
      assert html =~ "Projection created successfully"
      assert html =~ "some name"
    end

    test "updates projection in listing", %{conn: conn, projection: projection} do
      {:ok, index_live, _html} = live(conn, ~p"/projections")

      assert index_live |> element("#projections-#{projection.id} a", "Edit") |> render_click() =~
               "Edit Projection"

      assert_patch(index_live, ~p"/projections/#{projection}/edit")

      assert index_live
             |> form("#projection-form", projection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#projection-form", projection: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/projections")

      html = render(index_live)
      assert html =~ "Projection updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes projection in listing", %{conn: conn, projection: projection} do
      {:ok, index_live, _html} = live(conn, ~p"/projections")

      assert index_live |> element("#projections-#{projection.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#projections-#{projection.id}")
    end
  end

  describe "Show" do
    setup [:create_projection]

    test "displays projection", %{conn: conn, projection: projection} do
      {:ok, _show_live, html} = live(conn, ~p"/projections/#{projection}")

      assert html =~ "Show Projection"
      assert html =~ projection.name
    end

    test "updates projection within modal", %{conn: conn, projection: projection} do
      {:ok, show_live, _html} = live(conn, ~p"/projections/#{projection}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Projection"

      assert_patch(show_live, ~p"/projections/#{projection}/show/edit")

      assert show_live
             |> form("#projection-form", projection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#projection-form", projection: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/projections/#{projection}")

      html = render(show_live)
      assert html =~ "Projection updated successfully"
      assert html =~ "some updated name"
    end
  end
end
