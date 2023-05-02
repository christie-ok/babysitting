defmodule Babysitting.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :address, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :hours_bank, :integer, default: 0

      timestamps()
    end
  end
end
