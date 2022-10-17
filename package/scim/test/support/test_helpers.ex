defmodule SCIM.V2.TestHelpers do
  import ExUnit.Assertions

  # Call a parser function and assert a timely response.
  def assert_timely_return(fun, timeout \\ 200)
  def assert_timely_return(fun, timeout) do
    task = Task.async(fun)
    assert {:ok, result} = Task.yield(task, 200) || Task.shutdown(task)
    result
  end
end
