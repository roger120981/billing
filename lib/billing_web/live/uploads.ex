defmodule BillingWeb.Uploads do
  use BillingWeb, :live_view

  alias Billing.Storage

  def consume_files(socket, uploader) when is_atom(uploader) do
    consume_uploaded_entries(socket, uploader, fn %{path: path}, entry ->
      extname = Path.extname(entry.client_name)
      file_name = entry.uuid <> extname
      user_id = socket.assigns.current_scope.user.uuid

      Storage.save_upload!(socket.assigns.current_scope, path, file_name)

      {:ok, ~p"/uploads/#{user_id}/#{file_name}"}
    end)
  end
end
