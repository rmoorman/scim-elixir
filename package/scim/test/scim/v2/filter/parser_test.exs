defmodule SCIM.V2.Filter.ParserTest do
  use ExUnit.Case, async: true

  import SCIM.V2.TestHelpers

  describe "parse valid filter without error" do
    @filter_rules [
      # filter rules (from spec)
      ~s|userName Eq "john"|,
      ~s|Username eq "john"|,
      ~s|userName eq "bjensen"|,
      ~s|name.familyName co "O'Malley"|,
      ~s|userName sw "J"|,
      ~s|urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"|,
      ~s|title pr|,
      ~s|meta.lastModified gt "2011-05-13T04:42:34Z"|,
      ~s|meta.lastModified ge "2011-05-13T04:42:34Z"|,
      ~s|meta.lastModified lt "2011-05-13T04:42:34Z"|,
      ~s|meta.lastModified le "2011-05-13T04:42:34Z"|,
      ~s|title pr and userType eq "Employee"|,
      ~s|title pr or userType eq "Intern"|,
      ~s|schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"|,
      ~s|userType eq "Employee" and (emails co "example.com" or emails.value co "example.org")|,
      ~s|userType ne "Employee" and not (emails co "example.com" or emails.value co "example.org")|,
      ~s|userType eq "Employee" and (emails.type eq "work")|,
      ~s|userType eq "Employee" and emails[type eq "work" and value co "@example.com"]|,
      ~s|emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]|,
      # filter rules (elsewhere, made up, intentionally different)
      ~s|userType eq "Employee" and (emails co "example.com" or emails co "example.org")|,
      ~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber pr|
    ]

    for rule <- @filter_rules do
      test "filter rule ~s|#{rule}|" do
        assert {:ok, _result, "" = _rest, _, _, _} = parse(:scim_filter, unquote(rule))
      end
    end
  end

  describe "parse valid path rule without error" do
    @path_rules [
      # path rules (from spec)
      ~s|members|,
      ~s|name.familyName|,
      ~s|addresses[type eq "work"]|,
      ~s|members[value eq "2819c223-7f76-453a-919d-413861904646"]|,
      ~s|members[value eq "2819c223-7f76-453a-919d-413861904646"].displayName|,
      ~s|emails[type eq "work" and value ew "example.com"]|,
      ~s|addresses[type eq "work"].streetAddress|,
      # other rules (elsewhere, made up, intentionally different)
      ~s|emails[type eq "work"].value|,
      ~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber|,
      ~s|addresses[foo pr]|
    ]

    for rule <- @path_rules do
      test "path rule ~s|#{rule}|" do
        assert {:ok, _result, "" = _rest, _, _, _} = parse(:scim_path, unquote(rule))
      end
    end
  end

  describe "result of parsing an invalid rule" do
    @rule ~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber|
    test "~s|#{@rule}| used as a filter causes an error" do
      rule = @rule
      error = "expected string \"(\""
      assert {:error, ^error, ^rule, _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|adresses[foo]|
    test "~s|#{@rule}| has unparsed rest" do
      assert {:ok, _, "[foo]", _, _, _} = parse(:scim_path, @rule)
    end

    @rule ~s|adresses[zip sw "1234"|
    test "~s|#{@rule}| has unparsed rest" do
      assert {:ok, _, ~s|[zip sw "1234"|, _, _, _} = parse(:scim_path, @rule)
    end
  end

  describe "result of parsing valid filter rule" do
    @rule ~s|id eq User|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      assert [scim_filter: [attrexp: [_, _, compvalue: {:compkeyword, "User"}]]] = result
    end

    @rule ~s|id eq "foo"|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      assert [scim_filter: [attrexp: [_, _, compvalue: "foo"]]] = result
    end

    @rule ~s|id eq true|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      assert [scim_filter: [attrexp: [_, _, compvalue: true]]] = result
    end

    @rule ~s|id eq false|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      assert [scim_filter: [attrexp: [_, _, compvalue: false]]] = result
    end

    @rule ~s|id eq null|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      assert [scim_filter: [attrexp: [_, _, compvalue: nil]]] = result
    end

    @rule ~s|id eq 1|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      value = {:number, %Decimal{sign: 1, coef: 1, exp: 0}}
      assert [scim_filter: [attrexp: [_, _, compvalue: ^value]]] = result
    end

    @rule ~s|id eq 1.4|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      value = {:number, %Decimal{sign: 1, coef: 14, exp: -1}}
      assert [scim_filter: [attrexp: [_, _, compvalue: ^value]]] = result
    end

    @rule ~s|id eq -1.4|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      value = {:number, %Decimal{sign: -1, coef: 14, exp: -1}}
      assert [scim_filter: [attrexp: [_, _, compvalue: ^value]]] = result
    end

    @rule ~s|id eq -1.4e+10|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      value = {:number, %Decimal{sign: -1, coef: 14, exp: 9}}
      assert [scim_filter: [attrexp: [_, _, compvalue: ^value]]] = result
    end

    @rule ~s|userName Eq "john"|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [
              schema_uri: "",
              attrname: "userName"
            ],
            compareop: "eq",
            compvalue: "john"
          ]
        ]
      ]
      assert result == expected
    end

    @rule ~s|name.familyName co "O'Malley"|
    test @rule do
      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [
              schema_uri: "",
              attrname: "name",
              subattr: "familyName"
            ],
            compareop: "co",
            compvalue: "O'Malley"
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|userName[value sw "foo" and value ew "bar"]|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      expected = [
        scim_filter: [
          valuepath: [
            attrpath: [schema_uri: "", attrname: "userName"],
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "sw",
              compvalue: "foo",
            ],
            and_or: "and",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "ew",
              compvalue: "bar",
            ],
          ]
        ]
      ]
      assert result == expected
    end

    @rule ~s|userType eq "Employee" and emails[type eq "work" and value co "@example.com"]|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)
      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [schema_uri: "", attrname: "userType"],
            compareop: "eq",
            compvalue: "Employee",
          ],
          and_or: "and",
          valuepath: [
            attrpath: [schema_uri: "", attrname: "emails"],
            attrexp: [
              attrpath: [schema_uri: "", attrname: "type"],
              compareop: "eq",
              compvalue: "work",
            ],
            and_or: "and",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "co",
              compvalue: "@example.com",
            ],
          ]
        ]
      ]
      assert result == expected
    end

    @rule ~s|urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"|
    test @rule do
      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [
              schema_uri: "urn:ietf:params:scim:schemas:core:2.0:User",
              attrname: "userName"
            ],
            compareop: "sw",
            compvalue: "J"
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|not (meta.resourceType eq User) or (meta.resourceType eq Group)|
    test "#{@rule} (does not cause an error (even though spec's ABNF doesn't allow it)" do
      expected = [
        scim_filter: [
          not: "not",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "meta", subattr: "resourceType"],
              compareop: "eq",
              compvalue: {:compkeyword, "User"}
            ]
          ],
          and_or: "or",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "meta", subattr: "resourceType"],
              compareop: "eq",
              compvalue: {:compkeyword, "Group"}
            ]
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|(meta.resourceType eq User) or (meta.resourceType eq Group and (meta.resourceType eq Kaas or meta.foo eq Bar) or meta.foo eq Baz)|
    test @rule do
      expected = [
        scim_filter: [
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "meta", subattr: "resourceType"],
              compareop: "eq",
              compvalue: {:compkeyword, "User"}
            ]
          ],
          and_or: "or",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "meta", subattr: "resourceType"],
              compareop: "eq",
              compvalue: {:compkeyword, "Group"}
            ],
            and_or: "and",
            filter_grouping: [
              attrexp: [
                attrpath: [schema_uri: "", attrname: "meta", subattr: "resourceType"],
                compareop: "eq",
                compvalue: {:compkeyword, "Kaas"}
              ],
              and_or: "or",
              attrexp: [
                attrpath: [schema_uri: "", attrname: "meta", subattr: "foo"],
                compareop: "eq",
                compvalue: {:compkeyword, "Bar"}
              ]
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "meta", subattr: "foo"],
              compareop: "eq",
              compvalue: {:compkeyword, "Baz"}
            ]
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|(id eq "foo") or (id eq "bar" or id eq "baz") or (id eq "qux")|
    test @rule do
      expected = [
        scim_filter: [
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "id"],
              compareop: "eq",
              compvalue: "foo"
            ]
          ],
          and_or: "or",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "id"],
              compareop: "eq",
              compvalue: "bar"
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "id"],
              compareop: "eq",
              compvalue: "baz"
            ]
          ],
          and_or: "or",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "id"],
              compareop: "eq",
              compvalue: "qux"
            ]
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule """
    (
      (foo pr or foo eq 1)
    )
    and (
      bar gt 1
      and (
        (bar lt 5 and bar eq 3)
        and (bar eq 2 or bar eq 1.5 or bar eq 1.7)
      )
      or qux eq 2
    )
    """
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)

      expected = [
        scim_filter: [
          filter_grouping: [
            filter_grouping: [
              attrexp: [
                attrpath: [schema_uri: "", attrname: "foo"],
                presentop: "pr"
              ],
              and_or: "or",
              attrexp: [
                attrpath: [schema_uri: "", attrname: "foo"],
                compareop: "eq",
                compvalue: {:number, %Decimal{coef: 1, exp: 0, sign: 1}}
              ]
            ]
          ],
          and_or: "and",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "bar"],
              compareop: "gt",
              compvalue: {:number, %Decimal{coef: 1, exp: 0, sign: 1}}
            ],
            and_or: "and",
            filter_grouping: [
              filter_grouping: [
                attrexp: [
                  attrpath: [schema_uri: "", attrname: "bar"],
                  compareop: "lt",
                  compvalue: {:number, %Decimal{coef: 5, exp: 0, sign: 1}}
                ],
                and_or: "and",
                attrexp: [
                  attrpath: [schema_uri: "", attrname: "bar"],
                  compareop: "eq",
                  compvalue: {:number, %Decimal{coef: 3, exp: 0, sign: 1}}
                ]
              ],
              and_or: "and",
              filter_grouping: [
                attrexp: [
                  attrpath: [schema_uri: "", attrname: "bar"],
                  compareop: "eq",
                  compvalue: {:number, %Decimal{coef: 2, exp: 0, sign: 1}}
                ],
                and_or: "or",
                attrexp: [
                  attrpath: [schema_uri: "", attrname: "bar"],
                  compareop: "eq",
                  compvalue: {:number, %Decimal{coef: 15, exp: -1, sign: 1}}
                ],
                and_or: "or",
                attrexp: [
                  attrpath: [schema_uri: "", attrname: "bar"],
                  compareop: "eq",
                  compvalue: {:number, %Decimal{coef: 17, exp: -1, sign: 1}}
                ]
              ]
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "qux"],
              compareop: "eq",
              compvalue: {:number, %Decimal{coef: 2, exp: 0, sign: 1}}
            ]
          ]
        ]
      ]

      assert result == expected
    end

    @rule ~s|
    (
      l.id eq "0"
      and l.id eq "1"
      or l.id eq "2"
      or l.id eq "3"
      or l.id eq "4"
      and not (l.id eq "6")
    )
    and not (
      l.id eq "5"
    )
    |
    test @rule do
      # FIXME: `and` should have precedence before `or` .. right now they are
      # treated equally. There seem to be several ways of tackling this:
      # * adjusting the parser definition (abnf)
      # * add postprocessing (post_traverse logic) to the parser module
      # * add the logic to a postprocessing module (which we need anyway)
      expected = [
        scim_filter: [
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
              compareop: "eq",
              compvalue: "0"
            ],
            and_or: "and",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
              compareop: "eq",
              compvalue: "1"
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
              compareop: "eq",
              compvalue: "2"
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
              compareop: "eq",
              compvalue: "3"
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
              compareop: "eq",
              compvalue: "4"
            ],
            and_or: "and",
            not: "not",
            filter_grouping: [
              attrexp: [
                attrpath: [schema_uri: "", attrname: "l", subattr: "id"],
                compareop: "eq",
                compvalue: "6"
              ]
            ]
          ],
          and_or: "and",
          not: "not",
          filter_grouping: [
            attrexp: [
              attrpath: [
                schema_uri: "",
                attrname: "l",
                subattr: "id"
              ],
              compareop: "eq",
              compvalue: "5"
            ]
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end

    @rule ~s|id eq 60 and id eq 1188|
    test @rule do
      assert {:ok, result, "", _, _, _} = parse(:scim_filter, @rule)

      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [schema_uri: "", attrname: "id"],
            compareop: "eq",
            compvalue: {:number, %Decimal{sign: 1, coef: 60, exp: 0}}
          ],
          and_or: "and",
          attrexp: [
            attrpath: [schema_uri: "", attrname: "id"],
            compareop: "eq",
            compvalue: {:number, %Decimal{sign: 1, coef: 1188, exp: 0}}
          ]
        ]
      ]

      assert result == expected
    end

    @rule ~s|primaryGroup eq "world" and (firstName co "John" or lastName co "Smith")|
    test @rule do
      expected = [
        scim_filter: [
          attrexp: [
            attrpath: [schema_uri: "", attrname: "primaryGroup"],
            compareop: "eq",
            compvalue: "world"
          ],
          and_or: "and",
          filter_grouping: [
            attrexp: [
              attrpath: [schema_uri: "", attrname: "firstName"],
              compareop: "co",
              compvalue: "John"
            ],
            and_or: "or",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "lastName"],
              compareop: "co",
              compvalue: "Smith"
            ]
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_filter, @rule)
    end
  end

  describe "result of parsing valid attribute path" do
    @rule ~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber|
    test @rule do
      expected = [
        scim_path: [
          attrpath: [
            schema_uri: "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User",
            attrname: "employeeNumber"
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_path, @rule)
    end

    @rule ~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber.value|
    test @rule do
      expected = [
        scim_path: [
          attrpath: [
            schema_uri: "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User",
            attrname: "employeeNumber",
            subattr: "value"
          ]
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_path, @rule)
    end

    @rule ~s|emails[type eq "work" and value sw "department-sales." and value ew "example.com"].value|
    test @rule do
      expected = [
        scim_path: [
          valuepath: [
            attrpath: [
              schema_uri: "",
              attrname: "emails"
            ],
            attrexp: [
              attrpath: [schema_uri: "", attrname: "type"],
              compareop: "eq",
              compvalue: "work"
            ],
            and_or: "and",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "sw",
              compvalue: "department-sales."
            ],
            and_or: "and",
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "ew",
              compvalue: "example.com"
            ]
          ],
          subattr: "value"
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_path, @rule)
    end

    @rule ~s|urn:ietf:params:scim:schemas:extension:foo:2.0:User:bars[value sw "baz" or not (value sw "qux" and value ew "baz")].value|
    test @rule do
      expected = [
        scim_path: [
          valuepath: [
            attrpath: [
              schema_uri: "urn:ietf:params:scim:schemas:extension:foo:2.0:User",
              attrname: "bars"
            ],
            attrexp: [
              attrpath: [schema_uri: "", attrname: "value"],
              compareop: "sw",
              compvalue: "baz"
            ],
            and_or: "or",
            not: "not",
            valfilter_grouping: [
              attrexp: [
                attrpath: [schema_uri: "", attrname: "value"],
                compareop: "sw",
                compvalue: "qux"
              ],
              and_or: "and",
              attrexp: [
                attrpath: [schema_uri: "", attrname: "value"],
                compareop: "ew",
                compvalue: "baz"
              ]
            ]
          ],
          subattr: "value"
        ]
      ]

      assert {:ok, ^expected, "", _, _, _} = parse(:scim_path, @rule)
    end
  end
end
