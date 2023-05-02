defmodule Babysitting.Repo.Migrations.CreateChildren do
  use Ecto.Migration

  def change do
    create table(:children) do
      add :first_name, :string
      add :last_name, :string
      add :birthday, :date
      add :gender, :string
      add :parent_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:children, [:parent_id])
  end
end
