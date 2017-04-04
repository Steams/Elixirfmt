# Elixirfmt (Work in progress)

Elixir Code formatter with automatic line wrapping based on Phillip Wadler's "A Prettier Printer"


##### Current working Example

```Elixir
    max_width = 40

    str = "def nested(one,two,three,four) do
      sum4 = fn(x,y,z,a) -> x + y + z + a end

      somethingElse = fn(name,surname) -> name ++ surname end
      somethingElse = fn(name,surname) -> name ++ surname end
    end"

    ast = Code.string_to_quoted!(str)

    parsed = parse_ast(ast)

    doc = show_ast(parsed)

    IO.puts("|" <> String.duplicate("-",w-2) <> "|")
    IO.puts(pretty(max_width,doc))

```

Output with max line width 40

```
|--------------------------------------|
def nested( one, two, three, four, ) do 
  sum4 = fn( x, y, z, a, ) -> 
    x + y + z + a
  end
  
  somethingElse = fn(
    name, surname,
  ) ->  name ++ surname end
  
  somethingElse = fn(
    name, surname,
  ) ->  name ++ surname end
  
end
```

with Max line width 80 
```
|------------------------------------------------------------------------------|
def nested( one, two, three, four, ) do 
  sum4 = fn( x, y, z, a, ) ->  x + y + z + a end
  
  somethingElse = fn( name, surname, ) ->  name ++ surname end
  
  somethingElse = fn( name, surname, ) ->  name ++ surname end
  
end
```
