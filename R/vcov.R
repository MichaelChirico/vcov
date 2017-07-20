se = function(obj, ...) UseMethod('se')

vcov.lm = function(obj) {
  if (p <- obj$rank) {
    p1 = seq_len(p)
    rss = if (is.null(w <- obj$weights)) { 
      sum(obj$residuals^2)
    } else {
      sum(w * obj$residuals^2)
    }
    return(rss * chol2inv(obj$qr$qr[p1, p1, drop = FALSE])/obj$residual.df)
  } else return(numeric(0))
}

se.lm = function(obj) sqrt(diag(vcov.lm(obj)))

vcov.glm = function(obj, dispersion = NULL) {
  if (p <- obj$rank) {
    if (is.null(dispersion)) {
      dispersion = if (obj$family$family %in% c('poisson', 'binomial')) {
        1
      } else {
        df_r = obj$df.residual
        if (df_r) {
          if (any(!obj$weights)) 
            warning('observations with zero weight not',
                    'used for calculating dispersion')
          w = obj$weights
          idx = w > 0
          sum(w[idx] * obj$residuals[idx]^2)/df_r
        } else NaN
      }
    }
    p1 = seq_len(p)
    nm <- names(obj$coefficients[obj$qr$pivot[p1]])
    covmat = dispersion * chol2inv(obj$qr$qr[p1, p1, drop = FALSE])
    dimnames(covmat) = list(nm, nm)
    return(covmat)
  } else return(numeric(0))
}

se.glm = function(obj, dispersion = NULL) 
  sqrt(diag(vcov.glm(obj, dispersion = dispersion)))
