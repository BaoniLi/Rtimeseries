library(raster)
library(sp)
library(rgdal)
library(gstat)
library(maptools)

#���ù����ռ�
setwd("D:/datasets1/krigtmean")


#��ȡվ�����ݼ�����ֵ����
gauge_data_all<-na.omit(read.table("D:/datasets1/krigtmean.txt"))
date_len = ncol(gauge_data_all) #��ȡ������,����ѭ������
yzsta <- read.table("D:/datasets1/meteostatmean.txt",header=T)


for (i in seq(1,date_len,1)) {
  gauge_data = gauge_data_all[,i] # each column is a tif
   
  ##�趨վ�����ݵ�ͶӰΪWGS84����lon
  dsp <- SpatialPoints(yzsta[,2:3], proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  dsp <- SpatialPointsDataFrame(dsp,yzsta)
  
  #�˶λ���δͶӰ��ƽ������,���������޸�,��Ӱ����
  WGS84<- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")#���òο�ϵWGS84
  dsp1<-spTransform(dsp,WGS84)#����γ��ת��ƽ�����꣬ʹ��WGS�ο�ϵ
  #bound1<-spTransform(bound,WGS84)
  
  #���Ʋ�ֵ�ֱ���,����դ��ģ��
  template_raster<-raster("D:/CHM_PRE/krig.tif")
  #bound_raster<-rasterize(bound,template_raster)
  
  non_missing_indices <- !is.na(gauge_data)
  min_non_missing <- min(gauge_data[non_missing_indices], na.rm = TRUE)
  gauge_data[!non_missing_indices] <- min_non_missing
  
  # Calculate variogram
  v <- variogram(gauge_data ~ 1, data = dsp1)
  # plot(v,plot.number=T)
  v.fit<-fit.variogram(v,model=vgm(1,"Lin",0))
  #plot(v,v.fit)
  Grid<-as(template_raster,"SpatialGridDataFrame")#�����ֽ��߽�դ��ת�ɿռ�����
  kri<-krige(formula=gauge_data~1,model=v.fit,locations=dsp1,newdata=Grid,nmax=12, nmin=10)#locationΪ��֪������ꣻnewdataΪ��Ҫ��ֵ�ĵ��λ�ã�nmax��nmin�ֱ������������������ĸ���
  # spplot(kri["var1.pred"])
  
  date = i #������
  newname <- paste(date,'tif',sep = ".")
  writeRaster(raster(kri["var1.pred"]),newname)
  
  #str1 = paste('��',date,'��ֵ���',sep='')
  print(date)
}