#### predicates

is_type(x,t::DataType) = typeof(x) == t
is_type(x,t::Union) = typeof(x) == t

is_type_less(x,t::DataType) = typeof(x) <: t
is_type_less{T}(x::T,t::Union) = T <: t

is_SSJSym(s::SSJSym) = true
is_SSJSym(x) = false

is_SJSym(s::SJSym) = true
is_SJSym(x) = false

is_Mxpr{T<:Mxpr}(mx::T) = true
is_Mxpr(x) = false
is_Mxpr{T}(mx::Mxpr{T},s::Symbol) = T == s
is_Mxpr(x,s::Symbol) = false

# Return true if any element at level 1 of mx is an Mxpr with head `head`
function mxpr_head_freeq(mx::Mxpr, head)
    for i in 1:length(mx)
        is_Mxpr(mx[i],head)  && return false
    end
    return true
end

# We may need this at some time
# return true if h occurs anywhere in tree as a head
# Decided not to use this after it was written
# function has_head(mx::Mxpr, h::SJSym)
#     mhead(mx) == h && return true
#     for i in 1:length(mx)
#         has_head(mx[i],h) && return true
#     end
#     return false
# end
# has_head(x,h::SJSym) = false

# isa(x,Number) would work
is_Number{T<:Number}(mx::T) = true
is_Number(x) = false

is_Real{T<:Real}(mx::T) = true
is_Real(x) = false

is_Complex{T<:Real}(x::Complex{T}) = true
is_Complex(x) = false

is_Float{T<:AbstractFloat}(x::T) = true
is_Float(x) = false

is_imaginary_integer{T<:Integer}(z::Complex{T}) = real(z) == 0
is_imaginary_integer(x) = false

atomq(x) = ! isa(x,Mxpr)
# atomq{T<:Mxpr}(x::T) = false
# atomq(x) = true

is_Indeterminate(x::Symbol) = x == Indeterminate
is_Indeterminate(x) = false

is_Infintity(x) = false
is_Infintity(mx::Mxpr{:DirectedInfinity}) = length(mx) > 0 && mx[1] == 1 ? true : false

is_ComplexInfinity(x) = false
is_ComplexInfinity(mx::Mxpr{:DirectedInfinity}) = length(mx) == 0 ? true : false

is_Constant(x::SSJSym) = haskey(x.atrr,:Constant)

function is_Constant(x::Symbol)
    sjsym = getssym(x)
    haskey(sjsym.attr,:Constant)
end
is_Constant(x) = false

is_protected(sj::SJSym) = get(getssym(sj).attr,:Protected,false)

# BlankXXX defined in symataconstants.jl
is_blankxxx{T<:BlankXXX}(mx::T) = true
is_blankxxx{T<:Mxpr}(x::T) = false

####  Symata Predicates

@mkapprule ConstantQ :nargs => 1

do_ConstantQ(mx::Mxpr{:ConstantQ}, s::Symbol) = is_Constant(s)
do_ConstantQ(mx::Mxpr{:ConstantQ}, x) = false

@sjdoc AtomQ "
AtomQ(expr), in principle, returns true if expr has no parts accessible with Part.
However, currently, Julia Arrays can be accessed with Part, and return true under AtomQ.
"

@mkapprule AtomQ  :nargs => 1

@doap AtomQ(x) = atomq(x)

@sjdoc EvenQ "
EvenQ(expr) returns true if expr is an even integer.
"
@sjdoc OddQ "
OddQ(expr) returns true if expr is an odd integer.
"

@sjseealso_group(AtomQ,EvenQ,OddQ)
apprules(mx::Mxpr{:EvenQ}) = is_type_less(mx[1],Integer) && iseven(mx[1])
apprules(mx::Mxpr{:OddQ}) = is_type_less(mx[1],Integer) &&  ! iseven(mx[1])

@sjdoc DirtyQ "
DirtyQ(m) returns true if the timestamp of any symbol that m depends on
is more recent than the timestamp of m. This is for diagnostics.
"
apprules(mx::Mxpr{:DirtyQ}) = checkdirtysyms(mx[1])
do_syms(mx::Mxpr) = mxpr(:List,listsyms(mx)...)
do_syms(s) = mxpr(:List,)

#### NumericQ

@mkapprule NumericQ  :nargs => 1
@sjdoc NumericQ "
NumericQ(expr) returns true if N(expr) would return a number.
"
do_NumericQ(mx::Mxpr{:NumericQ}, x) = is_Numeric(x)

is_Numeric(x) = false
is_Numeric{T<:Number}(x::T) = true
is_Numeric(x::Symbol) = is_Constant(x)
function is_Numeric{T<:Mxpr}(x::T)
    get_attribute(x,:NumericFunction) || return false
    for i in 1:length(x)
        is_Numeric(x[i]) || return false
    end
    return true
end

#### NumberQ

@mkapprule NumberQ :nargs => 1

@sjdoc NumberQ "
NumberQ(x) returns true if x is an explicit number. i.e. it is a subtype of Julia type Number.
"

@doap NumberQ(x) = isa(x,Number)

#### MachineNumberQ

# Should we check for smaller floats ?
@mkapprule MachineNumberQ :nargs => 1
@doap MachineNumberQ(x::Float64) = true
@doap MachineNumberQ(x::Complex{Float64}) = true
@doap MachineNumberQ(x) = false

#### InexactNumberQ

@mkapprule InexactNumberQ :nargs => 1
@doap InexactNumberQ(x::AbstractFloat) = true
@doap InexactNumberQ{T<:AbstractFloat}(x::Complex{T}) = true
@doap InexactNumberQ(x) = false

#### IntegerQ
@mkapprule IntegerQ :nargs => 1
@doap IntegerQ(x) = isa(x,Integer)
# do_IntegerQ{T<:Integer}(mx::Mxpr{:IntegerQ}, x::T) = true
# do_IntegerQ(mx::Mxpr{:IntegerQ}, x) = false

#### ListQ
@mkapprule ListQ :nargs => 1
@doap ListQ(x::Mxpr{:List}) = true
@doap ListQ(x) = false

#### PermuationQ

@mkapprule PermutationQ :nargs => 1

@sjdoc PermutationQ "
PermutationQ(list) returns true if and only if list is a permuation of the integers from 1 through Length(list).
"

function do_PermutationQ(mx::Mxpr{:PermutationQ}, lst::Mxpr{:List})
    args = margs(lst)
    for arg in args
        ! (typeof(arg) <: Union{Integer,AbstractFloat}) && return false
    end
    isperm(args)
end

#### VectorQ

function vectorq(x::Mxpr{:List})
    for i in 1:length(x)
        is_Mxpr(x[i],:List) && return false
    end
    return true
end

function vectorq(x::Mxpr{:List}, test)
    if isa(test,Function)
        for i in 1:length(x)
            (test(x[i]) != true) && return false
        end
    else
        for i in 1:length(x)
            (doeval(mxpr(test, x[i])) != true) && return false
        end
    end
    return true
end

@mkapprule VectorQ :nargs => 1:2

@doap VectorQ(x) = false

@doap VectorQ(x::Mxpr{:List}) = vectorq(x)

@doap VectorQ(x::Mxpr{:List}, test) = vectorq(x,test)


