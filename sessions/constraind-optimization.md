% Computational Economics: Constrained Optimization
% Florian Oswald
% Sciences Po, 2016

----------------

# Constrained Optimisation

* Recall our generic definition of an optimization problem:
	$$ \min_{x\in\mathbb{R}^n} f(x)  \quad  s.t.\quad \begin{array} c_i(x) = 0, & i\in E \\
                                                              c_i(x) \geq 0, & i\in I \end{array}
                                                              $$
* E is the set of *equality constraints* and I is the set of *inequality constraints*.
* **Defintion: The Feasible Set**: Let $\Omega$ be the set of points $x$ that satisfy the constraints, i.e.
	$$ \Omega = {x|c_i(x)=0,i\in E; c_i(x)\geq 0, i\in I} $$
* Then, a different way of writign our problem is
	$$ \min_{x\in \Omega} f(x)  $$
* A vector $x^*$ is a *local solution* to this problem if $x^* \in \Omega$ and there is a neighborhood $\mathcal{N}$ s.t. $f(x)\geq f(x^*),\forall x\in \mathcal{N} \cap \Omega$.
* **Definition: The Active Set**: Active set $\mathcal{A}(x)$ at any feasible $x$ consists of the equality constraint indices from E together with the indices of the inequality constraints for $i$ for which $c_i(x) = 0$; that is,
	$$ \matcal{A}(x) = E \cup {i\in I|c_i(x) = 0} $$
	At a feasible point $x$, the inequality constraint $i \in I$ is said to be *active* if $c_i(x)=0$, and *inactive* if $c_i(x)>0$

## Nonlinear Constraints

* Consider the following problem
	$$ \min_{x \in \mathbb{R}^2} \sqrt{x_2}\quad s.t. \quad \begin{array}{c}        \\
	                                                                                x_2 \geq 0 \\
	                                                                         x_2 \geq (a_1 x_1 + b_1)^3 \\
	                                                                         x_2 \geq (a_2 x_1 + b_2)^3 \end{array}
	$
* This configuration of constraints leads to the following feasible region for parameters $a_1=2,b_1=0,a_2=-1,b_2=1$.
<img src="figs/NLopt-example-constraints.png" width="800" height="600" />

----------------

# Example: 1 equality constraint

* consider 
	$$ \min x_1 + x_2  \quad s.t. \quad x_1^2 + x_2^2 - 2 = 0 $$
* constraint is a circle with radius $\sqrt{2}$ centered at 0. The solution must lie *on* that circle.
* Solution: $(-1,-1)$. Consider any other point on circle, like $(\sqrt{2},0)$.

![Figure 12.3 in [@nocedal-wright]](figs-restricted/constrained-example.png) 

----------------

# Example: 1 inequality constraint

* Let's modify this example to
	$$ \min x_1 + x_2  \quad s.t. \quad 2- x_1^2 - x_2^2 \geq 0 $$
* constraint is the region inside a circle with radius $\sqrt{2}$ centered at 0. The solution must lie *on or inside* that circle.
* Solution: $(-1,-1)$. Consider any other point on circle, like $(\sqrt{2},0)$.
* Two cases: 
	1. $x$ lies strictly inside the circle, and $c_1(x) > 0$
	1. $x$ lies strictly on the circle, and $c_1(x) = 0$
* Complementarity condition.


--------------------

# First Order Optimality Conditions



--------------------

# Some Methods 

* Penalty Function and Augmented Lagrangian Methods
* Sequential Quadratic Method
* Interior Point Method


--------------------

# Penalty Function and Augmented Lagrangian Methods


--------------------

# First Order Optimality Conditions


----------------

# Constrained Optimisation with [`NLopt.jl`](https://github.com/JuliaOpt/NLopt.jl)

* We need to specify one function for each objective and constraint.
* Both of those functions need to compute the function value (i.e. objective or constraint) *and* it's respective gradient. 
* Notice that we can disregard $x_2\geq0$ here.
* `NLopt` expects contraints **always** to be formulated in the format 
	$$
	\texttt{constraint_function}(x) \leq 0 $$
* The constraint function is formulated for each constraint at $x$. it returns a number (the value of the constraint at $x$), and it fills out the gradient vector, which is the partial derivative of the current constraint wrt $x$.
* There is also the option to have vector valued constraints, see the documentation.
* We set this up as follows:

```julia
function myfunc(x::Vector, grad::Vector)
    if length(grad) > 0
        grad[1] = 0
        grad[2] = 0.5/sqrt(x[2])
    end
    return sqrt(x[2])
end

function constraint(x::Vector, grad::Vector, a, b)
    if length(grad) > 0
    	# modifies grad in place
        grad[1] = 3a * (a*x[1] + b)^2
        grad[2] = -1
    end
    return (a*x[1] + b)^3 - x[2]
end
using NLopt
# define an Opt object: which algorithm, how many dims of choice
opt = Opt(:LD_MMA, 2)
# set bounds and tolerance
lower_bounds!(opt, [-Inf, 0.])
xtol_rel!(opt,1e-4)

# define objective function
min_objective!(opt, myfunc)
# define constraints
# notice the anonymous function
inequality_constraint!(opt, (x,g) -> constraint(x,g,2,0), 1e-8)
inequality_constraint!(opt, (x,g) -> constraint(x,g,-1,1), 1e-8)

# call optimize
(minf,minx,ret) = optimize(opt, [1.234, 5.678])
```

