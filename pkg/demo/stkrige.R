# Ben Graeler, Feb 06, 2014.
library(sp)
library(spacetime)
library(gstat)

## examples:

data(vv)

separableModel <- vgmST("separable",
                        space=vgm(0.9,"Exp", 123, 0.1),
                        time =vgm(0.9,"Exp", 2.9, 0.1),
                        sill=100)

prodSumModel <- vgmST("productSum",
                      space=vgm(75, "Sph", 343, 0),
                      time= vgm(70, "Exp",   3, 0), 
                      sill=80, nugget=35)

# lower and upper bounds of the sum metric model
pars.l <- c(sill.s = 0, range.s = 10, nugget.s = 0,
            sill.t = 0, range.t = 1, nugget.t = 0,
            sill.st = 0, range.st = 10, nugget.st = 0, 
            anis = 1)
pars.u <- c(sill.s = 200, range.s = 500, nugget.s = 100,
            sill.t = 200, range.t = 15, nugget.t = 100,
            sill.st = 200, range.st = 500, nugget.st = 100,
            anis = 500)
sumMetricModel <- vgmST("sumMetric",
                        space=vgm(30, "Sph", 200,  6),
                        time =vgm(30, "Sph",  15,  7),
                        joint=vgm(60, "Exp",  84, 22),
                        stAni=100)

# simplified sumMetric model
pars.simple.l <- c(sill.s = 0, range.s = 10, 
                   sill.t = 0, range.t = 1, 
                   sill.st = 0, range.st = 10,
                   nugget=0, anis = 1)
pars.simple.u <- c(sill.s = 200, range.s = 500,
                   sill.t = 200, range.t = 15, 
                   sill.st = 200, range.st = 500, 
                   nugget = 100, anis = 500)

simpleSumMetricModel <- vgmST("simpleSumMetric",
                              space=vgm(30,"Sph", 150, 0),
                              time =vgm(30,"Sph", 10,  0),
                              joint=vgm(60,"Exp", 150, 0),
                              nugget=10, stAni=100)

# metric model
metricModel <- vgmST("metric",
                     joint=vgm(100, "Exp", 150, 10),
                     stAni=100)

# fitting
fitSepModel <- fit.StVariogram(vv, separableModel, 
                               method = "L-BFGS-B", 
                               lower = c(10,0,0.01,0,1),
                               upper = c(500,1,20,1,200))
attr(fitSepModel, "optim.output")$value # 6.76

fitProdSumModel <- fit.StVariogram(vv, prodSumModel, 
                                   method = "L-BFGS-B", 
                                   lower=rep(0.01,7))
attr(fitProdSumModel, "optim.output")$value # 7.05

fitSumMetricModel <- fit.StVariogram(vv, sumMetricModel, 
                                     method = "L-BFGS-B",
                                     lower=pars.l, upper=pars.u)
attr(fitSumMetricModel, "optim.output")$value # 6.62

fitSimpleSumMetricModel <- fit.StVariogram(vv, simpleSumMetricModel, 
                                           method = "L-BFGS-B",
                                           lower=pars.simple.l, 
                                           upper=pars.simple.u)
attr(fitSimpleSumMetricModel, "optim.output")$value # 6.44

fitMetricModel <- fit.StVariogram(vv, metricModel, method = "L-BFGS-B",
                                  lower=rep(0.0001,4))
attr(fitMetricModel, "optim.output")$value # 7.78

plot(vv, fitSepModel)
plot(vv, fitProdSumModel)
plot(vv, fitSumMetricModel)
plot(vv, fitSimpleSumMetricModel)
plot(vv, fitMetricModel)

# plot rgl
library(rgl)

