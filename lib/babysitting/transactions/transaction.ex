defmodule Babysitting.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Babysitting.Accounts.User

  @decimal_preciscion 2

  schema "transactions" do
    field :hours, :float
    field :start, :utc_datetime
    field :end, :utc_datetime

    belongs_to :caregiving_user, User
    belongs_to :care_getting_user, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:caregiving_user_id, :care_getting_user_id, :start, :end])
    |> validate_required([:caregiving_user_id, :care_getting_user_id, :start, :end])
    |> confirm_end_after_start()
    |> calculate_hours()
    |> validate_required([:hours])
  end

  def confirm_end_after_start(changeset) do
    %{start_datetime: start_datetime, end_datetime: end_datetime} = start_end_times(changeset)

    if DateTime.compare(start_datetime, end_datetime) == :lt do
      changeset
    else
      add_error(changeset, :start, "Start of caregiving time must be before end of caregiving time.")
    end
  end

  def calculate_hours(changeset) do
    %{start_datetime: start_datetime, end_datetime: end_datetime} = start_end_times(changeset)

    hours = DateTime.diff(end_datetime, start_datetime)
    |> seconds_to_hours()

    put_change(changeset, :hours, hours)
  end

  def seconds_to_hours(seconds) do
    seconds / 60 / 60 |> Float.round(@decimal_preciscion)
  end

  defp start_end_times(changeset) do
    %{
      start_datetime: get_field(changeset, :start),
      end_datetime: get_field(changeset, :end)
    }
  end
end
