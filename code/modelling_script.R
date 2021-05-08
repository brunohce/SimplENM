#Bruno Evaldt's ENMini script 

# Installing packages

#If Ubuntu system run in terminal 
#sudo apt install libgdal-dev default-jdk default-jre
#sudo R CMD javareconf

#If Fedora
#sudo dnf -y install gdal gdal-devel libcurl libcurl-devel udunits2-devel openssl-devel libxml2-devel geos-devel proj proj-devel -y



#Restart R
# install.packages('devtools');
# install.packages('dismo')
# install.packages('raster')
# install.packages('maxnet')
# install.packages('rgdal')
# install.packages('rgeos')
# install.packages('geosphere')
# install.packages('scales')
# install.packages('adehabitatHR')
# devtools::install_github("YaohuiZeng/grpregOverlap")
# devtools::install_github('adamlilith/omnibus', host = "https://api.github.com")
# devtools::install_github('adamlilith/legendary')
# # devtools::install_github('adamlilith/enmSdm')

# load packages
# library(dismo); library(maxnet);library(raster); library(rgeos);library(geosphere);library(rgdal);
# library(scales);library(omnibus);library(legendary);library(enmSdm); library(adehabitatHR)

################### set working directory ###################
setwd('~/Documentos/sdm')


# To run multiple species configure 'for' and add a '}' to the end of the script
# lista.sp <- list.files('./data/records_post/', pattern = 'csv$', full.names = T)
# 
# for (j in lista.sp){

################### gis files ###################

# load biome shapefile
shape <- rgdal::readOGR(dsn = "./data/masks", layer = "afcr")


# load elevation raster
elev <- raster::raster("./data/elev/elevation.tif")

# load current prediction rasters
lista.current <- list.files(path="./data/raster/current",pattern='tif$',full.names = T)
current <- raster::stack(lista.current)
#plot(current)

#load future projection rasters
lista.RCP26 <- list.files(path="./data/raster/RCP26",pattern='tif$',full.names = T)
RCP26 <- raster::stack(lista.RCP26)
raster::crs(RCP26) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
#plot(RCP26)

lista.RCP45 <- list.files(path="./data/raster/RCP45",pattern='tif$',full.names = T)
RCP45 <- raster::stack(lista.RCP45)
raster::crs(RCP45) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
# plot(RCP45)

lista.RCP60 <- list.files(path="./data/raster/RCP60",pattern='tif$',full.names = T)
RCP60 <- raster::stack(lista.RCP60)
raster::crs(RCP60) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
# plot(RCP60)

lista.RCP85 <- list.files(path="./data/raster/RCP85",pattern='tif$',full.names = T)
RCP85 <- raster::stack(lista.RCP85)
raster::crs(RCP85) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
# plot(RCP85)


# get predictors names
predictors <- names(current)

################### records ###################
# load records
records <- read.csv('.data/records/records.csv', header=T, sep=',')
records <- enmSdm::elimCellDups(records, current[[1]], longLat=c('lon', 'lat'))
records <- na.omit(records)
nrecords <- nrow(records)

# get species name
sp.name <- records$sp[[1]]
print(paste0(sp.name, " ENM in progress"))

# get latlon for threshold
recordsp95 <- records[,c(2,3)]

