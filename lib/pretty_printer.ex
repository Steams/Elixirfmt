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

  def %TEXT{text: x} <~> %TEXT{text: y} do
    %TEXT{text: (x <> y)}
  end

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

  defp best(w,k,x), do: be(w,k,[{0,x}])

  defp be(_,_,[]), do: :Nil

  defp be(w,k,[{_,:NIL} | z]), do: be(w,k,z)

  # defp be(w,k,[{i,%CAT{left: x, right: y}} | z]), do: be(w,k,([{i,x},{i,y}] ++ z))
  defp be(w,k,[{i,%CAT{left: x, right: y}} | z]), do: be(w,k,[{i,x} | [{i,y} | z]])

  # defp be(w,k,[{i,%NEST{indent: j, doc: x}} | z]), do: be(w,k,([{i+j,x}] ++ z))
  defp be(w,k,[{i,%NEST{indent: j, doc: x}} | z]), do: be(w,k,([{i+j,x} | z]))

  defp be(w,k,[{_,%TEXT{text: s}} | z]), do: %Text{text: s, doc: be(w,(k + (String.length s)),z)}

  defp be(w,_,[{i,:LINE} | z]), do: %Line{indent: i, doc: be(w,i,z)}

  # defp be(w,k,[{i,%UNION{left: x, right: y}} | z]), do: better(w,k,(be(w,k,([{i,x}] ++ z))),(be(w,k,([{i,y}] ++ z))))
  defp be(w,k,[{i,%UNION{left: x, right: y}} | z]), do: better(w,k,(be(w,k,([{i,x} | z]))),(be(w,k,([{i,y} | z]))))

  defp better(w,k,x,y), do: if fits(w-k,x), do: x, else: y

  defp fits(_,:Nil), do: true
  defp fits(w,%Text{text: s, doc: x}), do: fits((w - String.length s),x)
  defp fits(w,%Line{indent: _,doc: _}), do: true
  defp fits(w,_) when w < 0, do: false

  def pretty(w,x) do
    doc = best(w,0,x)
    layout doc
  end

  # Utils

  def bracket(l,x,r), do: group(text(l) <~> nest(2,line() <~> x) <~> line() <~> text(r))

  def cat_space(x,y), do: x <~> text(" ") <~> y
  def cat_line(x,y), do: x <~> line() <~> y
  def cat_best(x,y), do: x <~> (text(" ") <|> line()) <~> y

  def folddoc(f,[]), do: nill()
  def folddoc(f,[x]), do: x
  def folddoc(f,[x | xs]), do: f.(x,folddoc(f,xs))

  def spread(xs), do: folddoc(&cat_space/2,xs)
  def stack(xs), do: folddoc(&cat_line/2,xs)
  def spread_or_stack(xs), do: folddoc(&cat_best/2,xs)


  # -- Tree example

  defmodule Tree do
    defstruct name: "", children: {}
  end

  def showTree(%Tree{name: s, children: ts}), do: text(s) <~> showBracket(ts)

  def showBracket([]), do: nill()
  def showBracket(ts), do: bracket("[",showTrees(ts),"]")

  def showTrees([t | []]), do: showTree t
  def showTrees([t | ts]), do: showTree(t) <~> text(",") <~> line() <~> showTrees(ts)

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
