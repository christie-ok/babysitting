defmodule Babysitting.TransactionsTest do
  use Babysitting.DataCase

  alias Babysitting.Transactions

  describe "transactions" do
    alias Babysitting.Transactions.Transaction

    @invalid_attrs %{hours: nil}

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
        hours: 42,
        caregiving_user_id: caregiver.id,
        care_getting_user_id: care_getter.id
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.hours == 42
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = insert(:transaction)
      update_attrs = %{hours: 43}

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.hours == 43
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = insert(:transaction, hours: 5)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert %Transaction{hours: 5} = Transactions.get_transaction!(transaction.id)
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
end
