defmodule SCIM.V2.TestHelpers do
  import ExUnit.Assertions

  # Call a parser function and assert a timely response.
  def parse(parser \\ SCIM.V2.Filter.Parser, fun, input)
  def parse(parser, fun, input) do
    task = Task.async(fn -> apply(parser, fun, [input]) end)
    assert {:ok, result} = Task.yield(task, 200) || Task.shutdown(task)
    result
  end
end
