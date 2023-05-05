defmodule BabysittingWeb.API.APIControllerTest do
  use BabysittingWeb.ConnCase, async: true

  alias Babysitting.Accounts
  alias Babysitting.Accounts.User
  alias Babysitting.Children
  alias Babysitting.Children.Child

  describe "insert_user_and_children/2" do
    test "happy path - should create user and children", %{conn: conn} do
      assert [] == Accounts.list_users()
      assert [] == Children.list_children()

      post(conn, ~p"/api/user", %{
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
      })

      assert %User{first_name: "Morticia", last_name: "Addams", children: [child_1, child_2]} = Accounts.get_parent_with_children_by(:first_name, "Morticia")
      assert %Child{first_name: "Wednesday", last_name: "Addams"} = child_1
      assert %Child{first_name: "Pugsley", last_name: "Addams"} = child_2
    end
  end
end
