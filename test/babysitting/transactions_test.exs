defmodule Babysitting.TransactionsTest do
  use Babysitting.DataCase

  alias Babysitting.Transactions
  alias Babysitting.Transactions.Transaction

  @tuesday_ten_am ~U[2023-05-02 10:00:00Z]
  @wednesday_ten_am ~U[2023-05-03 10:00:00Z]
  @wednesday_two_thirty_pm ~U[2023-05-03 14:30:00Z]

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

      valid_attrs = %{
        start: ~U[2023-05-03 12:15:00Z],
        end: ~U[2023-05-03 14:30:00Z],
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.hours == 2.25
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(%{start: DateTime.utc_now(), end: DateTime.utc_now()})
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = insert(:transaction, start: @tuesday_ten_am, end: @wednesday_two_thirty_pm, hours: 28.5)
      update_attrs = %{start: @wednesday_ten_am, end: @wednesday_two_thirty_pm}

      assert transaction.hours == 28.5

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.hours == 4.5
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = insert(:transaction, hours: 2.0)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, %{start: @wednesday_two_thirty_pm, end: @tuesday_ten_am})

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

      assert %Ecto.Changeset{valid?: false} = changeset = Transactions.change_transaction(%Transaction{}, attrs)
      assert [error_1, error_2] = changeset.errors
      assert ^error_1 = {:caregiving_user_id, {"can't be blank", [validation: :required]}}
      assert ^error_2 = {:care_getting_user_id, {"can't be blank", [validation: :required]}}
    end

    test "change_transaction/1 should return invalid changeset if start datetime is after end datetime" do
      caregiving_user = insert(:user)
      care_getting_user = insert(:user)
      attrs = %{start: @wednesday_two_thirty_pm, end: @tuesday_ten_am, caregiving_user_id: caregiving_user.id, care_getting_user_id: care_getting_user.id}

      assert %Ecto.Changeset{valid?: false} = changeset = Transactions.change_transaction(%Transaction{}, attrs)
      assert [error] = changeset.errors
      assert error == {:start, {"Start of caregiving time must be before end of caregiving time.",
      []}}
    end

    test "change_transaction/1 should return valid changeset with the hours of the caregiving time" do
      caregiving_user = insert(:user)
      care_getting_user = insert(:user)
      attrs = %{end: @wednesday_two_thirty_pm, start: @tuesday_ten_am, caregiving_user_id: caregiving_user.id, care_getting_user_id: care_getting_user.id}

      assert %Ecto.Changeset{valid?: true} = changeset = Transactions.change_transaction(%Transaction{}, attrs)
      assert 28.5 == changeset.changes.hours
    end
  end
end
