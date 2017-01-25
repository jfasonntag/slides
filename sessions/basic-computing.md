% Computational Economics: Computer Basics
% Florian Oswald
% Sciences Po, 2016


# Introduction

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

---------------

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
>* Julia is **fast**.

---------------

# Julia Benchmarks

* Julia is [fast](http://julialang.org/benchmarks/).
	* But julia is also a high-level dynamic language. How come? 
	* The JIT compiler.
	* The [LLVM project](https://en.wikipedia.org/wiki/LLVM).


---------------

# Julia is open source (and it's for free)

* It's for free. 
* Did I say that it's for free?
* You will never again worry about licenses. Want to run 1000 instances of julia on your HPC? Do it.
* The entire standard library of julia is written in julia (and not in `C`, e.g., as is the case in R, matlab or python). It's easy to look and understand at how things work.
* Suppose you want to know how `searchsortedlast` is implemented in `julia`.

~~~~~~~~~~~ {.julia}
x = rand(10)
@edit searchsortedlast(x,0.5)
~~~~~~~~~~~ 


---------------

# Julia is new

* Julia is a very modern language, combining the best features of many other languages.
* For example, wow would you write that in `R`?
	$$ \sum_{i=1}^N \sum_{j=1}^i j$$

. . .  

  
~~~~~~~~~~~ {.R}
R> sum(unlist(lapply(1:10,function(x) 1:x)))
[1] 220
~~~~~~~~~~~ 

* and in julia? You could use a *Generator* expression, which does not allocate two arrays of values to sum over (which is what R has to do here). 

	~~~~~~~~~~~ {.julia}
	julia> sum(sum(j for j in 1:i) for i in 1:10)
	220
	~~~~~~~~~~~ 

* To have a peek at performance, consider this:

~~~~~~~~~~~ {.R}
R> n
[1] 25000
> system.time(sum(as.numeric(unlist(lapply(1:n,function(x) 1:x)))))
   user  system elapsed 
  1.710   0.830   2.545 
~~~~~~~~~~~ 

~~~~~~~~~~~ {.julia}
N = 25_000
julia> @time sum([sum([j for j in 1:i]) for i in 1:N])  # R-equivalent
  0.965853 seconds (97.73 k allocations: 2.333 GB, 21.25% gc time)

julia> @time sum(sum(j for j in 1:i) for i in 1:N)
  0.041750 seconds (113.21 k allocations: 3.107 MB)
~~~~~~~~~~~ 


------------------

# Community

* The `julia` community is a very active and thriving place, comparable to `R`.
* You should get used to asking questions in the different forums if you have problems. 
* You will find it much harder to learn any language if you are afraid to ask questions.
  
	* Your main forum is [https://discourse.julialang.org](https://discourse.julialang.org)
* You can get help on [stackoverflow](http://stackoverflow.com/questions/tagged/julia-lang) under tag `julia-lang`
* Many package maintainers are very active on their respective github repositories - some offer a gitter chat for questions.

------------------

## Why not julia?

* Julia is in version `0.5.0`. There may be language changes in future releases.
	* People were worried whether *julia is here to stay*. 
	* The developers are very cautious before releasing version `1.0` because of that.
	* There are examples of other languages which ran out of steam (Perl).
	* The next version `0.6` is being released early feb 2017.
* There are fewer packages for certain tasks than you have in R.
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

# Time to get your hands dirty (with some code)!

## First Things First: `Git`

* It is useful to first talk about `Git`, a widely used version control system.
* This is because the julia package system is built using git.
* In fact, a julia package is a `Git` *repository*.

How does Git work?

- After one makes changes to a project, they **commit** the changes
- Changes are **pushed** to the main repository hosted online
- To download the code, you **clone** the repository
- Instead of editing the main repository, one edits a **branch**
- To get the changes of the main branch in yours, you **fetch**, **pull**, or **rebase**
- One asks the owner of the repository to add their changes via a **pull request**
- Stable versions are called **releases**
- The packages can be found / investigated at Github.com

----------------

# First Things First: `Github.com`

- The major online service for git repositories is Github
- Github is a free service
- The code is hosted online, free for everyone to view
- Users can open **Issues** to ask for features and give bug reports to developers
- Many projects are brought together into **organizations** (JuliaMath, JuliaDiffEq, JuliaStats, etc.) 

An example Github repository for a Julia package is [https://github.com/JuliaOpt/JuMP.jl](https://github.com/JuliaOpt/JuMP.jl)


----------------

# Julia's Package Manager

* Officially registered packages are available on github via the function `Pkg.add()`.
	* Let's install the `Plots.jl` package: `Pkg.add("Plots")`
* Non-registered ones are available via `Pkg.clone()`
	* For example, `Pkg.clone("https://github.com/JuliaDiffEq/ParameterizedFunctions.jl")`

## Using a Package

* To use a package, we need to import it's code into our julia session.

~~~~~~~~~~~ {.julia}
using Plots
plot(rand(4,4))
~~~~~~~~~~~ 

----------------

# Cloning the `Slides` repository

* Let's try this out. We want to clone **this** repository, which lives at https://github.com/ScPo-CompEcon/slides
* You can get [https://desktop.github.com](https://desktop.github.com) for an easy interface to github. Open, and login with your github username.
* To clone, go to [https://github.com/ScPo-CompEcon/slides](https://github.com/ScPo-CompEcon/slides) and click on **clone**, then *Open in Desktop*
	* If you don't like GUI's, you can just copy the address and do in your terminal `git clone git@github.com:ScPo-CompEcon/slides.git`
* You can now use this package. For example, navigate to where you cloned it to and do

~~~~~~~~~~~ {.julia}
# you are in slides/
include("src/slides.jl")   # this loads the package code
hello()
~~~~~~~~~~~ 




----------------

# Some Numerical Concepts and `Julia`

* Machine epsilon: The smallest number that your computer can represent, type `eps()`.
* Infinity: A number greater than all representable numbers on your computer. [Obeys some arithmethmic rules](http://docs.julialang.org/en/release-0.5/manual/integers-and-floating-point-numbers/?highlight=infinity#special-floating-point-values)
	* Overflow: If you perform an operation where the result is greater than the largest representable number.
	* Underflow: You take two (very small) representable numbers, but the result is smaller than `eps()`. 
	* In Julia, you are wrapped around the end of your representable space:
	```julia
	x = typemax(Int64)
	x + 1
	```
* Integers and Floating Point Numbers.
* Single and Double Precision.
* In Julia, all of these are different [*numeric primitive types (head over to julia manual for a second)*](http://docs.julialang.org/en/release-0.5/manual/integers-and-floating-point-numbers/).
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

* What is a REPL?
* different modes:
	* julian
	* help: `?`
	* shell: `;`
	* search history file: 
		* incremental search with `CTRL r`
	* documented in the [manual](http://docs.julialang.org/en/release-0.5/manual/interacting-with-julia)

----------------



----------------
# Julia Primer

We'll introduce the following fundamental concepts:

* Workflow
* DataStructures
* Working with Data
* Statistics
* Plotting
* Performance

----------------

# Workflow





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

# Debugging Julia

* The [Debug.jl package](https://github.com/toivoh/Debug.jl).


----------------

# Plotting with Julia

* [http://mth229.github.io/graphing.html](http://mth229.github.io/graphing.html) has a nice intro using the package `Gadfly`
* See [quant-econ.net website](http://quant-econ.net/jl/julia_libraries.html#plotting) for good intro to PyPlot plotting.







