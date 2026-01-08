defmodule Billing.Repo.Migrations.AddLightDarkThemeToSettings do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :light_theme, :text
      add :dark_theme, :text
    end
  end
end
