defmodule TasxCore.Access.Emails do
  @moduledoc """
  `Access.Emails` context
  """

  alias TasxCore.Access.Emails.VerificationCode

  @doc ~S"""
  Sends an `VerificationCode` to the user email

  ## Examples

      iex> send_verification_code(user, code)
      {:ok, %Swoosh.Email{}}

      iex> send_verification_code(user, code)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate send_verification_code(user, code), to: VerificationCode.Send, as: :call
end
