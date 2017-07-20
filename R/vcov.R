se = function(object, ...) UseMethod('se')

vcov.lm = function(object, ...) {
  if (p <- object$rank) {
    p1 = seq_len(p)
    rss = if (is.null(w <- object$weights)) { 
      sum(object$residuals^2)
    } else {
      sum(w * object$residuals^2)
    }
    return(rss * chol2inv(object$qr$qr[p1, p1, drop = FALSE])/
             object$residual.df)
  } else return(numeric(0))
}

se.lm = function(object, ...) sqrt(diag(vcov.lm(object)))

vcov.glm = function(object, dispersion = NULL, ...) {
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

se.glm = function(object, dispersion = NULL, ...) 
  sqrt(diag(vcov.glm(object, dispersion = dispersion)))
