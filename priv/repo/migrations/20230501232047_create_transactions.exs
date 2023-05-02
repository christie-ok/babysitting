defmodule Babysitting.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :hours, :integer
      add :caregiving_user_id, references(:users, on_delete: :nothing)
      add :care_getting_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:caregiving_user_id])
    create index(:transactions, [:care_getting_user_id])
  end
end
