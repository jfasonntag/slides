



# unconstrained optimization

## maximum likelihood: probit

### show gradient

module maxlike

	using Optim
	using Distributions, PyPlot

	### create data
	function makeData(n)
		beta = [ 1; 1.5; -0.5 ]
		srand(3122015)
		numobs = n
		X = hcat(ones(numobs), randn(numobs,2))
		epsilon = randn(numobs)
		Y = X * beta + epsilon
		y = 1.0 * (Y .> 0)
		norm = Normal(0,1)	# create a normal distribution object with mean 0 and variance 1
		return (beta,numobs,X,y,norm)
	end


	# notice this depends only on the choice variables "betas"
	# X and y are in the enclosing scope, so visible from within this function
	function loglik(betas::Vector,X::Matrix,y::Vector,distrib::UnivariateDistribution) 
		xbeta     = X*betas	# (n,1)
		G_xbeta   = cdf(distrib,xbeta)	# (n,1)
		loglike   = y .* log(G_xbeta) .+ (1-y) .* log(1-G_xbeta)  # (n,1)
		objective = -mean(loglike)
		return objective
	end

	function grad(betas::Vector,st::Vector,X::Matrix,y::Vector,distrib::UnivariateDistribution) 
		xbeta     = X*betas	# (n,1)
		G_xbeta   = cdf(distrib,xbeta)	# (n,1)
		g_xbeta   = pdf(distrib,xbeta)	# (n,1)
		# println("G_xbeta = $G_xbeta")
		# println("g_xbeta = $g_xbeta")
		st[:]     = -mean((y .* g_xbeta ./ G_xbeta - (1-y) .* g_xbeta ./ (1-G_xbeta)) .* X,1)
	end

	function loglik_and_gradient(betas::Vector,st::Vector) 
		xbeta     = X*beta	# (n,1)
		G_xbeta   = cdf(distrib,xbeta)	# (n,1)
		st[:]     = -mean((y .* g_xbeta ./ G_xbeta - (1-y) .* g_xbeta ./ (1-G_xbeta)) .* X,1)
		loglike   = y .* log(G_xbeta) .+ (1-y) .* log(1-G_xbeta)  # (n,1)
		objective = -mean(loglike)
		return objective
	end


	function maximize_like(x0=[0.8,1.0,-0.1],meth=:nelder_mead)
		true_beta,numobs,X,y,norm = makeData(10000)
		res = optimize(arg->loglik(arg,X,y,norm),x0, method = meth, iterations = 100)
		return res
	end

	function maximize_like_grad(x0=[0.8,1.0,-0.1],meth=:bfgs)
		true_beta,numobs,X,y,norm = makeData(10000)
		storage = zeros(length(true_beta))
		res = optimize((arg)->loglik(arg,X,y,norm),(arg,storage)->grad(arg,storage,X,y,norm),x0, method = meth, iterations = 1000,grtol=1e-20,ftol=1e-20)
		return res
	end

	# function maximize_like_and_grad(x0=[0.8,1.0,-0.1],meth=:bfgs)
	# 	true_beta,numobs,X,y,norm = makeData(10000)
	# 	ff = DifferentiableFunction(loglik,grad,loglik_and_gradient)
	# 	storage = zeros(length(true_beta))
	# 	res = optimize(x->ff(x,storage,X,y,norm),x0, method = meth, iterations = 1000,grtol=1e-20,ftol=1e-20)
	# 	# res = optimize(ff,x0, method = meth, iterations = 1000,grtol=1e-20,ftol=1e-20)
	# 	return res
	# end


	function plotLike()
		true_beta,numobs,X,y,norm = makeData(10000)
		ngrid = 100
		pad = 1
		k = length(true_beta)
		beta0 = repmat(true_beta',ngrid,1)
		values = zeros(ngrid)
		fig,axes = subplots(1,k)
		currplot = 0
		for b in 1:k
			currplot += 1
			xaxis = collect(linspace(true_beta[b]-pad,true_beta[b]+pad,ngrid))
			betas = copy(beta0)
			betas[:,b] = xaxis
			for i in 1:ngrid
				values[i] = loglik(betas[i,:][:],X,y,norm)
			end
			ax = axes[currplot]
			ax[:plot](xaxis,values)
			ax[:set_title]("beta $currplot")
			ax[:axvline](x=true_beta[b],color="red")

		end
		fig[:canvas][:draw]()
	end

end

#v=[maxlike.loglik(x,X,y,norm) for x in [vcat(1.0,i,-0.5) for i in linspace(0,4,100)]]




