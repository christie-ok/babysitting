defmodule Babysitting.ChildrenTest do
  use Babysitting.DataCase

  alias Babysitting.Children
  alias Babysitting.Children.Child

  describe "children" do
    @invalid_attrs %{birthday: nil, first_name: nil, gender: nil, last_name: nil}

    test "list_children/0 returns all children" do
      child = insert(:child)
      child_id = child.id
      assert [%Child{id: ^child_id}] = Children.list_children()
    end

    test "get_child!/1 returns the child with given id" do
      child = insert(:child)
      child_id = child.id
      assert %Child{id: ^child_id} = Children.get_child!(child.id)
    end

    test "create_child/1 with valid data creates a child" do
      parent = insert(:user)

      valid_attrs = %{
        first_name: "some first_name",
        gender: :girl,
        last_name: "some last_name",
        birthday: ~D[2020-12-08],
        parent_id: parent.id
      }

      assert {:ok, %Child{} = child} = Children.create_child(valid_attrs)
      assert child.first_name == "some first_name"
      assert child.gender == :girl
      assert child.last_name == "some last_name"
      assert child.birthday == ~D[2020-12-08]
    end

    test "create_child/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Children.create_child(@invalid_attrs)
    end

    test "update_child/2 with valid data updates the child" do
      child = insert(:child, first_name: "some first name")
      update_attrs = %{first_name: "some updated first_name"}

      assert {:ok, %Child{} = child} = Children.update_child(child, update_attrs)
      assert child.first_name == "some updated first_name"
    end

    test "update_child/2 with invalid data returns error changeset" do
      child = insert(:child)
      child_id = child.id
      assert {:error, %Ecto.Changeset{}} = Children.update_child(child, @invalid_attrs)
      assert %Child{id: ^child_id} = Children.get_child!(child.id)
    end

    test "delete_child/1 deletes the child" do
      child = insert(:child)
      assert {:ok, %Child{}} = Children.delete_child(child)
      assert_raise Ecto.NoResultsError, fn -> Children.get_child!(child.id) end
    end

    test "change_child/1 returns a child changeset" do
      child = insert(:child)
      assert %Ecto.Changeset{} = Children.change_child(child)
    end
  end

  describe "child_age/1" do
    test "returns child's age rounded down to nearest integer" do
      today = Date.utc_today()
      one_year_ago = Date.add(today, -365)
      eighteen_months_ago = Date.add(today, -547)

      child_1 = insert(:child, birthday: one_year_ago)
      child_2 = insert(:child, birthday: eighteen_months_ago)
      child_3 = insert(:child, birthday: today)

      assert 1 == Children.child_age(child_1)
      assert 1 == Children.child_age(child_2)
      assert 0 == Children.child_age(child_3)
    end
  end
end
