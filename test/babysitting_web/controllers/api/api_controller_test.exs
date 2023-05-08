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

      assert conn.status == 200

      assert [
               %User{
                 id: morticia_id,
                 first_name: "Morticia",
                 last_name: "Addams",
                 hours_bank: 0
               }
             ] = Accounts.list_users()

      assert [
               %Child{first_name: "Wednesday", last_name: "Addams", parent_id: ^morticia_id},
               %Child{first_name: "Pugsley", last_name: "Addams", parent_id: ^morticia_id}
             ] = Children.list_children()
    end

    test "should not insert resources if parent data incomplete", %{conn: conn} do
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

      assert conn.status == 402
      assert conn.resp_body == "[last_name: {\"can't be blank\", [validation: :required]}]"

      assert [] == Accounts.list_users()
      assert [] == Children.list_children()
    end

    test "should insert parent, but not children if parent data is complete, but child data is not",
         %{conn: conn} do
      assert [] == Accounts.list_users()
      assert [] == Children.list_children()

      body = %{
        first_name: "Morticia",
        last_name: "Addams",
        children: [
          %{
            first_name: "Wednesday",
            last_name: "Addams",
            gender: :girl
          },
          %{first_name: "Pugsley", last_name: "Addams", gender: :boy}
        ]
      }

      conn = post(conn, ~p"/api/user", body)

      assert conn.status == 402
      assert conn.resp_body == "Error creating children."

      assert [
               %User{
                 first_name: "Morticia",
                 last_name: "Addams",
                 hours_bank: 0
               }
             ] = Accounts.list_users()

      assert [] == Children.list_children()
    end
  end

  describe "index/2" do
    test "returns empty list if no users", %{conn: conn} do
      body = %{}
      conn = get(conn, ~p"/api/users", body)

      assert decoded_resp_body(conn) == []
    end

    test "returns list of maps containing users' names, ids, and hours bank totals", %{conn: conn} do
      parent = insert(:user, first_name: "Morticia", last_name: "Addams", hours_bank: 10)

      insert(:child,
        parent: parent,
        first_name: "Wednesday",
        last_name: "Addams",
        gender: :girl,
        birthday: ~D[2018-09-13]
      )

      body = %{}
      conn = get(conn, ~p"/api/users", body)

      assert decoded_resp_body(conn) == [
               %{
                 "address" => nil,
                 "children" => [
                   %{
                     "birthday" => "2018-09-13",
                     "first_name" => "Wednesday",
                     "gender" => "girl",
                     "last_name" => "Addams"
                   }
                 ],
                 "city" => nil,
                 "first_name" => "Morticia",
                 "hours_bank" => 10,
                 "last_name" => "Addams",
                 "state" => nil,
                 "zip" => nil
               }
             ]
    end
  end

  defp decoded_resp_body(conn) do
    Jason.decode!(conn.resp_body)
  end
end
