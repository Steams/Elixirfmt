defmodule PrettyPrinter do

  # Data Stuctures

  defmodule Text do
    defstruct text: "", doc: {}
  end

  defmodule Line do
    defstruct indent: 0, doc: {}
  end

  defmodule CAT do
    defstruct left: {}, right: {}
  end

  defmodule NEST do
    defstruct indent: 0, doc: {}
  end

  defmodule TEXT do
    defstruct text: ""
  end

  defmodule UNION do
    defstruct left: {}, right: {}
  end

  # Fucntions

  def nill, do: :NIL

  def x <~> y do
    %CAT{left: x, right: y}
  end

  def x <|> y do
    %UNION{left: x, right: y}
  end

  def nest(i,a) do
    %NEST{indent: i,doc: a}
  end

  def text(s) do
    %TEXT{text: s}
  end

  def line, do: :LINE

  def group(x), do: (flatten x ) <|> x

  def flatten(:NIL), do: :NIL

  def flatten(%CAT{left: x,right: y}), do: %CAT{left: (flatten x),right: (flatten y)}

  def flatten(%NEST{indent: i,doc: x}), do: %NEST{indent: i,doc: flatten x}

  def flatten(%TEXT{text: s}), do: %TEXT{text: s}

  def flatten(:LINE), do: %TEXT{text: ""}

  def flatten(%UNION{left: x, right: y}), do: flatten x

  def layout(:Nil), do: ""
  def layout(%Text{text: s, doc: x}), do: (s <> layout(x))
  def layout(%Line{indent: i, doc: x}), do: ("\n" <> (copy(i," ")) <> layout(x))
  # def layout(%Line{indent: i, doc: x}), do: copy(i,">") <> layout(x)

  def copy(i,x) do
    list = for n <- 1..i, do: x
    List.foldl(list,"",fn(x,ac) -> x <> ac end)
  end

  def best(w,k,x), do: be(w,k,[{0,x}])

  def be(w,k,[]), do: :Nil

  def be(w,k,[{i,:NIL} | z]), do: be(w,k,z)

  def be(w,k,[{i,%CAT{left: x, right: y}} | z]), do: be(w,k,([{i,x},{i,y}] ++ z))

  def be(w,k,[{i,%NEST{indent: j, doc: x}} | z]), do: be(w,k,([{i+j,x}] ++ z))

  def be(w,k,[{i,%TEXT{text: s}} | z]), do: %Text{text: s, doc: be(w,(k + String.length s),z)}

  def be(w,k,[{i,:LINE} | z]), do: %Line{indent: i, doc: be(w,i,z)}

  def be(w,k,[{i,%UNION{left: x, right: y}} | z]), do: better(w,k,(be(w,k,([{i,x}] ++ z))),(be(w,k,([{i,y}] ++ z))))

  def better(w,k,x,y), do: if fits(w-k,x), do: x, else: y

  def fits(w,x) when w < 0, do: false
  def fits(w,:Nil), do: true
  def fits(w,%Text{text: s, doc: x}), do: fits((w - String.length s),x)
  def fits(w,%Line{indent: i,doc: x}), do: true

  def pretty(w,x), do: best(w,0,x) |> layout

  # Utils

  def bracket(l,x,r), do: group(text(l) <~> nest(2,(line <~> x)) <~> line <~> text(r))

  # -- Tree example

  defmodule Tree do
    defstruct name: "", children: {}
  end

  def showTree(%Tree{name: s, children: ts}), do: text(s) <~> showBracket(ts)

  def showBracket([]), do: nill
  def showBracket(ts), do: bracket("[",showTrees(ts),"]")

  def showTrees([t | []]), do: showTree t
  def showTrees([t | ts]), do: showTree(t) <~> text(",") <~> line <~> showTrees(ts)

  def showme, do: showTree(
        %Tree{name: "aaa", children: [
                 %Tree{name: "bbbbb", children: [
                          %Tree{name: "ccc", children: []},
                          %Tree{name: "dd", children: []}
                        ]},
                 %Tree{name: "eee", children: []}
               ]
        }
      )

  def testtree(w), do: pretty(w,(showTree(
                %Tree{name: "aaa", children: [
                         %Tree{name: "bbbbb", children: [
                                  %Tree{name: "ccc", children: []},
                                  %Tree{name: "dd", children: []}
                                ]},
                         %Tree{name: "eee", children: []},
                         %Tree{name: "ffff", children: [
                                  %Tree{name: "gg", children: []},
                                  %Tree{name: "hh", children: []},
                                  %Tree{name: "ii", children: []}
                                ]},
                       ]
                }
              )
          )
      )

  def test(i), do: IO.puts(testtree(i))

end
