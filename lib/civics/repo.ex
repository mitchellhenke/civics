defmodule Civics.Repo do
  use Ecto.Repo,
    otp_app: :civics,
    adapter: Ecto.Adapters.Postgres
end
