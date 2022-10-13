defmodule SCIM.V2.Filter do
  defmodule FilterExpression do
    @moduledoc """
    Wraps SCIM filters
    """
    defstruct [value: []]
  end

  defmodule PathExpression do
    @moduledoc """
    Wraps SCIM paths
    """
    defstruct [:value]
  end

  defmodule AttributePathExpression do
    @moduledoc """
    Describes how to reach an attribute

    Meant to be used as `value` of a `PathExpression` or within the `path` of
    an `AttributeRequirementExpression`.

    e.g. the `displayName` of `members` whose `name` start with `"foo"`:

      %AttributePathExpression{
        schema: "",
        attribute: "members",
        subattribute: "displayName",
        filter: [
          %AttributeRequirementExpression{
            path: %AttributePathExpression{schema: "", attribute: "name", subattribute: nil, filter: nil},
            op: :sw,
            value: %ValueExpression{type: :string, value: "foo"},
          },
        ]
      }
    """
    defstruct [:schema, :attribute, :subattribute, filter: []]
  end

  defmodule AttributeRequirementExpression do
    @moduledoc """
    Describes what is required of an attribute and it's value

    Meant to be used within the `value` of a `FilterExpression` or `filter` of
    an `AttributePathExpression`, either on it's own or wrapped within
    `BooleanExpression`.

    e.g. `someIdField` has to be equal to `"2819c223-7f76-453a-919d-413861904646"`

      %AttributeRequirementExpression{
        path: %AttributePathExpression{schema: "", attribute: "someIdField", subattribute: nil, filter: nil},
        op: :eq,
        value: %ValueExpression{type: :string, value: "2819c223-7f76-453a-919d-413861904646"},
      }

    e.g. the `displayName` of `members` whose `name` start with `"foo"` has to end with "bar":

      %AttributeRequirementExpression{
        path: %AttributePathExpression{
          schema: "",
          attribute: "members",
          subattribute: "displayName",
          filter: [
            %AttributeRequirementExpression{
              path: %AttributePathExpression{schema: "", attribute: "name", subattribute: nil, filter: nil},
              op: :sw,
              value: %ValueExpression{type: :string, value: "foo"},
            },
          ]
        },
        op: :ew,
        value: %ValueExpression{type: :string, value: "bar"},
      }
    """
    defstruct [:path, :op, :value]
  end

  defmodule BooleanExpression do
    @moduledoc """
    Describes a boolean operation (`and`, `or`, or `not`)

    e.g. `placeOfBirth` must `not` contain `town`

      %BooleanExpression{
        op: :not,
        value: [
          %AttributeRequirementExpression{
            path: %AttributePathExpression{schema: "", attribute: "placeOfBirth", subattribute: nil, filter: nil},
            op: :co,
            value: %ValueExpression{type: :string, value: "town"},
          }
        ]
      }

    e.g. `occupation` must be `carpenter` or `not` `librarian`

      %BooleanExpression{
        op: :or,
        value: [
          %AttributeRequirementExpression{
            path: %AttributePathExpression{schema: "", attribute: "occupation", subattribute: nil, filter: nil},
            op: :eq,
            value: %ValueExpression{type: :string, value: "carpenter"},
          },
          %BooleanExpression{
            op: :not,
            value: [
              %AttributeRequirementExpression{
                path: %AttributePathExpression{schema: "", attribute: "occupation", subattribute: nil, filter: nil},
                op: :eq,
                value: %ValueExpression{type: :string, value: "librarian"},
              }
            ]
          }
        ]
      }
    """
    defstruct [:op, value: []]
  end

  defmodule ValueExpression do
    @moduledoc """
    Wraps a value explicitly noting it's type

    FIXME: is the implementation result neater with or without wrapping the value?
    """
    defstruct [:type, :value]
  end

  defmodule GroupingExpression do
    defstruct [value: []]
  end
end
