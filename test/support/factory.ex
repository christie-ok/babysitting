defmodule Babysitting.Factory do
  use ExMachina.Ecto, repo: Babysitting.Repo

  @five_years_ago 365 * 5

  def user_factory do
    %Babysitting.Accounts.User{
      first_name: sequence("user_first_name"),
      last_name: sequence("user_last_name"),
      hours_bank: 0
    }
  end

  def child_factory do
    today = Date.utc_today()
    five_years_ago = Date.add(today, -@five_years_ago)

    %Babysitting.Children.Child{
      first_name: sequence("child_first_name"),
      last_name: sequence("child_last_name"),
      birthday: Enum.random(Date.range(five_years_ago, today)),
      gender: Enum.random([:girl, :boy, :other, :decline_to_state]),
      parent: build(:user)
    }
  end

  def transaction_factory do
    now = DateTime.utc_now()

    %Babysitting.Transactions.Transaction{
      caregiving_user: build(:user),
      care_getting_user: build(:user),
      start: DateTime.add(now, -5, :hour),
      end: DateTime.add(now, -3, :hour),
      hours: 2.0
    }
  end
end
