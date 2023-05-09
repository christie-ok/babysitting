defmodule BabysittingWeb.API.APIController do
  use BabysittingWeb, :controller

  alias Babysitting.Accounts
  alias Babysitting.Children
  alias Babysitting.Repo
  alias Babysitting.Transactions

  @child_attrs ["birthday", "first_name", "last_name", "gender", "parent_id"]
  @parent_attrs ["first_name", "last_name", "address", "city", "state", "zip"]
  @transaction_attrs ["caregiving_user_id", "care_getting_user_id", "start", "end"]

  def index_users(conn, _params) do
    users =
      Accounts.list_users()
      |> decorate_and_encode()

    send_resp(conn, 200, users)
  end

  def show_user(conn, params) do
    %{"id" => parent_id} = params

    case Accounts.get_user(parent_id) do
      nil ->
        send_resp(conn, 404, "User not found.")

      user ->
        user = Repo.preload(user, [:children])

        transactions = Transactions.list_transactions_for_user(user)

        send_resp(conn, 200, Jason.encode!(%{user: user, transactions: transactions}))
    end
  end

  def create_new_user(conn, params) do
    parent_attrs = Map.take(params, @parent_attrs)

    save_resource(&Accounts.create_user/1, parent_attrs, conn)
  end

  def edit_user(conn, params) do
    %{"id" => user_id} = params

    update_attrs = Map.take(params, @parent_attrs)

    update_resource(&Accounts.update_user/2, user_id, update_attrs, conn)
  end

  def create_new_child(conn, params) do
    child_attrs = Map.take(params, @child_attrs)

    save_resource(&Children.create_child/1, child_attrs, conn)
  end

  def create_new_transaction(conn, params) do
    transaction_attrs = Map.take(params, @transaction_attrs)

    save_resource(&Transactions.input_transaction/1, transaction_attrs, conn)
  end

  def edit_transaction(conn, params) do
    %{"id" => transaction_id} = params

    updated_attrs = Map.take(params, @transaction_attrs)

    update_resource(&Transactions.edit_transaction/2, transaction_id, updated_attrs, conn)
  end

  def delete_transaction(conn, params) do
    %{"id" => transaction_id} = params

    case Transactions.undo_transaction(transaction_id) do
      {:ok, _} ->
        send_resp(conn, 200, [])

      {:error, changeset} ->
        send_resp(conn, 402, encode_errors(changeset))
    end
  end

  defp update_resource(f, id, attrs, conn) do
    case f.(id, attrs) do
      {:ok, _} ->
        send_resp(conn, 200, [])

      {:error, changeset} ->
        send_resp(conn, 402, encode_errors(changeset))
    end
  end

  defp save_resource(f, attrs, conn) do
    case f.(attrs) do
      {:ok, _} ->
        send_resp(conn, 200, [])

      {:error, changeset} ->
        send_resp(conn, 402, encode_errors(changeset))
    end
  end

  defp encode_errors(changeset) do
    changeset.errors
    |> inspect()
    |> Jason.encode!()
  end

  defp decorate_and_encode(users) do
    users
    |> Repo.preload([:children])
    |> Jason.encode!()
  end

  defp calculate_childrens_ages(user) do
    %{children: children} = user

    children =
      Enum.map(
        children,
        fn child ->
          child
          |> Map.from_struct()
          |> Map.drop([:__meta__, :parent])
          |> Map.put(:age, Children.child_age(child))
        end
      )

    %{user | children: children}
  end
end