# adapted from demo(lollipop3d), to be simplified
lollipop3d <- function(data.x, data.y, data.z, surf.fun, surf.n=50,
                       xlim=range(data.x), ylim=range(data.y), zlim=range(data.z), asp=c(y=1,z=1),
                       xlab=deparse(substitute(x)), ylab=deparse(substitute(y)),
                       zlab=deparse(substitute(z)), main="", alpha.surf=0.4,
                       col.surf=fg,col.stem=c(fg,fg), col.pt="gray",type.surf="line",ptsize,
                       lwd.stem=2,lit=TRUE,bg="white",fg="black",col.axes=fg,col.axlabs=fg,
                       axis.arrow=TRUE,axis.labels=TRUE,box.col=bg, axes=c("lines","box")) {
  axes <- match.arg(axes)
  col.stem <- rep(col.stem,length=2)
  x.ticks <- pretty(xlim)
  x.ticks <- x.ticks[x.ticks>=min(xlim) & x.ticks<=max(xlim)]
  x.ticklabs <- if (axis.labels) as.character(x.ticks) else NULL
  y.ticks <- pretty(ylim)
  y.ticks <- y.ticks[y.ticks>=min(ylim) & y.ticks<=max(ylim)]
  y.ticklabs <- if (axis.labels) as.character(y.ticks) else NULL
  z.ticks <- pretty(zlim)
  z.ticks <- z.ticks[z.ticks>=min(zlim) & z.ticks<=max(zlim)]
  z.ticklabs <- if (axis.labels) as.character(z.ticks) else NULL
  if (!missing(surf.fun)) {
    surf.x <- seq(xlim[1],xlim[2],length=surf.n)
    surf.y <- seq(ylim[1],ylim[2],length=surf.n)
    surf.z <- outer(surf.x,surf.y,surf.fun)  ## requires surf.fun be vectorized
    z.interc <- surf.fun(data.x,data.y)
    zdiff <- diff(range(c(surf.z,data.z)))
  } else {
    z.interc <- rep(min(data.z),length(data.x))
    zdiff <- diff(range(data.z))
  }
  xdiff <- diff(xlim)
  ydiff <- diff(ylim)
  y.adj <- if (asp[1]<=0) 1 else asp[1]*xdiff/ydiff
  data.y <- y.adj*data.y
  y.ticks <- y.adj*y.ticks
  ylim <- ylim*y.adj
  ydiff <- diff(ylim)
  z.adj <- if (asp[2]<=0) 1 else asp[2]*xdiff/zdiff
  data.z <- z.adj*data.z
  if (!missing(surf.fun)) {
    surf.y <- y.adj*surf.y
    surf.z <- z.adj*surf.z
  }
  z.interc <- z.adj*z.interc
  z.ticks <- z.adj*z.ticks
  zlim <- z.adj*zlim
  open3d()
  clear3d("all")
  light3d()
  bg3d(color=c(bg,fg))
  if (!missing(surf.fun)) 
    surface3d(surf.x,surf.y,surf.z,alpha=alpha.surf,
              front=type.surf,back=type.surf, col=col.surf,lit=lit)
  if (missing(ptsize)) ptsize <- 0.02*xdiff
  ## draw points
  spheres3d(data.x,data.y,data.z,r=ptsize,lit=lit,color=col.pt)
  ## draw lollipops
  apply(cbind(data.x,data.y,data.z,z.interc),1,
        function(X) {
          lines3d(x=rep(X[1],2), y=rep(X[2],2), z=c(X[3],X[4]),
                  col=ifelse(X[3]>X[4],col.stem[1],col.stem[2]),lwd=lwd.stem)
        })
  bbox <- par3d("bbox")
  if (axes=="box") {
    bbox3d(xat=x.ticks,xlab=x.ticklabs, yat=y.ticks,ylab=y.ticklabs,
           zat=z.ticks,zlab=z.ticklabs,lit=lit)
  } else if (axes=="lines") { ## set up axis lines
    bbox <- par3d("bbox")
    axis3d(edge="x",at=x.ticks,labels=x.ticklabs,col=col.axes,arrow=axis.arrow)
    axis3d(edge="y",at=y.ticks,labels=y.ticklabs,col=col.axes,arrow=axis.arrow)
    axis3d(edge="z",at=z.ticks,labels=z.ticklabs,col=col.axes,arrow=axis.arrow)
    box3d(col=col.axes)
  }
  decorate3d(xlab=xlab, ylab=ylab, zlab=zlab, box=FALSE, axes=FALSE, col=col.axlabs,main=main)
}
# run script plotStVariogram3D.R before
lollipop3d(vv$spacelag, vv$timelag, vv$gamma,  main="separable model",
           function(x,y) variogramSurface(fitSepModel,data.frame(spacelag=x,timelag=y))[,3],
           col.stem=c("red","blue"), ptsize=sqrt(vv$np/1000))
lollipop3d(vv$spacelag, vv$timelag, vv$gamma, main="product-sum model",
           function(x,y) variogramSurface(fitProdSumModel,data.frame(spacelag=x,timelag=y))[,3],
           col.stem=c("red","blue"), ptsize=sqrt(vv$np/1000))
lollipop3d(vv$spacelag, vv$timelag, vv$gamma,  main="sum-metric model",
           function(x,y) variogramSurface(fitSumMetricModel,data.frame(spacelag=x,timelag=y))[,3],
           col.stem=c("red","blue"), ptsize=sqrt(vv$np/1000))
lollipop3d(vv$spacelag, vv$timelag, vv$gamma,  main="simplified sum-metric model",
           function(x,y) variogramSurface(fitSimpleSumMetricModel,data.frame(spacelag=x,timelag=y))[,3],
           col.stem=c("red","blue"), ptsize=sqrt(vv$np/1000))

## kriging using the sumMetric model (supports STS structures now as well)

data(air)
rr <- rural[,"2005-06-01/2005-06-10"]
rr <- as(rr,"STSDF")

x1 <- seq(from=6,to=15,by=.5)
x2 <- seq(from=47.5,to=55,by=.5)

DE_gridded <- SpatialPoints(cbind(rep(x1,length(x2)), rep(x2,each=length(x1))), 
                            proj4string=CRS(proj4string(rr@sp)))
gridded(DE_gridded) <- T
DE_pred <- STF(sp=as(DE_gridded,"SpatialPoints"), time=rr@time)
DE_kriged <- krige(PM10~1,locations=rr, newdata=DE_pred,
	modelList=fitSumMetricModel)
gridded(DE_kriged@sp) <- TRUE
stplot(DE_kriged,col.regions=bpy.colors())

# save(fitMetricModel, fitProdSumModel, fitSepModel, 
#      fitSimpleSumMetricModel, fitSumMetricModel,
#      file="../../shiny-apps/spatial//fittedSTvariogramModels.RData")