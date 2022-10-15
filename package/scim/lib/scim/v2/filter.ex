defmodule SCIM.V2.Filter do
  defmodule Filter do
    @moduledoc """
    Wraps boolean op, condition, and nested filter clauses

    e.g. the filter `(foo pr or foo eq 1) and (email ew "@example.com" or email ew "@example.org")`

      %Filter{
        value: %And{
          value: [
            value: %Or{
              value: [
                %Condition{
                  op: :pr,
                  path: %Path{attribute: "occupation"},
                },
                %Condition{
                  op: :eq,
                  path: %Path{attribute: "occupation"},
                  value: %Value{type: :number, value: 1},
                },
              ]
            },
            value: %Or{
              value: [
                %Condition{
                  op: :ew,
                  path: %Path{attribute: "email"},
                  value: %Value{type: :string, value: "@example.com"}
                },
                %Condition{
                  op: :ew,
                  path: %Path{attribute: "email"},
                  value: %Value{type: :string, value: "@example.org"}
                },
              ]
            }
          ]
        }
      }
    """

    alias SCIM.V2.Filter.{Condition, And, Or, Not}

    defstruct [:value]

    @type t :: %Filter{value: possible_values}
    @type possible_values :: Condition.t() | And.t() | Or.t() | Not.t()
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
            op: :sw,
            path: %Path{attribute: "name"},
            value: %Value{type: :string, value: "foo"},
          },
        }
      }
    """
    alias SCIM.V2.Filter.Filter

    defstruct [:schema, :attribute, :subattribute, :filter]

    @type t :: %Path{
            schema: String.t() | nil,
            attribute: String.t(),
            subattribute: String.t() | nil,
            filter: Filter.t() | nil
          }
  end

  defmodule Condition do
    @moduledoc """
    Describes a condition an attribute has to meet.

    e.g. `someIdField` has to be equal to `"2819c223-7f76-453a-919d-413861904646"`

      %Condition{
        op: :eq,
        path: %Path{attribute: "someIdField"},
        value: %Value{type: :string, value: "2819c223-7f76-453a-919d-413861904646"},
      }

    e.g. the `displayName` of `members` whose `name` start with `"foo"` has to end with "bar":

      %Condition{
        op: :ew,
        path: %Path{
          attribute: "members",
          subattribute: "displayName",
          filter: %Filter{
            value: %Condition{
              op: :sw,
              path: %Path{attribute: "name"},
              value: %Value{type: :string, value: "foo"},
            },
          }
        },
        value: %Value{type: :string, value: "bar"},
      }
    """
    alias SCIM.V2.Filter.{Path, Value}

    defstruct [:path, :op, :value]

    @type t :: %Condition{
            path: Path.t(),
            op: possible_ops,
            value: Value.t()
          }
    @type possible_ops :: :pr | :eq | :ne | :co | :sw | :ew | :gt | :lt | :ge | :le
  end

  defmodule And do
    @moduledoc """
    Boolean `and` for combining conditions and nested filters

    e.g. `occupation` must be `carpenter` and `city` must `not` be `Naha`

      %And{
        value: [
          %Condition{
            op: :eq,
            path: %Path{attribute: "occupation"},
            value: %Value{type: :string, value: "carpenter"},
          },
          %Not{
            value: %Condition{
              op: :eq,
              path: %Path{attribute: "city"},
              value: %Value{type: :string, value: "Naha"},
            }
          }
        ]
      }
    """
    alias SCIM.V2.Filter.Filter

    defstruct value: []

    @type t :: %And{value: [Filter.possible_values()]}
  end

  defmodule Or do
    @moduledoc """
    Boolean `or` for combining conditions and nested filters

    e.g. `occupation` must be `carpenter` or `librarian`

      %Or{
        value: [
          %Condition{
            op: :eq,
            path: %Path{attribute: "occupation"},
            value: %Value{type: :string, value: "carpenter"},
          },
          %Condition{
            op: :eq,
            path: %Path{attribute: "occupation"},
            value: %Value{type: :string, value: "librarian"},
          }
        ]
      }
    """
    alias SCIM.V2.Filter.Filter

    defstruct value: []

    @type t :: %Or{value: [Filter.possible_values()]}
  end

  defmodule Not do
    @moduledoc """
    Boolean `not` for negating the `and`, `or`, and conditions

    e.g. `placeOfBirth` must `not` contain `town`

      %Not{
        value: %Condition{
          op: :co,
          path: %Path{attribute: "placeOfBirth"},
          value: %Value{type: :string, value: "town"},
        }
      }
    """
    alias SCIM.V2.Filter.Filter

    defstruct [:value]

    @type t :: %Not{value: Filter.possible_values()}
  end

  defmodule Value do
    @moduledoc """
    Wraps a value while explicitly stating it's type
    """
    defstruct [:type, :value]

    @type t :: t_string | t_number | t_boolean | t_nil | t_keyword
    @type t_string :: %Value{type: :string, value: String.t()}
    @type t_number :: %Value{type: :number, value: Decimal.t()}
    @type t_boolean :: %Value{type: :boolean, value: boolean()}
    @type t_nil :: %Value{type: nil, value: nil}
    @type t_keyword :: %Value{type: :keyword, value: String.t()}
  end
end
