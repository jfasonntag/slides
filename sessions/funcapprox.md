% Computational Economics: Function Approximation
% Florian Oswald
% Sciences Po, Spring 2016

# Outline

1. Overview of Approximation Methods
	1. Interpolation
	1. Regression
1. Polynomial Interpolation
1. Spline Interpolation
1. Multidimensional Approximation

------------------------

# Approximation Methods

* Confronted with a non-analytic function $f$ (i.e. something not like $log(x)$), we need a way to numerically represent $f$ in a computer.
	* If your problem is to compute a value function in a dynamic problem, you don't have an analytic representation of $V$.
	* If you need to compute an equilibrium distribution for your model, you probably can't tell it's from one parametric family or another.
* Approximations use *data* of some kind which informs us about $f$. Most commonly, we know the function values $f(x_i)$ at a corresponding finite set of points $X = \{x_i\}_{i=1}^N$.
* The task of approximation is to take that data and tell us what the function value is at $f(y),y\not \in X$.
* To an economist this should sound very familiar: take a dataset, learn it's structure, and make predictions.
* The only difference is that we can do much better here, because we have more degree's of freedom (we can choose our $X$ in $Y=\beta X + \epsilon$)

------------------------

# Some Classification

* Local Approximations: approximate function and it's derivative $f,f'$ at a *single* point $x_0$. Taylor Series:
	$$ f(x) = f(x_0) + (x-x_0)f'(x_0) + \frac{(x-x_0)^2}{2}f''(x_0) + \dots + \frac{(x-x_0)^n}{n!}f^{n}(x_0) $$
* Interpolation or *Colocation*: find a function $\hat{f}$ that is a good fit to $f$, and require that $\hat{f}$ *passes through* the points. If we think of there being a *residual* $\epsilon_i = f(x_i) - \hat{f}(x_i)$ at each grid point $i$, this methods succeeds in setting $\epsilon_i=0,\forall i$.
* Regression: Minimize some notion of distance (squared) between $\hat{f}$ and $f$, without the requirement of pass through. 


------------------------

# Doing Interpolation in Julia

* In practice, you will make heavy use of high-quality interpolation packages in julia.
* List in the end.
* Nevertheless, function approximation is *extremely* problem-specific, so sometimes a certain approach does not work for your problem.
* This is why we will go through the mechanics of some common methods.
* I would like you to know where to start drilling if you need to go and hack somebody elses code.

-----------------------

# Interpolation Basics

* Let $f$ be a smooth function mapping $\mathbb{R}^d \mapsto \mathbb{R}$, and define $\hat{f}(\cdot;c)$ to be our parametric approximation function. We generically define this as
	$$  \hat{f}(x;c) = \sum_{j=1}^J c_j \phi_j(x) $$
	where 
	* $\phi_j : \mathbb{R}^d \mapsto \mathbb{R}$ is called a **basis function**,
	* $c={c_1,c_2,\dots,c_J}$ is a coefficient vector
* The integer $J$ is the *order* of the interpolation.
* Our problem is to choose $(\phi_i,c)$ in some way.
* We will construct a *grid* of $M\geq J$ points ${x_1,\dots,x_M}$ within the domain $\mathbb{R}^d$, and we will denote the *residuals* at each grid point by $\epsilon = {\epsilon_1,\dots,\epsilon_M}$:
	$$ \left[\begin{array}{c}
		\epsilon_1 \\
		 \vdots \\
		\epsilon_M \\ \end{array} \right]  = \left[\begin{array}{c} f(x_1) \\ \vdots \\ f(x_M)  \end{array} \right] - \left[\begin{array}{ccc} 
		\phi_1(x_1) & \dots & \phi_J(x_1) \\   
		\vdots      & \ddots & \vdots \\   
		\phi_1(x_M) & \dots & \phi_J(x_M)    
		\end{array} \right]  \cdot 
		\left[\begin{array}{c} c_1 \\ \vdots \\ c_J  \end{array} \right]
		$$
* *Interpolation* or colocation occurs when $J=M$, i.e. we have a square matrix of basis functions, and can exactly solve this.
* We basically need to solve the system
	$$ \begin{align} \sum_{j=1}^n c_j \phi_j(x_i) &= f(x_i),\forall i=1,2,\dots,n \\
	                  \mathbf{\Phi c}&= \mathbf{y}
	    \end{align}
	 $$
	where the second line uses vector notation, and $\mathbf{y}$ has all values of $f$.
