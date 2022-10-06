defmodule SCIM.V2.Filter.FromParserResult do
  alias SCIM.V2.Filter.{
    FilterExpression,
    PathExpression,
    BooleanExpression,
    AttributeExpression,
    ValueExpression
  }

  @attr_ops [:pr, :eq, :ne, :co, :sw, :ew, :gt, :lt, :ge, :le]
  @attr_op_mapping Map.new(@attr_ops, fn op -> {Atom.to_string(op), op} end)

  def build({:ok, result, "", _context, _line, _column}),
    do: {:ok, build(result)}

  def build({:ok, _result, rest, _context, _line, _column}),
    do: {:error, {:parser, "unparsable rest: #{rest}"}}

  def build({:error, message, _rest, _context, _line, _column}),
    do: {:error, {:parser, message}}

  def build([]), do: []

  def build([{:scim_filter, value} | rest]) do
    [%FilterExpression{value: build(value)} | build(rest)]
  end

  # defp build([{:scim_path, value} | rest]) do
  #  [%PathExpression{value: build(value)} | build(rest)]
  # end

  def build([{:attrexp, value} | rest]) do
    schema =
      case value[:attrpath][:schema_uri] do
        "" -> nil
        schema -> schema
      end

    attribute = value[:attrpath][:attrname]

    path = %PathExpression{
      schema: schema,
      attribute: attribute,
      subattribute: nil
    }

    {op, value} =
      case {value[:compareop], value[:presentop]} do
        {nil, presentop} -> {@attr_op_mapping[presentop], nil}
        {compareop, nil} -> {@attr_op_mapping[compareop], build({:value, value[:compvalue]})}
      end

    [%AttributeExpression{path: path, op: op, value: value} | build(rest)]
  end

  def build({:value, {:number, value}}), do: %ValueExpression{type: :number, value: value}
  def build({:value, {:compKeyword, value}}), do: %ValueExpression{type: :keyword, value: value}
  def build({:value, value}) when is_nil(value), do: %ValueExpression{type: nil, value: value}
  def build({:value, value}) when is_boolean(value), do: %ValueExpression{type: :boolean, value: value}
  def build({:value, value}) when is_binary(value), do: %ValueExpression{type: :string, value: value}

  # defp convert(list) when is_list(list), do: Enum.map(list, &convert/1)
  # defp convert({tag, tagged}), do: {tag, convert(tagged)}
  # defp convert(x), do: x
end
