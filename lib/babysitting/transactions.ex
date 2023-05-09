defmodule Babysitting.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Babysitting.Repo

  alias Babysitting.Transactions.Transaction

  defdelegate update_users_hours_banks(transaction), to: Babysitting.Accounts
  defdelegate restore_users_hours_banks(transaction), to: Babysitting.Accounts

  def input_transaction(attrs \\ %{}) do
    Repo.transaction(fn ->
      case create_transaction(attrs) do
        {:ok, transaction} ->
          update_users_hours_banks(transaction)
          transaction

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def edit_transaction(transaction_id, attrs) do
    transaction = get_transaction!(transaction_id)

    Repo.transaction(fn ->
      case update_transaction(transaction, attrs) do
        {:ok, transaction_updated} ->
          restore_users_hours_banks(transaction)
          update_users_hours_banks(transaction_updated)
          transaction_updated

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def undo_transaction(transaction_id) do
    transaction = get_transaction!(transaction_id)

    Repo.transaction(fn ->
      case delete_transaction(transaction) do
        {:ok, transaction} ->
          restore_users_hours_banks(transaction)
          transaction

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def list_transactions do
    Repo.all(Transaction)
  end

  def get_transaction!(id) when is_binary(id) do
    id = String.to_integer(id)

    get_transaction!(id)
  end

  def get_transaction!(id), do: Repo.get!(Transaction, id)

  def create_transaction(attrs \\ %{}) do
    %{child_ids: child_ids} = attrs

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  def list_transactions_for_user(user) do
    query =
      from t in Transaction,
        where: t.caregiving_user_id == ^user.id or t.care_getting_user_id == ^user.id

    Repo.all(query)
  end
end
