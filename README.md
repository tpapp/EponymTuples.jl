# EponymTuples

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![Build Status](https://travis-ci.org/tpapp/EponymTuples.jl.svg?branch=master)](https://travis-ci.org/tpapp/EponymTuples.jl)
[![Coverage Status](https://coveralls.io/repos/tpapp/EponymTuples.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/EponymTuples.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/EponymTuples.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/EponymTuples.jl?branch=master)

Julia package for deconstructing dispatch on `NamedTuple`s.

Uses the variable names *both* for the `NamedTuple` and deconstruction.

Allows replacing

```julia
f((a, b)::NamedTuple{(:a, :b), <: Tuple{Any, Int}}) = ...

(a = a, b = b, c = 3)
```

with

```julia
f(@eponymargs(a, b::Int)) = ...

@eponymtuple(a, b, c = 3)
```

It is pretty lightweight: `@eponymargs` and `@eponymtuple` are the only symbols exported; and the package has no dependencies.

The package is registered, install with
```julia
pkg> add EponymTuples
```
