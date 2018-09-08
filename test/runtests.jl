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

foo(@eponymargs(a, b)) = (:generic, a, b)
foo(@eponymargs(a::Int, b::Int)) = (:ints, a, b)

struct Bar{T}
    x::T
end

bar(@eponymargs(z::Bar{T})) where {T <: Real} = z.x

pack1(a) = @eponymtuple(a, b = 2)
pack2(a, b) = @eponymtuple(a, b)

end

@testset "dispatch" begin
    TestModule.foo((a = 1, b = 2.0)) ≡ (:generic, 1, 2.0)
    TestModule.foo((a = 1, b = 2)) ≡ (:ints, 1, 2)
    @test_throws MethodError TestModule.foo((1, 2))
    @test_throws MethodError TestModule.foo((a = 1, c = 2))

    @test TestModule.bar((z = TestModule.Bar(2), )) == 2
    @test_throws MethodError TestModule.bar((z = TestModule.Bar("a fish"), ))
end

@testset "eponymtuple expansion" begin
    @test :((a = a, b = b)) == macroexpand(Main, :(@eponymtuple(a, b)))
    @test :((a = a, b = 2)) == macroexpand(Main, :(@eponymtuple(a, b = 2)))
    @test_throws LoadError macroexpand(Main, :(@eponymtuple(a, bogus::T)))
end

@testset "eponymtuple return values" begin
    @test TestModule.pack1(9.0) ≡ (a = 9.0, b = 2)
    @test TestModule.pack2(42, "a fish") ≡ (a = 42, b = "a fish")
end

@testset "non-unique varnames" begin
    # just checking that these are caught by Julia
    @test_throws ErrorException @eval let a=1; @eponymtuple(a, a) end
    @test_throws ErrorException @eval let a=1; @eponymtuple(a, a = 1) end
    # these pass through the language at the moment
    @test_throws LoadError @eval f(@eponymargs(a, a)) = 2*a
end
