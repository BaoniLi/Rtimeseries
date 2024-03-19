library(raster)
library(sp)
library(rgdal)
library(gstat)
library(maptools)

#���ù����ռ�
setwd("E:/YANGTZE/UP/EA")

#��ȡվ�����ݼ�����ֵ����
gauge_data_all<-na.omit(read.table("E:/YANGTZE/UP/EA.txt"))
date_len = ncol(gauge_data_all) #��ȡ������,����ѭ������
yzsta <- read.table("E:/YANGTZE/YZstation/up.txt",header=T)

# #��ȡ����ʸ���߽�(��ֵ���հ�դ��ʱ��Ҫ��Ĥ�ü�)
# bound<-readOGR("YZDEM/subshp/s5.shp")
# #plot(bound,col="grey")

for (i in seq(1,date_len,1)) {
  gauge_data = gauge_data_all[,i]
  
  ##�趨վ�����ݵ�ͶӰΪWGS84����lon
  dsp <- SpatialPoints(yzsta[,2:3], proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  dsp <- SpatialPointsDataFrame(dsp,yzsta)
  
  #�˶λ���δͶӰ��ƽ������,���������޸�,��Ӱ����
  WGS84<- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")#���òο�ϵWGS84
  dsp1<-spTransform(dsp,WGS84)#����γ��ת��ƽ�����꣬ʹ��WGS�ο�ϵ
  #bound1<-spTransform(bound,WGS84)
  
  #���Ʋ�ֵ�ֱ���,����դ��ģ��
  template_raster<-raster("E:/YANGTZE/YZDEM/up/template.tif")
  #bound_raster<-rasterize(bound,template_raster)
  
  #������Ȩ��(idw)��ֵ
  gs <- gstat(formula=gauge_data~1, locations=dsp1,set=list(idp = 2))
  idw <- interpolate(template_raster, gs)
  #idwmask<-mask(idw,bound)
  #plot(idwmask)
  date = i #������
  newname <- paste('EA','idw',date,'tif',sep = ".")
  writeRaster(idw,newname)
  str1 = paste('��',date,'���ֵ���',sep='')
  print(str1)
}