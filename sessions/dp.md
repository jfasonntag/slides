% Computational Economics: Numerical Dynamic Programming
% Florian Oswald
% Sciences Po, 2016


# Intro

* Numerical Dynamic Programming (DP) is widely used to solve dynamic models.
* You are familiar with the technique from your core macro course.
* We will illustrate some ways to solve dynamic programs.
	1. Models with one continuous choice variable
	1. Models with a discrete-continuous choice combination
* We will go through
	1. Value Function Iteration (VFI)
	1. Endogenous Grid Method (EGM)
	1. Discrete Choice Endogenous Grid Method (DCEGM)

----------------

# Dynamic Programming

* Payoffs over time are 
	$$U=\sum_{t=1}^{\infty}\beta^{t}u\left(s_{t},c_{t}\right) $$
	where $\beta<1$ is a discount factor, $s_{t}$ is the state, $c_{t}$ is the control.

* The state (vector) evolves as $s_{t+1}=h(s_{t},c_{t})$.
* All past decisions are contained in $s_{t}$.

## Assumptions

* Let $c_{t}\in C(s_{t}),s_{t}\in S$ and assume $u$ is bounded in $(c,s)\in C\times S$.
* Stationarity: neither payoff $u$ nor transition $h$ depend on time.
* Write the problem as 
	$$ v(s)=\max_{s'\in\Gamma(s)}u(s,s')+\beta v(s') $$
* $\Gamma(s)$ is the constraint set (or feasible set) for $s'$ when the current state is $s$

## Existence

**Theorem.** Assume that $u(s,s')$ is real-valued, continuous, and bounded, that $\beta\in(0,1)$, and that the constraint set $\Gamma(s)$ is nonempty, compact, and continuous. Then there exists a unique function $v(s)$ that solves the above functional equation.

**Proof.** [@stokeylucas] theoreom 4.6.


----------------

# Value Function Iteration (VFI)

* Find the fix point of the functional equation by iterating on it until the distance between consecutive iterations becomes small.
* Motivated by the Bellman Operator, and it's characterization in the Continuous Mapping Theorem.

## Discrete DP VFI

* Represents and solves the functional problem in $\mathbb{R}$ on a finite set of grid points only.
* Widely used method.
	* Simple (+)
	* Robust (+)
	* Slow (-)
	* Imprecise (-)
* Precision depends on number of discretization points used. 
* High-dimensional problems are difficult to tackle with this method because of the curse of dimensionality.

----------------


# Deterministic growth model with Discrete VFI

* We have this theoretical model:

$$ \begin{align}
   V(k) &= \max_{0<k'<f(k)} \ln(f(k) - k') + \beta V(k')\\
     f(k)  & = k^\alpha\\
     k_0   & \text{given} 
     \end{align}
$$

* and we employ the followign numerical approximation:
	$$ V(k_i) = \max_{i'=1,2,\dots,n} \ln(f(k_i) - k_{i'}) + \beta V(i') $$

* The iteration is then on successive iterates of $V$: The LHS gets updated in each iteration!
	$$ \begin{align}
	V^{r+1}(k_i) &= \max_{i'=1,2,\dots,n} \ln(f(k_i) - k_{i'}) + \beta V^{r}(i') \\
	V^{r+2}(k_i) &= \max_{i'=1,2,\dots,n} \ln(f(k_i) - k_{i'}) + \beta V^{r+1}(i') \\
	... & 
	\end{align}
	$$

* And it stops at iteration $r$ if $d(V^{r},V^{r-1}) < \text{tol}$
* You choose a measure of *distance*, $d(\cdot,\cdot)$, and a level of tolerance.
* $V^{r}$ is usually an *array*. So $d$ will be some kind of *norm*.
* maximal absolute distance
* mean squared distance


----------------

# Exercise 1: Implement discrete VFI

## Checklist

1. Set parameter values
1. define a grid for state variable $k \in [0,2]$
1. initialize value function $V$
1. start iteration, repeatedly computing a new version of $V$.
1. stop if $d(V^{r},V^{r-1}) < \text{tol}$.
1. plot value and policy function 
1. report the maximum error of both wrt to analytic solution

~~~~~~~~~~~~~{.julia}
alpha     = 0.65
beta      = 0.95
grid_max  = 2  # upper bound of capital grid
n         = 150  # number of grid points
N_iter    = 3000  # number of iterations
kgrid     = 1e-6:(grid_max-1e-6)/(n-1):grid_max  # equispaced grid
f(x) = x^alpha  # defines the production function f(k)
tol = 1e-9
~~~~~~~~~~~~~

## Analytic Solution

In the above case, the problem has a closed form solution:

~~~~~~~~~~~~~{.julia}
ab        = alpha * beta
c1        = (log(1 - ab) + log(ab) * ab / (1 - ab)) / (1 - beta)
c2        = alpha / (1 - ab)
v_star(k) = c1 .+ c2 .* log(k)	
p_star(k) = ab * k.^alpha	
~~~~~~~~~~~~~


----------------

# Exercise 1: Implement discrete VFI


~~~~~~~~~~~~~{.julia}
# Bellman Operator
# inputs
# `grid`: grid of values of state variable
# `v0`: current guess of value function

# output
# `v1`: next guess of value function
# `pol`: corresponding policy function 

#takes a grid of state variables and computes the next iterate of the value function.
function bellman_operator(grid,v0)
    
    v1  = zeros(n)     # next guess
    pol = zeros(Int,n)     # policy function
    w   = zeros(n)   # temporary vector 

    # loop over current states
    # current capital
    for (i,k) in enumerate(grid)

        # loop over all possible kprime choices
        for (iprime,kprime) in enumerate(grid)
            if f(k) - kprime < 0   #check for negative consumption
                w[iprime] = -Inf
            else
                w[iprime] = log(f(k) - kprime) + beta * v0[iprime]
            end
        end
        # find maximal choice
        v1[i], pol[i] = findmax(w)     # stores Value und policy (index of optimal choice)
    end
    return (v1,pol)   # return both value and policy function
end



# VFI iterator
#
## input
# `n`: number of grid points
# output
# `v_next`: tuple with value and policy functions after `n` iterations.
function VFI()
    v_init = zeros(n)     # initial guess
    for iter in 1:N_iter
        v_next = bellman_operator(kgrid,v_init)  # returns a tuple: (v1,pol)
        # check convergence
        if maxabs(v_init.-v_next[1]) < tol
            println("Found solution after $iter iterations")
            return v_next
        elseif iter==N_iter
            warn("No solution found after $iter iterations")
            return v_next
        end
        v_init = v_next[1]  # update guess 
    end
end

# plot
function plotVFI()
    v = VFI()
    figure("discrete VFI",figsize=(10,5))
    subplot(131)
    plot(kgrid,v[1],color="blue")
    plot(kgrid,v_star(kgrid),color="black")
    xlim(-0.1,grid_max)
    ylim(-50,-30)
    xlabel("k")
    ylabel("value")
    title("value function")

    subplot(132)
    plot(kgrid,kgrid[v[2]])
    plot(kgrid,p_star(kgrid),color="black")
    xlabel("k")
    title("policy function")

    subplot(133)
    plot(kgrid,kgrid[v[2]])
    plot(kgrid,p_star(kgrid),color="black")
    xlabel("k")
    xlim(0.8,1.2)
    ylim(0.5,0.75)
    title("policy function zoom")
end

~~~~~~~~~~~~~~~


--------------

# Exercise 2: Discretizing only the state space (not control space)

* Same exercise, but now use a continuous solver for choice of $k'$.
* in other words, employ the following numerical approximation:
	$$ V(k_i) = \max_{k'\in[0,\bar{k}]} \ln(f(k_i) - k') + \beta V(k') $$
* To do this, you need to be able to evaluate $V(k')$ where $k'$ is potentially off the `kgrid`.
* use `Interpolations.jl` to linearly interpolate V.
    * the relevant object is setup with function `interpolate((grid,),v,Gridded(Linear()))`
* use `Optim::optimize()` to perform the maximization.
    * you have to define an ojbective function for each $k_i$
    * do something like `optimize(objective, lb,ub)` 


--------------

# Exercise 2: Discretizing only the state space (not control space)


~~~~~~~~~~~~~{.julia}
function bellman_operator2(grid,v0)
    
    v1  = zeros(n)     # next guess
    pol = zeros(n)     # consumption policy function

    Interp = interpolate((collect(grid),), v0, Gridded(Linear()) ) 

    # loop over current states
    # of current capital
    for (i,k) in enumerate(grid)

        objective(c) = - (log(c) + beta * Interp[f(k) - c])
        # find max of ojbective between [0,k^alpha]
        res = optimize(objective, 1e-6, f(k)) 
        pol[i] = f(k) - res.minimum
        v1[i] = -res.f_minimum
    end
    return (v1,pol)   # return both value and policy function
end

function VFI2()
    v_init = zeros(n)     # initial guess
    for iter in 1:N_iter
        v_next = bellman_operator2(kgrid,v_init)  # returns a tuple: (v1,pol)
        # check convergence
        if maxabs(v_init.-v_next[1]) < tol
            verrors = maxabs(v_next[1].-v_star(kgrid))
            perrors = maxabs(v_next[2].-p_star(kgrid))
            println("Found solution after $iter iterations")
            println("value function error = $verrors")
            println("policy function error = $perrors")
            return v_next
        elseif iter==N_iter
            warn("No solution found after $iter iterations")
            return v_next
        end
        v_init = v_next[1]  # update guess 
    end
end

function plotVFI2()
    v = VFI2()
    figure("discrete VFI - continuous control",figsize=(10,5))
    subplot(131)
    plot(kgrid,v[1],color="blue")
    plot(kgrid,v_star(kgrid),color="black")
    xlim(-0.1,grid_max)
    ylim(-50,-30)
    xlabel("k")
    ylabel("value")
    title("value function")

    subplot(132)
    plot(kgrid,v[2])
    plot(kgrid,p_star(kgrid),color="black")
    xlabel("k")
    title("policy function")

    subplot(133)
    plot(kgrid,v[2].-p_star(kgrid))
    xlabel("k")
    title("policy function error")
    println("policy=$(v[2])")
end

~~~~~~~~~~~~~



--------------

# Endogenous Grid Method (EGM)

* Fast, elegant and precise method to solve consumption/savings problems
* One continuous state variable
* One continuous control variable
    $$ V(M_t) = \max_{0<c<M_t} u(c) + \beta E V_{t+1}(R (M_t - c) + y_{t+1}) $$
* Here, $M_t$ is cash in hand, all available resources at the start of period $t$
    * For example, assets plus income.
* $A_t = M_t - c_t$ is end of period assets
* $y_{t+1}$ is stochastic next period income.
* $R$ is the gross return on savings, i.e. $R=1+r$.
* utility function can be of many forms, we only require twice differentiable and concave.

## EGM after [@carroll2006method]

* [@carroll2006method] introduced this method.
* The idea is as follows:
    * Instead of using non-linear root finding for optimal $c$ (see above)
    * fix a grid of possible end-of-period asset levels $A_t$
    * use structure of model to find implied beginning of period cash in hand.
    * We use euler equation and envelope condition to connect $M_{t+1}$ with $c_t$


--------------

# Recall Traditional Methods: VFI and Euler Equation 

* Just to be clear, let us repeat what we did in the beginning of this lecture, using the $M_t$ notation.
    $$ \begin{align}
    V(M_t) &= \max_{0<c<M_t} u(c) + \beta E V_{t+1}(R (M_t - c) + y_{t+1}) \\
    M_{t+1} &= R (M_t - c) + y_{t+1} \end{align}
    $$

## VFI

1. Define a grid over $M_t$.
2. In the final period, compute
    $$ V_T(M_T) = \max_{0<c<M_t} u(c) $$
3. In all preceding periods $t$, do
    $$ V_t(M_t) =  \max_{0<c_t<M_t} u(c_t) + \beta E V_{t+1}(R (M_t - c_t) + y_{t+1}) $$
4. where optimal consumption is
    $$ c_t^*(M_t) = \arg \max_{0<c_t<M_t} u(c_t) + \beta E V_{t+1}(R (M_t - c_t) + y_{t+1}) $$

## Euler Equation

* The first order condition of the Bellman Equation is
    $$ 
    \begin{align}
    \frac{\partial V_t}{\partial c_t} & = 0 \\
    u'(c_t) & = \beta E \left[\frac{\partial V_{t+1} (M_{t+1}) }{\partial M_{t+1}} \right] \quad (FOC)
    \end{align}
    $$
* By the Envelope Theorem, we have that
    $$ 
    \begin{align}
    \frac{\partial V_t}{\partial M_t} & = \beta E \left[\frac{\partial V_{t+1} (M_{t+1}) }{\partial M_{t+1}} \right] \\
    \text{by FOC} &  \\
    \frac{\partial V_t}{\partial M_t} & = u'(c_t) \\
    \text{true in every period:} & \\
    \frac{\partial V_{t+1}}{\partial M_{t+1}} & = u'(c_{t+1}) 
    \end{align}
    $$
* Summing up, we get the Euler Equation:
    $$ u'(c_t) = \beta E \left[u'(c_{t+1}) R \right] $$

### Euler Equation Algorithm

1. Fix grid over $M_t$
1. In the final period, compute
    $$ c_T^*(M_T) = \arg\max_{0<cT<M_t} u(c_T) $$
1. With optimal $c_{t+1}^*(M_{t+1})$ in hand, backward recurse to find $c_t$ from
    $$ u'(c_t) = \beta E \left[u'(c_{t+1}^*(R (M_t - c_t) + y_{t+1}) ) R \right] $$
1. Notice that if $M_t$ is small, the euler equation does not hold.
    * In fact, the euler equation would prescribe to *borrow*, i.e. set $M_t <0$. This is ruled out.
    * So, one needs to tweak this algorithm to check for this possibility
1. Homework.

--------------


# The EGM Algorithm

Starts in period $T$ with $c_T^* = M_T$. For all preceding periods:

1. Fix a grid of *end-of-period* assets $A_t$
1. Compute all possible next period cash-in-hand holdings $M_{t+1}$
    $$ M_{t+1} = R * A_t + y_{t+1} $$
    * for example, if there are $n$ values in $A_t$ and $m$ values for $y_{t+1}$, we have $dim(M_{t+1}) = (n,m)$
1. Given that we know optimal policy in $t+1$, use it to get consumption at each $M_{t+1}$
    $$ c_{t+1}^* (M_{t+1}) $$
1. Invert the Euler Equation to get current consumption compliant with an expected level of cash-on-hand, given $A_t$
    $$ c_{t} = (u')^{-1} \left( \beta E \left[u'(c_{t+1}^*(M_{t+1}) ) R |A_t \right]  \right) $$
1. Current period *endogenous* cash on hand just obeys the accounting relation
    $$ M_t = c_t + A_t $$


--------------

# Issues with traditional methods

## Numerical optimization at each grid point

1. We spend a lot of effort in the nonlinear optimization part (i.e. the $\max$ of the problem)
1. This is not guaranteed to work well in non-convex problems
1. precision suffers close to a binding borrowing constraint.

## EGM: no numerical optimization.

1. we have no call to anything like `optim` anywhere.
1. Gets the binding borrowing constraint exactly right, no approximation error.
1. The **speed gain** is **mind-blowing**.



-------------

# Core of a simple implementation

1. Define a `type` model:

```julia
type iidModel <: Model

    # computation grids
    avec::Vector{Float64}
    yvec::Vector{Float64}   # income support
    ywgt::Vector{Float64}   # income weights

    # intermediate objects (na,ny)
    m1::Array{Float64,2}    # next period cash on hand (na,ny)
    c1::Array{Float64,2}    # next period consumption
    ev::Array{Float64,2}

    # result objects
    C::Array{Float64,2}     # consumption function on (na,nT)
    S::Array{Float64,2}     # savings function on (na,nT)
    M::Array{Float64,2}     # endogenous cash on hand on (na,nT)
    V::Array{Float64,2}     # value function on (na,nT). Optional.
    Vzero::Array{Float64,1} # value of saving zero
end
```

2. Function `EGM!`

```julia
function EGM!(m::iidModel,p::Param)

    # final period: consume everything.
    m.M[:,p.nT] = m.avec
    m.C[:,p.nT] = m.avec
    m.C[m.C[:,p.nT].<p.cfloor,p.nT] = p.cfloor

    # preceding periods
    for it in (p.nT-1):-1:1

        # interpolate optimal consumption from next period on all cash-on-hand states
        # using C[:,it+1] and M[:,it+1], find c(m,it)

        tmpx = [0.0; m.M[:,it+1] ] 
        tmpy = [0.0; m.C[:,it+1] ]
        for ia in 1:p.na
            for iy in 1:p.ny
                m.c1[ia+p.na*(iy-1)] = linearapprox(tmpx,tmpy,m.m1[ia+p.na*(iy-1)],1,p.na)
                # m.c1[ia,iy] = linearapprox(tmpx,tmpy,m.m1[ia,iy],1,p.na)  # equivalent
            end
        end

        # get expected marginal value of saving: RHS of euler equation
        # beta * R * E[ u'(c_{t+1}) ] 
        Eu = p.R * p.beta .* up(m.c1,p) * m.ywgt

        # get optimal consumption today from euler equation: invert marginal utility
        m.C[:,it] = iup(Eu,p)

        # floor consumption
        m.C[m.C[:,it].<p.cfloor,it] = p.cfloor

        # get endogenous grid today
        m.M[:,it] = m.C[:,it] .+ m.avec
    end
end
```





-------------

# Discrete Choice EGM

* This is a method developed by Fedor Iskhakov, Thomas Jorgensen, John Rust and Bertel Schjerning.
* Reference: [@iskhakovRust2014]
* Suppose we have several discrete choices (like "work/retire"), combined with a continuous choice in each case (like "how much to consume given work/retire").
* Let $d=0$ mean to retire.
* Write the problem of a worker as
    $$ \begin{align}
    V_t(M_t) & = \max \left[ v_t(M_t|d_t=0), v_t(M_t|d_t=1) \right] \\
     &  \text{with}\\
    v_t(M_t|d_t=0) & = \max_{0<c_t<M_t} u(c_t) + \beta E W_{t+1}(R (M_t - c_t)) \\
    v_t(M_t|d_t=1) & = \max_{0<c_t<M_t} u(c_t) -1 + \beta E V_{t+1}(R (M_t - c_t) + y_{t+1}) 
    \end{align}
    $$
* The problem of a retiree is
    $$
    W_t(M_t) = \max_{0<c_t<M_t} u(c_t) + \beta E W_{t+1}(R (M_t - c_t)) 
    $$
* Our task is to compute the optimal consumption functions $c_t^*(M_t|d_t=0)$, $c_t^*(M_t|d_t=1)$


----------------

# Problems with Discrete-Continuous Choice

* Even if all conditional value functions $v$ are concave, the *envelope* over them, $V$, is in general not.
* [@clausenenvelope] show that there will be a kink point $\bar{M}$ such that 
    $$ v_t(\bar{M}|d_t=0) = v_t(\bar{M}|d_t=1) $$
    * We call any such point a **primary kink** (because it refers to a discrete choice in the **current period**)
* $V$ is not differentiable at $\bar{M}$.
* However, it can be shown that both left and right derivatives exist, with
    $$ V^-(\bar{M}) < V^+(\bar{M}) $$
* Given that the value of the derivative changes discretely at $\bar{M_t}$, the value function in $t-1$ will exhibit a discontinuity as well:
    * $v_{t-1}$ depends on $V_t$.
    * Tracing out the optimal choice of $c_{t-1}$ implies next period cash on hand $M_t$, and as that hits $\bar{M_t}$, the derivative jumps.
    * The derivative of the value function determines optimal behaviour via the Euler Equation.
    * We call a discontinuity in $v_{t-1}$ arising from a kink in $V_t$ a **secondary kink**.
* The kinks propagate backwards. 
* [@iskhakovRust2014] provide an analytic example where one can compute the actual number of kinks in period 1 of T.
* Figure 1 in [@clausenenvelope]:


<img src="figs/clausen-struub.png" width="1200" height="500"/>

![[@iskhakovRust2014] figure 1](figs/fedor-1.png)


------------

# Kinks

* Refer back to the work/retirement model from before.
* 6 period implementation of the DC-EGM method:

![github/floswald](figs/Dchoice_condV.png)

* [Iskhakov @ cemmap 2015: Value functions in T-1](http://www.cemmap.ac.uk/event/id/1213)
<img src="figs/fedor-3.png" width="900" height="500"/>


* [Iskhakov @ cemmap 2015: Value functions in T-2](http://www.cemmap.ac.uk/event/id/1213)
<img src="figs/fedor-4.png" width="900" height="500"/>

* [Iskhakov @ cemmap 2015: Consumption function in T-2](http://www.cemmap.ac.uk/event/id/1213)
<img src="figs/fedor-5.png" width="900" height="500"/>

* Optimal consumption in 6 period model:
![github/floswald](figs/Dchoice_envC.png)

------------

# The Problem with Kinks

* Relying on fast methods that rely on first order conditions (like euler equation) will fail.
* There are multiple zeros in the Euler Equation, and a standard Euler Equation approach is not guaranteed to find the right one.
* picture from Fedor Iskhakov's master class at [cemmap 2015](http://www.cemmap.ac.uk/event/id/1213):

<img src="figs/fedor-2-cropped.png" width="1000" height="500"/>

----------------

# DC-EGM Algorithm

1. Do the EGM step for each discrete choice $d$
1. Compute $d$-specific consumption and value functions
1. compare $d$-specific value functions to find optimal switch points
1. Build envelope over $d$-specific consumption functions with knowledge of which optimal $d$ applies where.

## But EGM relies on the Euler Equation?!

* Yes.
* An important result in [@clausenenvelope] is that the Euler Equation is still the necessary condition for optimal consumption
    * Intuition: marginal utility differs greatly at $\epsilon+\bar{M}$. 
    * No economic agent would ever locate **at** $\bar{M}$.
* This is different from saying that a proceedure that tries to find the zeros of the Euler Equation would still work.
    * this will pick the wrong solution some times.
* EGM finds **all** solutions. 
    * There is a proceedure to discard the "wrong ones". Proof in [@iskhakovRust2014]



----------------

# Adding Shocks

* This problem is hard to solve with standard methods.
* It is hard, because the only reliable method is VFI, and this is not feasible in large problems.
* Adding shocks to non-smooth problems is a widely used remedy.
    * think of "convexifying" in game theoretic models
    * (Add a lottery)
    * Also used a lot in macro
* Adding shocks does indeed help in the current model.
    * We add idiosyncratic taste shocks: Type 1 EV.
    * Income uncertainty: 
    * In general, the more shocks, the more smoothing.
* The problem becomes
    $$ \begin{align}
    V_t(M_t) & = \max \left[ v_t(M_t|d_t=0) + \sigma_\epsilon \epsilon_t(0), v_t(M_t|d_t=1) + \sigma_\epsilon \epsilon_t(1)\right]  \\
    v_t(M_t|d_t=1) & = \max_{0<c_t<M_t} \log(c_t) -1 + \beta \int E V_{t+1}(R (M_t - c_t) + y\eta_{t+1})f(d\eta_{t+1}) 
    \end{align}
    $$
    where the value for retirees stays the same.



----------------

# Adding Shocks


![[@iskhakovRust2014] figure 2](figs/fedor-7.png)

![[@iskhakovRust2014] figure 4](figs/fedor-6.png)


![[@iskhakovRust2014] figure 4](figs/fedor-8.png)

----------------

# Full DC-EGM

* Needs to discard *false* solutions. 
* Criterion:    
    * grid in $A_t$ is **increasing**
    * Assuming concave utility function, the function
        $$ A(M|d) = M - c(M|d) $$
        is **monotone non-decreasing**
    * This means that, if you go through $A_i$, and find that
        $$ M_t(A^j) < M_t(A^{j-1}) $$
        you know you entered a non-concave region
* The Algorithm goes through the upper envelope and *prunes* the *inferior* points $M$ from the endogenous grids.
* Precise details of Algorithm in paper.
* Julia implementation on [floswald/ConsProb.jl](https://github.com/floswald/ConsProb.jl)


----------------


# References






