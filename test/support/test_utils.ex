defmodule Babysitting.TestUtils do
  def users_hours_bank(user, hours) do
    user = Babysitting.Accounts.get_user(user.id)
    user.hours_bank == hours
  end
end
