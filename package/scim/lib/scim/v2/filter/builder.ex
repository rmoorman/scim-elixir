defmodule SCIM.V2.Filter.Builder do
  alias SCIM.V2.Filter.{
    Filter,
    Path,
    Condition,
    And,
    Or,
    Not,
    Value
  }

  @op_list [:pr, :eq, :ne, :co, :sw, :ew, :gt, :lt, :ge, :le]
  @op_mapping Map.new(@op_list, fn op -> {Atom.to_string(op), op} end)

  def build({:ok, result, "", _context, _line, _column}),
    do: {:ok, build(result)}

  def build({:ok, _result, rest, _context, _line, _column}),
    do: {:error, {:parser, "unparsable rest: #{rest}"}}

  def build({:error, message, _rest, _context, _line, _column}),
    do: {:error, {:parser, message}}

  def build(scim_filter: value), do: filter(value)
  def build(scim_path: value), do: path(value)

  ###
  ###
  ###

  defp filter([_ | _] = value), do: %Filter{value: filter_value(value)}
  defp filter(_), do: nil

  defp filter_value([_ | _] = filter) do
    filter
    |> filter_convert()
    |> filter_wrap_nots()
    |> filter_wrap_ands_and_ors()
    |> filter_flatten()
    |> filter_unwrap()
  end

  defp filter_convert(filter) do
    Enum.map(filter, fn
      {:filter_grouping, value} -> filter(value)
      {:valfilter_grouping, value} -> filter(value)
      {:valuepath, value} -> path(valuepath: value)
      {:attrexp, value} -> condition(value)
      other -> other
    end)
  end

  defp filter_wrap_nots(filter) do
    chunk_fn = fn
      # in case we encounter a `not`, we emit what we currently have and start
      # a new chunk for `not`
      {:not, _} = x, acc ->
        case acc do
          [] -> {:cont, [x]}
          acc -> {:cont, Enum.reverse(acc), [x]}
        end

      # in case the current chunk is a `not` chunk we emit it with the current
      # element added to it and start a new chunk
      after_not, [{:not, _}] = acc ->
        {:cont, Enum.reverse([after_not | acc]), []}

      # in other cases we just add to the current (not a `not`) chunk
      x, acc ->
        {:cont, [x | acc]}
    end

    after_fn = fn acc -> {:cont, Enum.reverse(acc), []} end

    not_chunk_to_struct = fn
      [{:not, _}, value] -> %Not{value: filter_value([value])}
      other -> other
    end

    filter
    |> Enum.chunk_while([], chunk_fn, after_fn)
    |> Enum.map(not_chunk_to_struct)
    |> List.flatten()
  end

  defp filter_wrap_ands_and_ors(filter) do
    make_chunk_fn = fn marker, type ->
      fn
        # if we encounter a marker item (e. `{:and_or, "and"}`), we pick the
        # previous item from the accumulator, start accumulating for the given
        # type and emit what is left (without the taken item)
        ^marker, [previous | rest] ->
          {:cont, Enum.reverse(rest), {type, [previous], false}}

        # if we don't expect a marker, we add the element to the accumulator
        # for the given type and note that we now expect a marker
        x, {^type, type_acc, false = _expect_marker} ->
          {:cont, {type, [x | type_acc], true}}

        # if we expect a marker and encounter one as well, we note that a
        # non-marker should be next
        ^marker, {^type, type_acc, true = _expect_marker} ->
          {:cont, {type, type_acc, false}}

        # if we expect a marker but we do not get one, we emit what we have
        # and start a new chunk with the current element
        x, {^type, type_acc, true = _expect_marker} ->
          {:cont, [{type, Enum.reverse(type_acc)}], [x]}

        x, acc ->
          {:cont, [x | acc]}
      end
    end

    after_fn = fn
      # if the left over accumulator is a type accumulator of a chunk function
      # emit it's value
      {type, type_acc, _expect_marker} ->
        {:cont, [{type, Enum.reverse(type_acc)}], []}

      # otherwise, just emit the rest
      acc ->
        {:cont, Enum.reverse(acc), []}
    end

    make_chunk_to_struct_fn = fn type, struct ->
      fn
        {^type, value} when is_list(value) ->
          struct(struct, value: value)

        other ->
          other
      end
    end

    and_chunk_fn = make_chunk_fn.({:and_or, "and"}, :and)
    and_chunk_to_struct_fn = make_chunk_to_struct_fn.(:and, And)
    or_chunk_fn = make_chunk_fn.({:and_or, "or"}, :or)
    or_chunk_to_struct_fn = make_chunk_to_struct_fn.(:or, Or)

    filter
    |> Enum.chunk_while([], and_chunk_fn, after_fn)
    |> List.flatten()
    |> Enum.map(and_chunk_to_struct_fn)
    |> Enum.chunk_while([], or_chunk_fn, after_fn)
    |> List.flatten()
    |> Enum.map(or_chunk_to_struct_fn)
  end

  defp filter_flatten(%Filter{value: value}), do: filter_flatten(value)
  defp filter_flatten(%And{value: value}), do: %And{value: filter_flatten(value)}
  defp filter_flatten(%Or{value: value}), do: %Or{value: filter_flatten(value)}
  defp filter_flatten(%Not{value: value}), do: %Not{value: filter_flatten(value)}
  defp filter_flatten(filter) when is_list(filter), do: Enum.map(filter, &filter_flatten/1)
  defp filter_flatten(filter), do: filter

  defp filter_unwrap([filter]), do: filter

  defp path(valuepath: valuepath, subattr: subattr) do
    valuepath = put_in(valuepath[:attrpath][:subattr], subattr)
    path(valuepath: valuepath)
  end

  defp path(valuepath: valuepath) do
    {[attrpath: attrpath], filter} = Keyword.split(valuepath, [:attrpath])
    path(attrpath: attrpath, filter: filter)
  end

  defp path(opts) do
    attrpath = Keyword.fetch!(opts, :attrpath)
    filter = Keyword.get(opts, :filter)

    %Path{
      schema: schema(attrpath[:schema_uri]),
      attribute: attrpath[:attrname],
      subattribute: attrpath[:subattr],
      filter: filter(filter)
    }
  end

  defp schema(""), do: nil
  defp schema(schema), do: schema

  defp condition(attrpath: attrpath, presentop: presentop) do
    %Condition{
      path: path(attrpath: attrpath),
      op: @op_mapping[presentop]
    }
  end

  defp condition(attrpath: attrpath, compareop: compareop, compvalue: compvalue) do
    %Condition{
      path: path(attrpath: attrpath),
      op: @op_mapping[compareop],
      value: value(compvalue)
    }
  end

  defp value({:number, value}), do: %Value{type: :number, value: value}
  defp value({:compKeyword, value}), do: %Value{type: :keyword, value: value}
  defp value(value) when is_nil(value), do: %Value{type: nil, value: value}
  defp value(value) when is_boolean(value), do: %Value{type: :boolean, value: value}
  defp value(value) when is_binary(value), do: %Value{type: :string, value: value}
end
