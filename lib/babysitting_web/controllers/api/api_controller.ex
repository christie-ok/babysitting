defmodule BabysittingWeb.API.APIController do
  use BabysittingWeb, :controller

  alias Babysitting.Accounts
  alias Babysitting.Children
  alias Babysitting.Utils

  def insert_user_and_children(conn, params) do
    parent_attrs =
      Map.take(params, ["first_name", "last_name", "address", "city", "state", "zip"])

    case Accounts.create_user(parent_attrs) do
      {:ok, parent} ->
        case create_children(params["children"], parent) do
          {:error, _} -> send_resp(conn, 402, "Error creating children.")
          _ -> send_resp(conn, 200, [])
        end

      {:error, changeset} ->
        send_resp(conn, 402, inspect(changeset.errors))
    end
  end

  defp create_children(children, parent) do
    children
    |> Enum.map(&Utils.atomize_keys/1)
    |> Children.insert_all_children(parent)
  end
end