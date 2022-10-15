defmodule SCIM.V2.Filter.BuilderTest do
  use ExUnit.Case, async: true

  import SCIM.V2.TestHelpers

  alias SCIM.V2.Filter.{
    Builder,
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
    |> Builder.build()
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

  describe "filter rules and returned filter data" do
    @filter_rules [
      {~s|userName Eq "john"|,
       %Filter{
         value: %Condition{
           op: :eq,
           path: %Path{attribute: "userName"},
           value: %Value{type: :string, value: "john"}
         }
       }},
      {~s|Username eq "john"|,
       %Filter{
         value: %Condition{
           op: :eq,
           path: %Path{attribute: "Username"},
           value: %Value{type: :string, value: "john"}
         }
       }},
      {~s|userName eq "bjensen"|,
       %Filter{
         value: %Condition{
           op: :eq,
           path: %Path{attribute: "userName"},
           value: %Value{type: :string, value: "bjensen"}
         }
       }},
      {~s|name.familyName co "O'Malley"|,
       %Filter{
         value: %Condition{
           op: :co,
           path: %Path{attribute: "name", subattribute: "familyName"},
           value: %Value{type: :string, value: "O'Malley"}
         }
       }},
      {~s|userName sw "J"|,
       %Filter{
         value: %Condition{
           op: :sw,
           path: %Path{attribute: "userName"},
           value: %Value{type: :string, value: "J"}
         }
       }},
      {~s|urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"|,
       %Filter{
         value: %Condition{
           op: :sw,
           path: %Path{schema: "urn:ietf:params:scim:schemas:core:2.0:User", attribute: "userName"},
           value: %Value{type: :string, value: "J"}
         }
       }},
      {~s|title pr|,
       %Filter{
         value: %Condition{
           op: :pr,
           path: %Path{attribute: "title"}
         }
       }},
      {~s|meta.lastModified gt "2011-05-13T04:42:34Z"|,
       %Filter{
         value: %Condition{
           op: :gt,
           path: %Path{attribute: "meta", subattribute: "lastModified"},
           value: %Value{type: :string, value: "2011-05-13T04:42:34Z"}
         }
       }},
      {~s|meta.lastModified ge "2011-05-13T04:42:34Z"|,
       %Filter{
         value: %Condition{
           op: :ge,
           path: %Path{attribute: "meta", subattribute: "lastModified"},
           value: %Value{type: :string, value: "2011-05-13T04:42:34Z"}
         }
       }},
      {~s|meta.lastModified lt "2011-05-13T04:42:34Z"|,
       %Filter{
         value: %Condition{
           op: :lt,
           path: %Path{attribute: "meta", subattribute: "lastModified"},
           value: %Value{type: :string, value: "2011-05-13T04:42:34Z"}
         }
       }},
      {~s|meta.lastModified le "2011-05-13T04:42:34Z"|,
       %Filter{
         value: %Condition{
           op: :le,
           path: %Path{attribute: "meta", subattribute: "lastModified"},
           value: %Value{type: :string, value: "2011-05-13T04:42:34Z"}
         }
       }},
      {~s|title pr and userType eq "Employee"|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :pr,
               path: %Path{attribute: "title"}
             },
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             }
           ]
         }
       }},
      {~s|title pr or userType eq "Intern"|,
       %Filter{
         value: %Or{
           value: [
             %Condition{
               op: :pr,
               path: %Path{attribute: "title"}
             },
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Intern"}
             }
           ]
         }
       }},
      {~s|schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"|,
       %Filter{
         value: %Condition{
           op: :eq,
           path: %Path{attribute: "schemas"},
           value: %Value{type: :string, value: "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"}
         }
       }},
      {~s|userType eq "Employee" and (emails co "example.com" or emails.value co "example.org")|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             },
             %Or{
               value: [
                 %Condition{
                   op: :co,
                   path: %Path{attribute: "emails"},
                   value: %Value{type: :string, value: "example.com"}
                 },
                 %Condition{
                   op: :co,
                   path: %Path{attribute: "emails", subattribute: "value"},
                   value: %Value{type: :string, value: "example.org"}
                 }
               ]
             }
           ]
         }
       }},
      {~s|userType ne "Employee" and not (emails co "example.com" or emails.value co "example.org")|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :ne,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             },
             %Not{
               value: %Or{
                 value: [
                   %Condition{
                     op: :co,
                     path: %Path{attribute: "emails"},
                     value: %Value{type: :string, value: "example.com"}
                   },
                   %Condition{
                     op: :co,
                     path: %Path{attribute: "emails", subattribute: "value"},
                     value: %Value{type: :string, value: "example.org"}
                   }
                 ]
               }
             }
           ]
         }
       }},
      {~s|userType eq "Employee" and (emails.type eq "work")|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             },
             %Condition{
               op: :eq,
               path: %Path{attribute: "emails", subattribute: "type"},
               value: %Value{type: :string, value: "work"}
             }
           ]
         }
       }},
      {~s|userType eq "Employee" and emails[type eq "work" and value co "@example.com"]|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             },
             %Path{
               attribute: "emails",
               filter: %Filter{
                 value: %And{
                   value: [
                     %Condition{
                       op: :eq,
                       path: %Path{attribute: "type"},
                       value: %Value{type: :string, value: "work"}
                     },
                     %Condition{
                       op: :co,
                       path: %Path{attribute: "value"},
                       value: %Value{type: :string, value: "@example.com"}
                     }
                   ]
                 }
               }
             }
           ]
         }
       }},
      {~s|emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]|,
       %Filter{
         value: %Or{
           value: [
             %Path{
               attribute: "emails",
               filter: %Filter{
                 value: %And{
                   value: [
                     %Condition{
                       op: :eq,
                       path: %Path{attribute: "type"},
                       value: %Value{type: :string, value: "work"}
                     },
                     %Condition{
                       op: :co,
                       path: %Path{attribute: "value"},
                       value: %Value{type: :string, value: "@example.com"}
                     }
                   ]
                 }
               }
             },
             %Path{
               attribute: "ims",
               filter: %Filter{
                 value: %And{
                   value: [
                     %Condition{
                       op: :eq,
                       path: %Path{attribute: "type"},
                       value: %Value{type: :string, value: "xmpp"}
                     },
                     %Condition{
                       op: :co,
                       path: %Path{attribute: "value"},
                       value: %Value{type: :string, value: "@foo.com"}
                     }
                   ]
                 }
               }
             }
           ]
         }
       }},
      {~s|userType eq "Employee" and (emails co "example.com" or emails co "example.org")|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               op: :eq,
               path: %Path{attribute: "userType"},
               value: %Value{type: :string, value: "Employee"}
             },
             %Or{
               value: [
                 %Condition{
                   op: :co,
                   path: %Path{attribute: "emails"},
                   value: %Value{type: :string, value: "example.com"}
                 },
                 %Condition{
                   op: :co,
                   path: %Path{attribute: "emails"},
                   value: %Value{type: :string, value: "example.org"}
                 }
               ]
             }
           ]
         }
       }},
      {~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber pr|,
       %Filter{
         value: %Condition{
           op: :pr,
           path: %Path{
             schema: "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User",
             attribute: "employeeNumber"
           }
         }
       }},
      {~s|foo eq 1 or foo eq 2 and bar eq 1 and baz eq 1 or baz eq 2|,
       %Filter{
         value: %Or{
           value: [
             %Condition{
               path: %Path{attribute: "foo"},
               op: :eq,
               value: %Value{type: :number, value: %Decimal{coef: 1, exp: 0, sign: 1}}
             },
             %And{
               value: [
                 %Condition{
                   path: %Path{attribute: "foo"},
                   op: :eq,
                   value: %Value{type: :number, value: %Decimal{coef: 2, exp: 0, sign: 1}}
                 },
                 %Condition{
                   path: %Path{attribute: "bar"},
                   op: :eq,
                   value: %Value{type: :number, value: %Decimal{coef: 1, exp: 0, sign: 1}}
                 },
                 %Condition{
                   path: %Path{attribute: "baz"},
                   op: :eq,
                   value: %Value{type: :number, value: %Decimal{coef: 1, exp: 0, sign: 1}}
                 }
               ]
             },
             %Condition{
               path: %Path{attribute: "baz"},
               op: :eq,
               value: %Value{type: :number, value: %Decimal{coef: 2, exp: 0, sign: 1}}
             }
           ]
         }
       }},
      {~s|userType eq "Employee" and emails[type eq "work" and not (value ew "@example.com")]|,
       %Filter{
         value: %And{
           value: [
             %Condition{
               path: %Path{attribute: "userType"},
               op: :eq,
               value: %Value{type: :string, value: "Employee"}
             },
             %Path{
               attribute: "emails",
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
         }
       }}
    ]

    for {rule, expected} <- @filter_rules do
      test "filter rule ~s|#{rule}|" do
        assert {:ok, data} = build(:scim_filter, unquote(rule))
        assert data == unquote(Macro.escape(expected))
      end
    end
  end

  describe "path rules and returned path data" do
    @path_rules [
      {~s|members|,
       %Path{
         attribute: "members"
       }},
      {~s|name.familyName|,
       %Path{
         attribute: "name",
         subattribute: "familyName"
       }},
      {~s|addresses[type eq "work"]|,
       %Path{
         attribute: "addresses",
         filter: %Filter{
           value: %Condition{
             op: :eq,
             path: %Path{attribute: "type"},
             value: %Value{type: :string, value: "work"}
           }
         }
       }},
      {~s|members[value eq "2819c223-7f76-453a-919d-413861904646"]|,
       %Path{
         attribute: "members",
         filter: %Filter{
           value: %Condition{
             op: :eq,
             path: %Path{attribute: "value"},
             value: %Value{type: :string, value: "2819c223-7f76-453a-919d-413861904646"}
           }
         }
       }},
      {~s|members[value eq "2819c223-7f76-453a-919d-413861904646"].displayName|,
       %Path{
         attribute: "members",
         subattribute: "displayName",
         filter: %Filter{
           value: %Condition{
             op: :eq,
             path: %Path{attribute: "value"},
             value: %Value{type: :string, value: "2819c223-7f76-453a-919d-413861904646"}
           }
         }
       }},
      {~s|emails[type eq "work" and value ew "example.com"]|,
       %Path{
         attribute: "emails",
         filter: %Filter{
           value: %And{
             value: [
               %Condition{
                 op: :eq,
                 path: %Path{attribute: "type"},
                 value: %Value{type: :string, value: "work"}
               },
               %Condition{
                 op: :ew,
                 path: %Path{attribute: "value"},
                 value: %Value{type: :string, value: "example.com"}
               }
             ]
           }
         }
       }},
      {~s|addresses[type eq "work"].streetAddress|,
       %Path{
         attribute: "addresses",
         subattribute: "streetAddress",
         filter: %Filter{
           value: %Condition{
             op: :eq,
             path: %Path{attribute: "type"},
             value: %Value{type: :string, value: "work"}
           }
         }
       }},
      {~s|emails[type eq "work"].value|,
       %Path{
         attribute: "emails",
         subattribute: "value",
         filter: %Filter{
           value: %Condition{
             op: :eq,
             path: %Path{attribute: "type"},
             value: %Value{type: :string, value: "work"}
           }
         }
       }},
      {~s|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber|,
       %Path{
         schema: "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User",
         attribute: "employeeNumber"
       }},
      {~s|addresses[foo pr]|,
       %Path{
         attribute: "addresses",
         filter: %Filter{
           value: %Condition{
             op: :pr,
             path: %Path{attribute: "foo"}
           }
         }
       }},
      {~s|emails[type eq "work" and not (value ew "@example.com")].label|,
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
       }}
    ]

    for {rule, expected} <- @path_rules do
      test "path rule ~s|#{rule}|" do
        assert {:ok, data} = build(:scim_path, unquote(rule))
        assert data == unquote(Macro.escape(expected))
      end
    end
  end
end
