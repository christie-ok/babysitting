defmodule Babysitting.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Babysitting.Accounts.User

  schema "transactions" do
    field :hours, :integer

    belongs_to :caregiving_user, User
    belongs_to :care_getting_user, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:caregiving_user_id, :care_getting_user_id, :hours])
    |> validate_required([:caregiving_user_id, :care_getting_user_id, :hours])
  end
end
