defmodule SCIM.V2.Filter.FromParserResultTest do
  use ExUnit.Case, async: true

  import SCIM.V2.TestHelpers

  alias SCIM.V2.Filter.{
    FromParserResult,
    FilterExpression,
    #PathExpression,
    AttributeRequirementExpression,
    AttributePathExpression,
    #BooleanExpression,
    ValueExpression,
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
        %FilterExpression{
          value: [
            %AttributeRequirementExpression{
              path: %AttributePathExpression{attribute: "id"},
              op: :pr,
            }
          ]
        }
      ]

      assert data == expected
    end

    @rule "id eq 1"
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %FilterExpression{
          value: [
            %AttributeRequirementExpression{
              path: %AttributePathExpression{attribute: "id"},
              op: :eq,
              value: %ValueExpression{type: :number, value: %Decimal{coef: 1, exp: 0, sign: 1}}
            }
          ]
        }
      ]

      assert data == expected
    end

    @rule ~s|contactEmail.value ew "@example.com"|
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %FilterExpression{
          value: [
            %AttributeRequirementExpression{
              path: %AttributePathExpression{attribute: "contactEmail", subattribute: "value"},
              op: :ew,
              value: %ValueExpression{type: :string, value: "@example.com"},
            }
          ]
        }
      ]

      assert data == expected
    end

    @tag :dev
    @rule ~s|emails[type eq "work" and not (value ew "@example.com")]|
    test @rule do
      assert {:ok, data} = build(:scim_filter, @rule)

      expected = [
        %FilterExpression{
          value: [
            %AttributePathExpression{attribute: "emails", filter: [
              %AttributeRequirementExpression{
                path: %AttributePathExpression{attribute: "type"},
                op: :eq,
                value: %ValueExpression{type: :string, value: "work"},
              }
            ]}
          ]
        }
      ]

      assert data == expected
    end
  end
end
