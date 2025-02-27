defmodule PRQL do
  @moduledoc """
  Documentation for `PRQL`.

  This module provide Elixir bindings for [PRQL](https://prql-lang.org/).

  PRQL is a modern language for transforming data.
  """
  alias PRQL.Native.CompileOptions

  @type target() ::
          :generic
          | :mssql
          | :mysql
          | :postgres
          | :ansi
          | :bigquery
          | :clickhouse
          | :glaredb
          | :sqlite
          | :snowflake
  @type format_opt :: {:format, boolean()}
  @type signature_comment_opt :: {:signature_comment, boolean()}
  @type target_opt :: {:target, target()}
  @type compile_opts :: format_opt() | signature_comment_opt() | target_opt()

  @doc ~S"""
  Compile a `PRQL` query to `SQL` query.

  Returns generated SQL query on success in shape of `{:ok, sql}`. This SQL query can
  be safely fed into a SQL driver to get the output.

  On error, `{:error, reason}` is returned where `reason` is a `JSON` string.
  Use any `JSON` encoder library to encode it.

  ## Options

    * `:target` - Dialect used for generate SQL. Accepted values are
    `:generic`, `:mssql`, `:mysql`, `:postgres`, `:ansi`, `:bigquery`,
    `:clickhouse`, `:glaredb`, `:sqlite`, `:snowflake`

    * `:format` - Formats the output, defaults to `true`

    * `signature_comment` - Set the signature comment generated by PRQL, defaults to `true`


  ## Examples

  Using default `Generic` target:
      iex> PRQL.compile("from customers", signature_comment: false)
      {:ok, "SELECT\n  *\nFROM\n  customers\n"}


  Using `MSSQL` target:
      iex> PRQL.compile("from customers\ntake 10", target: :mssql, signature_comment: false)
      {:ok, "SELECT\n  TOP (10) *\nFROM\n  customers\n"}
  """
  @spec compile(binary(), [compile_opts()]) :: {:ok, binary()} | {:error, binary()}
  def compile(prql_query, opts \\ []) when is_binary(prql_query) and is_list(opts) do
    PRQL.Native.compile(prql_query, struct(CompileOptions, opts))
  end

  @doc """
  The same as `compile/2` but raises `PRQL.PRQLError` exception in case of error
  """
  @spec compile!(binary(), [compile_opts()]) :: binary()
  def compile!(prql_query, opts \\ []) do
    case compile(prql_query, opts) do
      {:ok, result} -> result
      {:error, reason} -> raise PRQL.PRQLError, reason
    end
  end

  @doc """
  PRQL to PL AST
  """
  @spec prql_to_pl(binary()) :: {:ok, binary()} | {:error, binary()}
  def prql_to_pl(prql_query) when is_binary(prql_query) do
    PRQL.Native.prql_to_pl(prql_query)
  end

  @doc """
  The same as `prql_to_pl/1` but raises `PRQL.PRQLError` exception in case of error
  """
  @spec prql_to_pl!(binary()) :: binary()
  def prql_to_pl!(prql_query) when is_binary(prql_query) do
    case prql_to_pl(prql_query) do
      {:ok, result} -> result
      {:error, reason} -> raise PRQL.PRQLError, reason
    end
  end

  @doc """
  PL AST to RQ
  """
  @spec pl_to_rq(binary()) :: {:ok, binary()} | {:error, binary()}
  def pl_to_rq(pl_json) do
    PRQL.Native.pl_to_rq(pl_json)
  end

  @doc """
  The same as `pl_to_rq/1` but raises `PRQL.PRQLError` exception in case of error
  """
  @spec pl_to_rq!(binary()) :: binary()
  def pl_to_rq!(pl_json) do
    case pl_to_rq(pl_json) do
      {:ok, result} -> result
      {:error, reason} -> raise PRQL.PRQLError, reason
    end
  end

  @doc """
  RQ to SQL
  """
  @spec rq_to_sql(binary()) :: {:ok, binary()} | {:error, binary()}
  def rq_to_sql(rq_json) do
    PRQL.Native.rq_to_sql(rq_json)
  end

  @doc """
  The same as `rq_to_sql/1` but raises `PRQL.PRQLError` exception in case of error
  """
  @spec rq_to_sql!(binary()) :: binary()
  def rq_to_sql!(rq_json) do
    case rq_to_sql(rq_json) do
      {:ok, result} -> result
      {:error, reason} -> raise PRQL.PRQLError, reason
    end
  end
end
