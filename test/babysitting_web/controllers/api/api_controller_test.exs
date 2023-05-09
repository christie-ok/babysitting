defmodule BabysittingWeb.API.APIControllerTest do
  use BabysittingWeb.ConnCase, async: true

  alias Babysitting.Accounts
  alias Babysitting.Accounts.User
  alias Babysitting.Children
  alias Babysitting.Children.Child
  alias Babysitting.Transactions
  alias Babysitting.Transactions.Transaction

  describe "create_new_user/2" do
    test "happy path - should create user, returns 200", %{conn: conn} do
      assert [] == Accounts.list_users()

      body = %{
        first_name: "Morticia",
        last_name: "Addams"
      }

      conn = post(conn, ~p"/api/users/new", body)

      assert respose_status(conn, 200)

      assert [
               %User{
                 first_name: "Morticia",
                 last_name: "Addams",
                 hours_bank: 0.0
               }
             ] = Accounts.list_users()
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

      conn = post(conn, ~p"/api/users/new", body)

      assert respose_status(conn, 402)

      assert decoded_resp_body(conn) ==
               "[last_name: {\"can't be blank\", [validation: :required]}]"

      assert [] == Accounts.list_users()
      assert [] == Children.list_children()
    end
  end

  describe "index/2" do
    test "returns empty list if no users", %{conn: conn} do
      body = %{}
      conn = get(conn, ~p"/api/users", body)

      assert respose_status(conn, 200)
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

      assert respose_status(conn, 200)

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

  describe "show/2" do
    test "returns 404 if user not found", %{conn: conn} do
      body = %{}
      conn = get(conn, ~p"/api/users/1", body)

      assert respose_status(conn, 404)
    end

    test "happy path - returns user and 200", %{conn: conn} do
      insert(:user, id: 13, first_name: "Morticia", last_name: "Addams", hours_bank: 10)

      body = %{}
      conn = get(conn, ~p"/api/users/13", body)

      assert respose_status(conn, 200)

      assert decoded_resp_body(conn) == %{
               "address" => nil,
               "children" => [],
               "city" => nil,
               "first_name" => "Morticia",
               "hours_bank" => 10,
               "last_name" => "Addams",
               "state" => nil,
               "zip" => nil
             }
    end
  end

  describe "create_new_transaction/2" do
    test "inserts transaction and updates hours banks", %{conn: conn} do
      caregiver = insert(:user, id: 111, hours_bank: 10.0)
      care_getter = insert(:user, id: 222, hours_bank: 10.0)

      body = %{
        "caregiving_user_id" => caregiver.id,
        "care_getting_user_id" => care_getter.id,
        "start" => ~U[2023-05-03 10:00:00Z],
        "end" => ~U[2023-05-03 14:00:00Z]
      }

      assert [] = Transactions.list_transactions()

      conn = post(conn, ~p"/api/transactions/new", body)

      assert respose_status(conn, 200)

      assert [%Transaction{}] = Transactions.list_transactions()
      assert users_hours_bank(caregiver, 14.0)
      assert users_hours_bank(care_getter, 6.0)
    end

    test "sends 402 and list of errors if creation of transaction fails", %{conn: conn} do
      caregiver = insert(:user, id: 111, hours_bank: 10.0)
      care_getter = insert(:user, id: 222, hours_bank: 10.0)

      body = %{
        "caregiving_user_id" => caregiver.id,
        "care_getting_user_id" => nil,
        "start" => ~U[2023-05-03 10:00:00Z],
        "end" => ~U[2023-05-03 14:00:00Z]
      }

      assert [] = Transactions.list_transactions()

      conn = post(conn, ~p"/api/transactions/new", body)

      assert respose_status(conn, 402)

      assert "[care_getting_user_id: {\"can't be blank\", [validation: :required]}]" ==
               decoded_resp_body(conn)

      assert [] = Transactions.list_transactions()
      assert users_hours_bank(caregiver, 10.0)
      assert users_hours_bank(care_getter, 10.0)
    end
  end

  describe "create_new_child/2" do
    test "happy path - creates child and returns 200", %{conn: conn} do
      parent = insert(:user)

      body = %{
        birthday: ~D[2020-12-15],
        first_name: "Harry",
        last_name: "Potter",
        gender: :boy,
        parent_id: parent.id
      }

      assert [] == Children.list_children()

      conn = post(conn, ~p"/api/children/new", body)

      respose_status(conn, 200)

      assert [%Child{}] = Children.list_children()
    end

    test "fail path - returns 402 if insert unsuccessful", %{conn: conn} do
      parent = insert(:user)

      body = %{
        first_name: "Harry",
        last_name: "Potter",
        gender: :boy,
        parent_id: parent.id
      }

      assert [] == Children.list_children()

      conn = post(conn, ~p"/api/children/new", body)

      respose_status(conn, 402)

      assert [] = Children.list_children()
    end
  end

  describe "edit_transaction/2" do
    test "edits transaction and updates users' hours banks, sends 200", %{conn: conn} do
      caregiver = insert(:user, hours_bank: 10.0)
      care_getter = insert(:user, hours_bank: 10.0)

      existing_transaction =
        insert(
          :transaction,
          caregiving_user: caregiver,
          care_getting_user: care_getter,
          start: ~U[2023-05-03 10:00:00Z],
          end: ~U[2023-05-03 14:00:00Z],
          hours: 4.0
        )

      body = %{
        "caregiving_user_id" => caregiver.id,
        "care_getting_user_id" => care_getter.id,
        "start" => ~U[2023-05-03 10:00:00Z],
        "end" => ~U[2023-05-03 16:00:00Z]
      }

      conn = patch(conn, ~p"/api/transactions/#{existing_transaction.id}", body)

      assert respose_status(conn, 200)

      assert %Transaction{hours: 6.0} = Transactions.get_transaction!(existing_transaction.id)

      assert users_hours_bank(caregiver, 12.0)
      assert users_hours_bank(care_getter, 8.0)
    end

    test "failure path - sends 402 with errors message", %{conn: conn} do
      caregiver = insert(:user, hours_bank: 10.0)
      care_getter = insert(:user, hours_bank: 10.0)

      existing_transaction =
        insert(
          :transaction,
          caregiving_user: caregiver,
          care_getting_user: care_getter,
          start: ~U[2023-05-03 10:00:00Z],
          end: ~U[2023-05-03 14:00:00Z],
          hours: 4.0
        )

      body = %{
        "caregiving_user_id" => caregiver.id,
        "care_getting_user_id" => care_getter.id,
        "start" => ~U[2023-05-03 16:00:00Z],
        "end" => ~U[2023-05-03 10:00:00Z]
      }

      conn = patch(conn, ~p"/api/transactions/#{existing_transaction.id}", body)

      assert respose_status(conn, 402)

      assert %Transaction{start: ~U[2023-05-03 10:00:00Z], end: ~U[2023-05-03 14:00:00Z]} =
               Transactions.get_transaction!(existing_transaction.id)

      assert users_hours_bank(caregiver, 10.0)
      assert users_hours_bank(care_getter, 10.0)
    end
  end

  describe "edit_user/2" do
    test "edits user and returns 200", %{conn: conn} do
      user = insert(:user, first_name: "Leia", last_name: "Organa")

      body = %{last_name: "Organa-Solo"}

      conn = patch(conn, ~p"/api/users/#{user.id}", body)

      respose_status(conn, 200)

      assert %User{last_name: "Organa-Solo"} = Accounts.get_user!(user.id)
    end

    test "no change to user and returns 402 if update fails", %{conn: conn} do
      user = insert(:user, first_name: "Leia", last_name: "Organa")

      body = %{last_name: 123}

      conn = patch(conn, ~p"/api/users/#{user.id}", body)

      assert respose_status(conn, 402)

      assert %User{last_name: "Organa"} = Accounts.get_user!(user.id)
    end
  end

  defp users_hours_bank(user, hours) do
    user = Accounts.get_user(user.id)
    user.hours_bank == hours
  end

  defp respose_status(conn, status) do
    conn.status == status
  end

  defp decoded_resp_body(conn) do
    Jason.decode!(conn.resp_body)
  end
end
