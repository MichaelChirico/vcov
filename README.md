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
