defmodule SCIM.V2.Filter.ProcessorTest do
  use ExUnit.Case, async: true

  import SCIM.V2.TestHelpers
  import SCIM.V2.Filter.Processor, only: [process: 1]

  describe "logic expression output" do
    @rule ~s|foo eq 1|
    test @rule do
      parse(:scim_filter, @rule)
      |> process()
    end
  end
end
