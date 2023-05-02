defmodule Babysitting.AccountsTest do
  use Babysitting.DataCase

  alias Babysitting.Accounts

  describe "users" do
    alias Babysitting.Accounts.User

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
end
