defmodule TasxCore.Mailer do
  use Swoosh.Mailer, otp_app: :tasx

  import Ecto.Changeset, only: [change: 2, add_error: 3]

  require Logger

  def send_email(%Swoosh.Email{} = email) do
    case deliver(email) do
      {:ok, _metadata} ->
        {:ok, email}

      {:error, reason} ->
        Logger.error("Mailer error: #{inspect(reason)}")

        {%{}, %{email: :map}}
        |> change(%{email: Map.from_struct(email)})
        |> add_error(:email, "couldn't be sent")
        |> then(&{:error, &1})
    end
  end
end
