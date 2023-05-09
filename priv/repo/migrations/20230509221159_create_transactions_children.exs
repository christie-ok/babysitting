defmodule Babysitting.Repo.Migrations.CreateTransactionsChildren do
  use Ecto.Migration

  def change do
    create table(:transactions_children) do
      add :transaction_id, references(:transactions, on_delete: :nothing)
      add :child_id, references(:children, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions_children, [:transaction_id])
    create index(:transactions_children, [:child_id])
  end
end
