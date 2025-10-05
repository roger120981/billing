# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Billing.Repo.insert!(%Billing.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Billing.Repo
alias Billing.Customers.Customer
alias Billing.Companies.Company
alias Billing.Certificates.Certificate
alias Billing.EmissionProfiles.EmissionProfile

customers = [
  "Scorpion",
  "Sub-Zero",
  "Raiden",
  "Liu Kang",
  "Johnny Cage",
  "Sonya Blade",
  "Kitana",
  "Mileena",
  "Jax Briggs",
  "Kung Lao"
]

Enum.each(customers, fn full_name ->
  email = Regex.replace(~r/\s/, full_name, ".")

  %Customer{
    full_name: full_name,
    email: "#{email}@example.com",
    identification_number: "1234567890",
    identification_type: :cedula,
    address: "Arena",
    phone_number: "9999999999"
  }
  |> Repo.insert!()
end)

company =
  %Company{
    identification_number: "1234567890001",
    address: "Quito - Ecuador",
    name: "Mi empresa"
  }
  |> Repo.insert!()

certificate =
  %Certificate{
    name: "Firma P12",
    file: "file.p12",
    password: "Cambiar"
  }
  |> Repo.insert!()

%EmissionProfile{
  company_id: company.id,
  certificate_id: certificate.id,
  name: "Punto de emision 1"
}
|> Repo.insert!()
