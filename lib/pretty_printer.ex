defmodule PrettierPrinter do

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

  # def %TEXT{text: x} <~> %TEXT{text: y} do
  #   %TEXT{text: (x <> y)}
  # end

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

  defp flatten(:NIL), do: :NIL
  defp flatten(:LINE), do: %TEXT{text: " "}

  defp flatten(%CAT{left: x,right: y}), do: (flatten x) <~> (flatten y)
  defp flatten(%NEST{indent: i,doc: x}), do: %NEST{indent: i,doc: flatten x}
  defp flatten(%TEXT{text: s}), do: %TEXT{text: s}
  defp flatten(%UNION{left: x, right: _}), do: flatten x

  defp layout(:Nil), do: ""
  defp layout(%Text{text: s, doc: x}), do: s <> layout(x)
  defp layout(%Line{indent: i, doc: x}), do: "\n" <> String.duplicate(" ",i) <> layout(x)
  # def layout(%Line{indent: i, doc: x}), do: copy(i,">") <> layout(x)

  def best(w,k,x), do: be(w,k,[{0,x}])

  def be(w,k,[{_,%TEXT{text: s}} | z]), do: %Text{text: s, doc: be(w,(k + (String.length s)),z)}
  def be(w,k,[{i,%CAT{left: x, right: y}} | z]), do: be(w,k,[{i,x} | [{i,y} | z]])
  def be(w,k,[{i,%NEST{indent: j, doc: x}} | z]), do: be(w,k,([{i+j,x} | z]))
  def be(w,k,[{i,%UNION{left: x, right: y}} | z]), do: better(w,k,(be(w,k,([{i,x} | z]))),fn -> (be(w,k,([{i,y} | z]))) end)
  def be(w,k,[{_,:NIL} | z]), do: be(w,k,z)
  def be(w,_,[{i,:LINE} | z]), do: %Line{indent: i, doc: be(w,i,z)}
  def be(_,_,[]), do: :Nil

  # Changing better to accept a function as y so it doesnt evaluate unless it has to
  def better(w,k,x,y), do: if fits(w-k,x), do: x, else: y.()

  def fits(w,_) when w < 0, do: false
  def fits(w,%Text{text: s, doc: x}), do: fits((w - String.length s),x)
  def fits(_,%Line{indent: _,doc: _}), do: true
  def fits(_,:Nil), do: true

  def pretty(w,x) do
    best(w,0,x) |> layout
  end

  # Utils

  def cat_space(x,y), do: x <~> (text(" ") <~> y)

  def cat_line(x,y), do: x <~> (line <~> y)

  def cat_best(x,y), do: x <~> ((text(" ") <|> line) <~> y)

  def folddoc(_,[]), do: nill()
  def folddoc(_,[x]), do: x
  def folddoc(f,[x | xs]), do: f.(x,folddoc(f,xs))

  def spread(xs), do: folddoc(&cat_space/2,xs)
  def stack(xs), do: folddoc(&cat_line/2,xs)
  def spread_or_stack(xs), do: folddoc(&cat_best/2,xs)

  def bracket(l,x,r), do: group(text(l) <~> nest(2,line <~> x) <~> line <~> text(r))


  # -- Tree example

  defmodule Tree do
    defstruct name: "", children: {}
  end

  def showTree(%Tree{name: s, children: ts}), do: text(s) <~> showBracket(ts)

  def showBracket([]), do: nill()
  def showBracket(ts), do: bracket("[",showTrees(ts),"]")

  def showTrees([t | []]), do: showTree t
  def showTrees([t | ts]), do: showTree(t) <~> text(",") <~> line <~> showTrees(ts)

  def testtree(w,t), do: pretty(w,t)

  def test(i) do
    t = showTree(%Tree{name: "aaa", children: [
             %Tree{name: "bbbbb", children: [
                      %Tree{name: "ccc", children: []},
                      %Tree{name: "dd", children: []}
                    ]},
             %Tree{name: "eee", children: []},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: [
                               %Tree{name: "ffff", children: [
                                        %Tree{name: "gg", children: []},
                                        %Tree{name: "hh", children: []},
                                        %Tree{name: "ii", children: []}
                                      ]}
                             ]},
                      %Tree{name: "ii", children: []},
                      %Tree{name: "ffff", children: [
                               %Tree{name: "gg", children: []},
                               %Tree{name: "hh", children: []},
                               %Tree{name: "ii", children: []}
                             ]}
                    ]},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: []},
                      %Tree{name: "ii", children: []}
                    ]},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: []},
                      %Tree{name: "ii", children: []}
                    ]},
             %Tree{name: "eee", children: []},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: [
                               %Tree{name: "ffff", children: [
                                        %Tree{name: "gg", children: []},
                                        %Tree{name: "hh", children: []},
                                        %Tree{name: "ii", children: []}
                                      ]}
                             ]},
                      %Tree{name: "ii", children: []},
                      %Tree{name: "ffff", children: [
                               %Tree{name: "gg", children: []},
                               %Tree{name: "hh", children: []},
                               %Tree{name: "ii", children: []}
                             ]}
                    ]},
             %Tree{name: "bbbbb", children: [
                      %Tree{name: "ccc", children: []},
                      %Tree{name: "dd", children: []}
                    ]},
             %Tree{name: "eee", children: []},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: [
                               %Tree{name: "ffff", children: [
                                        %Tree{name: "gg", children: []},
                                        %Tree{name: "hh", children: []},
                                        %Tree{name: "ii", children: []}
                                      ]}
                             ]},
                      %Tree{name: "ii", children: []},
                      %Tree{name: "ffff", children: [
                               %Tree{name: "gg", children: []},
                               %Tree{name: "hh", children: []},
                               %Tree{name: "ii", children: []}
                             ]}
                    ]},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: []},
                      %Tree{name: "ii", children: []}
                    ]},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: []},
                      %Tree{name: "ii", children: []}
                    ]},
             %Tree{name: "ffff", children: [
                      %Tree{name: "gg", children: []},
                      %Tree{name: "hh", children: [
                               %Tree{name: "ffff", children: [
                                        %Tree{name: "gg", children: []},
                                        %Tree{name: "hh", children: []},
                                        %Tree{name: "ii", children: []}
                                      ]}
                             ]},
                      %Tree{name: "ii", children: []},
                      %Tree{name: "ffff", children: [
                               %Tree{name: "gg", children: []},
                               %Tree{name: "hh", children: []},
                               %Tree{name: "ii", children: []}
                             ]}
                    ]},
           ]
    })
    IO.inspect t
    IO.puts(testtree(i,t))
  end

end
