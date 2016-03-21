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
	where \beta<1 is a discount factor, $s_{t}$ is the state, $c_{t}$ is the control.

* The state (vector) evolves as $s_{t+1}=h(s_{t},c_{t})$.
* All past decisions are contained in $s_{t}$.

## Assumptions

* Let $c_{t}\in C(s_{t}),s_{t}\in S$ and assume $u$ is bounded in $(c,s)\in C\times S$.
* Stationarity: neither payoff $u$ nor transition $h$ depend on time.
* Write the problem as 
	$$ v(s)=\max_{s'\in\Gamma(s)}u(s,s')+\beta v(s') $$
* $\Gamma(s)$ is the constraint set (or feasible set) for $s'$ when the current state is $s$


# References

* The Integration part of these slides are based on [@maliar-maliar] chapter 5