* Solution: $\mathbf{c}= \mathbf{\Phi}^{-1}y$.

------------------------

# Regression Basics

* Clearly, on the previous slide we required that there are as many interpolation nodes as there are basis functions - we had $J$ equations for $M$ unknowns, so there exists a unique solution for $c$.
* We needed to *invert* $\mathbf{\Phi}$.
* If we have more, $M>J$ say, interpolation nodes than basis functions, we cannot do that. Instead we can define a loss function, and minimize it. 
* In the case of squared loss, of course, this leads to the least squares solution:
	$$ \begin{align} e_i &= f(x_i) - \sum_{j=1}^n c_j \phi_j(x_i) \\
	        \min_c e_i^2 & \implies \\
	        c            &= (\Phi'\Phi)^{-1} \Phi'y
	    \end{align}
	 $$


-------------------------

# Spectral and Finite Element Methods

* Spectral Methods are such that the basis functions are non-zero over the entire domain of $f$.
	* Polynomial interpolation
	* Chebychev interpolation
* Finite Element methods are such that basis functions are non-zero only on a subset of the domain.
	* Splines
		* Linear splines, i.e. splines of degree 1, a.k.a. *linear approximation*
		* Higher order splines, mainly the *cubic spline*.

. . .

### What makes a good Approximation?

* Should be arbitrarily accurate as we increase $n$.
* $\Phi$ Should be efficiently (fast) computable. If $\Phi$ were differentiable, we could easily get e.g. $\hat{f}'(x) = \sum_{j=1}^J c_j \phi_j'(x_i)$
* $c$ Should be efficiently (fast) computable.


-------------------------


# Polynomial Interpolation

* For any continuous real-valued function $f$ on interval $[a,b]$, and an $\epsilon>0$, there is a polynomial $p$, such that
	$$ || f - p ||_\infty \equiv \sup_{x\in[a,b]} |f(x)-p(x)| < \epsilon $$
* However, the choice of $p$ is critical. *Orthogonal Polynomials* have been shown to perform very well.

> <span style="color:red">Definition - Orthogonal Polynomials</span>: an orthogonal polynomial sequence is a family of polynomials such that any two different polynomials in the sequence are orthogonal to each other under some inner product. 

* There are many families that satisfy this. See [@judd-book] table 6.3 for an overview.
* We will now look at a widely used family, the Chebyshev polynomial.

-------------------------

# Chebyshev Nodes

* *Chebyshev Nodes* are defined in the interval $[-1,1]$ as 
	$$ x_i = \cos\left(\frac{2k-1}{2n} \pi\right), k=1,\dots,n $$
* Which maps to general interval $[a,b]$ as
	$$ x_i = \frac{1}{2} (a+b) + \frac{1}{2} (b-a) \cos\left(\frac{2k-1}{2n} \pi\right) , k=1,\dots,n $$
* Chebyshev nodes are **not** evenly spaced: there are more points towards the boundaries.

~~~~~~~~~~~~ {.julia}
using PyPlot
using FastGaussQuadrature: gausschebyshev
nodes = gausschebyshev(11)  # generate 11 Chebyshev Nodes
fig = figure(figsize=(10,4))
title(L"Chebyshev Nodes $x \in [-1,1]$")
ax = axes()
ax[:plot](nodes[1], ones(11), "+r")
ax[:yaxis][:set_visible](false)
fig[:canvas][:draw]()  # update figure
~~~~~~~~~~~~~~


-----------------------

# Chebyshev Nodes

<div class="center" style="width: auto; margin-left: auto; margin-right: auto;">![Chebyshev Nodes](figs/cheby-nodes.png) </div>

-------------------------


# What Polynomial to use? What form for $\Phi$?

* In principle the *monomial basis* could be used. It is just the power functions of $x$: $1,x,x^2,x^3,\dots$
* Stacking this up for each evaluation node (Chebyshev, or any other), gives the *Vandermonde Matrix*:
	$$ V = \left[\begin{matrix} 
			1 & x_1 & \dots & x_1^{n-2} & x_1^{n-1} \\ 
			1 & x_2 & \dots & x_2^{n-2} & x_2^{n-1} \\ 
			\vdots & \vdots & \ddots &  & \vdots \\ 
			1 & x_m & \dots & x_m^{n-2} & x_m^{n-1} 
			\end{matrix} \right]
			$$
    for the case with $m$ evaluation nodes for $x$, and $n$ basis functions for each $x_i$.
* $V$ is ill-conditioned and thus a bad choice.
* A much better polynomial basis is - surprise, surprise - the *Chebyshev Polynomial basis*.


-------------------------

# Evaluating the Chebyshev Polynomial and Basis Function
* As before, this Basis is defined in $[-1,1]$, so for general $x\in[a,b]$ we normalize $x$ to
	$$ z_i = 2\frac{x_i-a}{b-a} -1 $$
* There are several ways to obtain the value of the order $j$ Chebyshev polynomial at $z$, e.g. to get $\sum_{i=0}^n
a_i T_i(z)$.
	1. use definition $T_j(z) = \cos(\arccos(z)j)$. Or
	2. Recursively we have that $\phi_j(x) = T_{j-1}(z)$, and
		$$ \begin{align}
			T_0(z) =& 1 \\
			T_1(z) =& z \\
			T_{i+1}(z) =& 2zT_i(z) - T_{i-1}(z),i=1,\dots,n
			\end{align}
			$$

. . .

### Constructing $\Phi$ as $T$ evaluated *at* the Chebyshev Nodes
* Combining Chebyshev nodes evaluated at $T$ to construct $\Phi$ is a particularly good idea.
* Doing so, we obtain an interpolation matrix $\Phi$ with typical element
	$$ \phi_{ij} = \cos\left( \frac{(n-i+0.5)(j-1)\pi}{n}\right)  $$
* And we obtain that $\Phi$ is indeed orthogonal
	$$ \Phi^T \Phi = \text{diag}\{n,n/2,n/2,\dots,n/2\}  $$


-----------------------

# (Chebyshev) Interpolation Proceedure

* Let's summarize this proceedure.
* Instead of Chebyshev polynomials we could be using any other suitable family of polynomials.
* To obtain a Polynomial interpolant $\hat{f}$, we need:
	1. a function to $f$ interpolate. We need to be able to get the function values somehow.
	1. A set of (Chebyshev) interpolation nodes at which to compute $f$
	1. An interpolation matrix $\Phi$ that corresponds to the nodes we have chosen.
	1. A resulting coefficient vector $c$
* To obtain the value of the interpolation at $x'$ off our grid, we also need a way to evaluate $\Phi(x')$	.
	1. Evaluate the Basis function $\Phi$ at $x'$
	2. obtain new values as $y = \Phi c$.

