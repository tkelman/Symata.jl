
testUserSyms

#### Blanks

# Only Blank is currently useful

T Head(_) == Blank
T Head(__) == BlankSequence
T Head(___) == BlankNullSequence
T _b == Blank(b)
T __b == BlankSequence(b)
T ___b == BlankNullSequence(b)

ClearAll(a,b,c,d,p,f,d)

T ReplaceAll( f([a,b]) + f(c) , f([x_,y_]) => p(x+y)) == f(c) + p(a+b)


T Apply(List,ReplaceAll( f([a,b]) + f(c) , f([x_,y_]) => p(x+y))) == [f(c),p(a + b)]

T ReplaceAll([a/b, 1/b^2, 2/b^2] , b^n_ => d(n)) == [a*d(-1),d(-2),2*d(-2)]

# Pattern names do match consistently
T ReplaceAll( [a,b,[a,b]] , [x_,y_,[x_,y_]] => 1 ) == 1

# Pattern names do not match consistently
T ReplaceAll( [b,a,[a,b]] , [x_,y_,[x_,y_]] => 1 ) == [b,a,[a,b]]

T MatchQ( 1, _Integer) == true
T MatchQ( 1.0, _Integer) == false
T MatchQ( "zebra", _AbstractString) == true
T MatchQ( 1.0, _AbstractString) == false

Clear(a,b,gg,xx)

a = 1

# Patterns match structurally.
T MatchQ( a^2, x_^2) == false
T MatchQ( b^2, x_^2) == true
T MatchQ( b^2, _^2) == true
T MatchQ(f(b^2), f(x_^2)) == true

# Match expression with Head gg
T MatchQ( gg(xx) , _gg)

# Two blanks do not have to match the same expression
T MatchQ( a^b, _^_)

#### Alternatives

T a | b == Alternatives(a,b)
T MatchQ( 1, _Integer | _String)
T MatchQ( "dog", _Integer | _String)
T ReplaceAll( [a, b, c, d, a, b, b, b],  a | b => x) == [x,x,c,d,x,x,x,x]

# An unmatched alternative is replaced by Sequence(). Upon evaluation to fixed point, this
# empty sequence is removed.
f(x_, x_ | y_String) := [x,y]

# y is replaced by Sequence(), which is then removed.
T f(2,2) == [2]

# Here, y matches
T f(2,"cat") == [2,"cat"]

# The entire pattern fails to match
T  Head(f(2,3)) == f

# The alternatives can contain patterns at any depth
g(x_, x_ | h(y_String)) := [x,y]
T g(2,2) == [2]
T Head(g(2,"dog")) == g
T g(2,h("dog")) == [2,"dog"]

ClearAll(h,p,a,bc,d)

# Alternatives can be explicit expressions containing no blanks
h(a | b) := p
T [h(a), h(b), h(c), h(d)] == [p,p,h(c),h(d)]

# Powers match structually, so we include an alternative for a power with exponent one.
T ReplaceAll([1, x, x^2, x^3, y^2] , (x | x^_) => q) == [1,q,q,q,y^2]

# The head can be either a or b and it is bound to f
# FIXME. This is not parsed correctly. We get Span
# (f : (a | b))(x_) => r(f, x)
# FIXME. This is parsed as named pattern, but the rest of the parsing is wrong.
# (f::(a | b))(x_) => r(f, x)

ClearAll(a,b,c,f,g,h,p,x,y)

ClearAll(f,a,x)

# Module has local variables

a = 2
f(x_) := Module([a],(a=1,x+a))
T  f(3) == 4
T a == 2

ClearAll(f,a,b,c,d,p,x,gg,xx,n,y)

# ReplaceAll tries to replace at all levels, beginning with the entire expression.
T ReplaceAll(c, c => y) == y
T ReplaceAll(1, 1 => y) == y

# The Head of an expression is replaced
T ReplaceAll(c(1), c => y) == y(1)

ClearAll(c,y)

# We sometimes write rules in List(), because [x=>y] is parsed by Julia as deprecated Dict construction.
# However, this warning is currently suppresed.
ClearAll(r1,r2,zz,b,c)

# For each part of the expression, each of the listed rules is tried in turn.
zz = 10 * b^2 * (c+d)
T ReplaceAll(zz, List(c => 3,d => 2) ) == 50*b^2

ClearAll(r1,r2,zz,b,c)

ClearAll(pf,x,y,a,b,f)

