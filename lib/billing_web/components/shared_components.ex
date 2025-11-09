defmodule BillingWeb.SharedComponents do
  use Phoenix.Component
  use Gettext, backend: BillingWeb.Gettext
  use BillingWeb, :verified_routes

  alias BillingWeb.CoreComponents

  @doc """
  Render the raw content as markdown. Returns HTML rendered text.
  """
  def render_markdown(nil), do: Phoenix.HTML.raw(nil)

  def render_markdown(text) when is_binary(text) do
    # NOTE: This allows explicit HTML to come through.
    #   - Don't allow this with user input.
    text |> Earmark.as_html!(escape: false) |> Phoenix.HTML.raw()
  end

  @doc """
  Render a markdown containing web component.
  """
  attr :text, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def markdown(%{text: nil} = assigns), do: ~H""

  def markdown(assigns) do
    ~H"""
    <article class={["prose dark:prose-invert", @class]} {@rest}>{render_markdown(@text)}</article>
    """
  end

  attr :cart_size, :integer, required: true

  def cart_status(assigns) do
    ~H"""
    <div class={[
      "card w-full shadow-sm",
      @cart_size == 0 && "bg-neutral text-neutral-content",
      @cart_size > 0 && "bg-primary text-primary-content"
    ]}>
      <div class="card-body">
        <div class="flex justify-between">
          <h2 class="card-title">
            {ngettext("One product in your cart", "%{count} products in your cart", @cart_size)}
          </h2>

          <div class="card-actions justify-end">
            <.link :if={@cart_size > 0} navigate={~p"/cart"} class="btn btn-neutral">
              <CoreComponents.icon name="hero-shopping-cart" /> {gettext("View Cart")}
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
