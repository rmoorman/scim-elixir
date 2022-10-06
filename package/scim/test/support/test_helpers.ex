defmodule SCIM.V2.TestHelpers do
  import ExUnit.Assertions

  alias SCIM.V2.Filter.Parser

  # Call a parser function and assert a timely response.
  def parse(fun, input) do
    task = Task.async(fn -> Parser.parse(fun, input) end)
    assert {:ok, result} = Task.yield(task, 200) || Task.shutdown(task)
    result
  end
end
