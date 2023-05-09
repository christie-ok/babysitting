defmodule Babysitting.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Babysitting.Repo

  alias Babysitting.Accounts.User
  alias Babysitting.Transactions.Transaction

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
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
