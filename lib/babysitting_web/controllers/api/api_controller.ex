defmodule BabysittingWeb.API.APIController do
  use BabysittingWeb, :controller

  alias Babysitting.Accounts
  alias Babysitting.Children
  alias Babysitting.Repo
  alias Babysitting.Transactions
  alias Babysitting.Utils

  def index_users(conn, _params) do
    users =
      Accounts.list_users()
      |> decorate_and_encode()

    send_resp(conn, 200, users)
  end

  def show_user(conn, params) do
    %{"id" => parent_id} = params

    case Accounts.get_user(parent_id) do
      nil -> send_resp(conn, 404, "User not found.")
      user -> send_resp(conn, 200, decorate_and_encode(user))
    end
  end

  def create_new_user(conn, params) do
    parent_attrs =
      Map.take(params, ["first_name", "last_name", "address", "city", "state", "zip"])

    save_resource(&Accounts.create_user/1, parent_attrs, conn)
  end

  def edit_user(conn, params) do
    %{"id" => user_id} = params

    update_attrs =
      Map.take(params, ["first_name", "last_name", "address", "city", "state", "zip"])

    case Accounts.update_user(user_id, update_attrs) do
      {:ok, _} -> send_resp(conn, 200, [])
      {:error, changeset} -> send_resp(conn, 402, encode_errors(changeset))
    end
  end

  def create_new_child(conn, params) do
    child_attrs = Map.take(params, ["birthday", "first_name", "last_name", "gender", "parent_id"])

    save_resource(&Children.create_child/1, child_attrs, conn)
  end

  def create_new_transaction(conn, params) do
    transaction_attrs =
      Map.take(params, ["caregiving_user_id", "care_getting_user_id", "start", "end"])
      |> Utils.atomize_keys()

    save_resource(&Transactions.input_transaction/1, transaction_attrs, conn)
  end

  def edit_transaction(conn, params) do
    %{"id" => transaction_id} = params

    updated_attrs =
      Map.take(params, ["caregiving_user_id", "care_getting_user_id", "start", "end"])

    case Transactions.edit_transaction(transaction_id, updated_attrs) do
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
end
