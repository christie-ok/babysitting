defmodule Babysitting.Children.Child do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :parent_id, :first_name, :last_name, :birthday, :gender]}

  alias Babysitting.Accounts.User

  schema "children" do
    field :birthday, :date
    field :first_name, :string
    field :gender, Ecto.Enum, values: [:girl, :boy, :other, :decline_to_state]
    field :last_name, :string

    many_to_many :transactions, Babysitting.Transactions.Transaction, join_through: "transactions_children"

    belongs_to :parent, User

    timestamps()
  end

  @doc false
  def changeset(child, attrs) do
    child
    |> cast(attrs, [:first_name, :last_name, :birthday, :gender, :parent_id])
    |> validate_required([:first_name, :last_name, :birthday, :gender, :parent_id])
  end
end
