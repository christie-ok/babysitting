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

    case Accounts.create_user(parent_attrs) do
      {:ok, parent} ->
        case create_children(params["children"], parent) do
          {:error, _} -> send_resp(conn, 402, "Error creating children.")
          _ -> send_resp(conn, 200, [])
        end

      {:error, changeset} ->
        send_resp(conn, 402, encode_errors(changeset))
    end
  end

  def create_new_transaction(conn, params) do
    transaction_attrs =
      Map.take(params, ["caregiving_user_id", "care_getting_user_id", "start", "end"])
      |> Utils.atomize_keys()

    case Transactions.input_transaction(transaction_attrs) do
      {:ok, _transaction} ->
        send_resp(conn, 200, [])

      {:error, changeset} ->
        send_resp(conn, 402, encode_errors(changeset))
    end
  end

  defp create_children(children, parent) do
    children
    |> Enum.map(&Utils.atomize_keys/1)
    |> Children.insert_all_children(parent)
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