# A matched expression can be used as a Head
pf(x_,y_) :=  x(y)
T  pf(a,b) == a(b)

ClearAll(pf,x,y,a,b)

# Count the number of occurences of pattern in an expression. Currently matching only at level one.
# The pattern can be an explicit expression.
T Count(Range(10), 2) == 1

# Match only expressions with the given Head
T Count(Range(10), _Integer) == 10

# The name assigned to a match may be different for different elements in the list.
T Count(Range(10), b_Integer) == 10

# No expression matches the given Head
T Count(Range(10), _AbstractString) == 0

# We alias String to AbstractString
T Count(Range(10), _String) == 0

# Mathematica does not consider an integer to be 'Real'. We follow this practice here.
T Count([1,2,3.0] , _Real) == 1
T Count([1,2,3.0] , _Float) == 1

ClearAll(b)

# Matching literal expressions and various patterns.
T ReplaceAll( [x,x^2,a,b],  x => 3 ) == [3,9,a,b]
T ReplaceAll( [x,x^2,x^3,a,b],  x^2  => y) == [x,y,x^3,a,b]
T ReplaceAll( [x,x^2,x^3,a,b],  x^n_  => f(n) ) == [x,f(2),f(3),a,b]

ClearAll(a,b,x,y,z)

# Because we evaluate to a fixed point, the power is distributed across the List.
T ReplaceAll( [x,x^2,y,z], x => [a,b]) == [[a,b],[a ^ 2,b ^ 2],y,z]

# Replace the Head of a builtin (protected) symbol
T ReplaceAll(Sin(x), Sin => Cos) == Cos(x)

T ReplaceAll( 1 + x^2 + x^4 , x^p_ => f(p)) == 1 + f(2) + f(4)

# This :> is  RuleDelayed, but it makes no difference in this context.
# The first rule is applied first.
T ReplaceAll(x , [x :> 1, x :> 3, x :> 7]) ==  1

# FIXME Looks like Mma does threading over the lists of rules in this case. Not documented ?
# It is documented, but not on the /. page. Just the example is shown
# x /. {{x -> 1}, {x -> 3}, {x -> 7}}

# FIXME ReplaceAll should do currying with the rules, not the expression.
# ReplaceAll(x => a)([x, x^2, y, z])

T ReplaceAll( [a,b,c] , List :> f)  == f(a,b,c)

# Hold prevents evaluation of the inner expressions. But, Hold does not prevent pattern
# matching.

T ReplaceAll( Hold(x + x) , x => 7) == Hold(7 + 7)

# The RHS of the Rule x => 2^2 is evaluated before being applied
T ReplaceAll( Hold(x + x) , x => 2^2 ) == Hold(4 + 4)

# The RHS of the RuleDelayed is not evaluated
T ReplaceAll( Hold(x + x) , (x :> 2^2) ) == Hold(2 ^ 2 + 2 ^ 2)

# These are the same above, but we use the FullForm for Rule and RuleDelayed
T ReplaceAll( Hold(x + x) , Rule(x, 2^2) ) == Hold(4 + 4)
T ReplaceAll( Hold(x + x) , RuleDelayed(x , 2^2) ) == Hold(2 ^ 2 + 2 ^ 2)

T Replace(x^2, x^2 => a + b) == a + b
T Replace(1 + x^2, x^2 => a + b)  == 1 + x ^ 2

# Level specification

# Apply the rule only at level 1
T Replace(1 + x^2, x^2 => a + b, [1]) == 1 + a + b

# Apply only at level 0, i.e. the whole expression
T Replace(1 + a + f(a) + g(f(a)), a => b, 0) == 1 + a + f(a) + g(f(a))

# Apply at levels one and greater
T Replace(1 + a + f(a) + g(f(a)), a => b, 1) == 1 + b + f(a) + g(f(a))

# At levels 2 and greater
T Replace(1 + a + f(a) + g(f(a)), a => b, 2) == 1 + b + f(b) + g(f(a))

# At levels 3 and greater
T Replace(1 + a + f(a) + g(f(a)), a => b, 3) == 1 + b + f(b) + g(f(b))

# Only at level 1, 2, or 3.
T Replace(1 + a + f(a) + g(f(a)), a => b, [1]) == 1 + b + f(a) + g(f(a))
T Replace(1 + a + f(a) + g(f(a)), a => b, [2]) == 1 + a + f(b) + g(f(a))
T Replace(1 + a + f(a) + g(f(a)), a => b, [3]) == 1 + a + f(a) + g(f(b))

