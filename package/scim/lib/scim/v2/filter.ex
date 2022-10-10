defmodule SCIM.V2.Filter do
  # Wraps scim filters
  defmodule FilterExpression do
    defstruct [:value]
  end

  # Wraps scim paths
  defmodule PathExpression do
    defstruct [:value]
  end

  """
  %AttributeExpression{
    path: %AttributePathExpression{
      schema: "",
      attribute: "members",
      subattribute: "displayName",
      filter: [
        %AttributeExpression{
          path: %AttributePathExpression {
            schema: "",
            attribute: "value",
            subattribute: nil,
            filter: nil,
          },
          comp: %AttributeComparisonExpression{op: :eq, value: %ValueExpression{type: :string, value: "2819c223-7f76-453a-919d-413861904646"}},
        },
      ]
    },
    comp: %AttributeComparisonExpression{op: :se, value: %ValueExpression{}},
  }
  """

  # Expresses that an attribute should be checked for value or presence
  defmodule AttributeExpression do
    defstruct [:path, :op, :value]
  end

  # Expresses the path of an attribute value and filtering to apply...
  # (mostly used for updating fields)
  defmodule ValuePathExpression do
    defstruct [:path, :filter]
  end

  # Expresses the path of an attribute to be checked (nests within
  # `AttributeExpression` and `ValuePathExpression`)
  defmodule AttributePathExpression do
    defstruct [:schema, :attribute, :subattribute]
  end

  # Expresses how to combine multiple attribute checks (boolean and/or ops)
  defmodule BooleanExpression do
    defstruct [:value]
  end

  # Expresses which type of value an attribute should be compared against
  defmodule ValueExpression do
    defstruct [:type, :value]
  end
end
