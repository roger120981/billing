defmodule Billing.TaxiDriver do
  @invoice_url "https://api.taxideral.com/facturas"
  @sign_invoice_url "https://api.taxideral.com/firmar"

  @headers [
    {"Content-Type", "application/json"},
    {"accept", "application/xml"}
  ]

  def build_invoice_xml(invoice_params) do
    json_body = Jason.encode!(invoice_params)

    case HTTPoison.post(@invoice_url, json_body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def sing_invoice_xml(xml_path, certificate) do
    headers = ["Content-Type": "multipart/form-data"]

    form_data = [
      {"p12_file", "priv/static/uploads/#{certificate.file}"},
      {"xml_file", xml_path},
      {"p12_password", certificate.password}
    ]

    IO.inspect(HTTPoison.post(@sign_invoice_url, {:multipart, form_data}, headers))

    # case HTTPoison.post(@sign_invoice_url, {:multipart, form_data}, headers) do
    #   {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
    #     {:ok, body}

    #   {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
    #     {:error, %{status_code: status_code, body: body}}

    #   {:error, %HTTPoison.Error{reason: reason}} ->
    #     {:error, reason}
    # end
  end
end