ClearAll(a,b,f,)

# Try replacement at each level. Once, we descend to a level, replacement is attempted on all elements at
# that level.
T ReplaceAll( x + y , List(x => a, y => b)) == a + b

# Rule evaluates the RHS when it is created.
result = ReplaceAll( [x,x,x,x,x],  x  => RandomReal() )
T result[1] == result[2] == result[3]

# RuleDelayed does not evaluate the RHS before the rule is applied. So,
# all elements are replaced with RandomReal(). After evaluation to a fixed
# point, each element is a different number
result = ReplaceAll( [x,x,x,x,x],  x  :> RandomReal() )
T result[1] != result[2] != result[3]

b = 1
# All elements are replaced with Increment(b). In the next evaluation cycle, each is evaluated once.
T ReplaceAll( [x,x,x,x,x],  x :> Increment(b)) == [1,2,3,4,5]

b = 1
# Increment(b) is evaluated once before matching, returning 1. 1 then evaluates to itself
T ReplaceAll( [x,x,x,x,x],  x => Increment(b)) == [1,1,1,1,1]

# The first matching rule is is used.
T ReplaceAll([x^2, x^3, x^4] , List(x^3 => u, x^n_ => p(n))) == [p(2),u,p(4)]

# Match at the highest level first. If a match is found at one level, matching subexpressions
# is not attempted.
# fixed bug. we were matching sublevels before current level.
T ReplaceAll(h(x + h(y)) , h(u_) => u^2)  == (x + h(y))^2

# Matching is only attempted once for each element. So this swaps x and y.
T ReplaceAll([x^2, y^3]  , [x => y, y => x])  == [y ^ 2,x ^ 3]

# This works. But, we have to use parens. Not satisfactory
# We should not write many tests with infix symbols, etc. Because the choices change.
T x^2 ./ (x => (1+y)) ./ (y => b)  == (1 + b) ^ 2

# This shows the difference between Rule and RuleDelayed.

b = 3
r1 = a => b
r2 = a :> b
Clear(b)

T Replace( a, r1) == 3
T Replace( a, r2) == b
 b = 4
T Replace( a, r1) == 3
T Replace( a, r2) == 4
ClearAll(a,b)

# Match anything except expressions that match the argument to Except().
Replace([1, 7, "Hi", 3, Indeterminate], Except(_:?(NumericQ)) :> 0, 1)

# Stop trying rules on an expression after the first succesful match.
T ReplaceAll(x^2 + y^6 , List(x => 2 + a, a => 3))  == (2 + a) ^ 2 + y ^ 6

# ReplaceRepeated effectively repeats ReplaceAll till the expression stops changing.
# So, different rules may be applied to the same expression or subexpression.
T ReplaceRepeated(x^2 + y^6 , List(x => 2 + a, a => 3)) == 25 + y ^ 6

# ReplaceRepeated replaces until no rule matches.
T ReplaceAll( Expand( (a+b)^3 ) , x_Integer => 1) == a + 2a*b + b
T ReplaceRepeated( Expand( (a+b)^3 ) , x_Integer => 1)  == a +  a * b + b

# This applies two rules for Log repeatedly to an expression.
rules = [Log(x_ * y_) => Log(x) + Log(y), Log(x_^k_) => k * Log(x)]
T  ReplaceRepeated(Log(Sqrt(a*(b*c^d)^e)), rules) == 1/2 * (Log(a) + e * (Log(b) + d * Log(c)))
T  ReplaceAll(Log(Sqrt(a*(b*c^d)^e)), rules) == 1/2 * Log(a * ((b * (c ^ d)) ^ e))

# We usually use named patterns only with a single blank, e.g. b_. But, we may associate a
# name with any pattern expression.
# Pattern name for complex (compound) pattern
T ReplaceAll( b^b, a::(_^_) => g(a)) == g(b^b)

# Why do we get this ? Looks like we perform the currying immediately. Mma defers evaluation.
# sjulia > f(a)(b)(c)(d)
# f(a,b,c,d)

# tests a fix for bug that caused julia-level error in the following line
ex = Hold(f(a)(b)(c)(d))
T ReplaceAll(Hold(f(a)(b)), f(x_) => g) == Hold(g(b))

# ReplaceAll descends into subexpressions until it finds a match.
T ReplaceAll( [[[x]]], x => 3) == [[[3]]]

