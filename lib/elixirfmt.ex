defmodule Elixirfmt do
  import PrettyPrinter

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

  # defmacro is_operator(op) do
  #   quote do: unquote(op) == :=
  # end

  defmacro is_operator(op) do
    quote do
      unquote(op) == := or unquote(op) == :+
    end
  end

  defmacro is_fbody(op) do
    quote do
      unquote(op) == :->
    end
  end

  defmacro is_anonfunc(op) do
    quote do
      unquote(op) == :fn
    end
  end

  defmodule AstNode do
    defstruct type: "", value: "", meta: [], children: []
  end

  defmodule AstNode do
    defstruct type: "", value: "", meta: [], children: []
  end
  # restructure this to have a type and a container, or just type value where value is like BinaryOperator

  defmodule BinaryOp do
    defstruct name: "", left: {}, right: {}
  end

  defmodule FuncBody do
    defstruct body: {}
  end

  defmodule Atom do
    defstruct name: ""
  end

  defmodule AstFBody do
    defstruct args: [], body: {}
  end

  def getFunctionBody(node) do
    xs = hd node
    body = hd(tl node)
    arguments = Enum.map(xs, fn x -> parseAst(x) end)
    %AstFBody{args: arguments, body: parseAst(body)}
  end

  def getChildNodes(nodes,parent_type \\ :Any) do
    case parent_type do
      :FunctionBody -> getFunctionBody(nodes)
      :AnonymousFunction -> getChildNodes(nodes)
      :Atom -> []
      _ -> Enum.map(nodes,fn x -> parseAst(x) end)
    end
  end

  def getNodeType({value,meta,children}) do
    case value do
      x when is_fbody(x) -> :FunctionBody
      x when is_anonfunc(x) -> :AnonymousFunction
      x when is_operator(x) -> :Operator
      x when is_atom(x) -> :Atom
      _ -> :Unknown
    end
  end

  def parseAst(ast) do
    {value,meta,children} = ast
    node_type = getNodeType(ast)
    IO.inspect ast
    IO.inspect node_type
    # Enum.map(children, fn x -> IO.inspect x end)
    # IO.inspect children
    IO.puts "_________________________________-"

    %AstNode{type: node_type, value: value, meta: meta, children: getChildNodes(children,node_type)}
    # # walk the tree recursively and create AstNodes
  end

  def printAst(ast) do
    %AstNode{type: type,value: value} = ast
    case value do
      %BinaryOp{name: op, left: x, right: y} -> printAst(x) <~> text(" " <> op <> " ") <~>  printAst(y)
      %AnonFunc{args: x, body: f} -> text "fn" <~> brackets("(",args,")") <~> text "->" <~> line
      %FuncBody{body: x} -> nest(2,printAst(x))
      %Atom{name: x} -> text s
      _ -> text "unknown"
    end
  end

  def test do
    str = "{:=, [], [
      {:sum2, [], Elixir},
      {:fn, [], [
        {:->, [], [
          [{:one, [], Elixir}, {:two, [], Elixir}],
          {:+, [context: Elixir, import: Kernel], [
            {:one, [], Elixir},
            {:two, [], Elixir}
          ]}
        ]}
      ]}
    ]} "

    ast=  {:=, [], [{:sum2, [], Elixir}, {:fn, [], [{:->, [], [[{:one, [], Elixir}, {:two, [], Elixir}], {:+, [context: Elixir, import: Kernel], [{:one, [], Elixir}, {:two, [], Elixir}]}]}]}]}

    # parseAst(Code.string_to_quoted!(str))
    parsed = parseAst(ast)
    # layout(printAst(parsed))
  end

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

# %Elixirfmt.AstNode{children: [%Elixirfmt.AstNode{children: [], meta: [],
#                                                  type: :Atom, value: :sum2},
#                               %Elixirfmt.AstNode{children: [%Elixirfmt.AstNode{children: %Elixirfmt.AstFBody{args: [%Elixirfmt.AstNode{children: [],
#                                                                                                                                        meta: [], type: :Atom, value: :one},
#                                                                                                                     %Elixirfmt.AstNode{children: [], meta: [], type: :Atom, value: :two}],
#                                                                                                              body: %Elixirfmt.AstNode{children: [%Elixirfmt.AstNode{children: [],
#                                                                                                                                                                     meta: [], type: :Atom, value: :one},
#                                                                                                                                                  %Elixirfmt.AstNode{children: [], meta: [], type: :Atom, value: :two}],
#                                                                                                                                       meta: [context: Elixir, import: Kernel], type: :Operator, value: :+}},
#                                                                                 meta: [], type: :FunctionBody, value: :->}], meta: [],
#                               type: :AnonymousFunction, value: :fn}], meta: [], type: :Operator, value: :=}
