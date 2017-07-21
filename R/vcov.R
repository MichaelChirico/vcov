se = function(object, ...) sqrt(diag(Vcov(object, ...)))

Vcov = function(object, ...) UseMethod('Vcov')

Vcov.default = vcov

Vcov.lm = function(object, ...) {
  if (p <- object$rank) {
    p1 = seq_len(p)
    rss = if (is.null(w <- object$weights)) { 
      sum(object$residuals^2)
    } else {
      sum(w * object$residuals^2)
    }
    covmat = rss * chol2inv(object$qr$qr[p1, p1, drop = FALSE])/
      object$df.residual
    nm = names(object$coefficients)
    dimnames(covmat) = list(nm, nm)
    return(covmat)
  } else return(numeric(0))
}

Vcov.glm = function(object, dispersion = NULL, ...) {
  if (p <- object$rank) {
    if (is.null(dispersion)) {
      dispersion = if (object$family$family %in% c('poisson', 'binomial')) {
        1
      } else {
        df_r = object$df.residual
        if (df_r) {
          if (any(!object$weights)) 
            warning('observations with zero weight not',
                    'used for calculating dispersion')
          w = object$weights
          idx = w > 0
          sum(w[idx] * object$residuals[idx]^2)/df_r
        } else NaN
      }
    }
    p1 = seq_len(p)
    nm <- names(object$coefficients[object$qr$pivot[p1]])
    covmat = dispersion * chol2inv(object$qr$qr[p1, p1, drop = FALSE])
    dimnames(covmat) = list(nm, nm)
    return(covmat)
  } else return(numeric(0))
}
