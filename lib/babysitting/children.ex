defmodule Babysitting.Children do
  @moduledoc """
  The Children context.
  """

  import Ecto.Query, warn: false
  alias Babysitting.Repo

  alias Babysitting.Children.Child

  def list_children do
    Repo.all(Child)
  end

  def get_child!(id), do: Repo.get!(Child, id)

  def create_child(attrs \\ %{}) do
    %Child{}
    |> Child.changeset(attrs)
    |> Repo.insert()
  end

  def update_child(%Child{} = child, attrs) do
    child
    |> Child.changeset(attrs)
    |> Repo.update()
  end

  def delete_child(%Child{} = child) do
    Repo.delete(child)
  end

  def change_child(%Child{} = child, attrs \\ %{}) do
    Child.changeset(child, attrs)
  end

  def child_age(%Child{} = child) do
    Date.diff(Date.utc_today(), child.birthday)
    |> div(365)
    |> floor()
  end
end
