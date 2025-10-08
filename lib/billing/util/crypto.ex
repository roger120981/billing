defmodule Billing.Util.Crypto do
  def encrypt(salt, payload) do
    Plug.Crypto.encrypt(get_crypto_key_base(), salt, payload)
  end

  def decrypt(salt, payload_encrypted) do
    Plug.Crypto.decrypt(get_crypto_key_base(), salt, payload_encrypted)
  end

  defp get_crypto_key_base do
    Application.get_env(:billing, :crypto_key_base)
  end
end
