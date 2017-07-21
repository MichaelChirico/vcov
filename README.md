# Faster Variance-Covariance Matrices and Standard Errors

If you've ever bootstrapped a model to get standard errors, you've had to compute standard errors from re-sampled models thousands of times.

In such situations, any wasted overhead can cost you time unnecessarily. Note, then, the standard method for extracting a variance-covariance matrix from a standard linear model, `stats:::vcov.lm`:

```
vcov.lm = function(obj, ...) {
  so <- summary.lm(object)
  so$sigma^2 * so$cov.unscaled
}
```

That is, `stats:::vcov.lm` first _summarizes_ your model, _then_ extracts the covariance matrix from this object. 

Unfortunately, `stats:::summary.lm` wastes precious time computing other summary statistics about your model that you may not care about.

Enter `vcov`, which cuts out the middle man, and simply gives you back the covariance matrix directly. Here's a timing comparison:

```
library(microbenchmark)
set.seed(1320840)
x = rnorm(1e6)
y = 3 + 4*x
reg = lm(y ~ x)

microbenchmark(times = 100,
               vcov = vcov:::Vcov.lm(reg),
               stats = stats:::vcov.lm(reg))
# Unit: milliseconds
#   expr      min       lq     mean   median       uq       max neval
#   vcov 12.45546 14.16308 18.80733 14.72963 15.17740  50.64684   100
#  stats 37.43096 44.62640 52.31549 45.59744 46.99589 251.90297   100
```

That's three times as fast, or about 30 milliseconds saved (on an admittedly dinky machine). That means about 30 seconds saved in a 1000-resample bootstrap -- this example alone spent 3 more seconds using the `stats` method, i.e., 75% of the run time was dedicated to `stats`. 

## Bonus: Accuracy

In returning a covariance matrix, by using the indirect approach taken in `stats`, numerical error is introduced unnecessarily. The formula for covariance of vanilla OLS is of course:

$$ \mathbb{V}[\hat{\beta}] = \sigma^2 \left( X^T X \right) ^ {-1} $$

`stats`, unfortunately, computes this as essentially

    covmat = sqrt(sigma2)^2 * XtXinv
    
The extra square root and exponentiation introduce some minor numerical error; we obviate this by simply computing `sigma2` and multiplying it with `XtXinv`. The difference is infinitesimal, but easily avoided.

Let's consider a situation where we can get an analytic form of the variance. Consider $y_i = i$, $i = 1, \ldots, n$ regressed with OLS against a constant, $\beta$.

The OLS solution is $\hat{\beta} = \frac{n+1}2$. The implied error variance is $\sigma^2 = \frac{n}{n-1} \frac{n^2 - 1}{12}$, so the implied covariance "matrix" (singleton) is $\mathbb{V}[\hat{\beta}] = \frac{n^2 - 1}{12(n - 1)}$, since $ \left( X^T X \right) ^ {-1} = \frac1{n} $.

```
N = 1e5
y = 1:N 

reg = lm(y ~ 1)
true_variance = (N^2-1)/(12*(N - 1))

stat_err = abs(true_variance - stats:::vcov.lm(reg))
vcov_err = abs(true_variance - vcov:::Vcov.lm(reg))
#absolute error with vcov
#  (i.e., there's still some numerical issues introduced
#   by the numerics behind the other components)
vcov_err
#              (Intercept)
# (Intercept) 1.818989e-12

#relative error of stats compared to vcov
#  (sometimes the error is 0 for both methods)
stat_err/vcov_err
#             (Intercept)
# (Intercept)           2
```
