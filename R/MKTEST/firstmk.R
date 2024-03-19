library(trend)
library(utils)
library(raster)
library(sp)
library(rgdal)
library(gstat)
library(maptools)

######
setwd("E:/YANGTZE/YRD")
STA <- read.table("E:/YANGTZE/YZstation/yrd.txt", head=T)
indic <- read.table("RH.txt", head=F)
nsta = nrow(STA)
year = 17
######
mkp = matrix(0,nsta,1)
mkz = matrix(0,nsta,1)


#���Ƽ���
for (i in (1:nsta))
{
  timeseries = indic[i,]
  mk <- mk.test(timeseries)
  mkp[i,1] <- mk$p.value
  mkz[i,1] <- mk$statistic
}


#Zֵ��ֵ
gauge_data_all <- mkz[,1]
date_len = ncol(gauge_data_all) #��ȡ������,����ѭ������
for (i in seq(1,date_len,1)) {
  gauge_data = gauge_data_all[,i]
  
  ##�趨վ�����ݵ�ͶӰΪWGS84����lon
  dsp <- SpatialPoints(STA[,2:3], proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  dsp <- SpatialPointsDataFrame(dsp,STA)
  
  #�˶λ���δͶӰ��ƽ������,���������޸�,��Ӱ����
  WGS84<- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")#���òο�ϵWGS84
  dsp1<-spTransform(dsp,WGS84)#����γ��ת��ƽ�����꣬ʹ��WGS�ο�ϵ
  
  
  #���Ʋ�ֵ�ֱ���,����դ��ģ��
  template_raster<-raster("E:/YANGTZE/YZDEM/yrd/template.tif")
  
  
  #������Ȩ��(idw)��ֵ
  gs <- gstat(formula=gauge_data~1, locations=dsp1,set=list(idp = 2))
  idw <- interpolate(template_raster, gs)
  date = i #������
  newname <- paste('EA','idw',date,'tif',sep = ".")
  writeRaster(idw,newname)
  str1 = paste('��',date,'�Ų�ֵ���',sep='')
  print(str1)
}


nrow = nrow(template_raster)
ncol = ncol(template_raster)
d = matrix(0,nrow,ncol)
d[] = raster(template_raster)


pvalue1 = 0.05
pvalue2 = 0.1



trendpic = matrix(0,nrow,ncol)


#������ͼ
# for (j in (1:nrow))
# {
#   for (k in (1:ncol))
#   {
#     trendpic[j,k] = mkz[j,k]
#   }
# }
for (j in (1:nrow))
{
  for (k in (1:ncol))
  {
    if (mkp[j,k]<pvalue1 & mkz[j,k]<0){
      trendpic[j,k] = 0
    } else if (mkp[j,k]>=pvalue1 & mkp[j,k]<pvalue2 & mkz[j,k]<0){
      trendpic[j,k] = 1
    } else {
      trendpic[j,k] = 2
    }
  }
}

setwd("E:/YANGTZE/YRD")
######
GridTopology1km <- GridTopology(cellcentre.offset = c(115.7574026,28.01630263), cellsize = c(0.004811252243,0.004811252243),cells.dim = c(ncol,nrow))
#cellcentre.offset�����½�դ���������꣨���ȡ�γ�ȣ���cellsize��դ��ߴ磻dim������*������asciiΪ���½�դ������½Ƕ������꣨��С������Сγ�ȣ�
# Sat.cor <- as.data.frame(SpatialGridDataFrame(grid = GridTopology1km, data = as.data.frame(vector(mode = "numeric",length = nro*nco))))
# Sat.cor <- Sat.cor[,-1]
# colnames(Sat.cor) <- c("xlon","ylat")

######
SatBase.grid <- read.asciigrid("ascii.txt") #ascii˳�������Ͻǿ�ʼ��һ��һ��
Sat.base <- as.data.frame(SatBase.grid)
colnames(Sat.base) <- c("ascii","xlon","ylat")
Sat.base <- Sat.base[order(Sat.base$xlon,-Sat.base$ylat),] #��Ϊ��R����һ�������Ͻǿ�ʼ��һ��һ��
#SatBase.raster <- raster(Sat.base,layer=1,values=T)
#plot(SatBase.raster)
#Sat.base1 <- merge(Sat.cor,Sat.base,by.x=c("xlon","ylat"),by.y=c("xlon","ylat"),all.x=T)



dim(trendpic) <- c(nrow*ncol,1)
trendpic1 <- as.data.frame(trendpic)
trendpic1 <- cbind(Sat.base,trendpic1)



######
ET05_1km.grid <- SpatialGridDataFrame(grid = GridTopology1km, data = as.data.frame(trendpic1$V1))#data�������ݿ�����,����grid��
ET05_1km.raster <- raster(ET05_1km.grid,layer=1,values=T)
#plot(ET05_1km.raster)
newname <- paste('RH14Z','trend','tif',sep = ".")
writeRaster(ET05_1km.raster,newname)