defmodule Babysitting.Repo do
  use Ecto.Repo,
    otp_app: :babysitting,
    adapter: Ecto.Adapters.Postgres
end
