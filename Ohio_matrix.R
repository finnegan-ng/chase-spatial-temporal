setwd("/path/")

install.packages("SpatioTemporal")

library(sp)
library(xts)
library(spacetime)
library(sp)
library(RColorBrewer)
library(gstat)
library(dplyr)
library(maps)
library(mapdata)
library(fields)
library(ggmap)
library(SpatioTemporal)

bank.latlon<-read.csv("oh_latlon.csv",sep = ",",header = FALSE)

bank.latlon.mat<-as.matrix(bank.latlon)
bank.latlon.mat

#variance appr. 0.58


bank.dep <-read.csv("oh_dep.csv",sep = ",",header = FALSE)
#bank.dep[1:7]<-log1p(bank.dep[1:7])
bank.dep[1:7]<-log(bank.dep[1:7])
head(bank.dep)
bank.dep.mat<-as.matrix(bank.dep)
bank.dep.mat

#density histogram
plot(density(bank.dep.mat))

qqnorm(bank.dep.mat, pch = 1, frame = FALSE)
qqline(bank.dep.mat, col = "steelblue", lwd = 2)

bank.latlon.mat<-SpatialPoints(bank.latlon.mat[,c(2,1)])
proj4string(bank.latlon.mat)<-CRS("+proj=longlat +datum=WGS84")
bank.latlon.mat

bank.years<-2010:2016
bank.y<-as.Date(paste(bank.years,"-01-01",sep = ""), "%Y-%m-%d")

bank.st<-STFDF(bank.latlon.mat,bank.y,data.frame(deposits = as.vector(as.matrix(bank.dep))))
dim(bank.st)
summary(bank.st)

#plot
display.brewer.all()

my.palette<-brewer.pal(n=10,name="RdBu")
stxy <- stplot(bank.st[,,"deposits"],mode="xy", col.regions=my.palette,cuts=15,animate=0)
stxy

stxt <- stplot(bank.st[,,"deposits"],mode="xt")
stxt

stts <- stplot(bank.st[,,"deposits"],mode="ts")
stts

#map OH
states <- map_data("state")
oh_df <- subset(states, region == "ohio")
counties <- map_data("county")
oh_county <- subset(counties, region == "ohio")
oh_base <- ggplot(data = oh_df, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = "gray")
oh_base + theme_nothing()
oh_map <- oh_base + geom_polygon(data = oh_county, fill = NA, color = "white") +
  geom_polygon(color = "black", fill = NA) 

oh_map + geom_point(data=)

#Variogram
head(bank.st)
dep <- bank.st[,,"deposits"]
var <- variogramST(deposits~1, data = bank.st, assumeRegular = T, tlags = 0:6)
varplot <- plot(var,scales=list(arrows=FALSE), map=F)
varplot
varplotwire<-plot(var,wireframe=T, scales=list(arrows=FALSE))
varplotwire
summary(var)

varplotT <-plot(var,map=T) 
varplotT

#Prediction
#vignette("st",package = "gstat")

rs = sample(dim(bank.st)[2],7)

lst = lapply(rs, function(i) { x = bank.st[,i]; x$ti = i; x} )
pts = do.call(rbind, lst)

v = variogram(deposits~ti, pts[!is.na(pts$deposits),], dX=0, cressie =TRUE )
plot(v,pch = 16, col = "blue", cex = 2)

vmod = fit.variogram(v, vgm(c("Exp","Mat","Sph","Ste")), fit.kappa=TRUE) #Matern, M. Stein's parameterization

plot(v,pch = 16, col = "blue", cex = 2)
vmod

vv = variogram(deposits~1 , bank.st, width=200/8, cutoff = 200, tlags=0:6)
vv
plot(vv)
plot(vv,map=FALSE)
plot(vv, wireframe=TRUE)

var = variogram(deposits~V1+V2,bank.st, tlags=0:6)
plot(var)



#Fitting a spatio-temporal variogram model
#metric
metricVgm <- vgmST("metric",
                   joint=vgm(0.9,"Exp",120,0),
                   sill = 0.4,
                   stAni=0.2)
