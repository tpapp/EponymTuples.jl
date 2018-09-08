module EponymTuples

export @eponymargs, @eponymtuple

var_and_type(ex::Symbol) = ex => Any

function var_and_type(ex::Expr)
    if ex.head == :(::) && (ex.args[1] isa Symbol)
        ex.args[1] => ex.args[2]
    else
        throw(ArgumentError("Can't handle expression $(ex), use a symbol or `symbol::type`."))
    end
end

function check_duplicate_vars(itr)
    seen = Set{Symbol}()
    for symbol in itr
        if symbol ∈ seen
            error(ArgumentError("duplicate variable name $(symbol)"))
        else
            push!(seen, symbol)
        end
    end
    nothing
end

"""
    @eponymargs(a, b::T, ...)

Expands to form like `((a, b)::NamedTuple{(:a, :b), <: Tuple{Any, T}})`, using
the variable names *both* for the `NamedTuple` and deconstruction in the
function arguments.

Valid arguments are variable names, or names followed by a type specifier (when
missing, `Any` is used).

# Example

```jldoctest
julia> using EponymTuples

julia> foo(@eponymargs(a, b)) = a + b
foo (generic function with 1 method)

julia> foo((a = 1, b = 2))
3
```
"""
macro eponymargs(args...)
    vars_and_types = map(var_and_type, args)
    vars = first.(vars_and_types)
    check_duplicate_vars(vars)
    types = map(esc ∘ last, (vars_and_types))
    :(($(map(esc, vars)...),)::$(esc(:NamedTuple)){$(vars),
                                                   <: $(esc(:Tuple)){$(types...)}})
end

var_and_value_form(ex::Symbol) = (e = esc(ex); :($(e) = $(e)))

function var_and_value_form(ex::Expr)
    if ex.head == :(=) && (ex.args[1] isa Symbol)
        :($(esc(ex.args[1])) = $(esc(ex.args[2])))
    else
        throw(ArgumentError("Can't handle expression $(ex), use a symbol or `symbol = value`."))
    end
end

"""
    @eponymtuple(a, b = bval, ...)

Expands to `(a = a, b = bval, ...)`, creating a named tuple.

Each argument is either a symbol, resulting in assigning its own value, or an
assignment, passed as is.

The recommended use is the first one, allowing the creation of named tuples
without repeating the name. Overriding the value is just for convenience, if you
are using it too much you are probably better off with the standard `NamedTuple`
constructor `(a = aval, b = bval, ...)`.
"""
macro eponymtuple(args...)
    forms = map(var_and_value_form, args)
    Expr(:tuple, forms...)
end

end # module
