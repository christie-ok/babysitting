defmodule Babysitting.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:address, :city, :first_name, :last_name, :state, :zip, :hours_bank, :children]}

  @required_fields [:first_name, :last_name]
  @optional_fields [:address, :city, :state, :zip, :hours_bank]
  @fields @required_fields ++ @optional_fields

  schema "users" do
    field :address, :string
    field :city, :string
    field :first_name, :string
    field :last_name, :string
    field :state, :string
    field :zip, :string
    field :hours_bank, :float, default: 0.0

    has_many :children, Babysitting.Children.Child, foreign_key: :parent_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
