defmodule VantageWeb.InvestigationCollaboratorLiveTest do
  use VantageWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vantage.InvestigationsFixtures

  @create_attrs %{role: "some role"}
  @update_attrs %{role: "some updated role"}
  @invalid_attrs %{role: nil}

  defp create_investigation_collaborator(_) do
    investigation_collaborator = investigation_collaborator_fixture()
    %{investigation_collaborator: investigation_collaborator}
  end

  describe "Index" do
    setup [:create_investigation_collaborator]

    test "lists all investigation_collaborators", %{conn: conn, investigation_collaborator: investigation_collaborator} do
      {:ok, _index_live, html} = live(conn, ~p"/investigation_collaborators")

      assert html =~ "Listing Investigation collaborators"
      assert html =~ investigation_collaborator.role
    end

    test "saves new investigation_collaborator", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/investigation_collaborators")

      assert index_live |> element("a", "New Investigation collaborator") |> render_click() =~
               "New Investigation collaborator"

      assert_patch(index_live, ~p"/investigation_collaborators/new")

      assert index_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/investigation_collaborators")

      html = render(index_live)
      assert html =~ "Investigation collaborator created successfully"
      assert html =~ "some role"
    end

    test "updates investigation_collaborator in listing", %{conn: conn, investigation_collaborator: investigation_collaborator} do
      {:ok, index_live, _html} = live(conn, ~p"/investigation_collaborators")

      assert index_live |> element("#investigation_collaborators-#{investigation_collaborator.id} a", "Edit") |> render_click() =~
               "Edit Investigation collaborator"

      assert_patch(index_live, ~p"/investigation_collaborators/#{investigation_collaborator}/edit")

      assert index_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/investigation_collaborators")

      html = render(index_live)
      assert html =~ "Investigation collaborator updated successfully"
      assert html =~ "some updated role"
    end

    test "deletes investigation_collaborator in listing", %{conn: conn, investigation_collaborator: investigation_collaborator} do
      {:ok, index_live, _html} = live(conn, ~p"/investigation_collaborators")

      assert index_live |> element("#investigation_collaborators-#{investigation_collaborator.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#investigation_collaborators-#{investigation_collaborator.id}")
    end
  end

  describe "Show" do
    setup [:create_investigation_collaborator]

    test "displays investigation_collaborator", %{conn: conn, investigation_collaborator: investigation_collaborator} do
      {:ok, _show_live, html} = live(conn, ~p"/investigation_collaborators/#{investigation_collaborator}")

      assert html =~ "Show Investigation collaborator"
      assert html =~ investigation_collaborator.role
    end

    test "updates investigation_collaborator within modal", %{conn: conn, investigation_collaborator: investigation_collaborator} do
      {:ok, show_live, _html} = live(conn, ~p"/investigation_collaborators/#{investigation_collaborator}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Investigation collaborator"

      assert_patch(show_live, ~p"/investigation_collaborators/#{investigation_collaborator}/show/edit")

      assert show_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#investigation_collaborator-form", investigation_collaborator: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/investigation_collaborators/#{investigation_collaborator}")

      html = render(show_live)
      assert html =~ "Investigation collaborator updated successfully"
      assert html =~ "some updated role"
    end
  end
end
