defmodule SCIM.V2.Filter.Processor do
  def process(data), do: convert(data)

  defp convert(list) when is_list(list), do: Enum.map(list, &convert/1)
  defp convert({tag, tagged}), do: {tag, convert(tagged)}
  defp convert(x), do: x
end
