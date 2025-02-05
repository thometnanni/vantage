defmodule VantageWeb.InvestigationLiveTest do
  use VantageWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vantage.InvestigationsFixtures

  @create_attrs %{
    name: "some name",
    time: "2025-02-02T15:37:00.000000Z",
    description: "some description",
    longitude: 120.5,
    latitude: 120.5
  }
  @update_attrs %{
    name: "some updated name",
    time: "2025-02-03T15:37:00.000000Z",
    description: "some updated description",
    longitude: 456.7,
    latitude: 456.7
  }
  @invalid_attrs %{name: nil, time: nil, description: nil, longitude: nil, latitude: nil}

  defp create_investigation(_) do
    investigation = investigation_fixture()
    %{investigation: investigation}
  end

  describe "Index" do
    setup [:create_investigation]

    test "lists all investigations", %{conn: conn, investigation: investigation} do
      {:ok, _index_live, html} = live(conn, ~p"/investigations")

      assert html =~ "Investigations"
      assert html =~ investigation.name
    end

    test "saves new investigation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/investigations")

      assert index_live |> element("a", "New Investigation") |> render_click() =~
               "New Investigation"

      assert_patch(index_live, ~p"/investigations/new")

      assert index_live
             |> form("#investigation-form", investigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#investigation-form", investigation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/investigations")

      html = render(index_live)
      assert html =~ "Investigation created successfully"
      assert html =~ "some name"
    end

    test "updates investigation in listing", %{conn: conn, investigation: investigation} do
      {:ok, index_live, _html} = live(conn, ~p"/investigations")

      assert index_live
             |> element("#investigations-#{investigation.id} a", "Edit")
             |> render_click() =~
               "Edit Investigation"

      assert_patch(index_live, ~p"/investigations/#{investigation}/edit")

      assert index_live
             |> form("#investigation-form", investigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#investigation-form", investigation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/investigations")

      html = render(index_live)
      assert html =~ "Investigation updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes investigation in listing", %{conn: conn, investigation: investigation} do
      {:ok, index_live, _html} = live(conn, ~p"/investigations")

      assert index_live
             |> element("#investigations-#{investigation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#investigations-#{investigation.id}")
    end
  end

  describe "Show" do
    setup [:create_investigation]

    test "displays investigation", %{conn: conn, investigation: investigation} do
      {:ok, _show_live, html} = live(conn, ~p"/investigations/#{investigation}")

      assert html =~ "Show Investigation"
      assert html =~ investigation.name
    end

    test "updates investigation within modal", %{conn: conn, investigation: investigation} do
      {:ok, show_live, _html} = live(conn, ~p"/investigations/#{investigation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Investigation"

      assert_patch(show_live, ~p"/investigations/#{investigation}/show/edit")

      assert show_live
             |> form("#investigation-form", investigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#investigation-form", investigation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/investigations/#{investigation}")

      html = render(show_live)
      assert html =~ "Investigation updated successfully"
      assert html =~ "some updated name"
    end
  end
end