---------------

# NLopt: Rosenbrock

* Let's tackle the rosenbrock example.
* To make it more interesting, let's add an inequality constraint.
	$$ \min_{x\in \mathbb{R}^2} (1-x_1)^2  + 100(x_2-x_1^2)^2  \quad s.t. \quad 0.8 - x_1^2 -x_2^2 \geq 0 $$
* in `NLopt` format, the constraint is $x_1 + x_2 - 0.8 \leq 0$

```julia
function rosenbrock(x::Vector,grad::Vector)
    if length(grad) > 0
	    grad[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
	    grad[2] = 200.0 * (x[2] - x[1]^2)
    end
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end
function r_constraint(x::Vector, grad::Vector)
    if length(grad) > 0
	grad[1] = 2*x[1]
	grad[2] = 2*x[2]
	end
	return x[1]^2 + x[2]^2 - 0.8
end
opt = Opt(:LD_MMA, 2)
lower_bounds!(opt, [-5, -5.0])
min_objective!(opt,(x,g) -> rosenbrock(x,g))
inequality_constraint!(opt, (x,g) -> r_constraint(x,g))
ftol_rel!(opt,1e-9)
(minf,minx,ret) = optimize(opt, [-1.0,0.0])
```


----------------

# JuMP

* Introduce [`JuMP.jl`](https://github.com/JuliaOpt/JuMP.jl)
* JuMP is a mathematical programming interface for Julia. It is like AMPL, but for free and with a decent programming language.
* The main highlights are:
	* It uses automatic differentiation to compute derivatives from your expression.
	* It supplies this information, as well as the sparsity structure of the Hessian to your preferred solver.
	* It decouples your problem completely from the type of solver you are using. This is great, since you don't have to worry about different solvers having different interfaces.
	* In order to achieve this, `JuMP` uses [`MathProgBase.jl`](https://github.com/JuliaOpt/MathProgBase.jl), which converts your problem formulation into a standard representation of an optimization problem.
* Let's look at the readme.


----------------

# JuMP: Example

* Instead of hand-coding first and second derivatives, you only have to give `JuMP` expressions for objective and constraints.
* Here is an example.

```julia
using JuMP

let

    m = Model()

    @defVar(m, x)
    @defVar(m, y)

    @setNLObjective(m, Min, (1-x)^2 + 100(y-x^2)^2)

    solve(m)

    println("x = ", getValue(x), " y = ", getValue(y))

end
```

* not bad, right?
* adding the constraint from before:

```julia
let

    m = Model()

    @defVar(m, x)
    @defVar(m, y)

    @setNLObjective(m, Min, (1-x)^2 + 100(y-x^2)^2)
    @addNLConstraint(m,x^2 + y^2 <= 0.8)

    solve(m)

    println("x = ", getValue(x), " y = ", getValue(y))

end
```
\Gamma	 = 0

# JuMP: Maximium Likelihood

* Let's redo the maximum likelihood example in JuMP.
* Let $\mu,\sigma^2$ be the unknown mean and variance of a random sample generated from the normal distribution.
* Find the maximum likelihood estimator for those parameters!
* density:
	$$ f(x_i|\mu,\sigma^2) = \frac{1}{\sigma \sqrt{2\pi}} \exp\left(-\frac{(x_i - \mu)^2}{2\sigma^2}\right) $$
* Likelihood Function
	$$ \begin{align} L(\mu,\sigma^2) = \Pi_{i=1}^N f(x_i|\mu,\sigma^2) =& \frac{1}{(\sigma \sqrt{2\pi})^n} \exp\left(-\frac{1}{2\sigma^2} \sum_{i=1}^N (x_i-\mu)^2 \right) \\
	 =& \left(\sigma^2 2\pi\right)^{-\frac{n}{2}} \exp\left(-\frac{1}{2\sigma^2} \sum_{i=1}^N (x_i-\mu)^2 \right) \end{align} $$
* Constraints: $\mu\in \mathbb{R},\sigma>0$
* log-likelihood: 
	$$ \log L = l = -\frac{n}{2} \log \left( 2\pi \sigma^2 \right) - \frac{1}{2\sigma^2} \sum_{i=1}^N (x_i-\mu)^2 $$
* Let's do this in `JuMP`.

. . .

```julia
#  Copyright 2015, Iain Dunning, Joey Huchette, Miles Lubin, and contributors
#  example modified 
using JuMP
using Distributions

distrib = Normal(4.5,3.5)
n = 10000

data = rand(distrib,n);

m = Model()

@defVar(m, mu, start = 0.0)
@defVar(m, sigma >= 0.0, start = 1.0)

@setNLObjective(m, Max, -(n/2)*log(2π*sigma^2)-sum{(data[i]-mu)^2, i=1:n}/(2*sigma^2))

solve(m)
println("μ = ", getValue(mu),", mean(data) = ", mean(data))
println("σ^2 = ", getValue(sigma)^2, ", var(data) = ", var(data))
```


---------------------

# References