# turn csv into spatial points data frame vor visualization 
records.spatial <- sp::SpatialPointsDataFrame(coords=cbind(records$lon, records$lat), data=records, proj4string=CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'))


# check records
#par(mfrow=c(1, 1))
#plot(current[[1]])
#plot(records.spatial,add=T)


################### sampling variables at species and background locations ###################

# extract the raster values at each record location
env <- current
envSpecies <- raster::extract(env, cbind(records$lon, records$lat))
envSpecies <- as.data.frame(envSpecies)
records <- cbind(records, envSpecies)
summary(records[7])

# randomly generate 10,000 background sites
randomBgSites <- dismo::randomPoints(current, 10000)

# extract environment at sites
randomBgEnv <- raster::extract(current, randomBgSites)
randomBgEnv <- as.data.frame(randomBgEnv)

# remove any sites with NA for at least one variable
isNa <- is.na(rowSums(randomBgEnv))
if (any(isNa)) {
  randomBgSites <- randomBgSites[-which(isNa), ]
  randomBgEnv <- randomBgEnv[-which(isNa), ]
}

# combine with coordinates and rename coordinate fields
randomBg <- cbind(randomBgSites, randomBgEnv)
names(randomBg)[1:2] <- c('lon', 'lat')

dir.create(file.path("Results"), recursive=TRUE, showWarnings=FALSE)
setwd('./Results')
dir.create(file.path(paste(sp.name)), recursive=TRUE, showWarnings=FALSE)
setwd(paste(sp.name))


################### creating output directories ################### 

# output directory
dir.create(file.path("Models", "Current", "Ensemble"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "Current", "Thresholded"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "Current", "Uncertainty"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP26", "Ensemble"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP26", "Thresholded"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP26", "Uncertainty"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP45", "Ensemble"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP45", "Thresholded"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP45", "Uncertainty"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP60", "Ensemble"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP60", "Thresholded"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP60", "Uncertainty"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP85", "Ensemble"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP85", "Thresholded"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path("Models", "RCP85", "Uncertainty"), recursive=TRUE, showWarnings=FALSE)


###################  calculating k-folds for random cross validation ################### 
kPres <- dismo::kfold(x=records, k=5)
kBg <- dismo::kfold(x=randomBg, k=5)
RecordsFold <- cbind(records[1:3], kPres)
BgFold <- cbind(randomBgSites, kBg)

################### storing evaluation metrics and threshold ###################  

write.table(RecordsFold, paste0("./Records ", sp.name , '.csv'), sep = ',', row.names = F, quote = F)
write.table(BgFold, paste0("./Background ", sp.name , '.csv'), sep = ',', row.names = F, quote = F)
thresholdvalue <- tssRandom <- aucRandom <- cbiRandom <- rep(NA, 5)

################### calibration and projection ###################

# cycle through each k-fold
for (i in 1:5) {
  # make training data frame with predictors and vector of 1/0 for
  # presence/background... using only points not in this k-fold
  envData <- rbind(
    records[kPres!=i, predictors],
    randomBg[kBg!=i, predictors]
  )
  
  presBg <- c(rep(1, sum(kPres!=i)), rep(0, sum(kBg!=i)))
  
  trainData <- cbind(presBg, envData)
  
  # tuning model: tests combinations of regularization and features
  # and picks the one with the lowest AIC
  tunedModel <- trainMaxNet(data=trainData,
                            regMult= c(seq(1, 4, by = 0.5)),
                            verbose=F,
                            classes = "lqh",
                            testClasses=TRUE,
                            clamp=T,
                            out = c('model', 'tuning'))
  
  write.table(tunedModel$tuning, file=paste0('./Models/TuningKFold ', i, " ", sp.name, '.csv'), row.names = F, quote = F)
  
  tunedModel <- tunedModel$model
  
  # save
  save(tunedModel,
       file=paste0('./Models/CurrentKFold ', i, ' ', sp.name, '.Rdata'),
       compress=TRUE)
  
  # predict current time
  currentprediction <- predict(
    current[[predictors]],
    tunedModel,
    filename=paste0('./Models/Current/Current ', sp.name," ", i),
    format='GTiff', overwrite=TRUE, type='cloglog')
  
  # predict to RCP26 scenario
  predict(
    RCP26[[predictors]],
    tunedModel,
    filename=paste0('./Models/RCP26/RCP26 ', sp.name," ", i),
    format='GTiff', overwrite=TRUE, type='cloglog')
  
  predict(
    RCP45[[predictors]],
    tunedModel,
    filename=paste0('./Models/RCP45/RCP45 ', sp.name," ", i),
    format='GTiff', overwrite=TRUE, type='cloglog')
  
  # predict to RCP60 scenario
  predict(
    RCP60[[predictors]],
    tunedModel,
    filename=paste0('./Models/RCP60/RCP60 ', sp.name," ", i),
    format='GTiff', overwrite=TRUE, type='cloglog')
  
  predict(
    RCP85[[predictors]],
    tunedModel,
    filename=paste0('./Models/RCP85/RCP85 ', sp.name," ", i),
    format='GTiff', overwrite=TRUE, type='cloglog')
  
  
  # predict to presences and background sites
  predPres <- raster::predict(tunedModel, newdata=records[kPres==i, ], type='cloglog')
  predBg <- raster::predict(tunedModel, newdata=randomBg[kBg==i, ], type='cloglog')
  
  # calculate 5th percentile as threshold
  occPredVals <- raster::extract(currentprediction, recordsp95)
  p95 <- round(length(occPredVals) * 0.95)
  thisTr <- rev(sort(occPredVals))[p95]
  thresholdvalue[i] <- thisTr
  
  # evaluate and remember result
  thisEval <- dismo::evaluate(p=as.vector(predPres), a=as.vector(predBg))
  
  thisTss <- enmSdm::tssWeighted(pres=predPres, bg=predBg, thresholds = thisTr)
  tssRandom[i] <- thisTss
  
  thisAuc <- enmSdm::aucWeighted(pres=predPres, bg=predBg)
  aucRandom[i] <- thisAuc
  
  thisCbi <- enmSdm::contBoyce(pres=predPres, bg=predBg)
  cbiRandom[i] <- thisCbi
  
}

################### saving evaluation metrics ###################

# calculate evaluation metrics mean and sd and round to two decimal places

tssround <- round(tssRandom,2)
tssmean <- round(mean(tssRandom), 2)
tsssd <- round(sd(tssRandom), 2)
tssmeansd <- cbind(tssround, tssmean, tsssd)

aucround <- round(aucRandom,2)
aucmean <- round(mean(aucRandom), 2)
aucsd <- round(sd(aucRandom), 2)
aucmeansd <- cbind(aucround, aucmean, aucsd)

cbiround <- round(cbiRandom,2)
cbimean <- round(mean(cbiRandom), 2)
cbisd <- round(sd(cbiRandom), 2)
cbimeansd <- cbind(cbiround, cbimean, cbisd)

metrics <- cbind(cbimeansd,aucmeansd, tssmeansd)
metrics.summary <- t(as.data.frame(metrics[1,][c(2, 3, 5, 6, 8, 9)]))
row.names(metrics.summary) <- NULL

################### saving threshold values ###################

# calculate thresholdvalue mean and sd and round to two decimal places
thresholdvaluewmean <- weighted.mean(thresholdvalue, cbiRandom)
thresholdvaluesd <- sd(thresholdvalue)
thresholdvaluemeansd <- cbind(thresholdvalue, thresholdvaluewmean, thresholdvaluesd)
threshold.summary <- t(as.data.frame(thresholdvaluemeansd[1,][c(2, 3)]))
row.names(threshold.summary) <- NULL


metrics.thr <- cbind(metrics, thresholdvaluemeansd)
write.table(metrics.thr, paste0("./Metrics-Threshold ", sp.name , '.csv'), sep = ",", row.names = F, quote = F)


###################  ensembling and saving projections (TSS Weighted) ###################

currentkfolds <- list.files(path="./Models/Current/",pattern='tif$',full.names = T)
currentkfolds <- raster::stack(currentkfolds)

uncertainty.current <- raster::calc(currentkfolds, fun=var)
writeRaster(uncertainty.current,
            filename=paste0('./Models/Current/Uncertainty/Current Uncertainty ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

currentkfoldsfinal <- raster::weighted.mean(currentkfolds, cbiRandom)
writeRaster(currentkfoldsfinal,
            filename=paste0('./Models/Current/Ensemble/Current Ensemble ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP26kfolds <- list.files(path='./Models/RCP26/',pattern='tif$',full.names = T)
RCP26kfolds <- raster::stack(RCP26kfolds)

uncertainty.RCP26 <- raster::calc(RCP26kfolds, fun=var)
writeRaster(uncertainty.RCP26,
            filename=paste0('./Models/RCP26/Uncertainty/RCP26 Uncertainty ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP26kfoldsfinal <- raster::weighted.mean(RCP26kfolds, cbiRandom)
writeRaster(RCP26kfoldsfinal,
            filename=paste0('./Models/RCP26/Ensemble/RCP26 Ensemble ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP45kfolds <- list.files(path='./Models/RCP45/',pattern='tif$',full.names = T)
RCP45kfolds <- raster::stack(RCP45kfolds)

uncertainty.RCP45 <- raster::calc(RCP45kfolds, fun=var)
writeRaster(uncertainty.RCP45,
            filename=paste0('./Models/RCP45/Uncertainty/RCP45 Uncertainty ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP45kfoldsfinal <- raster::weighted.mean(RCP45kfolds, cbiRandom)
writeRaster(RCP45kfoldsfinal,
            filename=paste0('./Models/RCP45/Ensemble/RCP45 Ensemble ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP60kfolds <- list.files(path='./Models/RCP60/',pattern='tif$',full.names = T)
RCP60kfolds <- raster::stack(RCP60kfolds)

uncertainty.RCP60 <- raster::calc(RCP60kfolds, fun=var)
writeRaster(uncertainty.RCP60,
            filename=paste0('./Models/RCP60/Uncertainty/RCP60 Uncertainty ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP60kfoldsfinal <- raster::weighted.mean(RCP60kfolds, cbiRandom)
writeRaster(RCP60kfoldsfinal,
            filename=paste0('./Models/RCP60/Ensemble/RCP60 Ensemble ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP85kfolds <- list.files(path='./Models/RCP85/',pattern='tif$',full.names = T)
RCP85kfolds <- raster::stack(RCP85kfolds)

uncertainty.RCP85 <- raster::calc(RCP85kfolds, fun=var)
writeRaster(uncertainty.RCP85,
            filename=paste0('./Models/RCP85/Uncertainty/RCP85 Uncertainty ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')

RCP85kfoldsfinal <- raster::weighted.mean(RCP85kfolds, cbiRandom)
writeRaster(RCP85kfoldsfinal,
            filename=paste0('./Models/RCP85/Ensemble/RCP85 Ensemble ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog')


################### thresholding maps ################### 

#buffer around points to crop overprediction
records.points <- recordsp95
coordinates(records.points) <- ~lon + lat
mcp.records <- mcp(records.points, percent = 100)
mcp.area <- mcp.records

crs(mcp.records) <- crs(shape)
mcp.records <- spTransform(mcp.records, CRS("+init=epsg:32723"))
km <- 1000
buffered.mcp.records <- raster::buffer(mcp.records, width = 200*km )
buffered.mcp.records <- spTransform(buffered.mcp.records, CRS("+init=epsg:4326"))


#mask 200 km buffer

binary.current <- currentkfoldsfinal >= thresholdvaluewmean
binary.current <- mask(binary.current, buffered.mcp.records, updateNA=T, updatevalue = 0)

writeRaster(binary.current,
            filename=paste0('./Models/Current/Thresholded/Current Binary ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog', bylayer=T)

binary.RCP26 <- RCP26kfoldsfinal >= thresholdvaluewmean
binary.RCP26 <- mask(binary.RCP26, buffered.mcp.records, updateNA=T, updatevalue = 0)

writeRaster(binary.RCP26,
            filename=paste0('./Models/RCP26/Thresholded/RCP26 Binary ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog', bylayer=T)

binary.RCP45 <- RCP45kfoldsfinal >= thresholdvaluewmean
binary.RCP45 <- mask(binary.RCP45, buffered.mcp.records, updateNA=T, updatevalue = 0)

writeRaster(binary.RCP45,
            filename=paste0('./Models/RCP45/Thresholded/RCP45 Binary ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog', bylayer=T)

binary.RCP60 <- RCP60kfoldsfinal >= thresholdvaluewmean
binary.RCP60 <- mask(binary.RCP60, buffered.mcp.records, updateNA=T, updatevalue = 0)

writeRaster(binary.RCP60,
            filename=paste0('./Models/RCP60/Thresholded/RCP60 Binary ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog' , bylayer=T)

binary.RCP85 <- RCP85kfoldsfinal >= thresholdvaluewmean
binary.RCP85 <- mask(binary.RCP85, buffered.mcp.records, updateNA=T, updatevalue = 0)

writeRaster(binary.RCP85,
            filename=paste0('./Models/RCP85/Thresholded/RCP85 Binary ', sp.name),
            format='GTiff', overwrite=TRUE, type='cloglog', bylayer=T)

################### calculating area ################### 

shape.current <- rasterToPolygons(binary.current, na.rm = T, fun=function(x){x>0})
area.current <- sum(raster::area(shape.current) / 1000000)
area.current.change <- (100*((area.current/area.current)-1))
area.current.ratio <- area.current/area.current

area.current.final <- cbind('current', area.current, area.current.change, area.current.ratio)

shape.RCP26 <- rasterToPolygons(binary.RCP26, na.rm = T, fun=function(x){x>0})
area.RCP26 <- sum(raster::area(shape.RCP26) / 1000000)
area.RCP26.change <- (100*((area.RCP26/area.current)-1))
area.RCP26.ratio <- area.RCP26/area.current

area.RCP26.final <- cbind('RCP26', area.RCP26, area.RCP26.change, area.RCP26.ratio)

shape.RCP45 <- rasterToPolygons(binary.RCP45, na.rm = T, fun=function(x){x>0})
area.RCP45 <- sum(raster::area(shape.RCP45) / 1000000)
area.RCP45.change <- (100*((area.RCP45/area.current)-1))
area.RCP45.ratio <- area.RCP45/area.current

area.RCP45.final <- cbind('RCP45', area.RCP45, area.RCP45.change, area.RCP45.ratio)

shape.RCP60 <- rasterToPolygons(binary.RCP60, na.rm = T, fun=function(x){x>0})
area.RCP60 <- sum(raster::area(shape.RCP60) / 1000000)
area.RCP60.change <- (100*((area.RCP60/area.current)-1))
area.RCP60.ratio <- area.RCP60/area.current

area.RCP60.final <- cbind("RCP60", area.RCP60, area.RCP60.change, area.RCP60.ratio)

shape.RCP85 <- rasterToPolygons(binary.RCP85, na.rm = T, fun=function(x){x>0})
area.RCP85 <- sum(raster::area(shape.RCP85) / 1000000)
area.RCP85.change <- (100*((area.RCP85/area.current)-1))
area.RCP85.ratio <- area.RCP85/area.current

area.RCP85.final <- cbind('RCP85', area.RCP85, area.RCP85.change, area.RCP85.ratio)

area <- rbind(area.current.final, area.RCP26.final, area.RCP45.final, area.RCP60.final, area.RCP85.final)

################### calculating elevation ################### 

points.current <- rasterToPoints(binary.current, spatial = T, fun=function(x){x>0})
elev.current <- extract(elev, points.current)
elev.current <- na.omit(elev.current)
elev.current <- t(summary(elev.current))
elev.current.range <- elev.current[6] - abs(elev.current[1])

elev.current <- cbind('current', elev.current, elev.current.range)

points.RCP26 <- rasterToPoints(binary.RCP26, spatial = T, fun=function(x){x>0})
elev.RCP26 <- extract(elev, points.RCP26)
elev.RCP26 <- na.omit(elev.RCP26)
elev.RCP26 <- t(summary(elev.RCP26))
elev.RCP26.range <- elev.RCP26[6] - abs(elev.RCP26[1])

elev.RCP26 <- cbind('RCP26', elev.RCP26, elev.RCP26.range)

points.RCP45 <- rasterToPoints(binary.RCP45, spatial = T, fun=function(x){x>0})
elev.RCP45 <- extract(elev, points.RCP45)
elev.RCP45 <- na.omit(elev.RCP45)
elev.RCP45 <- t(summary(elev.RCP45))
elev.RCP45.range <- elev.RCP45[6] - abs(elev.RCP45[1])

elev.RCP45 <- cbind('RCP45', elev.RCP45, elev.RCP45.range)

points.RCP60 <- rasterToPoints(binary.RCP60, spatial = T, fun=function(x){x>0})
elev.RCP60 <- extract(elev, points.RCP60)
elev.RCP60 <- na.omit(elev.RCP60)
elev.RCP60 <- t(summary(elev.RCP60))
elev.RCP60.range <- elev.RCP60[6] - abs(elev.RCP60[1])

elev.RCP60 <- cbind('RCP60', elev.RCP60, elev.RCP60.range)

points.RCP85 <- rasterToPoints(binary.RCP85, spatial = T, fun=function(x){x>0})
elev.RCP85 <- extract(elev, points.RCP85)
elev.RCP85 <- na.omit(elev.RCP85)
elev.RCP85 <- t(summary(elev.RCP85))
elev.RCP85.range <- elev.RCP85[6] - abs(elev.RCP85[1])

elev.RCP85 <- cbind('RCP85', elev.RCP85, elev.RCP85.range)

elevation <- rbind(elev.current, elev.RCP26, elev.RCP45, elev.RCP60, elev.RCP85)

area.elevation <- cbind(area, elevation[,-1])
colnames(area.elevation) <- c('Scenario', 'Sqkm', '%Change', 'Area Ratio', 'Min', '1stQu', 'Median', 'Mean', '3rdQu', 'Max', 'ElevationRange')
write.table(area.elevation, paste0("./Area-Elevation ", sp.name , '.csv'), sep = ',', row.names =F, quote = F)


log.final <- (data.frame(sp.name, nrecords, metrics.summary, threshold.summary ))
write.table(log.final, paste0("./Log ", sp.name , '.csv'), sep = ',',col.names = T, row.names =F, quote = F)

# 
#  par(mfrow=c(1, 5))
# # 
# # 
# plot(binary.current, legend=F, main="Current")
# #plot(records.spatial,add=T)
# plot(binary.RCP26, legend=F, main="2070 RCP 2.6")
# #plot(records.spatial,add=T)
# plot(binary.RCP45, legend=F, main="2070 RCP 4.5")
# #plot(records.spatial,add=T)
# plot(binary.RCP60, legend=F, main="2070 RCP 6.0")
# #plot(records.spatial,add=T)
# plot(binary.RCP85, legend=F, main="2070 RCP 8.5")
# #plot(records.spatial,add=T)
print(paste0(sp.name, " ENM done :)"))

setwd('~/Documentos/sdm')
rm(list = ls())
gc()}