ClearAll(x,ex)

# Currying with Count

countprimes = Count(_:?(PrimeQ))
T  countprimes(Range(100)) == 25
ClearAll(countprimes)


#### Cases

# Use a Julia function to list the perfect squares less than 100.
T  Cases(Range(100), _:?(:( (x) -> typeof(mpow(x,1//2)) <: Integer )) ) == [1,4,9,16,25,36,49,64,81,100]

T Cases([1,2.0,3,"dog"], _String) == ["dog"]
T DeleteCases([1,2.0,3,"dog"], _String) == [1,2.0,3]

# Currying, or operator form.
dstring = DeleteCases(_String)
T dstring([1,2.0,3,"dog"]) == [1,2.0,3]

T Cases([f(1),2.0,3,f("dog")], f(x_)) == [f(1),f("dog")]
T Cases([f(1),2.0,3,f("dog")], f(x_String)) == [f("dog")]

T Cases([1, 1, f(a), 2, 3, y, f(8), 9, f(10)], _Integer) == [1,1,2,3,9]
T Cases([1, 1, f(a), 2, 3, y, f(8), 9, f(10)], Except(_Integer)) == [f(a),y,f(8),f(10)]

# Cases with replacement rule
T Cases([1, 1, f(a), 2, 3, y, f(8), 9, f(10)], f(x_) => x) == [a,8,10]

# Cases and currying
T Cases(_Integer)([1, 1, f(a), 2, 3, y, f(8), 9, f(10)]) == [1,1,2,3,9]

# Two unnamed blanks can match different expressions
T Cases([[1, 2], [2], [3, 4, 1], [5, 4], [3, 3], [a,a]], [_, _]) == [[1,2],[5,4],[3,3],[a,a]] 

# Cases returns expression with head List, not the head of input expression.
T Cases(f(1,2,3,a), _Symbol) == [a]

# Level specifications
expr = f(1,2,3,a,[b],d,[g,f, h(a, h(b)) , h(h(c))] )
T Cases(expr , _Symbol) == [a,d]
T Cases(expr , _Symbol, 1) == [a,d]
T Cases(expr , _Symbol, [1]) == [a,d]
T Cases(expr , _Symbol, 2) == [a,b,d,g,f]
T Cases(expr , _Symbol, 3) == [a,b,d,g,f,a]
T Cases(expr , _Symbol, 4) == [a,b,d,g,f,a,b,c]
T Cases(expr , _Symbol, 5) == [a,b,d,g,f,a,b,c]
T Cases(expr , _Symbol, Infinity) == [a,b,d,g,f,a,b,c]
T Cases(expr , _Symbol, [2]) == [b,g,f]
T Cases(expr , _Symbol, [3]) == [a]
T Cases(expr , _Symbol, [4]) == [b,c]
T Cases(expr , _Symbol, [5]) == []
T Cases(expr , _Symbol, [2,3]) == [b,g,f,a]
T Cases(expr , _Symbol, [2,4]) == [b,g,f,a,b,c]
T Cases(expr , _Symbol, -1) ==  Cases(expr , _Symbol, Depth(expr) - 1) ==  Cases(expr , _Symbol, 4)
T Cases(expr , _Symbol, -2) ==  Cases(expr , _Symbol, Depth(expr) - 2) ==  Cases(expr , _Symbol, 3)
T Cases(expr , _Symbol, -3) ==  Cases(expr , _Symbol, Depth(expr) - 3)

T Cases(expr , _Symbol, [-1]) ==  Cases(expr , _Symbol, [Depth(expr) - 1])
T Cases(expr , _Symbol, [-2]) ==  Cases(expr , _Symbol, [Depth(expr) - 2]) ==  Cases(expr , _Symbol, [3])
T Cases(expr , _Symbol, [-3]) ==  Cases(expr , _Symbol, [Depth(expr) - 3]) ==  Cases(expr , _Symbol, [2])

# Cases with replacement rule
T Cases([a,b,c,c], k::(Except(c)) => k^2) == [a^2,b^2]
# Cases with replacement rule at level 2 only
T Cases([a,b,c,c,[z]], k::(Except(c)) => k^2, [2]) == [z^2]

# Match a Rule
T Cases([a => b, c => d], HoldPattern(a => _)) == [a => b]

ClearAll(a,b,c,d,g,f,h,y,z,expr)

#### Except

T MatchQ( "cat",  Except("dog"))
T MatchQ( "cat",  Except("cat")) == False
T MatchQ( "cat",  Except(3,"cat"))
T MatchQ( "cat",  Except(3,"dog")) == False
T MatchQ( "cat",  Except("cat","dog")) == False

T Cases([a, b, 0, 1, 2, x, y], Except(_Integer)) == [a,b,x,y]
T Cases([1, 0, 2, 0, 3], Except(0)) == [1,2,3]
T Cases([a, b, 0, 1, 2, x, y], Except(0,_Integer)) == [1,2]

# This works, but only with parens around IntegerQ, otherwise it is interpreted as
# Optional. Syntax needs work.
T MatchQ(1, Except(_:?(IntegerQ))) == False
T MatchQ(a, Except(_:?(IntegerQ)))

ClearAll(dstring,result,r1,r2, a, b, d, c, e, f, m, n, p, x, y, z, rules, k, u, ex, g, h)

T p_ == Pattern(p,Blank())
T p_q  == Pattern(p,Blank(q))
T p_Integer:?(PrimeQ) == PatternTest(Pattern(p,Blank(Integer)),PrimeQ)
T p_:?(PrimeQ) == PatternTest(Pattern(p,Blank()),PrimeQ)
T _^_ == Power(Blank(),Blank())

# This should evaluate to True, but does not.
# Mma has PatternTest evaluation parts of held expressions. So 2 + 3 should be evaluated,
# at least to match their behavior. No explanation is given for why this is so.
#T MatchQ(Hold(2 + 3), Hold(_:?(IntegerQ)))

# Try using :: for Pattern
# NB We use both :: and :, while Mma uses : in all instances below.
# It would be nice if we could use one symbol
# We use : for Span, as well. Mma uses :: for Message and ;; for Span.
T a::b == Pattern(a,b)
T a::(b_^c_) == Pattern(a,Power(Pattern(b,Blank()),Pattern(c,Blank())))

ClearAll(p,q,a,b,c,g,f,x,y)

#### Optional

T _:0 == Optional(Blank(),0)
T x_y:0 == Optional(Pattern(x,Blank(y)),0)
T x_y:(a*b) == Optional(Pattern(x,Blank(y)),Times(a,b))

f(x_, y_:3) := x + y

T f(1,5) == 6
T f(1) == 4
T f(a+b) == 3 + a + b
T f(a+b,z) == a + b + z

ClearAll(a,b,z,f,x,y)

f(x_, y_Integer:3) := x + y

T f(1) == 4
T f(1,5) == 6
T Head(f(1,4.0)) == f
T Args(f(1,4.0)) == [1,4.0]

ClearAll(a,b,z,f,x,y)

g(x_:"cat") := x

T g(1) == 1
T g() == "cat"

ClearAll(g,x)

f(x_, y_:a, z_:b) := [x,y,z]

T f(1) == [1,a,b]
T f(1,2) == [1,2,b]
T f(1,2,3) == [1,2,3]

ClearAll(x,y,a,b,g,f)

#### Condition

T  MatchQ( -2 , Condition( x_ , x < 0))
T  MatchQ( 1 , Condition( x_ , x < 0)) == False
T  ReplaceAll([6, -7, 3, 2,-1,-2], Condition( x_ , x < 0) => w ) == [6,w,3,2,w,w]

# Note this condition is on the RHS.
T  ReplaceAll([1,2,3, "cat"], x_Integer => Condition( y, x > 2)) == [1,2,y,"cat"]

T  Cases( [[a, b], [1, 2, 3], [[d, 6], [d, 10]]], Condition([x_, y_], ! ListQ(x) && ! ListQ(y))) == [[a,b]]

# Condition on definition
f(x_) :=  Condition(x^2, x > 3)
T f(4) == 16
T Head(f(2)) == f

ClearAll(x,y,a,b,d,f)

#### Repeated RepeatedNull

T MatchQ([a,a,a], [Repeated(a)])
T MatchQ([a], [Repeated(a)])
T ! MatchQ([], [Repeated(a)])
T ! MatchQ([a,a,b], [Repeated(a)])
T ! MatchQ([a,b,a], [Repeated(a)])
T MatchQ([a,a,b], [Repeated(a),b])
T MatchQ([a,a,b,c,c,c], [Repeated(a),b, Repeated(c)])

T ReplaceAll([ [], [f(a),f(b)], [f(a),f(a,b)], [f(a),f(c+d) ]] , [ Repeated(f(_)) ] => x ) == [[],x,[f(a),f(a,b)],x]
T ReplaceAll([f(a, a), f(a, b), f(a, a, a)], f(Repeated(a)) => x ) == [x,f(a,b),x]
T Cases([f(a), f(a, b, a), f(a, a, a)], f(Repeated(a))) == [f(a),f(a,a,a)]
T Cases([f(a), f(a, a, b), f(a, b, a), f(a, b, b)], f(Repeated(a), Repeated(b))) == [f(a,a,b),f(a,b,b)]
T Cases([f(a), f(a, b, a), f(a, c, a)], f(Repeated(a | b))) == [f(a),f(a,b,a)]

# Need to implement Transpose to test this
# v(x::[Repeated([_, _])] := Transpose(x)

# This too
# v(x::[Repeated([_,n_])] := Transpose(x)

# We do not have enough of Norm implemented. But the pattern does work.
# T  f(x::[Repeated([_, _])]) := Norm(N(x))

T MatchQ([a,a,b], [Repeated(_Symbol)])
T ! MatchQ([a,a,b,3], [Repeated(_Symbol)])
T MatchQ([a,a,b,3], [Repeated(_Symbol),_ ])

T ! MatchQ([1,2,3], [Repeated(_Integer,1)])
T ! MatchQ([1,2,3], [Repeated(_Integer,2)])
T MatchQ([1,2,3], [Repeated(_Integer,3)])
T MatchQ([1,2,3], [Repeated(_Integer,4)])
T ! MatchQ([1,2,3], [Repeated(_Integer,[2])])
T ! MatchQ([1,2,3], [Repeated(_Integer,[4])])
T MatchQ([1,2,3], [Repeated(_Integer,[3])])
T MatchQ([1,2,3], [Repeated(_Integer,[1,4])])
T MatchQ([1,2,3], [Repeated(_Integer,[1,3])])
T ! MatchQ([1,2,3], [Repeated(_Integer,[4,10])])
T ! MatchQ([1,2,3], [Repeated(_Integer,[1,2])])
T MatchQ([1,2,3], [Repeated(_Integer,[0,4])])
T MatchQ([], [Repeated(_Integer,[0,4])])
T MatchQ([a,b,c,3], [Repeated(Except(_Integer)), _Integer] )

# Between 1 and 0, so this fails
T ! MatchQ([], [Repeated(_Integer,0)])

T MatchQ([], [RepeatedNull(_Integer)])
T MatchQ([1,2], [RepeatedNull(_Integer)])
T ! MatchQ([1,2], [RepeatedNull(_Integer,0)])
T MatchQ([], [RepeatedNull(_Integer,0)])
T MatchQ([], [RepeatedNull(_Integer, [0,4])])
T ! MatchQ([], [RepeatedNull(_Integer, [1,4])])

# FIXME.
# f(x_Integer, y::Repeated(_Symbol)) := [x,y]
# f(3,a,b) --> [3,a,b], i.e. y should be spliced in.
# We get no match
# Following does work
g(x_Integer, y::[7,Repeated(_Symbol)]) := [x,y]
T g(1,[7,a,b]) == [1,[7,a,b]]
T Head(g(1,[6,a,b])) == g

ClearAll(f,g,a,b,c,d,x,y)

#### FreeQ

T ! FreeQ(a,a)
T FreeQ(a,b)
T ! FreeQ([a],a)
T FreeQ([a],a, [0])
T ! FreeQ([[f(a)],b,c], a)
T FreeQ([[f(a)],b,c], a, 1)
T FreeQ([[f(a)],b,c], a, 2)
T ! FreeQ([[f(a)],b,c], a, 3)
T FreeQ([[f(a)],b,c], a, [4])
T ! FreeQ([[f(a)],b,c], a, 4)
T ! FreeQ(1, _Integer)
T FreeQ(a, _Integer)
T ! FreeQ([a,f(f(f(3)))], _Integer)
T FreeQ([a,f(f(f(3)))], _Integer, 3)
T ! FreeQ([a,f(f(f(3)))], _Integer, 4)

# Factor out constant
# No AC matching, although this will work in a few simple cases.
# f(c_ * x_, x_) := Condition( c * f(x, x) , FreeQ(c, x))

# Fails. we are not matching heads.
# Table(FreeQ(Integrate(x^n, x), Log), [n, -5, 5])

ClearAll(f,a,b,c)

 testUserSyms
