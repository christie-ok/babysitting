defmodule Babysitting.TransactionsTest do
  use Babysitting.DataCase

  alias Babysitting.Transactions

  @tuesday_ten_am ~U[2023-05-02 10:00:00Z]
  @wednesday_ten_am ~U[2023-05-03 10:00:00Z]
  @wednesday_two_thirty_pm ~U[2023-05-03 14:30:00Z]

  describe "transactions" do
    alias Babysitting.Transactions.Transaction

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
  end

  describe "calculate_hours/1"  do
    test "calculates length of care given" do
      transaction = insert(:transaction, start: @wednesday_ten_am, end: @wednesday_two_thirty_pm)
       assert %{hours: 4.5} == Transactions.change_transaction(transaction).changes
    end
  end
end
