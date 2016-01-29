% Computational Economics: Computer Basics
% Florian Oswald
% Sciences Po, 2016



# Introduction

* This lecture has two parts:

1. An introduction to some computing basics.
2. Numerical approximation of Integrals and Derivatives.

------------------------

# This set of slides

* These slides are visible as long as you are online. It's a website ;-) 
* You can hit `c` on your keyboard to see a table of contents. clickable.
* There will be working code on those slides. I invite you to copy and paste this into a julia session and try it out.

---------------

# Computing Basics

* It is important that we understand some basics about computers.
* Even though software (and computers) always get more and more sophisticated, there is still a considerable margin for "human error". This doesn't mean necessarily that there is something wrong, but certain ways of doing things may have severe performance implications.
* Whatever else happens, *you* write the code, and one way of writing code is different from another.

. . .


<div class="center" style="width: auto; margin-left: auto; margin-right: auto;"> ![](figs/picnic.jpeg) </div>

* In this session, we will look at some very basic computer structure, and see some common pitfalls in numerical analysis. 
* We will take advantage to introduce the julia computing language.
	1. Step Number 1: [install julia](http://julialang.org/downloads/)!
	1. Step Number 2: Why Julia?

# Julia? Why Julia?

>* The *best* software doesn't exist. All of the following statements depend on:
	1. The problem at hand. 
		* You are fine with Stata if you need to run a probit.
		* Languages have different comparative advantages with regards to different tasks.
	1. Preferences of the analyst. Some people just *love* their software.
* That said, there are some general themes we should keep in mind when choosing a software.
>* [Stephen Johnson at MIT has a good pitch.](https://github.com/stevengj/julia-mit)
>* High-level languages for technical computing: Matlab, Python, R, ...
	* you get going immediately
	* very important for exploratory coding or data analysis
	* You don't want to worry about type declarations and compilers at the exploratory stage
>* High-level languages are slow.
	* Traditional Solutions to this: Passing the high-speed threshold.
	* Using `Rcpp` or `Cython` etc is a bit like [Stargate](https://en.wikipedia.org/wiki/Stargate_SG-1). You loose control the moment you pass the barrier to `C++` for a little bit. (Even though those are great solutions.) If the `C++` part of your code becomes large, testing this code becomes increasingly difficult.
	* You end up spending your time coding `C++`. But that has it's own drawbacks.
>* Julia is [fast](http://julialang.org/benchmarks/).
	* But julia is also a high-level dynamic language. How come? 
	* The JIT compiler.
	* The [LLVM project](https://en.wikipedia.org/wiki/LLVM).
* Julia is open source (and it's for free)
	* It's for free. Did I say that it's for free?
	* You will never again worry about licenses. Want to run 1000 instances of julia? Do it.
	* The entire standard library of julia is written in julia (and not in `C`, e.g., as is the case in R, matlab or python). It's easy to look and understand at how things work.
>* Julia is a very modern language, combining the best features of many other languages.

. . .

## Why not julia?

* Julia is still in version `0.4.0`. There may be language changes in future releases.
* There are way fewer packages for certain tasks than for, say, R.
* Relatively few people know it. Your supervisor almost surely doesn't know it.

---------------

# Economists and Their Software

* [@jesus-computing], in [*A Comparison of Programming Languages in Economics*](http://economics.sas.upenn.edu/~jesusfv/comparison_languages.pdf), compare some widely used languages on a close to [identical piece of code](https://github.com/jesusfv/Comparison-Programming-Languages-Economics).
* It can be quite contentious to talk about Software to Economists.
	* Religious War. 
	* Look at the [comments on this blog post regarding the paper](http://marginalrevolution.com/marginalrevolution/2014/07/a-comparison-of-programming-languages-in-economics.html).
	* There *are* switching costs from one language to another.
	* Network effects (Seniors handing down their software to juniors etc)
* Takeaway from that paper: 
	* There are some very good alternatives to `fortran`
	* `fortran` is **not** faster than `C++`
	* It seems pointless to invest either money or time in `matlab`, given the many good options that are available for free.
* Let's briefly look at the timings table.
* However you feel about the question of software choice, given your particular situation, there is one **fundamental** thing you should always keep in mind:


-------------------

# The Fundamental Tradeoff

## Developer Time (Your Time) is Much More Expensive than Computing Time

* It may well be that the runtime of a fortran program is one third of the time it takes to run the program in julia, or anything else for that matter.
* However, the time it takes to **develop** that program is very likely to be (much) longer in fortran. 
* Particularly if you want to hold your program to the same quality standards.

## Takeaway

* Given my personal experience with many of the above languagues, I think `julia` is a very good tool for economists with non-trivial computational tasks.
* This is why I am using it for demonstrations in this course.

---------------

# A Second Fundamental Tradeoff

* Regardless of the software you use, there is one main problem with computation.
* It concerns **speed vs accuracy**.
* You may be able to do something very fast, but at very small accuracy (i.e. with a high numerical margin of error)
* On the other hand, you may be able to get a very accurate solution, but it may take you an irrealistic amount of time to get there.
* You have to face that tradeoff and decide for yourself what's best.

## A Warning

> In Donald Knuth's paper "Structured Programming With GoTo Statements", he wrote: "Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say about 97% of the time: **premature optimization is the root of all evil**. Yet we should not pass up our opportunities in that critical 3%."


---------------

# Computers

* At a high level, computers execute instructions.
* Most of the actual *computation* is performed on the Central Processing Unit (CPU). The CPU does 
	* Addition
	* substraction
	* multiplication
	* division
	* maybe also (depends on Chipset)
		* exponentiation
		* logarithm
		* trogonometric operations
	* Everything else is a combination of those.
	* The speed of those operations varies a lot. Exponentiation is about 10 times slower than multiplication.


---------------

# Motivational Example

* Suppose we want to compute
	$$ u(c,l) = \frac{\left(c^\alpha l^{1-\alpha} \right)^{1-\gamma}}{1-\gamma} $$
* Let's take $c=1.1,l=0.8$ and compute this.

~~~~~~~~~~~ {.julia}
alpha = 0.7
gamma = 2.1
# naive approach
u(c,l) = ((c^alpha * l^(1-alpha))^(1-gamma)) / (1-gamma)
~~~~~~~~~~~

. . .

## more sophisticated approach

* Note that $x^\alpha = \exp(\alpha \log(x))$.
* (particularly non-integer) exponentiation is expensive. let's see if we can do better: 

~~~~~~~~~~~ {.julia}
u2(c,l)      = exp( alpha*(1-gamma) * log(c) + (1-alpha)*(1-gamma) * log(l) )/(1-gamma)
# benchmark
# 1) same result?
using Base.Test
@test_approx_eq u(1.1,0.8) u2(1.1,0.8)
# 2) timing?
n = 1e7 	# get a reasonable sample size
t1 = @elapsed for i in 1:n u(1.1,0.8) end
t2 = @elapsed for i in 1:n u2(1.1,0.8) end
println("u1 takes $(round(t1/t2,2)) times longer than u2")
~~~~~~~~~~~

## even more sophisticated approach

* Now realise that there is a lot of precomputation that could be done.

~~~~~~~~~~~ {.julia}
mgamma        = (1-gamma)
alpha_mgamma  = alpha*mgamma
malpha_mgamma = (1-alpha)*mgamma
u3(c,l)       = exp( alpha_mgamma * log(c) + malpha_mgamma * log(l) ) / mgamma
@test_approx_eq u(1.1,0.8) u3(1.1,0.8)
t3 = @elapsed for i in 1:n u3(1.1,0.8) end
println("u1 takes $(round(t1/t3,2)) times longer than u3")
~~~~~~~~~~~

----------------

# Some Numerical Concepts and `Julia`

* Machine epsilon: The smallest number that your computer can represent, type `eps()`.
* Infinity: A number greater than all representable numbers on your computer. [Obeys some arithmethmic rules](http://docs.julialang.org/en/release-0.4/manual/integers-and-floating-point-numbers/?highlight=infinity#special-floating-point-values)
	* Overflow: If you perform an operation where the result is greater than the largest representable number.
	* Underflow: You take two (very small) representable numbers, but the result is smaller than `eps()`. 
	* In Julia, you are wrapped around the end of your representable space:
	```julia
	x = typemax(Int64)
	x + 1
	```
* Integers and Floating Point Numbers.
* Single and Double Precision.
* In Julia, all of these are different [*numeric primitive types (head over to julia manual for a second)*](http://docs.julialang.org/en/release-0.4/manual/integers-and-floating-point-numbers/).
* Julia also supports *Arbitrary Precision Arithmetic*. Thus, overflow shouldn't become an issue anymore.
* See min and max for different types:

~~~~~~~~~~~ .{julia}
for T in [Int8,Int16,Int32,Int64,Int128,UInt8,UInt16,UInt32,
		  UInt64,UInt128,Float32,Float64]
         println("$(lpad(T,7)): [$(typemin(T)),$(typemax(T))]")
end
~~~~~~~~~~~

----------------

# Interacting with the `Julia REPL`

* REPL?
* different modes.
* incremental search with `CTRL r`
* documented in the [manual](http://docs.julialang.org/en/release-0.4/manual/interacting-with-julia)



----------------

# `Julia` Primer: What is a `module`?

* A separate `namespace`: variable names inside a module are not visible from outside, unless exported.
* If you use somebody else's code that contains the object `model`, and you have code that also defines `model`, you have a name conflict.
* Using modules avoids this conflict.
* Julia packages are provided as `module`s. 
* You should adapt `module`s as the best workflow practice with julia.
* Let's try this out.
	1. Create a folder somewhere called `modTest`
	1. inside that folder create another folder called `src`. this will contain our `source code`.
	1. inside `src`, create a file called `tmodule.jl` as in *test module*.
	1. In your terminal you would do
		```bash
		cd   # go home
		mkdir modTest
		cd modTest
		mkdir src
		cd src
		touch tmodule.jl
		```
* Open that file in your text editor. I recommend [http://www.sublimetext.com](http://www.sublimetext.com)

----------------

# `Julia` Primer: Working with modules

* We will create a module called *Example*.
* Into your file write and save

```julia
module Example

	hello(who::AbstractString) = "Hello, $who"
	domath(x::Number) = (x + 5)

end
```

* open julia, and go to folder `modTest` with `cd("path/to/modTest")`.
* we need to `include` the code of the package/module with `include("src/tmodule.jl")`.
* type `hello("Bond. James Bond.")`

> * you get an error.
> * function `hello` is unknown.
> * We need to either `export` it from the module, or tell the REPL that it's in module `Example`. Type `Example.hello("Bond. James Bond.")`

> * Alternatively go back to your editor and change the module to:

~~~~~~~~~~~~~ {.julia}
module Example
	export hello, domath

	hello(who::AbstractString) = "Hello, $who"
	domath(x::Number) = (x + 5)

end
~~~~~~~~~~~~~   

> * After that we can do

~~~~~~~~~~~~~ {.julia}
using Example
hello("Bond. James Bond.")
domath(pi)
~~~~~~~~~~~~~

----------------

# `Julia` Primer: Types

* Types are at the core of what makes julia a great language. 
* *Everything* in julia is represented as a datatype. 
* Remember the different numeric *types* from before? Those are types.
* The [manual](http://docs.julialang.org/en/release-0.4/manual/types/), as usual, is very informative on this.
* From the [wikibook on julia](https://en.wikibooks.org/wiki/Introducing_Julia/Types), here is a representation of the numeric type graph:

![](https://upload.wikimedia.org/wikipedia/commons/4/40/Type-hierarchy-for-julia-numbers.png)

----------------

# `Julia` Primer: Custom Types

* The great thing is that you can create you own types. 
* Going with the example from the wikibook, we could have types `Jaguar` and `Pussycat` as being subtypes of `feline`:

~~~~~~~~~~~~~ {.julia}
abstract Feline
type Jaguar <: Feline
	weight::Float64
	sound::AbstractString
end
type Pussycat <: Feline
	weight::Float64
	sound::AbstractString
end
~~~~~~~~~~~~~~~

* This means both jaguar and pusscat are subtypes of `Feline`, 
* They have common fields `weight` and `sound`.
* but there could be different functions. We call function specific to a type 'methods'

```julia
function do_your_thing(j::Jaguar)
	println(j.sound)
	println("I am going to throw my entire $(j.weight) kg at you, I'll catch, kill and eat you!")
	println("I am a $(typeof(j))!!!!")
end
function do_your_thing(c::Pussycat)
	println(c.sound)
	println("I should watch my line, $(c.weight) is enough for a $(typeof(c))")
	println(c.sound)
end
```

-----------------

# Julia Primer: Multiple Dispatch

* You have just learned `multiple dispatch`. The same function name dispatches to different functions, depending on the input argument type.
* Add all of the above code into the module `Example`
* Add Jaguar, Pussycat, and `do_your_thing` to `export` and save the file.

. . .

~~~~~~~~~~~~~ {.julia}
module Example
	# exports
	export hello, domath, Jaguar, Pussycat, do_your_thing

	# types
	abstract Feline
	type Jaguar <: Feline
		weight::Float64
		sound::AbstractString
	end
	type Pussycat <: Feline
		weight::Float64
		sound::AbstractString
	end

	# methods
	hello(who::AbstractString) = "Hello, $who"
	domath(x::Number) = (x + 5)
	
	"""
	makes a jaguar do their thing. 
	"""
	function do_your_thing(j::Jaguar)
		println(j.sound)
		println("I am going to throw my entire $(j.weight) kg at you, I'll catch, kill and eat you!")
		println("I am a $(typeof(j))!!!!")
	end

	"""
	makes a pussycat do their thing. 
	"""
	function do_your_thing(c::Pussycat)
		println(c.sound)
		println("I should watch my weight, $(c.weight) is enough for a $(typeof(c))")
		println(c.sound)
	end
end
~~~~~~~~~~~~~   
* reload the module: `include("src/tmodule.jl")`
* Let's create a cat or a panther via

```julia
using Example
j = Jaguar(130.1,"roaaarrrrrrr")
c = Pussycat(9.8,"miauuu")
```

* and make them `do_their_thing`:

```julia
do_your_thing(j)
do_your_thing(c)
```

* of course we can also use the other functions in `Example`:

```julia
Example.hello(string(typeof(j)))
```

------------------

# Julia Primer: Important performance lesson - Type Stability

* If you don't declare types, julia will try to infer them for you.
* DANGER: don't change types along the way. 
	* julia optimizes your code for a specific type configuration.
	* it's not the same CPU operation to add two `Int`s and two `Float`s. The difference matters.
* Example

```julia
function t1(n)
    s  = 0  # typeof(s) = Int
    for i in 1:n
        s += s/i
    end
end
function t2(n)
    s  = 0.0   # typeof(s) = Float64
    for i in 1:n
        s += s/i
    end
end
@time t1(10000000)
@time t2(10000000)
```

----------------

# Unit Testing and Code Quality


<div class="center" style="width: auto; margin-left: auto; margin-right: auto;"> ![](http://www.phdcomics.com/comics/archive/phd033114s.gif) </div>

. . .

## What is Unit Testing? Why should you test you code?

* Bugs are very hard to find just by *looking* at your code.
* Bugs hide.
* From this very instructive [MIT software construction class](http://web.mit.edu/6.005/www/fa15/classes/03-testing/#unit_testing_and_stubs):

> Even with the best validation, it’s very hard to achieve perfect quality in software. Here are some typical residual defect rates (bugs left over after the software has shipped) per kloc (one thousand lines of source code):
>
>  * 1 - 10 defects/kloc: Typical industry software.
>  * 0.1 - 1 defects/kloc: High-quality validation. The Java libraries might achieve this level of correctness.
>  * 0.01 - 0.1 defects/kloc: The very best, safety-critical validation. NASA and companies like Praxis can achieve this level.
>
> This can be discouraging for large systems. For example, if you have shipped a million lines of typical industry source code (1 defect/kloc), it means you missed 1000 bugs!

* One widely-used way to prevent your code from having too many errors, is to continuously test it.
* This issue is widely neglected in Economics as well as other sciences.
	* If the resulting graph looks right, the code should be alright, shouldn't it?
	* Well, should it?
* It is regrettable that so little effort is put into verifying the proper functioning of scientific code. 
	* Referees in general don't have access to the computing code for paper that is submitted to a journal for publication.
	* How should they be able to tell whether what they see in black on white on paper is the result of the actual computation that was proposed, rather than the result of chance (a.k.a. a bug)?
		* Increasingly papers do post the source code *after* publication.
	* The scientific method is based on the principle of **reproduciblity** of results. 
		* Notice that having something reproducible is only a first step, since you can reproduce with your buggy code the same nice graph. 
		* But from where we are right now, it's an important first step.
	* This is an issue that is detrimental to credibility of Economics, and Science, as a whole. 
* Extensively testing your code will guard you against this.

## Best Practice

* You want to be in **maximum control** over your code at all times:
	* You want to be **as sure as possible** that a certain piece of code is doing, what it actually meant to do.
	* This sounds trivial (and it is), yet very few people engage in unit testing.
* Things are slowly changing. See [http://www.runmycode.org](http://www.runmycode.org) for example.
* **You** are the generation that is going to change this. Do it.
* Let's look at some real world Examples.

---------------

# Examples


## Ariane 5 blows up because of a bug

> It took the European Space Agency 10 years and $7 billion to produce Ariane 5, a giant rocket capable of hurling a pair of three-ton satellites into orbit with each launch and intended to give Europe overwhelming supremacy in the commercial space business.

> All it took to explode that rocket less than a minute into its maiden voyage last June, scattering fiery rubble across the mangrove swamps of French Guiana, was a small computer program trying to stuff a 64-bit number into a 16-bit space. 

> This shutdown occurred 36.7 seconds after launch, when the guidance system's own computer tried to convert one piece of data -- the sideways velocity of the rocket -- from a 64-bit format to a 16-bit format. The number was too big, and an overflow error resulted. When the guidance system shut down, it passed control to an identical, redundant unit, which was there to provide backup in case of just such a failure. But the second unit had failed in the identical manner a few milliseconds before. And why not? It was running the same software.


## NASA Mars Orbiter crashes because of a bug

> For nine months, the Mars Climate Orbiter was speeding through space and speaking to NASA in metric. But the engineers on the ground were replying in non-metric English.
> It was a mathematical mismatch that was not caught until after the $125-million spacecraft, a key part of NASA's Mars exploration program, was sent crashing too low and too fast into the Martian atmosphere. The craft has not been heard from since.
> Noel Henners of Lockheed Martin Astronautics, the prime contractor for the Mars craft, said at a news conference it was up to his company's engineers to assure the metric systems used in one computer program were compatible with the English system used in another program. The simple conversion check was not done, he said.


## LA Airport Air Traffic Control shuts down because of a bug

>(IEEE Spectrum) -- It was an air traffic controller's worst nightmare. Without warning, on Tuesday, 14 September, at about 5 p.m. Pacific daylight time, air traffic controllers lost voice contact with 400 airplanes they were tracking over the southwestern United States. Planes started to head toward one another, something that occurs routinely under careful control of the air traffic controllers, who keep airplanes safely apart. But now the controllers had no way to redirect the planes' courses.

> The controllers lost contact with the planes when the main voice communications system shut down unexpectedly. To make matters worse, a backup system that was supposed to take over in such an event crashed within a minute after it was turned on. The outage disrupted about 800 flights across the country.

> Inside the control system unit is a countdown timer that ticks off time in milliseconds. The VCSU uses the timer as a pulse to send out periodic queries to the VSCS. It starts out at the highest possible number that the system's server and its software can handle—232. It's a number just over 4 billion milliseconds. When the counter reaches zero, the system runs out of ticks and can no longer time itself. So it shuts down.

> Counting down from 232 to zero in milliseconds takes just under 50 days. The FAA procedure of having a technician reboot the VSCS every 30 days resets the timer to 232 almost three weeks before it runs out of digits.

----------------

# Automated Testing

* You should try to minimize the effort of writing tests.
* Using an automated test suite is very helpful here.
* In Julia, we have got `Base.Test` in the Base package, and `FactCheck` as a package.
* Let's add some tests to your Example module.
* create a folder `test` in `modTest`
* inside that folder, open a file `runtests.jl`

----------------

# Automated Testing

* Let us create a test module for our `Example` module.

```julia
module TestExample
	using Example
	using FactCheck

	facts("testing constructors") do
		@fact typeof(Pussycat(9.8,"miauuu")) --> Pussycat
		@fact typeof(Jaguar(9.8,"miauuu")) --> Jaguar
	end

	facts("testing domath") do
		@fact domath(10) --> 15.0
		@fact domath(-5) == 0.0 --> true
	end
end
```

* There are many more assertions. Checkout the [FactCheck website](https://github.com/JuliaLang/FactCheck.jl). 
* now run the tests with `include("test/runtests.jl")`

----------------

# Automated Testing on Travis

* [https://travis-ci.org](https://travis-ci.org) is a continuous integration service.
* It runs your test on their machines and notifies you of the result.
* Every time you push a commit to github.
* If the repository is public on github, the service is for free.
* Many julia packages are testing on Travis.
* You should look out for that green badge.


----------------

# Debugging with Julia

* The [https://github.com/toivoh/Debug.jl](Debug.jl) package.


----------------

# Plotting with Julia

* [http://mth229.github.io/graphing.html](http://mth229.github.io/graphing.html) has a nice intro using the package `Gadfly`
* See [quant-econ.net website](http://quant-econ.net/jl/julia_libraries.html#plotting) for good intro to PyPlot plotting.


----------------

# Numerical Differentiation and Integration

## Derivatives

1. Finite Differencing: a numerical approximation
	* Based on Taylor's Theorem
	* Observe variation in function values from evaluating it at "close" points.
	* Forward Differencing and Central Differencing
2. Automatic Differentiation
	* Breaks down the actual `code` that defines a function and performs elementary differentiation rules, after disecting expressions via the chain rule.
	* This produces **analytic** derivatives, i.e. there is **no** approximation error.
	* This is the future.
3. Symbolic Differentiation
	* Some languages (most notably Mathematica) support symbolic algebra. Very useful sometimes if one needs to work through complicated expressions.
	* Not very useful for high computational demands, i.e. repeated computation of derivatives in an optimization routine.

-------------

# Finite Differences

* Consider the definition of the derivative of $f$ at point $x$:
	$$ f'(x) = \lim_{h\to0}\frac{f(x+h)-f(x)}{h} $$
* The simplest way to calculate a numerical derivative is to replicate this computation for small $h$ with:
	$$ f'(x) \approx \frac{f(x+h)-f(x)}{h},\quad h\text{ small.} $$
* This is known as the Forward Difference approach.
* There are different approaches, e.g. the central difference approach does
	$$ f'(x) \approx \frac{f(x+h)-f(x-h)}{2h},\quad h\text{ small.} $$
* How does this perform?

```julia
using Gadfly
f(x) = 2 - x^2
c = -0.75
sec_line(h) = x -> f(c) + (f(c + h) - f(c))/h * (x - c)
plot([f, sec_line(1), sec_line(.5), sec_line(.25), sec_line(.05)], -1, 1)
```

* What's the problem? Well, what is *small*?


-------------

# Finite Differences: what's the right step size $h$?

* Theoretically, we would like to have $h$ as small as possible, since we want to approximate the limit at zero.
* In practice, on a computer, there is a limit to this. There is a smallest representable number, as we know.
* `eps()`.
* One can show that the optimal step size is $h=\sqrt{\texttt{eps()}}$

	
------------

# Automatic Differentiation (AD)

* 2 modes: Forward and Reverse Mode.
* The basic idea is that the derivative of any function can be decomposed into some basic algebraic operations.
* The [wikipedia page is informative](https://en.wikipedia.org/wiki/Automatic_differentiation)

	![[By Berland at en.wikipedia [Public domain], from Wikimedia Commons](https://commons.wikimedia.org/wiki/File%3AAutomaticDifferentiation.png)](figs/wikipedia-AD.png)

## Example

* Suppose we want to differentiate $f(x_1,x_2) = x_1 x_2 + \sin x_1$
* We label subexpressions by $w_i$ as follows:
	$$ \begin{array}{cl}
	f(x_1,x_2) &= x_1 x_2 + \sin x_1 \\
	&= w_1 w_2 + sin w_1 \\
	&= w_3  + w_4 \\
	&= w_5 
	\end{array} 
	$$
* Computation of the partial derivative starts with the seed value, i.e. $\dot{w}_1 = \frac{\partial x_1}{\partial x_1} = 1$.
* We store for each subexpression both the value and the derivative, i.e. $(w_i,\dot{w}_i)$
* We then sweep through the expression tree as in this picture:

	![[By Berland at en.wikipedia [Public domain], from Wikimedia Commons](https://commons.wikimedia.org/wiki/File%3AForwardAccumulationAutomaticDifferentiation.png)](figs/wikipedia-AD-example.png)


-----------------

# AD in Julia

* The organisation here is [http://www.juliadiff.org](http://www.juliadiff.org)
* There are many packages to perform differentiation with Julia here.
* Many packages rely on the machinery here. 
* Let's quickly look at [https://github.com/JuliaDiff/ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl)

```julia
# from ForwardDiff's readme:
using ForwardDiff
f(x::Vector) = sum(sin, x) + prod(tan, x) * sum(sqrt, x)
x = rand(5); # get 5 random points
g = ForwardDiff.gradient(f); # g = ∇f
j = ForwardDiff.jacobian(g); # j = J(∇f)
ForwardDiff.hessian(f, x) # H(f)(x) == J(∇f)(x), as expected
```

* The authors provide some benchmarks. Let's run those:

```julia
include(joinpath(Pkg.dir("ForwardDiff"),"benchmarks","run_all_benchmarks(ForwardDiffBenchmarks.Rosenbrock)"))
```


----------------


# Numerical Approximation of Integrals

* We will focus on methods that represent integrals as weighted sums.
* The typical representation will look like:
	$$ E[G(\epsilon)] = \int_{\mathbb{R}^N} G(\epsilon) w(\epsilon) d\epsilon \approx \sum_{j=1}^J \omega_j G(\epsilon_j) $$
	* $N$ is the dimensionality of the integration problem.
	* $G:\mathbb{R}^N \mapsto \mathbb{R}$ is the function we want to integrate wrt $\epsilon \in \mathbb{R}^N$.
	* $w$ is a density function s.t. $\int_{\mathbb{R}^n} w(\epsilon) d\epsilon = 1$.
	* $\omega$ are weights such that (most of the time) $\sum_{j=1}^J \omega_j = 1$.
<!-- * We will look at normal shocks $\epsilon \sim N(0_N,I_N)$
	* in that case, $w(\epsilon) = (2\pi)^{-N/2} \exp \left(-\frac{1}{2}\epsilon^T \epsilon \right)$
	* $I_N$ is the n by n identity matrix, i.e. there is no correlation among the shocks for now.
	* Other random processes will require different weighting functions, but the principle is identical.
 -->
 * For now, let's say that $N=1$

-----------------


# Quadrature Rules

* We focus exclusively on those and leave Simpson and Newton Cowtes formulas out.
	* This is because Quadrature is the method that in many situations gives highes accuracy with lowest computational cost.
* Quadrature provides a rule to compute weights $w_j$ and nodes $\epsilon_j$.
* There are many different quadrature rules.
* They differ in their domain and weighting function.
* [https://en.wikipedia.org/wiki/Gaussian_quadrature](https://en.wikipedia.org/wiki/Gaussian_quadrature)
* In general, we can convert our function domain to a rule-specific domain with change of variables.


-----------------

# Gauss-Hermite: Expectation of a Normally Distributed Variable

* There are many different rules, all specific to a certain random process.
* Gauss-Hermite is designed for an integral of the form
	$$ \int_{-\infty}^{+\infty} e^{-x^2} G(x) dx $$
	and where we would approximate 
	$$ \int_{-\infty}^{+\infty} e^{-x^2} f(x) dx \approx \sum_{i=1}^n \omega_i G(x_i) $$
* Now, let's say we want to approximate the expected value of function $f$ when it's argument $z\sim N(\mu,\sigma^2)$:
	$$ E[f(z)] = \int_{-\infty}^{+\infty} \frac{1}{\sigma \sqrt{2\pi}} \exp \left( -\frac{(z-\mu)^2}{2\sigma^2} \right) f(z) dz $$

--------------

# Gauss-Hermite: Expectation of a Normally Distributed Variable

* The rule is defined for $x$ however. We need to transform $z$:
	$$ x = \frac{(z-\mu)^2}{2\sigma^2} \Rightarrow z = \sqrt{2} \sigma x + \mu $$
* This gives us now (just plug in for $z$)
	$$ E[f(z)] = \int_{-\infty}^{+\infty} \frac{1}{ \sqrt{\pi}} \exp \left( -x^2 \right) f(\sqrt{2} \sigma x + \mu) dx $$
* And thus, our approximation to this, using weights $\omega_i$ and nodes $x_i$ is
	$$ E[f(z)] \approx \sum_{j=1}^J \frac{1}{\sqrt{\pi}} \omega_j f(\sqrt{2} \sigma x_j + \mu)$$

------------

# Using Quadrature in Julia

* [https://github.com/ajt60gaibb/FastGaussQuadrature.jl](https://github.com/ajt60gaibb/FastGaussQuadrature.jl)

```julia
Pkg.add("FastGaussQuadrature")

using FastGaussQuadrature

np = 3

rules = Dict("hermite" => gausshermite(np),
             "chebyshev" => gausschebyshev(np),
             "legendre" => gausslegendre(np),
             "lobatto" => gausslobatto(np))


using DataFrames

nodes = DataFrame([x[1] for x in values(rules)],Symbol[symbol(x) for x in keys(rules)])
weights = DataFrame([x[2] for x in values(rules)],Symbol[symbol(x) for x in keys(rules)])
```

------------



# Quadrature in more dimensions: Product Rule

* If we have $N>1$, we can use the product rule: this just takes the kronecker product of all univariate rules.
* This works well as long as $N$ is not too large. The number of required function evaluations grows exponentially.
	$$ E[G(\epsilon)] = \int_{\mathbb{R}^N} G(\epsilon) w(\epsilon) d\epsilon \approx \sum_{j_1=1}^{J_1} \cdots \sum_{j_N=1}^{J_N} \omega_{j_1}^1 \cdots \omega_{j_N}^N G(\epsilon_{j_1}^1,\dots,\epsilon_{j_N}^N) $$
	where $\omega_{j_1}^1$ stands for weight index $j_1$ in dimension 1, same for $\epsilon$.
* Total number of nodes: $J=J_1 J_2 \cdots J_N$, and $J_i$ can differ from $J_k$.

## Example for $N=3$

* Suppose we have $\epsilon^i \sim N(0,1),i=1,2,3$ as three uncorrelated random variables.
* Let's take $J=3$ points in all dimensions, so that in total we have $J^N=27$ points.
* We have the nodes and weights from before in `rules["hermite"]`.

```julia
nodes = Any[]
push!(nodes,repeat(rules["hermite"][1],inner=[1],outer=[9]))
push!(nodes,repeat(rules["hermite"][1],inner=[3],outer=[3]))
push!(nodes,repeat(rules["hermite"][1],inner=[9],outer=[1]))
weights = kron(rules["hermite"][2],kron(rules["hermite"][2],rules["hermite"][2]))
df = hcat(DataFrame(weights=weights),DataFrame(nodes,[:dim1,:dim2,:dim3]))
```

* Imagine you had a function $g$ defined on those 3 dims: in order to approximate the integral, you would have to evaluate $g$ at all combinations of `dimx`, multiply with the corresponding weight, and sum.


----------------

# Alternatives to the Product Rule

* Monomial Rules: They grow only linearly.
* Please refer to [@judd-book] for more details.


-----------------

# Monte Carlo Integration

* A widely used method is to just draw $N$ points randomly from the space of the shock $\epsilon$, and to assign equal weights $\omega_j=\frac{1}{N}$ to all of them.
* The expectation is then
	$$ E[G(\epsilon)] \approx \frac{1}{N} \sum_{j=1}^N  G(\epsilon_j) $$
* This in general a very inefficient method.
* Particularly in more than 1 dimensions, the number of points needed for good accuracy is very large.

## Quasi Monte Carlo Integration

* Uses non-product techniques to construct a grid of uniformly spaced points.
* The researcher controlls the number of points. 
* We need to construct equidistributed points.
* Typically one uses a low-discrepancy sequence of points, e.g. the Weyl sequence:
* $x_n = {n v}$ where $v$ is an irrational number and `{}` stands for the fractional part of a number. for $v=\sqrt{2}$,
	$$ x_1 = \{1 \sqrt{2}\} = \{1.4142\} = 0.4142, x_2 = \{2 \sqrt{2}\} = \{2.8242\} = 0.8242,... $$
* Other low-discrepancy sequences are Niederreiter, Haber, Baker or Sobol.

```julia
Pkg.add("Sobol")
using Sobol
using PyPlot
s = SobolSeq(2)
p = hcat([next(s) for i = 1:1024]...)'
subplot(111, aspect="equal")
plot(p[:,1], p[:,2], "r.")
```


![Sobol Sequences in [0,1]^2](figs/Sobol.png) 

----------------

# Correlated Shocks

* We often face situations where the shocks are in fact correlated.
	$$ E[G(\epsilon)] = \int_{\mathbb{R}^N} G(\epsilon) w(\epsilon) d\epsilon \approx \sum_{j_1=1}^{J_1} \cdots \sum_{j_N=1}^{J_N} \omega_{j_1}^1 \cdots \omega_{j_N}^N G(\epsilon_{j_1}^1,\dots,\epsilon_{j_N}^N) $$
* Now $\epsilon \sim N(\mu,\Sigma)$ where $\Sigma$ is an N by N variance-covariance matrix.
* The multivariate density is
	$$w(\epsilon) = (2\pi)^{-N/2} det(\Sigma)^{-1/2} \exp \left(-\frac{1}{2}(\epsilon - \mu)^T (\epsilon - \mu) \right)$$
* We need to perform a change of variables before we can integrate this.
* Given $\Sigma$ is symmetric and positive semi-definite, it has a Cholesky decomposition, 
	$$ \Sigma = \Omega \Omega^T $$
	where $\Omega$ is a lower-triangular with strictly positive entries.
* The linear change of variables is then
	$$ v = \Omega^{-1} (\epsilon - \mu)  $$
* Plugging this in gives
	$$ \sum_{j=1}^J \omega_j  G(\Omega v_j + \mu) \equiv \sum_{j=1}^J \omega_j  G(\epsilon_j) $$
	where $v\sim N(0,I_N)$.
* So, we can follow the exact same steps as with the uncorrelated shocks, but need to adapt the nodes.





# References

* The Integration part of these slides are based on [@maliar-maliar] chapter 5





