defmodule Billing.InvoiceHandler do
  alias Billing.Invoices
  alias Billing.Invoicing
  alias Billing.TaxiDriver
  alias Billing.ElectronicInvoices
  alias Billing.EmissionProfiles
  alias Billing.Invoices.ElectronicInvoice
  alias Phoenix.PubSub

  def handle_invoice(invoice_id) do
    invoice = Invoices.get_invoice!(invoice_id)
    certificate = Billing.Invoicing.fetch_certificate(invoice)

    with {:ok, invoice_params} <- Invoicing.build_request_params(invoice),
         # Electronic Invoice :created
         {:ok, electronic_invoice} <- create_electronic_invoice(invoice.id, invoice_params),
         {:ok, _invoice_id} <- broadcast_success(invoice_id),

         # Electronic Invoice :signed
         {:ok, electronic_invoice} <- signed_xml(electronic_invoice, certificate),
         {:ok, _invoice_id} <- broadcast_success(invoice_id),

         # Electronic Invoice :send | :back | :error
         {:ok, electronic_invoice} <- send_invoice(electronic_invoice),
         {:ok, _invoice_id} <- broadcast_success(invoice_id),

         # Electronic Invoice :authorized | :unauthorized | :error | :not_found_or_pending
         {:ok, electronic_invoice} <- verify_authorization(electronic_invoice),
         {:ok, _invoice_id} <- broadcast_success(invoice_id),

         # Update Emission profile sequence
         {:ok, emission_profile} <-
           increment_emission_profile_sequence(
             invoice.emission_profile_id,
             electronic_invoice.state
           ),

         # Electronic Invoice: PDF
         {:ok, _pdf_file_path} <- create_pdf(electronic_invoice) do
      {:ok, emission_profile}
    else
      {:error, error} ->
        broadcast_error(invoice_id, error)

        {:error, error}
    end
  end

  def handle_auth_invoice(electronic_invoice_id) do
    electronic_invoice = ElectronicInvoices.get_electronic_invoice!(electronic_invoice_id)
    invoice = Invoices.get_invoice!(electronic_invoice.invoice_id)

    # Electronic Invoice :authorized | :unauthorized | :error | :not_found_or_pending

    with {:ok, electronic_invoice} <- verify_authorization(electronic_invoice),
         {:ok, _invoice_id} <- broadcast_success(invoice.id),
         {:ok, emission_profile} <-
           increment_emission_profile_sequence(
             invoice.emission_profile_id,
             electronic_invoice.state
           ),
         {:ok, _pdf_file_path} <- create_pdf(electronic_invoice) do
      {:ok, emission_profile}
    else
      {:error, error} ->
        broadcast_error(invoice.id, error)

        {:error, error}
    end
  end

  # Electronic Invoice :created

  def create_electronic_invoice(invoice_id, invoice_params) do
    with {:ok, body: xml, access_key: access_key} <- TaxiDriver.build_invoice_xml(invoice_params),
         {:ok, _xml_path} <- save_xml(xml, access_key) do
      ElectronicInvoices.create_electronic_invoice(invoice_id, access_key)
    else
      error -> error
    end
  end

  # Electronic Invoice :signed

  def signed_xml(%ElectronicInvoice{state: :created} = electronic_invoice, certificate) do
    xml_path = "#{Billing.get_storage_path()}/#{electronic_invoice.access_key}.xml"

    with {:ok, signed_xml} <- TaxiDriver.sign_invoice_xml(xml_path, certificate),
         {:ok, electronic_invoice} <-
           ElectronicInvoices.update_electronic_invoice(electronic_invoice, :signed),
         {:ok, _signed_xml_path} <- save_signed_xml(signed_xml, electronic_invoice.access_key) do
      {:ok, electronic_invoice}
    else
      error -> error
    end
  end

  def signed_xml(_electronic_invoice, _certificate) do
    {:error, "Factura no creada"}
  end

  # Electronic Invoice :send | :back | :error

  defp send_invoice(%ElectronicInvoice{state: :signed} = electronic_invoice) do
    signed_xml_path = "#{Billing.get_storage_path()}/#{electronic_invoice.access_key}-signed.xml"

    with {:ok, body: response_xml, sri_status: sri_status} <-
           TaxiDriver.send_invoice_xml(signed_xml_path),
         {:ok, _electronic_invoice} <-
           ElectronicInvoices.update_electronic_invoice(
             electronic_invoice,
             ElectronicInvoice.determinate_status(sri_status)
           ),
         {:ok, _response_xml_path} <-
           save_response_xml(response_xml, electronic_invoice.access_key) do
      {:ok, electronic_invoice}
    else
      error -> error
    end
  end

  defp send_invoice(_electronic_invoice) do
    {:error, "Factura no firmada"}
  end

  # Electronic Invoice :authorized | :unauthorized | :error | :not_found_or_pending

  defp verify_authorization(%ElectronicInvoice{state: :sent} = electronic_invoice) do
    with {:ok, body: auth_xml, sri_status: sri_status} <-
           TaxiDriver.auth_invoice(electronic_invoice.access_key),
         {:ok, electronic_invoice} <-
           ElectronicInvoices.update_electronic_invoice(
             electronic_invoice,
             ElectronicInvoice.determinate_status(sri_status)
           ),
         {:ok, _auth_xml_path} <- save_auth_response_xml(auth_xml, electronic_invoice.access_key) do
      {:ok, electronic_invoice}
    else
      error -> error
    end
  end

  defp verify_authorization(_electronic_invoice) do
    {:error, "Factura no autorizada"}
  end

  # Update Emission profile sequence

  defp increment_emission_profile_sequence(emission_profile_id, :authorized) do
    emission_profile = EmissionProfiles.get_emission_profile!(emission_profile_id)

    new_sequence = emission_profile.sequence + 1

    EmissionProfiles.update_emission_profile(emission_profile, %{sequence: new_sequence})
  end

  defp increment_emission_profile_sequence(_emission_profile_id, _state) do
    {:error, "Factura no autorizada"}
  end

  # Electronic Invoice: PDF

  defp create_pdf(%ElectronicInvoice{state: :authorized} = electronic_invoice) do
    auth_xml_path = "#{Billing.get_storage_path()}/#{electronic_invoice.access_key}-auth.xml"

    with {:ok, pdf_content} <- TaxiDriver.pdf_invoice_xml(auth_xml_path),
         {:ok, _pdf_file_path} <- save_pdf_file(pdf_content, electronic_invoice.access_key) do
    else
      error -> error
    end
  end

  defp create_pdf(_electronic_invoice) do
    {:error, "Factura no autorizada"}
  end

  # Store files section

  defp save_xml(xml, access_key) do
    path = "#{Billing.get_storage_path()}/#{access_key}.xml"
    File.write(path, xml)

    {:ok, path}
  end

  defp save_signed_xml(xml, access_key) do
    path = "#{Billing.get_storage_path()}/#{access_key}-signed.xml"
    File.write(path, xml)

    {:ok, path}
  end

  defp save_response_xml(xml, access_key) do
    path = "#{Billing.get_storage_path()}/#{access_key}-response.xml"
    File.write(path, xml)

    {:ok, path}
  end

  defp save_auth_response_xml(xml, access_key) do
    path = "#{Billing.get_storage_path()}/#{access_key}-auth.xml"
    File.write(path, xml)

    {:ok, path}
  end

  defp save_pdf_file(pdf_content, access_key) do
    path = "#{Billing.get_storage_path()}/#{access_key}.pdf"
    File.write(path, pdf_content)

    {:ok, path}
  end

  # Broadcast section

  defp broadcast_success(invoice_id) do
    PubSub.broadcast(
      Billing.PubSub,
      "invoice:#{invoice_id}",
      {:update_electronic_invoice, %{invoice_id: invoice_id}}
    )

    {:ok, invoice_id}
  end

  def broadcast_error(invoice_id, error) do
    PubSub.broadcast(
      Billing.PubSub,
      "invoice:#{invoice_id}",
      {:electronic_invoice_error, %{invoice_id: invoice_id, error: inspect(error)}}
    )

    {:error, error}
  end
end
