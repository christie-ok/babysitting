defmodule BabysittingWeb.API.APIController do
  use BabysittingWeb, :controller

  alias Babysitting.Accounts
  alias Babysitting.Children
  alias Babysitting.Utils

  def insert_user_and_children(conn, params) do
    parent_attrs =
      Map.take(params, ["first_name", "last_name", "address", "city", "state", "zip"])
      |> IO.inspect(label: "parent attrs")

    case Accounts.create_user(parent_attrs) do
      {:ok, parent} ->
        params["children"]
        |> Enum.map(&Utils.atomize_keys/1)
        |> Children.insert_all_children(parent)

        send_resp(conn, 200, [])

      {:error, changeset} ->
        send_resp(conn, 402, inspect(changeset.errors))
    end

    conn
  end
end
