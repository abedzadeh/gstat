% $Id: fit.variogram.Rd,v 1.6 2006-02-10 19:03:27 edzer Exp $
\name{fit.variogram}
\alias{fit.variogram}
\title{ Fit a Variogram Model to a Sample Variogram }
\description{
Fit ranges and/or sills from a simple or nested variogram model 
to a sample variogram }
\usage{
fit.variogram(object, model, fit.sills = TRUE, fit.ranges = TRUE,
	fit.method = 7, debug.level = 1, warn.if.neg = FALSE )
}
\arguments{
\item{object}{ sample variogram, output of \link{variogram} }
\item{model}{ variogram model, output of \link{vgm} }
\item{fit.sills}{ logical; determines whether the partial sill
coefficients (including nugget variance) should be fitted; or logical
vector: determines for each partial sill parameter whether it should be
fitted or fixed.  }
\item{fit.ranges}{ logical; determines whether the range coefficients
(excluding that of the nugget component) should be fitted; or logical
vector: determines for each range parameter whether it should be fitted
or fixed.  }
\item{fit.method}{ fitting method, used by gstat. The default method uses
weights $N_h/h^2$ with $N_h$ the number of point pairs and $h$ the
distance. This criterion is not supported by theory, but by practice. 
For other values of \code{fit.method}, see table 4.2 in the gstat
manual. }
\item{debug.level}{ integer; set gstat internal debug level }
\item{warn.if.neg}{ logical; if TRUE a warning is issued whenever
a sill value of a direct variogram becomes negative }
}
\value{
returns a fitted variogram model (of class \code{variogramModel}).

This is a data.frame has two attributes: (i) \code{singular} a logical
attribute that indicates whether the non-linear fit converged, or ended
in a singularity, and (ii) \code{SSErr} a numerical attribute with the
(weighted) sum of squared errors of the fitted model. See Notes below.

}

\note{ If fitting the range(s) is part of the job of this function,
the results may well depend on the starting values, given in argument
\code{model}.  This is nothing new, but generally true for non-linear
regression problems. This function uses the internal gstat (C) code,
which iterates over (a) a direct (ordinary or weighted least squares)
fit of the partial sills and (b) an iterated search, using gradients,
for the optimal range value(s), until convergence of after a combined
step ((a) and (b)) is reached.

If for a direct (i.e. not a cross) variogram a sill parameter (partial
sill or nugget) becomes negative, fit.variogram is called again with
this parameter set to zero, and with a FALSE flag to further fit this
sill. This implies that once at the search space boundary, a sill value 
does not never away from it. 

On singular model fits: If your variogram turns out to be a flat,
horizontal or sloping line, then fitting a three parameter model such
as the exponential or spherical with nugget is a bit heavy: there's an
infinite number of possible combinations of sill and range (both very
large) to fit to a sloping line. In this case, the returned, singular
model may still be useful: just try and plot it. Gstat converges when
the parameter values stabilize, and this may not be the case. Another
case of singular model fits happens when a model that reaches the sill
(such as the spherical) is fit with a nugget, and the range parameter
starts, or converges to a value smaller than the distance of the second
sample variogram estimate. In this case, again, an infinite number of
possibilities occur essentially for fitting a line through a single
(first sample variogram) point. In both cases, fixing one or more of
the variogram model parameters may help you out.

}

\references{ \url{http://www.gstat.org/} 

Pebesma, E.J., 2004. Multivariable geostatistics in S: the gstat package.
Computers \& Geosciences, 30: 683-691.
}

\author{ Edzer Pebesma }
\seealso{
\link{variogram},
\link{vgm}
}

\examples{
library(sp)
data(meuse)
vgm1 <- variogram(log(zinc)~1, ~x+y, meuse)
fit.variogram(vgm1, vgm(1,"Sph",300,1))
}

\keyword{models}
