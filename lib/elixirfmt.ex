defmodule Elixirfmt do
  import PrettierPrinter

  @moduledoc """
  Documentation for Elixirfmt.
  """

  @doc """

  """

  defmacro is_block(op) do
    quote do
      unquote(op) == :__block__
    end
  end

  defmacro is_operator(op) do
    quote do
      unquote(op) == := or
      unquote(op) == :+ or
      unquote(op) == :++ or
      unquote(op) == :<>
    end
  end

  defmacro is_fbody(op) do
    quote do
      unquote(op) == :->
    end
  end

  defmacro is_func_def(op) do
    quote do
      unquote(op) == :def
    end
  end

  defmacro is_anonfunc(op) do
    quote do
      unquote(op) == :fn
    end
  end

  defmodule AstNode do
    defstruct type: "", value: {}
  end

  defmodule BinaryOp do
    defstruct name: "", left: {}, right: {}
  end

  defmodule Atom do
    defstruct name: ""
  end

  defmodule Func do
    defstruct args: [], body: {}
  end

  defmodule FuncDef do
    defstruct name: "", args: [], body: {}
  end

  defmodule Block do
    defstruct children: []
  end

  # NOTE this is for block do funcs, need a different one for inline ones  ", do:"
  def buildFunctionDefinition({id,meta,[{name,funcmeta,args},[do: body]]}) do
    # IO.puts "= Building Function Definition ="
    # IO.puts "= Parsing Function Arguments ="
    arguments = Enum.map(args, fn x -> parse_ast(x) end)
    # IO.puts "= Parsing Function Body ="
    %FuncDef{name: to_string(name), args: arguments, body: parse_ast(body)}
  end

  def buildBinaryOp({name,meta,[left,right]}) do
    # IO.puts "= Building Binary Operator ="
    # IO.puts "= Parsing Left Argument ="
    x = parse_ast(left)
    # IO.puts "= Parsing Right Argument ="
    y = parse_ast(right)

    %BinaryOp{name: name, left: x, right: y}
  end

  # children is = [{:->,[],[[args],{body}]}]
  def buildAnonFunction({id,meta,children}) do
    [{:->,meta,[args,body]}] = children
    arguments = Enum.map(args, fn x -> parse_ast(x) end)
    %Func{args: arguments, body: parse_ast(body)}
  end

  def buildAtom({name,meta,children}) do
    %Atom{name: to_string(name)}
  end

  def buildBlock({name,meta,children}) do
     kids = Enum.map(children, fn x -> parse_ast(x) end)
    %Block{children: kids}
  end

  def getNodeValue(ast,type) do
    case type do
      :FunctionDefinition -> buildFunctionDefinition(ast)
      :Block -> buildBlock(ast)
      :AnonymousFunction -> buildAnonFunction(ast)
      :Operator -> buildBinaryOp(ast)
      :Atom -> buildAtom(ast)
    end
  end

  def get_node_type({value,meta,children}) do
    case value do
      x when is_block(x) -> :Block
      x when is_func_def(x) -> :FunctionDefinition
      x when is_anonfunc(x) -> :AnonymousFunction
      x when is_operator(x) -> :Operator
      x when is_atom(x) -> :Atom
      _ -> :Unknown
    end
  end

  # Convert Ast Tuples to a Typed representation that can be pattern matched on (using structs)
  def parse_ast(ast) do
    {value,meta,children} = ast
    node_type = get_node_type(ast)
    # IO.inspect ast
    # IO.inspect node_type
    # IO.puts "_________________________________"

    %AstNode{type: node_type, value: getNodeValue(ast,node_type)}
  end


  def show_args(args) do
    arguments = Enum.map(args, fn(x) -> show_ast(x) <~> text(",") end)
    spread_or_stack(arguments)
  end

  # Convert Typed Ast Structs to "Prettier Printer" DOC types
  def show_ast(ast) do

    %AstNode{type: type,value: value} = ast

    case value do

      %FuncDef{name: name, args: args, body: body} ->
        head = text("def " <> name) <~> (bracket("(",show_args(args),")") <~> text(" do"))
        body = bracket("",show_ast(body),"end")
        cat_best(head,body)

      %BinaryOp{name: op, left: x, right: y} ->
        left = show_ast(x) <~> text(" " <> to_string(op))
        right = show_ast(y)
        cat_best(left,right)

      %Block{children: xs} ->
        kids = Enum.map(xs, fn(x) -> show_ast(x) <~> line end)
        stack(kids)

      %Func{args: args, body: f} ->
        head = text("fn") <~> bracket("(",show_args(args),") ->")
        body = bracket("",show_ast(f),"end")
        cat_best(head,body)

      %Atom{name: x} ->
        text(to_string(x))

      _ -> text "unknown"
    end
  end

  # TODO Handle anonymous function calls with dot in parser/printer
  def test(w) do

    # str = "sum5 = fn(one,two,three,four,five) -> one + two + three + four + five end"
    # str = "def sum5(one,two) do one + two end "

    # str = "def sum5(one,two) do one + two end "
    str = "def nested(one,two,three,four) do
      sum4 = fn(x,y,z,a) -> x + y + z + a end

      somethingElse = fn(name,surname) -> name ++ surname end
      somethingElse = fn(name,surname) -> name ++ surname end
    end"

    ast = Code.string_to_quoted!(str)

    parsed = parse_ast(ast)
    doc = show_ast(parsed)
    # IO.puts("______________AST____________")
    # IO.inspect parsed
    # IO.puts("______________DOC____________")
    # IO.inspect doc
    IO.puts("|" <> String.duplicate("-",w-2) <> "|")
    IO.puts(pretty(w,doc))
  end

  def format(w,str) do
    ast = Code.string_to_quoted!(str)
    parsed = parse_ast(ast)
    IO.puts("|" <> String.duplicate("-",w-2) <> "|")
    IO.puts(pretty(w,show_ast(parsed)))
  end

end
