defmodule Elixirfmt do
  @moduledoc """
  Documentation for Elixirfmt.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elixirfmt.hello
      :world

  """
  def getFileText do
    {:ok, content} = File.read("/home/steams/Development/elixirfmt/lib/elixirfmt.ex")
    content
  end

  defmacro is_operator(op) do
    quote do: unquote(op) == :=
  end

  defmodule AstNode do
    defstruct type: "", value: "", meta: [], children: []
  end

  def getAstNodes(nodes) do
    # Enum.map nodes parseAst
    nodes
  end

  def getNodeType({value,meta,children}) do
    case value do
      x when is_operator(x) -> :Operator
      x when is_atom(x) -> :Atom
      _ -> :Unknown
    end
  end

  def parseAst(ast) do
    {value,meta,children} = ast
    # walk the tree recursively and create AstNodes
    %AstNode{type: getNodeType(ast), value: value, meta: meta, children: getAstNodes(children)}
  end

  # def printAst(ast) do
  #   %AstNode{type: type,value: value,meta: meta,children: children} = ast
  #   case type do
  #     :Operator -> printOperator
  #   end
  # end

  def hello do
    %AstNode{type: "Number", value: 57, meta: [], children: []}
  end
end

# {:=, [],
#  [{:sum2, [], Elixir},
#   {:fn, [],
#     [{:->, [],
#      [[{:one, [], Elixir}, {:two, [], Elixir}],
#       {:+, [context: Elixir, import: Kernel],
#        [{:one, [], Elixir}, {:two, [], Elixir}]}]}]}]}

# {:defmodule, [line: 1],
#  [{:__aliases__, [counter: 0, line: 1], [:Elixirfmt]},
#   [do: {:__block__, [],
#     [{:@, [line: 2],
#       [{:moduledoc, [line: 2], ["Documentation for Elixirfmt.\n"]}]},
#      {:@, [line: 6],
#       [{:doc, [line: 6],
#         ["Hello world.\n\n## Examples\n\n    iex> Elixirfmt.hello\n    :world\n\n"]}]},
#      {:def, [line: 15],
#       [{:getFileText, [line: 15], nil},
#        [do: {:__block__, [],
#          [{:=, [line: 16],
#            [{:ok, {:content, [line: 16], nil}},
#             {{:., [line: 16],
#               [{:__aliases__, [counter: 0, line: 16], [:File]}, :read]},
#              [line: 16],
#              ["/home/steams/Development/elixirfmt/lib/elixirfmt.ex"]}]},
#           {:content, [line: 17], nil}]}]]},
#      {:defmacro, [line: 19],
#       [{:is_operator, [line: 19], [{:op, [line: 19], nil}]},
#        [do: {:quote, [line: 20],
#          [[do: {:==, [line: 20],
#             [{:unquote, [line: 20], [{:op, [line: 20], nil}]}, :=]}]]}]]},
#      {:defmodule, [line: 23],
#       [{:__aliases__, [counter: 0, line: 23], [:AstNode]},
#        [do: {:defstruct, [line: 24],
#          [[type: "", value: "", meta: [], children: []]]}]]},
#      {:def, [line: 27],
#       [{:getAstNodes, [line: 27], [{:x, [line: 27], nil}]},
#        [do: {:x, [line: 28], nil}]]},
#      {:def, [line: 31],
#       [{:getNodeType, [line: 31],
#         [{:{}, [line: 31],
#           [{:value, [line: 31], nil}, {:meta, [line: 31], nil},
#            {:children, [line: 31], nil}]}]},
#        [do: {:case, [line: 32],
#          [{:value, [line: 32], nil},
#           [do: [{:->, [line: 33],
#              [[{:when, [line: 33],
#                 [{:x, [line: 33], nil},
#                  {:is_operator, [line: 33], [{:x, [line: 33], nil}]}]}],
#               :Operator]},
#             {:->, [line: 34], [[{:_, [line: 34], nil}], :Unknown]}]]]}]]},
#      {:def, [line: 38],
#       [{:parseAst, [line: 38], [{:ast, [line: 38], nil}]},
#        [do: {:__block__, [],
#          [{:=, [line: 39],
#            [{:{}, [line: 39],
#              [{:value, [line: 39], nil}, {:meta, [line: 39], nil},
#               {:children, [line: 39], nil}]}, {:ast, [line: 39], nil}]},
#           {:%, [line: 41],
#            [{:__aliases__, [counter: 0, line: 41], [:AstNode]},
#             {:%{}, [line: 41],
#              [type: {:getNodeType, [line: 41], [{:ast, [line: 41], nil}]},
#               value: {:value, [line: 41], nil}, meta: {:meta, [line: 41], nil},
#               children: {:getAstNodes, [line: 41],
#                [{:children, [line: 41], nil}]}]}]}]}]]},
#      {:def, [line: 44],
#       [{:hello, [line: 44], nil},
#        [do: {:%, [line: 45],
#          [{:__aliases__, [counter: 0, line: 45], [:AstNode]},
#           {:%{}, [line: 45],
#            [type: "Number", value: 57, meta: [], children: []]}]}]]}]}]]}
