defmodule SCIM.V2.Filter do
  defmodule FilterExpression do
    defstruct [:value]
  end

  defmodule PathExpression do
    defstruct [:schema, :attribute, :subattribute]
  end

  defmodule BooleanExpression do
    defstruct [:value]
  end

  defmodule AttributeExpression do
    defstruct [:path, :op, :value]
  end

  defmodule ValueExpression do
    defstruct [:type, :value]
  end
end
