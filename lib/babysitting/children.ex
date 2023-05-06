defmodule Babysitting.Children do
  @moduledoc """
  The Children context.
  """

  import Ecto.Query, warn: false
  alias Babysitting.Repo

  alias Babysitting.Children.Child

  @doc """
  Returns the list of children.

  ## Examples

      iex> list_children()
      [%Child{}, ...]

  """
  def list_children do
    Repo.all(Child)
  end

  @doc """
  Gets a single child.

  Raises `Ecto.NoResultsError` if the Child does not exist.

  ## Examples

      iex> get_child!(123)
      %Child{}

      iex> get_child!(456)
      ** (Ecto.NoResultsError)

  """
  def get_child!(id), do: Repo.get!(Child, id)

  @doc """
  Creates a child.

  ## Examples

      iex> create_child(%{field: value})
      {:ok, %Child{}}

      iex> create_child(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_child(attrs \\ %{}) do
    %Child{}
    |> Child.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a child.

  ## Examples

      iex> update_child(child, %{field: new_value})
      {:ok, %Child{}}

      iex> update_child(child, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_child(%Child{} = child, attrs) do
    child
    |> Child.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a child.

  ## Examples

      iex> delete_child(child)
      {:ok, %Child{}}

      iex> delete_child(child)
      {:error, %Ecto.Changeset{}}

  """
  def delete_child(%Child{} = child) do
    Repo.delete(child)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking child changes.

  ## Examples

      iex> change_child(child)
      %Ecto.Changeset{data: %Child{}}

  """
  def change_child(%Child{} = child, attrs \\ %{}) do
    Child.changeset(child, attrs)
  end

  def insert_all_children(children, parent) do
    children =
      Enum.map(
        children,
        &Map.merge(&1, %{
          parent_id: parent.id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        })
      )

    Repo.insert_all(Child, children,
      placeholders: %{timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}
    )
  rescue
    _ -> {:error, "Error inserting children."}
  end
end
