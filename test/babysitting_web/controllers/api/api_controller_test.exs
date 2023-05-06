defmodule BabysittingWeb.API.APIControllerTest do
  use BabysittingWeb.ConnCase, async: true

  alias Babysitting.Accounts
  alias Babysitting.Accounts.User
  alias Babysitting.Children
  alias Babysitting.Children.Child

  describe "insert_user_and_children/2" do
    test "happy path - should create user and children, returns 200", %{conn: conn} do
      assert [] == Accounts.list_users()
      assert [] == Children.list_children()

      body = %{
        first_name: "Morticia",
        last_name: "Addams",
        children: [
          %{
            first_name: "Wednesday",
            last_name: "Addams",
            gender: :girl,
            birthday: ~D[2018-09-13]
          },
          %{first_name: "Pugsley", last_name: "Addams", gender: :boy, birthday: ~D[2021-10-31]}
        ]
      }

      conn = post(conn, ~p"/api/user", body)

      assert {200, _, _} = Plug.Test.sent_resp(conn)

      assert [
               %User{
                 id: morticia_id,
                 first_name: "Morticia",
                 last_name: "Addams"
               }
             ] = Accounts.list_users()

      assert [
               %Child{first_name: "Wednesday", last_name: "Addams", parent_id: ^morticia_id},
               %Child{first_name: "Pugsley", last_name: "Addams", parent_id: ^morticia_id}
             ] = Children.list_children()
    end

    test "should not insert resources if data incomplete", %{conn: conn} do
      assert [] == Accounts.list_users()
      assert [] == Children.list_children()

      body = %{
        first_name: "Morticia",
        children: [
          %{
            first_name: "Wednesday",
            last_name: "Addams",
            gender: :girl,
            birthday: ~D[2018-09-13]
          },
          %{first_name: "Pugsley", last_name: "Addams", gender: :boy, birthday: ~D[2021-10-31]}
        ]
      }

      conn = post(conn, ~p"/api/user", body)

      assert {402, _, "[last_name: {\"can't be blank\", [validation: :required]}]"} =
               Plug.Test.sent_resp(conn)

      assert [] == Accounts.list_users()
      assert [] == Children.list_children()
    end
  end
end
