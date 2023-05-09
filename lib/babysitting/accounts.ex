defmodule Babysitting.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Babysitting.Repo

  alias Babysitting.Accounts.User
  alias Babysitting.Transactions.Transaction

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(user_id, attrs) when is_binary(user_id) do
    user = get_user!(user_id)

    update_user(user, attrs)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def user_options do
    list_users()
    |> Enum.map(&{full_name(&1), &1.id})
  end

  def get_parent_with_children_by(get_by, value) do
    lookup = Map.new([{get_by, value}])

    Repo.get_by(
      User,
      lookup
    )
    |> Repo.preload([:children])
  end

  def update_users_hours_banks(%Transaction{} = transaction) do
    %{caregiving_user: caregiving_user, care_getting_user: care_getting_user, hours: hours} =
      Repo.preload(transaction, [:caregiving_user, :care_getting_user], force: true)

    add_hours_to_bank(caregiving_user, hours)
    deduct_hours_from_bank(care_getting_user, hours)
  end

  def restore_users_hours_banks(%Transaction{} = transaction) do
    %{caregiving_user: caregiving_user, care_getting_user: care_getting_user, hours: hours} =
      Repo.preload(transaction, [:caregiving_user, :care_getting_user])

    add_hours_to_bank(care_getting_user, hours)
    deduct_hours_from_bank(caregiving_user, hours)
  end

  defp add_hours_to_bank(user, hours) do
    update_user(user, %{hours_bank: user.hours_bank + hours})
  end

  defp deduct_hours_from_bank(user, hours) do
    update_user(user, %{hours_bank: user.hours_bank - hours})
  end
end
