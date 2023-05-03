defmodule Babysitting.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :hours, :float, null: false
      add :caregiving_user_id, references(:users, on_delete: :nothing), null: false
      add :care_getting_user_id, references(:users, on_delete: :nothing), null: false
      add :start, :utc_datetime, null: false
      add :end, :utc_datetime, null: false

      timestamps()
    end

    create index(:transactions, [:caregiving_user_id])
    create index(:transactions, [:care_getting_user_id])
  end
end