metricVgm <- fit.StVariogram(vv, metricVgm)
metricVgm

attr(metricVgm, "optim")$value
attr(metricVgm,"MSE")

plot(metricVgm,map=FALSE)

plot(vv, metricVgm, map=FALSE)

#separable
sepVgm <- vgmST("separable",
                        method = "Nelder-Mead", # no lower & upper needed
                        space=vgm(0.4,"Exp", 120, 0),
                        time =vgm(0.4,"Exp", 1, 0),
                        sill=0.8)
sepVgm<-fit.StVariogram(vv,sepVgm)
sepVgm

attr(sepVgm, "optim")$value


plot(vv, sepVgm, map=FALSE)

#lower
pars.l <- c(sill.s = 0, range.s = 10, nugget.s = 0,sill.t = 0, range.t = 1, nugget.t = 0,sill.st = 0, range.st = 10, nugget.st = 0, anis = 0)

#Product Sum
pars.l <- c(sill.s = 0, range.s = 10, nugget.s = 0,sill.t = 0, range.t = 1, nugget.t = 0,sill.st = 0, range.st = 10, nugget.st = 0, anis = 0)

prodSumModel <- vgmST("productSum",space = vgm(0.9, "Exp", 50, 0.1),
                      time = vgm(0.1, "Exp", 1000, 0.1),k = 5) 
StAni = estiStAni(vv, c(0,2000))
prodSumModel<-fit.StVariogram(vv,prodSumModel, fit.method = 7, stAni = StAni, method = "L-BFGS-B",
                              lower=pars.l)
prodSumModel

attr(prodSumModel,"optim")$value
attr(prodSumModel,"MSE")

plot(vv,prodSumModel, wireframe=T)

#control = list(parscale = c(1,10,1,1,0.1,1,10))
#lower = rep(0.0001, 7))

#Sum Metric
SimplesumMetric <- vgmST("simpleSumMetric",space = vgm(0.35,"Sph", 120, 0),
                         time = vgm(0.35,"Sph", 120, 0), 
                         joint = vgm(0.7,"Sph", 120, 0), nugget=0, stAni=0.2) 

SimplesumMetric_Vgm <- fit.StVariogram(var, SimplesumMetric)
attr(SimplesumMetric_Vgm, "MSE")

plot(vv,SimplesumMetric_Vgm,map=FALSE)

#plot
plot(vv,list(sepVgm, prodSumModel, metricVgm),all=T,wireframe=T) 
plot(vv,metricVgm, all = T, wireframe = T)

#anisotropy
estiStAni(vv, c(1,200))

#Universal S-T kriging
spat_pred_grid <- expand.grid(
  lon = seq(-85, -81, length = 20),
  lat = seq(38, 42, length = 20)) %>%
  SpatialPoints(proj4string = CRS(proj4string(bank.st)))
gridded(spat_pred_grid) <- TRUE

temp_pred_grid <- seq(as.Date("2010-01-01"), by ="year", length.out = 7)
temp_pred_grid

DE_pred <- STF(sp = spat_pred_grid, # spatial part
               time = temp_pred_grid) # temporal part

pred_kriged <- krigeST(deposits~1, data=bank.st,
                       newdata = DE_pred, modelList = metricVgm,
                       computeVar = TRUE)

#prodSumModel
pred_kriged

display.brewer.pal()

color_pal<-rev(colorRampPalette(brewer.pal(11,"Spectral"))(16))
#color_pal<-rev(colorRampPalette(rainbow))
stplot(pred_kriged,
       main = "Predictions of log Deposits",
       layout=c(3,3),
       col.regions=color_pal)

#Prediction (kriging) standard errors can be plotted in a similar way
pred_kriged$se<-sqrt(pred_kriged$var1.var)
stplot(pred_kriged[, , "se"],
       main = " Prediction std. errors of log Deposits",
       layout=c(3,3),
       col.regions=color_pal)

summary(pred_kriged)


#Cross-validation
m<-vgm(0.6461874,"Ste Mat",2.182146,kappa = 0.5)
x<-krige.cv(deposits~1,bank.latlon.mat,bank.dep, m)





