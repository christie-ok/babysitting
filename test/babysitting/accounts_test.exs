defmodule Babysitting.AccountsTest do
  use Babysitting.DataCase

  alias Babysitting.Accounts
  alias Babysitting.Accounts.User
  alias Babysitting.Children.Child

  describe "users" do
    @invalid_attrs %{first_name: nil, last_name: nil}

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        address: "some address",
        city: "some city",
        first_name: "some first_name",
        last_name: "some last_name",
        state: "some state",
        zip: "some zip",
        hours_bank: 5
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)

      assert user.address == "some address"
      assert user.city == "some city"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.state == "some state"
      assert user.zip == "some zip"
      assert user.hours_bank == 5
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      update_attrs = %{hours_bank: 4}

      assert user.hours_bank == 0

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)

      assert user.hours_bank == 4
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "full_name/1" do
    test "returns user's full name" do
      user = insert(:user, first_name: "Harry", last_name: "Potter")

      assert "Harry Potter" == Accounts.full_name(user)
    end
  end

  describe "get_parent_with_children_by" do
    setup do
      %User{id: molly_id} = molly = insert(:user, first_name: "Molly", last_name: "Weasley")
      %Child{id: ron_id} = insert(:child, first_name: "Ron", last_name: "Weasley", parent: molly)

      %Child{id: ginny_id} =
        insert(:child, first_name: "Ginny", last_name: "Weasley", parent: molly)

      %{
        molly_id: molly_id,
        ron_id: ron_id,
        ginny_id: ginny_id
      }
    end

    test "should return user (parent) struct with children preloaded by parent's first name", %{
      molly_id: molly_id,
      ron_id: ron_id,
      ginny_id: ginny_id
    } do
      assert %User{id: ^molly_id, children: [child_1, child_2]} =
               Accounts.get_parent_with_children_by(:first_name, "Molly")

      assert %Child{id: ^ron_id} = child_1
      assert %Child{id: ^ginny_id} = child_2
    end

    test "should return user (parent) struct with children preloaded by parent's id", %{
      molly_id: molly_id,
      ron_id: ron_id,
      ginny_id: ginny_id
    } do
      assert %User{id: ^molly_id, children: [child_1, child_2]} =
               Accounts.get_parent_with_children_by(:id, molly_id)

      assert %Child{id: ^ron_id} = child_1
      assert %Child{id: ^ginny_id} = child_2
    end

    test "should return nil if cannot find parent" do
      assert nil ==
               Accounts.get_parent_with_children_by(:first_name, "someone not in the database")
    end
  end

  describe "update_users_hours_banks/1" do
    test "adds hours to caregiver's bank, subtracts hours from care getter's bank" do
      caregiver = insert(:user, hours_bank: 10.0)
      care_getter = insert(:user, hours_bank: 10.0)

      transaction =
        insert(:transaction, care_getting_user: care_getter, caregiving_user: caregiver, hours: 2)

      Accounts.update_users_hours_banks(transaction)

      assert users_updated_hours_bank(caregiver, 12)
      assert users_updated_hours_bank(care_getter, 8)
    end
  end

  defp users_updated_hours_bank(user, hours) do
    user = Accounts.get_user(user.id)

    user.hours_bank == hours
  end
end
