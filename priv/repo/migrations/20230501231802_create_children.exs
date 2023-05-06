defmodule Babysitting.Repo.Migrations.CreateChildren do
  use Ecto.Migration

  def change do
    create table(:children) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :birthday, :date, null: false
      add :gender, :string
      add :parent_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:children, [:parent_id])
  end
end
