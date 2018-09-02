using EponymTuples
using EponymTuples: var_and_type # also test internals
using Test

@testset "internals" begin
    @test var_and_type(:Foo) == (:Foo => Any)
    @test var_and_type(:(bar::Int)) == (:bar => :Int)
    @test_throws ArgumentError var_and_type(:(1+1))
end

module TestModule               # wrap in a module to check escaping

using EponymTuples

foo(@eponymtuple(a, b)) = (:generic, a, b)
foo(@eponymtuple(a::Int, b::Int)) = (:ints, a, b)

struct Bar{T}
    x::T
end

bar(@eponymtuple(z::Bar{T})) where {T <: Real} = z.x

end

@testset "dispatch" begin
    TestModule.foo((a = 1, b = 2.0)) ≡ (:generic, 1, 2.0)
    TestModule.foo((a = 1, b = 2)) ≡ (:ints, 1, 2)
    @test_throws MethodError TestModule.foo((1, 2))
    @test_throws MethodError TestModule.foo((a = 1, c = 2))

    @test TestModule.bar((z = TestModule.Bar(2), )) == 2
    @test_throws MethodError TestModule.bar((z = TestModule.Bar("a fish"), ))
end
