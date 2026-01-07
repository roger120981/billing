defmodule BillingWeb.SettingLive.Form do
  use BillingWeb, :live_view

  import BillingWeb.Uploads, only: [consume_files: 2]

  alias Billing.Settings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} settings={@settings}>
      <div class="text-center">
        <.header>
          {gettext("Store Setttings")}
          <:subtitle>
            {gettext("ustomize your store, change the store name or upload a logo")}
          </:subtitle>
        </.header>
      </div>

      <.form
        for={@form}
        id="form"
        phx-submit="update_setting"
        phx-change="validate_setting"
      >
        <.input
          field={@form[:title]}
          type="text"
          label={gettext("Title")}
          required
        />

        <div class="mb-3">
          <.live_file_input upload={@uploads.avatar} class="file-input" />
        </div>

        <section phx-drop-target={@uploads.avatar.ref} class="phx-drop-target-active:scale-105">
          <article :for={entry <- @uploads.avatar.entries} class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption>{entry.client_name}</figcaption>
            </figure>

            <progress value={entry.progress} max="100">{entry.progress}% </progress>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

            <p :for={err <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">
              {error_to_string(err)}
            </p>
          </article>

          <p :for={err <- upload_errors(@uploads.avatar)} class="alert alert-danger">
            {error_to_string(err)}
          </p>
        </section>

        <.button variant="primary" phx-disable-with={gettext("Changing...")}>
          {gettext("Save Settings")}
        </.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    setting = Settings.get_setting!(socket.assigns.current_scope)
    setting_changeset = Settings.change_setting(socket.assigns.current_scope, setting)

    socket =
      socket
      |> assign(:setting, setting)
      |> assign(:form, to_form(setting_changeset))
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_setting", %{"setting" => setting_params}, socket) do
    form =
      socket.assigns.current_scope
      |> Settings.change_setting(socket.assigns.setting, setting_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("update_setting", %{"setting" => setting_params}, socket) do
    avatar =
      socket
      |> consume_files(:avatar)
      |> List.first()

    setting_params = Map.put(setting_params, "avatar", avatar)

    case Settings.save_setting(
           socket.assigns.current_scope,
           socket.assigns.setting,
           setting_params
         ) do
      {:ok, _setting} ->
        info = gettext("Settings saved")
        {:noreply, socket |> put_flash(:info, info) |> push_navigate(to: ~p"/settings")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
