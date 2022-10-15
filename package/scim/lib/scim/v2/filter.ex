defmodule SCIM.V2.Filter do
  defmodule Filter do
    @moduledoc """
    Wraps boolean op, condition, and nested filter clauses

    e.g. the filter `(foo pr or foo eq 1) and (email ew "@example.com" or email ew "@example.org")`

      %Filter{
        value: %And{
          value: [
            %Filter{
              value: %Or{
                value: [
                  %Condition{path: %Path{attribute: "occupation"}, op: :pr},
                  %Condition{path: %Path{attribute: "occupation"}, op: :eq, value: %Value{type: :number, value: 1}},
                ]
              }
            },
            %Filter{
              value: %Or{
                value: [
                  %Condition{path: %Path{attribute: "email"}, op: :ew, value: %Value{type: :string, value: "@example.com"}},
                  %Condition{path: %Path{attribute: "email"}, op: :ew, value: %Value{type: :string, value: "@example.org"}},
                ]
              }
            }
          ]
        }
      }
    """
    defstruct [:value]
  end

  defmodule Path do
    @moduledoc """
    Describes how to reach an attribute

    Meant to be used as `value` of a `PathExpression` or within the `path` of
    an `AttributeRequirementExpression`.

    e.g. the `displayName` of `members` whose `name` start with `"foo"`:

      %Path{
        attribute: "members",
        subattribute: "displayName",
        filter: %Filter{
          value: %Condition{
            path: %Path{attribute: "name"},
            op: :sw,
            value: %Value{type: :string, value: "foo"},
          },
        }
      }
    """
    defstruct [:schema, :attribute, :subattribute, :filter]
  end

  defmodule Condition do
    @moduledoc """
    Describes a condition an attribute has to meet.

    e.g. `someIdField` has to be equal to `"2819c223-7f76-453a-919d-413861904646"`

      %Condition{
        path: %Path{attribute: "someIdField"},
        op: :eq,
        value: %Value{type: :string, value: "2819c223-7f76-453a-919d-413861904646"},
      }

    e.g. the `displayName` of `members` whose `name` start with `"foo"` has to end with "bar":

      %Condition{
        path: %Path{
          attribute: "members",
          subattribute: "displayName",
          filter: %Filter{
            value: %Condition{
              path: %Path{attribute: "name"},
              op: :sw,
              value: %Value{type: :string, value: "foo"},
            },
          }
        },
        op: :ew,
        value: %Value{type: :string, value: "bar"},
      }
    """
    defstruct [:path, :op, :value]
  end

  defmodule And do
    @moduledoc """
    Boolean `and` for combining conditions and nested filters

    e.g. `occupation` must be `carpenter` and `city` must `not` be `Naha`

      %And{
        value: [
          %Condition{
            path: %Path{attribute: "occupation"},
            op: :eq,
            value: %Value{type: :string, value: "carpenter"},
          },
          %Not{
            value: %Condition{
              path: %Path{attribute: "city"},
              op: :eq,
              value: %Value{type: :string, value: "Naha"},
            }
          }
        ]
      }
    """
    defstruct value: []
  end

  defmodule Or do
    @moduledoc """
    Boolean `or` for combining conditions and nested filters

    e.g. `occupation` must be `carpenter` or `librarian`

      %Or{
        value: [
          %Condition{
            path: %Path{attribute: "occupation"},
            op: :eq,
            value: %Value{type: :string, value: "carpenter"},
          },
          %Condition{
            path: %Path{attribute: "occupation"},
            op: :eq,
            value: %Value{type: :string, value: "librarian"},
          }
        ]
      }
    """
    defstruct value: []
  end

  defmodule Not do
    @moduledoc """
    Boolean `not` for negating the `and`, `or`, conditions, and nested filters

    e.g. `placeOfBirth` must `not` contain `town`

      %Not{
        value: %Condition{
          path: %Path{attribute: "placeOfBirth"},
          op: :co,
          value: %Value{type: :string, value: "town"},
        }
      }
    """
    defstruct [:value]
  end

  defmodule Value do
    @moduledoc """
    Wraps a value explicitly noting it's type

    FIXME: is the implementation result neater with or without wrapping the value?

    e.g. a value of type `string` and literal value "foo"

      %Value{type: :string, value: "foo"},
    """
    defstruct [:type, :value]
  end
end
