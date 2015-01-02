---
layout: post
category: ecology
tags:
  - earlywarning
---





some sample data


```r
library(sde)
library(nimble)
set.seed(123)
d <- expression(0.5 * (10-x))
s <- expression(1) 
data <- as.data.frame(sde.sim(X0=6,drift=d, sigma=s, T=20, N=100))
```

```
sigma.x not provided, attempting symbolic derivation.
```

```r
plot(data)
```

![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-1-1.svg) 



## LSN version ##

Test case: Set prior for `m` $\approx 0$:


```r
lsn <- modelCode({
   theta ~ dunif(1e-10, 100.0)
   sigma_x ~ dunif(1e-10, 100.0)
   sigma_y ~ dunif(1e-10, 100.0)
       m ~ dunif(-1e2, 1e2)
    x[1] ~ dunif(0, 100)
    y[1] ~ dunif(0, 100) 

  for(i in 1:(N-1)){
    mu_x[i] <- x[i] + y[i] * (theta - x[i]) 
    x[i+1] ~ dnorm(mu_x[i], sd = sigma_x) 
    mu_y[i] <- y[i] + m * t[i]
    y[i+1] ~ dnorm(mu_y[i], sd = sigma_y) 
  }
})
```

Constants in the model definition are the length of the dataset, $N$ and the time points of the sample. Note we've made time explicit, we'll assume uniform spacing here. 


```r
constants <- list(N = length(data$x), t = 1:length(data$x))
```

Initial values for the parameters


```r
inits <- list(theta = 6, m = 0, sigma_x = 1, sigma_y = 1, y = rep(1,constants$N))
```


and here we go as before:


```r
Rmodel <- nimbleModel(code = lsn, 
                      constants = constants, 
                      data = data, 
                      inits = inits)
Cmodel <- compileNimble(Rmodel)
```




```r
mcmcspec <- MCMCspec(Rmodel, print=TRUE,thin=1e2)
```

```
[1] RW sampler;   targetNode: theta,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
[2] RW sampler;   targetNode: sigma_x,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
[3] RW sampler;   targetNode: sigma_y,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
[4] RW sampler;   targetNode: m,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
[5] RW sampler;   targetNode: y[1],  adaptive: TRUE,  adaptInterval: 200,  scale: 1
[6] conjugate_dnorm sampler;   targetNode: y[2],  dependents_dnorm: x[3], y[3]
...
```

```r
Rmcmc <- buildMCMC(mcmcspec)
Cmcmc <- compileNimble(Rmcmc, project = Cmodel)
```



```r
Cmcmc(1e4)
```

```
NULL
```


and examine results


```r
samples <- as.data.frame(as.matrix(nfVar(Cmcmc, 'mvSamples')))
dim(samples)
```

```
[1] 100 206
```

```r
samples <- samples[,1:4]
```



```r
mean(samples$theta)
```

```
[1] 10.11174
```

```r
mean(samples$m)
```

```
[1] -1.88765e-05
```

```r
mean(samples$sigma_x)
```

```
[1] 0.385018
```





```r
plot(samples[ , 'm'], type = 'l', xlab = 'iteration', ylab = 'm')
plot(samples[ , 'sigma_x'], type = 'l', xlab = 'iteration', ylab = expression(sigma[x]))
plot(samples[ , 'sigma_y'], type = 'l', xlab = 'iteration', ylab = expression(sigma[y]))
plot(samples[ , 'theta'], type = 'l', xlab = 'iteration', ylab = expression(theta))
```

![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-10-1.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-10-2.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-10-3.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-10-4.svg) 


```r
hist(samples[, 'm'], xlab = 'm')
hist(samples[, 'sigma_x'], xlab = expression(sigma[x]))
hist(samples[, 'sigma_y'], xlab = expression(sigma[y]))
hist(samples[, 'theta'], xlab = expression(theta))
```

![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-11-1.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-11-2.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-11-3.svg) ![](/2014/assets/figures/posts/2014-12-04-lsn-nimble/unnamed-chunk-11-4.svg) 

