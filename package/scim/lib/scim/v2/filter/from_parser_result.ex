defmodule SCIM.V2.Filter.FromParserResult do
  alias SCIM.V2.Filter.{
    FilterExpression,
    PathExpression,
    AttributeRequirementExpression,
    AttributePathExpression,
    GroupingExpression,
    BooleanExpression,
    ValueExpression,
  }

  @op_list [:pr, :eq, :ne, :co, :sw, :ew, :gt, :lt, :ge, :le, :and, :or, :not]
  @op_mapping Map.new(@op_list, fn op -> {Atom.to_string(op), op} end)

  def build({:ok, result, "", _context, _line, _column}),
    do: {:ok, result |> IO.inspect(label: "\n\ninput") |> build() |> IO.inspect(label: "output")}

  def build({:ok, _result, rest, _context, _line, _column}),
    do: {:error, {:parser, "unparsable rest: #{rest}"}}

  def build({:error, message, _rest, _context, _line, _column}),
    do: {:error, {:parser, message}}

  ###
  ###
  ###

  def build([scim_filter: value]), do: [build({:scim_filter, value})]
  def build({:scim_filter, value}) do
    case value do
      [valuepath: valuepath, subattr: subattr] ->
        valuepath = put_in(valuepath[:attrpath][:subattr], subattr)
        build({:attribute_path, valuepath})

      [valuepath: valuepath] ->
        build({:attribute_path, valuepath})

      value -> build({:filter, value})
    end
  end

  def build({:attribute_path, _valuepath}), do: nil

  def build({:filter, _filter}), do: nil


  """
  def build([]), do: []

  def build([{:scim_filter, value} | rest]) do
    [%FilterExpression{value: build(value)} | build(rest)]
  end

  def build([{:scim_path, value} | rest]) do
   [%PathExpression{value: build(value)} | build(rest)]
  end
  """

end

"""
  def build([{:attrexp, attrexp} | rest]) do
    [build({:attribute_requirement, attrexp}) | build(rest)]
  end

  def build([{:valuepath, valuepath}, {:subattr, subattr} | rest]) do
    # when a scim_path is parsed, `subattr` is to be found directly next to
    # `valuepath` rather than inside the nested `attrpath`, so we move it
    # to `attrpath` for simplicity
    valuepath = put_in(valuepath[:attrpath][:subattr], subattr)
    [build({:attribute_path, valuepath}) | build(rest)]
  end

  def build([{:valuepath, valuepath} | rest]) do
    [build({:attribute_path, valuepath}) | build(rest)]
  end

  def build([{:valfilter_grouping, grouping} | rest]) do
    [build({:grouping, grouping}) | build(rest)]
  end

  ###
  ###
  ###

  def build({:attribute_requirement, attrexp}) do
    attrexp_without_requirements = Keyword.drop(attrexp, [:compareop, :compvalue, :presentop])
    path = build({:attribute_path, attrexp_without_requirements})

    {op, value} =
      cond do
        op = attrexp[:presentop] -> {@attr_op_mapping[op], nil}
        op = attrexp[:compareop] -> {@attr_op_mapping[op], build({:value, attrexp[:compvalue]})}
      end

    %AttributeRequirementExpression{path: path, op: op, value: value}
  end

  def build({:attribute_path, attrexp}) do
    {attrpath, filter} = Keyword.split(attrexp, [:attrpath])

    %AttributePathExpression{
      schema: build({:schema, attrpath[:attrpath][:schema_uri]}),
      attribute: attrpath[:attrpath][:attrname],
      subattribute: attrpath[:attrpath][:subattr],
      filter: build(filter),
    }
  end

  def build({:grouping, grouping}) do
    IO.inspect(grouping, label: "=========== grouping")
    %GroupingExpression{value: [build({:filter, grouping})]}
  end

  def build({:schema, ""}), do: nil
  def build({:schema, schema}), do: schema

  def build({:filter, filter}) do
    IO.inspect(filter)
    filter
  end
  #def build({:filter, []}), do: []
  #def build({:filter, [rest]}), do: build([rest])
  #def build({:filter, [foo | rest]}), do: [foo | build([rest])]
  #def build({:filter, [{:not, _}, left, {:and_or, "and"}, {:not, _}, right | rest]}), do: rest
  #def build({:filter, [{:not, _}, left, {:and_or, "or"}, {:not, _}, right | rest]}), do: rest
  #def build({:filter, [{:not, _}, left, {:and_or, "and"}, right | rest]}), do: rest
  #def build({:filter, [{:not, _}, left, {:and_or, "or"}, right | rest]}), do: rest
  #def build({:filter, [left, {:and_or, "and"}, {:not, _}, right | rest]}) do
  #  IO.inspect({left, right})
  #  IO.inspect({build([left]), build([right])})
  #  #build([left])
  ##  IO.inspect({left, right})
  ##  build([left])
  #  [%BooleaiiinAndOrExpression{
  #    op: :and,
  #    left: build([left]),
  #    right: build([right]),
  #  }]
  #  ++ [
  #      %BooleanExpression{op: :not, value: build([right])}
  #    ]
  #  }]
  #end
  #def build({:filter, [left, {:and_or, "or"}, {:not, _}, right | rest]}), do: rest
  #def build({:filter, [left, {:and_or, "and"}, right | rest]}), do: rest
  #def build({:filter, [left, {:and_or, "or"}, right | rest]}), do: rest

  def build({:value, {:number, value}}), do: %ValueExpression{type: :number, value: value}
  def build({:value, {:compKeyword, value}}), do: %ValueExpression{type: :keyword, value: value}
  def build({:value, value}) when is_nil(value), do: %ValueExpression{type: :nil, value: value}
  def build({:value, value}) when is_boolean(value), do: %ValueExpression{type: :boolean, value: value}
  def build({:value, value}) when is_binary(value), do: %ValueExpression{type: :string, value: value}

  # defp convert(list) when is_list(list), do: Enum.map(list, &convert/1)
  # defp convert({tag, tagged}), do: {tag, convert(tagged)}
  # defp convert(x), do: x
"""
