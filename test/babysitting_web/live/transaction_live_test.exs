defmodule BabysittingWeb.TransactionLiveTest do
  use BabysittingWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_attrs %{hours: 43}
  @invalid_attrs %{hours: nil}

  defp create_transaction(_) do
    transaction = insert(:transaction)
    %{transaction: transaction}
  end

  describe "Index" do
    setup [:create_transaction]

    @tag :skip
    test "lists all transactions", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/transactions")

      assert html =~ "Listing Transactions"
    end

    @tag :skip
    test "saves new transaction", %{conn: conn} do
      caregiver = insert(:user)
      care_getter = insert(:user)

      create_attrs = %{
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id,
        hours: 3
      }

      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live |> element("a", "New Transaction") |> render_click() =~
               "New Transaction"

      assert_patch(index_live, ~p"/transactions/new")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transactions")

      html = render(index_live)
      assert html =~ "Transaction created successfully"
    end

    @tag :skip
    test "updates transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live |> element("#transactions-#{transaction.id} a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(index_live, ~p"/transactions/#{transaction}/edit")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transactions")

      html = render(index_live)
      assert html =~ "Transaction updated successfully"
    end

    @tag :skip
    test "deletes transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live
             |> element("#transactions-#{transaction.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#transactions-#{transaction.id}")
    end
  end

  describe "Show" do
    setup [:create_transaction]

    @tag :skip
    test "displays transaction", %{conn: conn, transaction: transaction} do
      {:ok, _show_live, html} = live(conn, ~p"/transactions/#{transaction}")

      assert html =~ "Show Transaction"
    end

    @tag :skip
    test "updates transaction within modal", %{conn: conn, transaction: transaction} do
      {:ok, show_live, _html} = live(conn, ~p"/transactions/#{transaction}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(show_live, ~p"/transactions/#{transaction}/show/edit")

      assert show_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/transactions/#{transaction}")

      html = render(show_live)
      assert html =~ "Transaction updated successfully"
    end
  end
end
