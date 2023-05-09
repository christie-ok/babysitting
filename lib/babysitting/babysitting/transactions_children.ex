defmodule Babysitting.Babysitting.TransactionsChildren do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions_children" do

    field :transaction_id, :id
    field :child_id, :id

    timestamps()
  end

  @doc false
  def changeset(transactions_children, attrs) do
    transactions_children
    |> cast(attrs, [])
    |> validate_required([])
  end
end
