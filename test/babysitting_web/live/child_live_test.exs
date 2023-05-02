defmodule BabysittingWeb.ChildLiveTest do
  use BabysittingWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_attrs %{
    birthday: ~D[2020-12-08],
    first_name: "some updated first_name",
    gender: :boy,
    last_name: "some updated last_name"
  }
  @invalid_attrs %{birthday: nil, first_name: nil, gender: nil, last_name: nil}

  defp create_child(_) do
    child = insert(:child)
    %{child: child}
  end

  describe "Index" do
    setup [:create_child]

    test "lists all children", %{conn: conn, child: child} do
      {:ok, _index_live, html} = live(conn, ~p"/children")

      assert html =~ "Listing Children"
      assert html =~ child.first_name
    end

    test "saves new child", %{conn: conn} do
      parent = insert(:user)

      create_attrs = %{
        birthday: ~D[2020-12-08],
        first_name: "some first_name",
        gender: :girl,
        last_name: "some last_name",
        parent_id: parent.id
      }

      {:ok, index_live, _html} = live(conn, ~p"/children")

      assert index_live |> element("a", "New Child") |> render_click() =~
               "New Child"

      assert_patch(index_live, ~p"/children/new")

      assert index_live
             |> form("#child-form", child: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#child-form", child: create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/children")

      html = render(index_live)
      assert html =~ "Child created successfully"
      assert html =~ "some first_name"
    end

    test "updates child in listing", %{conn: conn, child: child} do
      {:ok, index_live, _html} = live(conn, ~p"/children")

      assert index_live |> element("#children-#{child.id} a", "Edit") |> render_click() =~
               "Edit Child"

      assert_patch(index_live, ~p"/children/#{child}/edit")

      assert index_live
             |> form("#child-form", child: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#child-form", child: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/children")

      html = render(index_live)
      assert html =~ "Child updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes child in listing", %{conn: conn, child: child} do
      {:ok, index_live, _html} = live(conn, ~p"/children")

      assert index_live |> element("#children-#{child.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#children-#{child.id}")
    end
  end

  describe "Show" do
    setup [:create_child]

    test "displays child", %{conn: conn, child: child} do
      {:ok, _show_live, html} = live(conn, ~p"/children/#{child}")

      assert html =~ "Show Child"
      assert html =~ child.first_name
    end

    test "updates child within modal", %{conn: conn, child: child} do
      {:ok, show_live, _html} = live(conn, ~p"/children/#{child}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Child"

      assert_patch(show_live, ~p"/children/#{child}/show/edit")

      assert show_live
             |> form("#child-form", child: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#child-form", child: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/children/#{child}")

      html = render(show_live)
      assert html =~ "Child updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
