defmodule Api.Repo.Migrations.SetupDatabase do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION pg_trgm", "DROP EXTENSION pg_trgm"
    execute "CREATE EXTENSION citext", "DROP EXTENSION citext"
    execute "CREATE FUNCTION count_not_nulls(variadic p_array anyarray) RETURNS BIGINT AS $$ SELECT count(x) FROM unnest($1) AS x $$ LANGUAGE SQL IMMUTABLE;"
  end
end
