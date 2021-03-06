\name{Vcov}
\alias{se}
\alias{Vcov}
\alias{Vcov.lm}
\alias{Vcov.glm}
\title{Fast Covariance Matrix and Standard Error Computation}
\description{
  Skip wasted object summary steps computed by base R when computing covariance matrices and standard errors of common model objects.
}
\usage{
  Vcov(object, ...)

  \method{Vcov}{lm}(object, ...)

  \method{Vcov}{glm}(object, dispersion = NULL, ...)
  
  se(object, ...)
}
\arguments{
  \item{object}{ A fitted model object. }
  \item{...}{ Additional arguments for method functions. For the \code{glm} method this can be used to pass a \code{dispersion} parameter. }
  \item{dispersion}{ The dispersion parameter for the family used. Either a single numerical value or \code{NULL} (the default), in which case it is inferred from \code{obj}. For details, see \code{\link{summary.glm}}. }
}
\seealso{ 
  \code{\link{summary.glm}}
}
\examples{
  # data taken from ?lm
  ctl = c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
  trt = c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
  group = gl(2, 10, 20, labels = c("Ctl","Trt"))
  weight = c(ctl, trt)
  reg_lm = lm(weight ~ group)
  Vcov(reg_lm)
  se(reg_lm)

  # data taken from ?glm
  counts = c(18,17,15,20,10,20,25,13,12)
  outcome = gl(3,1,9)
  treatment = gl(3,3)
  reg_glm = glm(counts ~ outcome + treatment, family = poisson)
  Vcov(reg_glm)
  se(reg_glm)
}