----------------------

# Polynomial Interpolation with `Julia`: `ApproxFun.jl`

* [`ApproxFun.jl`](https://github.com/ApproxFun/ApproxFun.jl) is a Julia package based on the Matlab package [`chebfun`](http://www.chebfun.org). It is quite amazing.
* More than just *function approximation*. This is a toolbox to actually *work* with functions.
* given 2 functions $f,g$, we can do algebra with them, i.e. $h(x) = f(x) + g(x)^2$
* We can differentiate and integrate
* Solve ODE's and PDE's
* represent period functions
* Head over to the website and look at the readme.

-----------------------

# Polynomial Interpolation with `Julia`: `ApproxFun.jl`

* This even works with discontinuities:

~~~~~~~~~~~~~ {.julia}
using ApproxFun
ff = x->sign(x-0.1)/2 + cos(4*x);  # sign introduces a jump at 0.1
x  = Fun(identity)	# set up a function space
space(x)
f  = ff(x)	# define ff on that space
ApproxFun.plot(f)	# plot

# whats the first deriv at 0.785?
f'(0.785)
# integral of f?
g = cumsum(f)
g = g + f(-1)
integral = norm(f-g)
~~~~~~~~~~~~~ 


-----------------------

# Polynomial Interpolation with `Julia`: `ApproxFun.jl`

* The main purpose of this package is to manipulate analytic functions, i.e. function with an algebraic representation.
* There is the possibility to supply a set of data points and fit a polynomial:

~~~~~~~~~~~~~ {.julia}
S=Chebyshev([-1,1])
x=points(S,20)  # Get 20 points from that space
v=cos(cos(4*x))
f=Fun(ApproxFun.transform(S,v),S)
setplotter("PyPlot")
figure()
subplot(121) #create first axis of 1x2 plot array
ApproxFun.plot(f)
title(L"$f(x)=\cos(4x)$")
# what about some random data?
v2=rand(20)
f2=Fun(ApproxFun.transform(S,v2),S)
subplot(122) #create second axis of 1x2 plot array
title("x = rand(20)")
ApproxFun.plot(f2,linewidth=1.5)
ApproxFun.plot(x,v2,marker="o",color="red")
~~~~~~~~~~~~~ 

* Check out more examples with [my conversation with one of the package authors](https://github.com/ApproxFun/ApproxFun.jl/issues/275)


-----------------------

# `ApproxFun.jl` fitting some (random) data

<div class="center" style="width: auto; margin-left: auto; margin-right: auto;">![`ApproxFun.jl` data fitting](figs/approxFun-data.png) </div>

-----------------------

# Splines: Piecewise Polynomial Approximation

* Splines are a finite element method, i.e. there are regions of the function domain where some basis functions are zero.
* As such, they provide a very flexible framework for approximation instead of high-order polynomials.
	* Keep in mind that Polynomials basis functions are non-zero on the entire domain. Remember the Vandermonde matrix.
* They bring some element of local approximation back into our framework. What happens at one end of the domain to the function is not important to what happens at the other end.
* Looking back at the previous plot of random data: we are searching for **one** polynomial to fit **all** those wiggles. A spline will allow us to design **different** polynomials in different parts of the domain.

. . .

## Splines: Basic Setup

* The fundamental building block is the *knot vector*, or the *breakpoints vector* $\mathbf{z}$ of length $p$. An element of $\mathbf{z}$ is $z_i$.
* $\mathbf{z}$ is ordered in ascending order.
* $\mathbf{z}$ spans the domain $[a,b]$ of our function, and we have that $a=z_1,b=z_p$
* A spline is of *order k* if the polynomial segments are k-th order polynomials.
* Literature: [@deboor] is the definitive reference for splines.

-----------------------

# Splines: Characterization

* Given $p$ knots, there are $p-1$ polynomial segments of order $k$, each characterized by $k+1$ coefficients, i.e. a total of $(p-1)(k+1)$ parameters.
* However, we also require the spline to be continuous and differentiable of degree $k-1$ at the $p-2$ interior breakpoints.
* Imposing that uses up an additional $k(p-2)$ conditions.
* We are left with $n = (p-1)(k+1) - k(p-2) = p+k-1$ free parameters.
* A Spline of order $k$ and $p$ knots can thus be written as a linear combination of it's $n = p+k-1$ basis functions.

-----------------------

# Splines: Show some Basis Functions


~~~~~~~~~~~~ {.julia}
using ApproXD   
# Pkg.clone("https://github.com/floswald/ApproXD.jl")
using PyPlot
bs = BSpline(7,3,0,1) #7 knots, degree 3 in [0,1]
# how many basis functions? (go back 1 slide.)
# getNumCoefs(bs)
B = full(getBasis(collect(linspace(0,1.0,500)),bs))
# setup the plot
fig,axes = subplots(3,3,figsize=(10,5))
for i in 1:3
	for j in 1:3
		ax = axes[j,i]
		count = i+(j-1)*3
		ax[:plot](B[:,count])
		ax[:grid]()
		ax[:set_title]("Basis $(count-1)")
		ax[:xaxis][:set_visible](false)
		ax[:set_ylim](-0.1,1.1)
		ax[:xaxis][:set_major_locator]=matplotlib[:ticker][:MultipleLocator](1)
		ax[:yaxis][:set_major_locator]=matplotlib[:ticker][:MultipleLocator](1)
	end
end
fig[:canvas][:draw]()
~~~~~~~~~~~~~~

-----------------------

# Splines: Show some Basis Functions

<div class="center" style="width: auto; margin-left: auto; margin-right: auto;">![Cubic Spline Basis of degree 3](figs/cubic-bspline.png) </div>

* Notice that placing each of those panels on top of each other generates a sparse matrix!

-----------------------




# B-Splines: Definition

* We mostly use Basis Splines, or **B-Splines**.
* Here is a recursive definition of a B-Spline (and what is used in `ApproXD`):
* Denote the $j$-th basis function of degree $k$ with knot vector $\mathbf{z}$  at $x$ as $B_j^{k,\mathbf{z}} (x)$
* Again, there are $n = k + p - 1$ $B$'s (where $p$` = length(z)`)
* We can define $B_j^{k,\mathbf{z}} (x)$ recursively like this:
	$$  B_j^{k,\mathbf{z}} (x) = \frac{x-z_{j-k}}{z_j - z_{j-k}} B_{j-1}^{k-1,\mathbf{z}} (x)  + \frac{z_{j+1}-x}{z_{j+1} - z_{j+1-k}} B_{j}^{k-1,\mathbf{z}} (x), j=1,\dots,n$$

. . .


* The recursion starts with
	$$ B_j^{0,\mathbf{z}} (x) = \begin{cases}
		1 & \text{if }z_j \leq x <	z_{j+1}\\
		0 & \text{otherwise.}
		\end{cases}
		$$
* For this formulation to work, we need to extend the knot vector for $j<1,j>p$:
	$$ z_j = \begin{cases}
		a & \text{if }j \leq 1\\
		b & \text{if }j \geq p
		\end{cases} $$
* And we need to set the endpoints
	$$ B_0^{k-1,\mathbf{z}} = B_n^{k-1,\mathbf{z}} =0 $$
* You may see that this gives rise to a triangular computation strategy, as pointed out [here](http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/B-spline/bspline-basis.html).


-----------------------

# B-Splines: Derivatives and Integrals

* This is another very nice thing about B-Splines.
* The derivative wrt to it's argument $x$ is
	$$ \frac{d B_j^{k,\mathbf{z}} (x)}{dx} = \frac{k}{z_j - z_{j-k}} B_{j-1}^{k-1,\mathbf{z}} (x)  + \frac{k}{z_{j+1} - z_{j+1-k}} B_{j}^{k-1,\mathbf{z}} (x), j=1,\dots,n$$
* Similarly, the Integral is just the sum over the basis functions:
	$$ \int_a^x B_j^{k,\mathbf{z}} (y) dy = \sum_{i=j}^n \frac{z_i - z_{i-k}}{k} B_{i+1}^{k+1,\mathbf{z}} (x)  $$


-----------------------

# Linear B-Spline: A useful special case

* This is *connecting the dots with a straight line*
* This may incur some approximation error if the underlying function is very curved between the dots.
* However, it has some benefits: 
	* it is shape-preserving, 
	* it is fast,
	* it is easy to build.
* For a linear spline with evenly spaced breakpoints, this becomes almost trivial.
	* Let's define $h = \frac{b-a}{n-1}$ as the distance between breakpoints.
	* Our basis function becomes very simple, giving us a measure of how far $x$ is from the next knot:
		$$ \phi_j (x) = \begin{cases}
			1 - \frac{|x-z_j|}{h} & \text{if } |x-z_j| \leq h \\
			0                    & \text{otherwise}
			\end{cases} $$
	* Notice that each interior basis function (i.e. not 0 and not $n$) has witdth $2h$.

~~~~~~~~~~~~ {.julia}
using ApproXD
bs = BSpline(9,1,0,1) #9 knots, degree 1 in [0,1]
# how many basis functions? (go back 1 slide.)
# getNumCoefs(bs)
B = full(getBasis(collect(linspace(0,1.0,500)),bs))
# setup the plot
fig,axes = subplots(3,3,figsize=(10,5))
for i in 1:3
	for j in 1:3
		ax = axes[j,i]
		count = i+(j-1)*3
		ax[:plot](B[:,count])
		ax[:grid]()
		ax[:set_title]("Basis $(count-1)")
		ax[:xaxis][:set_visible](false)
		ax[:set_ylim](-0.1,1.1)
		ax[:xaxis][:set_major_locator]=matplotlib[:ticker][:MultipleLocator](1)
		ax[:yaxis][:set_major_locator]=matplotlib[:ticker][:MultipleLocator](1)
	end
end
fig[:canvas][:draw]()
~~~~~~~~~~~~~~

-----------------------

# Splines: Linear Spline Plot

<div class="center" style="width: auto; margin-left: auto; margin-right: auto;">![Spline Basis of degree 1](figs/linear-bspline.png) </div>

-----------------------

# Linear B-Spline: Evaluation

* In order to evaluate the linear interpolator, we need to know only one thing: Which knot span is active, i.e. what is $j$ s.t. $x\in [z_j, z_{j+1}]$?
* This is a classic problem in computer science. Binary search.
* `julia` implements [`searchsortedlast`](http://docs.julialang.org/en/release-0.4/stdlib/sort/#Base.searchsortedlast).	
* Once we know $j$, it's easy to get the interpolated value as
	$$ \hat{f}(x) = \frac{x-z_j}{h}  f(z_{j+1}) + \frac{z_{j+1}-x}{h}  f(z_{j}) $$



-----------------------


# The Importance of Knot Placement

* We just talked about *equally spaced knots*. This is just a special case.
* B-Splines give us the flexibility to place the knots where we want.
* Contrary to Polynomial interpolations (where we cannot choose the evaluation nodes), this is very helpful in cases where we know that a function is very curved in a particular region.
* Canonical Example: Runge's function: $f(x) = (1+25x^2)^{-1}$.
* Also: If you know that your function has a kink (i.e. a discontinuous first derivative) at $\hat{x}$, then you can stack breakpoints on top of each other *at* $\hat{x}$

-----------------------

# B-Spline Approximation with [`Interpolations.jl`](https://github.com/tlycken/Interpolations.jl)

* Let's go the readme page and give it a look!

-----------------------

# The CompEcon Toolbox of Miranda and Fackler

* [CompEcon.jl](https://github.com/spencerlyon2/CompEcon.jl)


-----------------------

# Mulitidimensional Approximation

* Up to now, everything we did was in one dimesion.
* Economic problems *often* have more dimension than that.
	* The number of state variables in your value functions are the number of dimensions.
* We can readily extend what we learned into more dimensions.
* However, we will quickly run into feasibility problems: hello *curse of dimensionality*.


------------------------

# Tensor Product of univariate Basis Functions: Product Rule

* One possibility is to approximate e.g. the 2D function $f(x,y)$ by
	$$ \hat{f}(x,y) = \sum_{i=1}^n \sum_{j=1}^m c_{i,j} \phi_i^x(x) \phi_j^y(y)  $$
	* here $\phi_i^x$ is the basis function in $x$ space, 
	* you can see that the coefficient vector $c_{i,j}$ is indexed in two dimensions now.
	* Notice that our initial notation was general enough to encompass this case, as we defined the basis functions as $\mathbb{R}^d \mapsto \mathbb{R}$. So with the product rule, this mapping is just given by $\phi_i^x(x) \phi_j^y(y)$.
* This formulation requires that we take the product of $\phi_i^x(x), \phi_j^y(y)$ at *all* combinations of their indices, as is clear from the summations.
* This is equivalent to the tensor product between $\phi_i^x$ and $\phi_j^y$.

## Computing Coefficients from Tensor Product Spaces {#compute-c}

* Extending this into $D$ dimensions, where in each dim $i$ we have $n_i$ basis functions, we get
	$$ \hat{f}(x_1,x_2,\dots,x_D) = \sum_{i_1=1}^{n_1} \sum_{i_2=1}^{n_2} \dots  \sum_{i_D=1}^{n_D} c_{i_1,i_2,\dots,i_D} \phi_{i_1}(x_1) \phi_{i_2}(x_2) \dots \phi_{i_D}(x_D)  $$ 
* In Vector notation
	$$ 
	\hat{f}(x_1,x_2,\dots,x_D) =  \left[ \phi_{D}(x_D) \otimes \phi_{D-1}(x_{D-1})  \otimes \dots  \otimes  \phi_{1}(x_1) \right]  c $$
	where $c$ is is an $n=\Pi_{i=1}^D n_i$ column vector
* The solution is the interpolation equation as before,
	$$ \begin{align}\Phi c =& y \\
					\Phi   =& \Phi_D \otimes \Phi_{D-1} \otimes \dots \otimes \Phi_{1} \end{align} $$

------------------------

# The Problem with Tensor Product of univariate Basis Functions

* What's the problem?
* Well, solving $\Phi c = y$ is hard. 
* If we have as many evaluation points as basis functions in each dimension, i.e. if each single $\Phi_i$ is a square matrix, $\Phi$ is of size (n,n). 
* Inverting this is *extremely* hard even for moderately sized problems.
* Sometimes it's not even possible to allocate $\Phi$ in memory.
* Here it's important to remember the sparsity structure of a spline basis function.

~~~~~~~~~~~~~~ {.julia}
using PyPlot
fig = figure()
ax = axes()
ax[:imshow](B)  # B was the BSpline basis from before
ax[:set_aspect]("auto")
fig[:canvas][:draw]()
~~~~~~~~~~~~~~~~~~


------------------------

# Sparseness of B-Spline Basis

<div class="center" style="width: auto; margin-left: auto; margin-right: auto;">![BSpline basis functions are sparse. ](figs/spline-basis-sparse.png) </div>

* Blue is zero.
* the y axis lists 500 equispaced points in [0,1]
* the x axis shows the value of all basis functions
	* i.e. each row is all basis functions evaluated at $x_i$
* This is a cubic spline basis. at most $k+1=3$ basis are non-zero for any $x$.


------------------------

# Using Sparsity of Splines

* It may be better to store the splines in sparse format.
* Look at object `B` by typing `B` and `typeof(B)`
* There are sparse system solvers available.
* Creating and storing the inverse of $\Phi$ destroys the sparsity structure (inverse of a sparse matrix is not sparse), and may not be a good idea.
* Look back at [Computing coefficients form the tensor product](#compute-c)
* We only have to sum over the non-zero entries! Every other operation is pure cost.
* This is implemented in `ApproXD.jl` for example via
	
	```julia
    function evalTensor2{T}(mat1::SparseMatrixCSC{T,Int64},
                            mat2::SparseMatrixCSC{T,Int64},
                            c::Vector{T})
    ```

-----------------------

# High Dimensional Functions: Introducing the Smolyak Grid

* This is a modification of the Tensor product rule. 
* It elemininates points from the full tensor product according to their *importance* for the quality of approximation.
* The user controls this quality parameter, thereby increasing/decreasing the size of the grid.
* [@jmmv] is a complete technical reference for this method.
* [@maliar-maliar] chapter 4 is very good overview of this topic, and the basis of this part of the lecture.

--------------------

# The Smolyak Grid in 2 Dimensions

* Approximation level $\mu \in \mathbb{N}$ governs the quality of the approximation.
* Start with a unidimensional grid of points $x$:
	$$ x = \left\{-1,\frac{-1}{\sqrt{2}},0,\frac{1}{\sqrt{2}},1\right\} $$
	which are 5 Chebyshev nodes (it's not important that those are Chebyshev nodes, any grid will work).
* A 2D tensor product $x\otimes x$ gives 25 grid points
	$$ x\otimes x=\left\{(-1,-1),(-1,\frac{-1}{\sqrt{2}}),\dots,(1,1)\right\} $$
* The Smolyak method proceeds differently.
* We construct three nested sets:
	$$ \begin{array}{l}
		i=1 : S_1 = \{0\} \\
		i=2 : S_2 = \{0,-1,1\} \\
		i=3 : S_3 = \left\{-1,\frac{-1}{\sqrt{2}},0,\frac{1}{\sqrt{2}},1\right\}  \end{array} $$
* Then, we construct all possible 2D tensor products using elements from these nested sets in a table (next slide).
* Finally, we select only those elements of the table, that satisfy the Smolyak rule:
	$$ i_1 + i_2 \leq d + \mu $$
	where $i_1,i_2$ are column and row index, respectively, and $d,\mu$ are the number of dimensions and the quality of approximation.

--------------------

# The Smolyak Grid in 2D: Tensor Table

![[@maliar-maliar] table 3: All Tensor Products](figs/smolyak-tensortab.png)

## Selecting Elements

* Denote the Smolyak grid for $d$ dimensions at level $\mu$ by $\mathcal{H}^{d,\mu}$.
* if $\mu=0$ we have $i_1+i_2\leq 2$. Only one point satisfies this, and 
	$$ \mathcal{H}^{2,0} = \{(0,0)\} $$
* if $\mu=1$ we have $i_1+i_2\leq 3$. Three cases satisfy this:
	1. $i_1 = 1, i_2=1 \rightarrow (0,0)$
	1. $i_1 = 1, i_2=2 \rightarrow (0,0),(0,-1),(0,1)$
	1. $i_1 = 2, i_2=1 \rightarrow (0,0),(-1,0),(1,0)$
	* Therefore, the unique elements from the union of all of those is
		$$ \mathcal{H}^{2,1} = \{(0,0),(-1,0),(1,0),(0,-1),(0,1)\} $$
* if $\mu=2$ we have $i_1+i_2\leq 4$. Six cases satisfy this:
	1. $i_1 = 1, i_2=1$
	1. $i_1 = 1, i_2=2$
	1. $i_1 = 2, i_2=1$
	1. $i_1 = 1, i_2=3$
	1. $i_1 = 2, i_2=2$
	1. $i_1 = 3, i_2=1$
	* Therefore, the unique elements from the union of all of those is
		$$ \mathcal{H}^{2,2} = \left\{(-1,1),(0,1),(1,1),(-1,0),(0,0),(1,0),(-1,-1),(0,-1),(1,-1),\left(\frac{-1}{\sqrt{2}},0\right),\left(\frac{1}{\sqrt{2}},0\right),\left(0,\frac{-1}{\sqrt{2}}\right),\left(0,\frac{1}{\sqrt{2}}\right)\right\} $$
* Note that those elements are on the diagonal from top left to bottom right expanding through all the tensor products on table 3.

------------------------

# Size of Smolyak Grids

* The Smolyak grid grows much slower (at order $d$ to a power of $\mu$) than the Tensor grid (exponential growth)

![[@maliar-maliar] figure 2: Tensor vs Smolyak in 2D](figs/smolyak-vs-tensor.png)

![[@maliar-maliar] figure 4: Tensor vs Smolyak in 2D, number of grid points](figs/smolyak-tensor-points.png)

------------------------

# Smolyak Polynomials

* Corresponding to the construction of grid points, there is the Smolyak way of constructing polynomials.
* This works exactly as before. We start with a one-dimensional set of basis functions (again Chebyshev here, again irrelevant):
	$$ \left\{1,x,2x^2-1,4x^3-3x,8x^4-8x^2+1\right\} $$
* Three nested sets:
	$$ \begin{array}{l}
		i=1 : S_1 = \{1\} \\
		i=2 : S_2 = \{1,x,2x^2-1\} \\
		i=3 : S_3 = \left\{1,x,2x^2-1,4x^3-3x,8x^4-8x^2+1\right\}  \end{array} $$
* Denoting $\mathcal{P}^{d,\mu}$ the Smolyak polynomial, we follow exactly the same steps as for the grids to select elements of the full tensor product table 5:


![[@maliar-maliar] figure 5: All Smolyak Polynomials in 2D](figs/smolyak-polynomial.png)


------------------------

# Smolyak Interpolation

This proceeds as in the previouses cases:

1. Evaluate $f$ at all grid points $\mathcal{H}^{d,\mu}$.
1. Evaluate the set of basis functions given by $\mathcal{P}^{d,\mu}$f$ at all grid points $\mathcal{H}^{d,\mu}$.
1. Solve for the interpolating coefficients by inverting the Basis function matrix.

## Extensions

* There is a lot of redundancy in computing the grids the way we did it.
* More sophisticated approaches take care not to compute repeated elements.





--------------

# Smolyak Grids in Julia

* There are at least 2 julia packages that implement this idea:
	* [https://github.com/EconForge/Smolyak](https://github.com/EconForge/Smolyak)
	* [https://github.com/alancrawford/Smolyak](https://github.com/alancrawford/Smolyak)



---------------

# Using `alancrawford/Smolyak`

From the unit tests of that package:

```julia
	Pkg.clone("https://github.com/alancrawford/Smolyak.git")

	# here is the true function
	# in a real world application, evaluating this is the biggest cost
	# we would like to evaluate only a few times.

	slopes = rand(4)	
	truefun(x) = 1.1 + slopes[1]*x[1] - slopes[2]*x[2]^2 + (slopes[3]*x[3])^3 * slopes[4] * x[4]

	# choose approx level in each dim
	mu = [1,2,2,1]
	D = length(mu)
	lb = -2*ones(length(mu))
	ub = 12*ones(length(mu))
	sg = SmolyakGrid(mu,lb,ub)
	sb = SmolyakBasis(sg)
	makeBasis!(sb)
	sp = SmolyakPoly(sb)

	for i in 1:sb.NumPts
		sp.Value[i] = truefun(sg.xGrid[i]) 	# Assign true fvals to poly
	end
	make_pinvBFt!(sp,sb)		
	Smolyak.MakeCoef!(sp) 		

	# make basis on random point
	NumObs = 50
	X = Vector{Float64}[ Float64[lb[d]+( ub[d]- lb[d])*rand() for d in 1:D] for i in 1:NumObs]
	sbX = SmolyakBasis(X,mu,lb,ub,0,0)
	makeBasis!(sbX)
	spX = SmolyakPoly(sbX)
	copy!(spX.Coef,sp.Coef)   # assign precomputed coefs
	ynew = makeValue!(spX,sbX) # Interpolated Values
	valsnew = [truefun(i) for i in X]
	using PyPlot
	scatter(ynew,valsnew)
	ylabel("truth")
	xlabel("approx")
	grid()

```

-----------------------

## Bibliography

* [@fackler-miranda] is the main reference for this lecture. 
* [@judd-book] is the classic reference. A bit more difficult.
* [@jesus-computing] gives an overview over computing languages widely used in Economics.

-----------------


# References
