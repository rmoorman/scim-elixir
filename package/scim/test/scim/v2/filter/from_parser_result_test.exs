defmodule SCIM.V2.Filter.FromParserResultTest do
  use ExUnit.Case, async: true

  import SCIM.V2.TestHelpers

  alias SCIM.V2.Filter.{
    FromParserResult,
    Filter,
    Path,
    Condition,
    And,
    Or,
    Not,
    Value
  }

  defp build(type, input) do
    parse(type, input)
    |> FromParserResult.build()
  end

  describe "returned filter parsing errors" do
    @rule "!invalid!"
    test @rule do
      assert {:error, {:parser, error}} = build(:scim_filter, @rule)
      assert error == "expected string \"(\""
    end
  end

  describe "returned path parsing errors" do
    @rule "!invalid!"
    test @rule do
      assert {:error, {:parser, error}} = build(:scim_path, @rule)
      assert error == "expected ASCII character in the range 'A' to 'Z' or in the range 'a' to 'z'"
    end

    @rule "field!"
    test @rule do
      assert {:error, {:parser, error}} = build(:scim_path, @rule)
      assert error == "unparsable rest: !"
    end
  end

  describe "returned filter data" do
    @rule "id pr"
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %Filter{
          value: %Condition{
            path: %Path{attribute: "id"},
            op: :pr
          }
        }
      ]

      assert data == expected
    end

    @rule "id eq 1"
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %Filter{
          value: %Condition{
            path: %Path{attribute: "id"},
            op: :eq,
            value: %Value{type: :number, value: %Decimal{coef: 1, exp: 0, sign: 1}}
          }
        }
      ]

      assert data == expected
    end

    @rule ~s|contactEmail.value ew "@example.com"|
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %Filter{
          value: %Condition{
            path: %Path{attribute: "contactEmail", subattribute: "value"},
            op: :ew,
            value: %Value{type: :string, value: "@example.com"}
          }
        }
      ]

      assert data == expected
    end

    @tag :dev
    @rule ~s|userType eq "Employee" and emails[type eq "work" and not (value ew "@example.com")]|
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %Filter{
          value: %Path{
            attribute: "emails",
            filter: %Filter{
              value: %Condition{
                path: %Path{attribute: "type"},
                op: :eq,
                value: %Value{type: :string, value: "work"}
              }
            }
          }
        }
      ]

      assert data == expected
    end

    @tag :dev
    @rule ~s|emails[type eq "work" and not (value ew "@example.com")].label|
    test @rule do
      assert {:ok, data} = build(:scim_path, @rule)

      expected = [
        %Path{
          attribute: "emails",
          subattribute: "label",
          filter: %Filter{
            value: %And{
              value: [
                %Condition{
                  path: %Path{attribute: "type"},
                  op: :eq,
                  value: %Value{type: :string, value: "work"}
                },
                %Not{
                  value: %Condition{
                    path: %Path{attribute: "value"},
                    op: :ew,
                    value: %Value{type: :string, value: "@example.com"}
                  }
                }
              ]
            }
          }
        }
      ]

      assert data == expected
    end
  end
end
