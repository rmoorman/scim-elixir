defmodule SCIM.V2.Ecto.QueryBuildingTest do
  use ExUnit.Case, async: true

  import SCIM.V2.Filter, only: [filter: 1]

  defmodule Builder do
    alias SCIM.V2.Filter.{
      #Filter,
      #Path,
      #Condition,
      #And,
      #Or,
      #Not,
      #Value,
    }
  end

  test "dingen" do
    filter("id eq 1")
    |> IO.inspect()
  end






  #test "dingen", context do
  #  pid = Ecto.Adapters.SQL.Sandbox.start_owner!(SCIM.TestRepo, shared: not context[:async])
  #  on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  #  assert %{rows: [[2]]} = Ecto.Adapters.SQL.query!(SCIM.TestRepo, "SELECT 1 + 1", [])
  #end
end
