module EponymTuples

export @eponymtuple

var_and_type(ex::Symbol) = ex => Any

function var_and_type(ex::Expr)
    if ex.head == :(::) && (ex.args[1] isa Symbol)
        ex.args[1] => ex.args[2]
    else
        throw(ArgumentError("Can't handle expression $(ex)."))
    end
end

"""
    @eponymtuple(a, b::T, ...)

Expands to form `((a, b)::NamedTuple{(:a, :b), <: Tuple{Any, T}})`.

Example:

```jldoctest
julia> using EponymTuples

julia> foo(@eponymtuple(a, b)) = a + b
foo (generic function with 1 method)

julia> foo((a = 1, b = 2))
3
```
"""
macro eponymtuple(args...)
    vars_and_types = map(var_and_type, args)
    vars = first.(vars_and_types)
    types = map(esc ∘ last, (vars_and_types))
    :(($(map(esc, vars)...),)::$(esc(:NamedTuple)){$(vars),
                                                   <: $(esc(:Tuple)){$(types...)}})
end

end # module
