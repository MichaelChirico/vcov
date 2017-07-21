\name{vcov-package}
\alias{vcov-package}
\docType{package}
\title{ Variance-Covariance Matrices and Standard Errors }
\description{
   This package is designed to produce variance-covariance matrices and standard errors as directly/efficiently as possible from fit models. Default methods (e.g., in \code{stats}) tend to first compute the \code{summary} object for a model, from which the matrix is extracted. The catch is that the \code{summary} itself often involves several other extraneous computations. The \code{summary} methods are typically fast for most purposes, but falter in this regard when a user wishes to compute standard errors of perhaps thousands of models (as may happen, for example, when bootstrapping). 
}
