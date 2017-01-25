

module dp

	using PyPlot, Interpolations, Optim

	alpha     = 0.65
	beta      = 0.95
	grid_max  = 2  # upper bound of capital grid
	n         = 150  # number of grid points
	N_iter    = 3000  # number of iterations
	kgrid     = 1e-6:(grid_max-1e-6)/(n-1):grid_max  # equispaced grid
	f(x) = x^alpha  # defines the production function f(k)
	tol = 1e-9

	ab        = alpha * beta
	c1        = (log(1 - ab) + log(ab) * ab / (1 - ab)) / (1 - beta)
	c2        = alpha / (1 - ab)
	v_star(k) = c1 .+ c2 .* log(k)	
	p_star(k) = ab * k.^alpha	


	"""
	# Bellman Operator

	## inputs
	1. `grid`: grid of values of state variable
	2. `v0`: current guess of value function

	## output
	1. `v1`: next guess of value function
	2. `pol`: corresponding policy function 

	takes a grid of state variables and computes the next iterate of the value function.

	"""
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


	"""
	# VFI iterator

	## input
	* `n`: number of grid points

	## output
	* `v_next`: tuple with value and policy functions after `n` iterations.

	"""
	function VFI()
	    v_init = zeros(n)     # initial guess
	    for iter in 1:N_iter
	        v_next = bellman_operator(kgrid,v_init)  # returns a tuple: (v1,pol)
	        # check convergence
	        if maxabs(v_init.-v_next[1]) < tol
	            verrors = maxabs(v_next[1].-v_star(kgrid))
	            perrors = maxabs(kgrid[v_next[2]].-p_star(kgrid))
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

	# run

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
    	    # 6) save that in the result vector
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

	# run

	# plot
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

end


