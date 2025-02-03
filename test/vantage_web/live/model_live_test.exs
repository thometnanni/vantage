defmodule VantageWeb.ModelLiveTest do
  use VantageWeb.ConnCase

  import Phoenix.LiveViewTest
  import Vantage.ModelsFixtures

  @create_attrs %{name: "some name", file: "some file"}
  @update_attrs %{name: "some updated name", file: "some updated file"}
  @invalid_attrs %{name: nil, file: nil}

  defp create_model(_) do
    model = model_fixture()
    %{model: model}
  end

  describe "Index" do
    setup [:create_model]

    test "lists all models", %{conn: conn, model: model} do
      {:ok, _index_live, html} = live(conn, ~p"/models")

      assert html =~ "Listing Models"
      assert html =~ model.name
    end

    test "saves new model", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/models")

      assert index_live |> element("a", "New Model") |> render_click() =~
               "New Model"

      assert_patch(index_live, ~p"/models/new")

      assert index_live
             |> form("#model-form", model: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#model-form", model: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/models")

      html = render(index_live)
      assert html =~ "Model created successfully"
      assert html =~ "some name"
    end

    test "updates model in listing", %{conn: conn, model: model} do
      {:ok, index_live, _html} = live(conn, ~p"/models")

      assert index_live |> element("#models-#{model.id} a", "Edit") |> render_click() =~
               "Edit Model"

      assert_patch(index_live, ~p"/models/#{model}/edit")

      assert index_live
             |> form("#model-form", model: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#model-form", model: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/models")

      html = render(index_live)
      assert html =~ "Model updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes model in listing", %{conn: conn, model: model} do
      {:ok, index_live, _html} = live(conn, ~p"/models")

      assert index_live |> element("#models-#{model.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#models-#{model.id}")
    end
  end

  describe "Show" do
    setup [:create_model]

    test "displays model", %{conn: conn, model: model} do
      {:ok, _show_live, html} = live(conn, ~p"/models/#{model}")

      assert html =~ "Show Model"
      assert html =~ model.name
    end

    test "updates model within modal", %{conn: conn, model: model} do
      {:ok, show_live, _html} = live(conn, ~p"/models/#{model}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Model"

      assert_patch(show_live, ~p"/models/#{model}/show/edit")

      assert show_live
             |> form("#model-form", model: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#model-form", model: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/models/#{model}")

      html = render(show_live)
      assert html =~ "Model updated successfully"
      assert html =~ "some updated name"
    end
  end
end
