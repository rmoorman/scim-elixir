defmodule SCIM.V2.Filter.Parser do
  @moduledoc """
  Parser module for parsing SCIM filters and paths

  This module contains functionality to parse SCIM filter and path strings that
  adhere to the specification with some additions (e.g. multi-line support).

  The parser handles basic primitive value conversion/casting for strings,
  booleans, nil, and numbers. More complex conversions should be done
  elsewhere.
  """
  @external_resource "lib/scim/v2/filter/parser.abnf"

  use AbnfParsec,
    abnf_file: "lib/scim/v2/filter/parser.abnf",
    transform: %{
      "string" => {:reduce, {List, :to_string, []}},
      "true" => {:replace, true},
      "false" => {:replace, false},
      "null" => {:replace, nil},
      "number" => {:post_traverse, {:extract_decimal, []}},
      "compareOp" => {:post_traverse, {:extract_lc_op, []}},
      "presentOp" => {:post_traverse, {:extract_lc_op, []}},
      "compKeyword" => {:reduce, {List, :to_string, []}},
      "schema-uri" => [{:reduce, {List, :to_string, []}}, {:map, {String, :trim_trailing, [":"]}}],
      "ATTRNAME" => {:reduce, {List, :to_string, []}},
      "NOT" => {:reduce, {List, :to_string, []}},
      "AND-OR" => {:reduce, {List, :to_string, []}},
      "subAttr" => {:post_traverse, {:extract_subname, []}}
    },
    ignore: [
      "ws",
      "quotation-mark",
      "grouping-start",
      "grouping-end",
      "attribute-filter-start",
      "attribute-filter-end"
    ],
    # convert values like `{:def, ["value"]}` to `"value"`
    # (removing the wrapping of the value in a list and a tagged tuple)
    unbox: [
      "string",
      "true",
      "false",
      "null",
      "nameChar",
      "json-char",
      "unescaped",
      "digit1-9",
      "zero",
      "decimal-point",
      "e",
      "schema-uri-part",
      "schema-uri-sep",
      "FILTER",
      "scim-rfc-path",
      "valFilter"
    ],
    # convert things like `{:def, ["value"]}` to `{:def, "value"}`
    # (removing the wrapping of the value in a list)
    unwrap: [
      "number",
      "NOT",
      "AND-OR",
      "compKeyword",
      "compValue",
      "compareOp",
      "presentOp",
      "schema-uri",
      "ATTRNAME",
      "subAttr"
    ]

  def parse(:scim_filter, input), do: scim_filter(input)
  def parse(:scim_path, input), do: scim_path(input)

  # convert `{:subattr, [".", {:attrname, "familyName"}]}` to `{:subattr, ["familyName"]}`
  defp extract_subname(rest, [{:attrname, name}, "."], context, _line, _offset) do
    {rest, [name], context}
  end

  defp extract_lc_op(rest, [op], context, _line, _offset) do
    {rest, [String.downcase(op)], context}
  end

  defp extract_decimal(rest, opts, context, _line, _offset) do
    int = Keyword.get(opts, :int)
    frac = Keyword.get(opts, :frac)
    minus = Keyword.get(opts, :minus)

    exp =
      Keyword.get(opts, :exp)
      |> case do
        [?e, {:minus, '-'} | rest] -> [?e, '-' | rest]
        [?e, {:plus, '+'} | rest] -> [?e, '+' | rest]
        other -> other
      end

    decimal = Decimal.new("#{minus}#{int}#{frac}#{exp}")

    {rest, [decimal], context}
  end
end
