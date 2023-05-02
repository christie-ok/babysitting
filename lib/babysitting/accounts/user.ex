defmodule Babysitting.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :address, :string
    field :city, :string
    field :first_name, :string
    field :last_name, :string
    field :state, :string
    field :zip, :string
    field :hours_bank, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :address, :city, :state, :zip, :hours_bank])
    |> validate_required([:first_name, :last_name])
  end
end
