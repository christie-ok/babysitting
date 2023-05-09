defmodule Babysitting.TransactionsTest do
  use Babysitting.DataCase

  alias Babysitting.Transactions
  alias Babysitting.Transactions.Transaction

  @tuesday_ten_am ~U[2023-05-02 10:00:00Z]
  @wednesday_ten_am ~U[2023-05-03 10:00:00Z]
  @wednesday_two_thirty_pm ~U[2023-05-03 14:30:00Z]
  @wednesday_four_pm ~U[2023-05-03 16:00:00Z]

  describe "transactions" do
    test "list_transactions/0 returns all transactions" do
      transaction = insert(:transaction)
      transaction_id = transaction.id
      assert [%Transaction{id: ^transaction_id}] = Transactions.list_transactions()
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = insert(:transaction)
      transaction_id = transaction.id
      assert %Transaction{id: ^transaction_id} = Transactions.get_transaction!(transaction.id)
    end

    test "create_transaction/1 with valid data creates a transaction" do
      caregiver = insert(:user)
      care_getter = insert(:user)
      child = insert(:child, parent: care_getter)

      valid_attrs = %{
        start: @wednesday_ten_am,
        end: @wednesday_two_thirty_pm,
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id,
        child_ids: [child.id]
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.hours == 4.5
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Transactions.create_transaction(%{
                 start: DateTime.utc_now(),
                 end: DateTime.utc_now()
               })
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction =
        insert(:transaction, start: @tuesday_ten_am, end: @wednesday_two_thirty_pm, hours: 28.5)

      update_attrs = %{start: @wednesday_ten_am, end: @wednesday_two_thirty_pm}

      assert transaction.hours == 28.5

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.hours == 4.5
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = insert(:transaction, hours: 2.0)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, %{
                 start: @wednesday_two_thirty_pm,
                 end: @tuesday_ten_am
               })

      assert %Transaction{hours: 2.0} = Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = insert(:transaction)
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = insert(:transaction)
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end

    test "change_transaction/1 should return invalid changeset if missing required data" do
      attrs = %{start: @tuesday_ten_am, end: @wednesday_two_thirty_pm}

      assert %Ecto.Changeset{valid?: false} =
               changeset = Transactions.change_transaction(%Transaction{}, attrs)

      assert [error_1, error_2] = changeset.errors
      assert ^error_1 = {:caregiving_user_id, {"can't be blank", [validation: :required]}}
      assert ^error_2 = {:care_getting_user_id, {"can't be blank", [validation: :required]}}
    end

    test "change_transaction/1 should return invalid changeset if start datetime is after end datetime" do
      caregiving_user = insert(:user)
      care_getting_user = insert(:user)

      attrs = %{
        start: @wednesday_two_thirty_pm,
        end: @tuesday_ten_am,
        caregiving_user_id: caregiving_user.id,
        care_getting_user_id: care_getting_user.id
      }

      assert %Ecto.Changeset{valid?: false} =
               changeset = Transactions.change_transaction(%Transaction{}, attrs)

      assert [error] = changeset.errors

      assert error ==
               {:start, {"Start of caregiving time must be before end of caregiving time.", []}}
    end

    test "change_transaction/1 should return valid changeset with the hours of the caregiving time" do
      caregiving_user = insert(:user)
      care_getting_user = insert(:user)

      attrs = %{
        end: @wednesday_two_thirty_pm,
        start: @tuesday_ten_am,
        caregiving_user_id: caregiving_user.id,
        care_getting_user_id: care_getting_user.id
      }

      assert %Ecto.Changeset{valid?: true} =
               changeset = Transactions.change_transaction(%Transaction{}, attrs)

      assert 28.5 == changeset.changes.hours
    end
  end

  describe "input_transaction/1" do
    test "happy path - inserts transaction and adjusts users' hours_banks" do
      caregiver = insert(:user, hours_bank: 10.0)
      care_getter = insert(:user, hours_bank: 10.0)

      transaction_attrs = %{
        start: @wednesday_ten_am,
        end: @wednesday_two_thirty_pm,
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id
      }

      Transactions.input_transaction(transaction_attrs)

      assert users_hours_bank(caregiver, 14.5)
      assert users_hours_bank(care_getter, 5.5)
    end

    test "failure to create transaction" do
      caregiver = insert(:user, hours_bank: 10.0)
      care_getter = insert(:user, hours_bank: 10.0)

      transaction_attrs = %{
        start: @wednesday_ten_am,
        end: @wednesday_two_thirty_pm,
        caregiving_user_id: caregiver.id,
        care_getting_user_id: nil
      }

      assert {:error, %Ecto.Changeset{valid?: false}} =
               Transactions.input_transaction(transaction_attrs)

      assert [] == Transactions.list_transactions()
      assert users_hours_bank(caregiver, 10.0)
      assert users_hours_bank(care_getter, 10.0)
    end
  end

  describe "edit_transaction/1" do
    test "sames users, change in horus - updates transaction and adjusts users hours" do
      caregiver = insert(:user, hours_bank: 14.5)
      care_getter = insert(:user, hours_bank: 5.5)

      existing_transaction =
        insert(:transaction,
          caregiving_user: caregiver,
          care_getting_user: care_getter,
          start: @wednesday_ten_am,
          end: @wednesday_two_thirty_pm,
          hours: 4.5
        )

      new_attrs = %{
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id,
        start: @wednesday_ten_am,
        end: @wednesday_four_pm
      }

      assert {:ok, %Transaction{hours: 6.0}} =
               Transactions.edit_transaction(existing_transaction.id, new_attrs)

      assert users_hours_bank(caregiver, 16.0)
      assert users_hours_bank(care_getter, 4.0)
    end

    test "different users - updates transaction and adjusts users hours" do
      caregiver = insert(:user, hours_bank: 10.0)
      wrong_care_getter = insert(:user, hours_bank: 10.0)
      correct_care_getter = insert(:user, hours_bank: 10.0)
      correct_care_getter_id = correct_care_getter.id

      existing_transaction =
        insert(:transaction,
          caregiving_user: caregiver,
          care_getting_user: wrong_care_getter,
          start: @wednesday_ten_am,
          end: @wednesday_two_thirty_pm,
          hours: 4.5
        )

      new_attrs = %{
        caregiving_user_id: caregiver.id,
        care_getting_user_id: correct_care_getter.id,
        start: @wednesday_ten_am,
        end: @wednesday_two_thirty_pm
      }

      assert {:ok, %Transaction{care_getting_user_id: ^correct_care_getter_id}} =
               Transactions.edit_transaction(existing_transaction.id, new_attrs)

      assert users_hours_bank(caregiver, 10.0)
      assert users_hours_bank(wrong_care_getter, 14.5)
      assert users_hours_bank(correct_care_getter, 5.5)
    end

    test "no changes if update fails" do
      caregiver = insert(:user, hours_bank: 14.5)
      care_getter = insert(:user, hours_bank: 5.5)

      existing_transaction =
        insert(:transaction,
          caregiving_user: caregiver,
          care_getting_user: care_getter,
          start: @wednesday_ten_am,
          end: @wednesday_two_thirty_pm,
          hours: 4.5
        )

      new_attrs = %{
        caregiving_user: caregiver,
        care_getting_user: care_getter,
        start: @wednesday_four_pm,
        end: @wednesday_ten_am
      }

      assert {:error, _} = Transactions.edit_transaction(existing_transaction.id, new_attrs)

      assert %Transaction{hours: 4.5} = Transactions.get_transaction!(existing_transaction.id)

      assert users_hours_bank(caregiver, 14.5)
      assert users_hours_bank(care_getter, 5.5)
    end
  end

  describe "undo_transaction/1" do
    test "happy path - deletes transaction and restores users hours" do
      caregiver = insert(:user, hours_bank: 14.5)
      care_getter = insert(:user, hours_bank: 5.5)

      existing_transaction =
        insert(:transaction,
          caregiving_user: caregiver,
          care_getting_user: care_getter,
          start: @wednesday_ten_am,
          end: @wednesday_two_thirty_pm,
          hours: 4.5
        )

      assert {:ok, _} = Transactions.undo_transaction(existing_transaction.id)

      assert_raise Ecto.NoResultsError, fn ->
        Transactions.get_transaction!(existing_transaction.id)
      end

      assert users_hours_bank(caregiver, 10.0)
      assert users_hours_bank(caregiver, 10.0)
    end
  end

  describe "list_transactions_for_user/1" do
    test "lists all transactions where user is caregiver or care_getter" do
      user = insert(:user)
      user_id = user.id

      insert(:transaction, caregiving_user: user)
      insert(:transaction, care_getting_user: user)
      insert(:transaction)

      assert [
               %Transaction{
                 caregiving_user_id: ^user_id
               },
               %Transaction{
                 care_getting_user_id: ^user_id
               }
             ] = Transactions.list_transactions_for_user(user)
    end
  end
end
