defmodule BillingWeb.CertificateLiveTest do
  use BillingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Billing.CertificatesFixtures

  @create_attrs %{file: "some file", password: "some password"}
  @update_attrs %{file: "some updated file", password: "some updated password"}
  @invalid_attrs %{file: nil, password: nil}
  defp create_certificate(_) do
    certificate = certificate_fixture()

    %{certificate: certificate}
  end

  describe "Index" do
    setup [:create_certificate]

    test "lists all certificates", %{conn: conn, certificate: certificate} do
      {:ok, _index_live, html} = live(conn, ~p"/certificates")

      assert html =~ "Listing Certificates"
      assert html =~ certificate.file
    end

    test "saves new certificate", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/certificates")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Certificate")
               |> render_click()
               |> follow_redirect(conn, ~p"/certificates/new")

      assert render(form_live) =~ "New Certificate"

      assert form_live
             |> form("#certificate-form", certificate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#certificate-form", certificate: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/certificates")

      html = render(index_live)
      assert html =~ "Certificate created successfully"
      assert html =~ "some file"
    end

    test "updates certificate in listing", %{conn: conn, certificate: certificate} do
      {:ok, index_live, _html} = live(conn, ~p"/certificates")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#certificates-#{certificate.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/certificates/#{certificate}/edit")

      assert render(form_live) =~ "Edit Certificate"

      assert form_live
             |> form("#certificate-form", certificate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#certificate-form", certificate: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/certificates")

      html = render(index_live)
      assert html =~ "Certificate updated successfully"
      assert html =~ "some updated file"
    end

    test "deletes certificate in listing", %{conn: conn, certificate: certificate} do
      {:ok, index_live, _html} = live(conn, ~p"/certificates")

      assert index_live
             |> element("#certificates-#{certificate.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#certificates-#{certificate.id}")
    end
  end

  describe "Show" do
    setup [:create_certificate]

    test "displays certificate", %{conn: conn, certificate: certificate} do
      {:ok, _show_live, html} = live(conn, ~p"/certificates/#{certificate}")

      assert html =~ "Show Certificate"
      assert html =~ certificate.file
    end

    test "updates certificate and returns to show", %{conn: conn, certificate: certificate} do
      {:ok, show_live, _html} = live(conn, ~p"/certificates/#{certificate}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/certificates/#{certificate}/edit?return_to=show")

      assert render(form_live) =~ "Edit Certificate"

      assert form_live
             |> form("#certificate-form", certificate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#certificate-form", certificate: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/certificates/#{certificate}")

      html = render(show_live)
      assert html =~ "Certificate updated successfully"
      assert html =~ "some updated file"
    end
  end
end
