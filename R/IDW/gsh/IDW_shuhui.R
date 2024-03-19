library(raster)
library(sp)
library(rgdal)
library(gstat)
library(raster)
library(maptools)
##���ù����ռ�
setwd("D:/��������/griddata")

#��ȡʵ��վ�㽵�����ݣ�1�죩
gauge_data_all<-na.omit(read.csv("gsh/TEM.csv",header=T))

date_len = nrow(gauge_data_all) #��ȡ������,����ѭ������
sta <- read.csv("gsh/STA.csv",header=F)
#��ȡ������߽�
bound<-readOGR("shp/shm_TJ.shp")
plot(bound,col="grey")

for (i in seq(1,date_len/3,1)) {
  start_row = 3*(i-1)+1 #ÿһ��ѭ����ʼ��ȡ������
  end_row = i*3  #ÿһ��ѭ��������ȡ������
  gauge_data = gauge_data_all[start_row:end_row,]
  
  ##�趨�������ݵ�ͶӰΪWGS84
  dsp <- SpatialPoints(sta[,2:3], proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  dsp <- SpatialPointsDataFrame(dsp,gauge_data)
  
  #�˶λ���δͶӰ��ƽ������,���������޸�,��Ӱ����
  WGS84<- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")#���òο�ϵWGS84
  dsp1<-spTransform(dsp,WGS84)#����γ��ת��ƽ�����꣬ʹ��WGS�ο�ϵ
  bound1<-spTransform(bound,WGS84)
  
  template_raster<-raster("tj.tif")  #���п��Ʋ�ֵ�ֱ���
  bound_raster<-rasterize(bound,template_raster)
  
  #������Ȩ��(idw)��ֵ
  gs <- gstat(formula=gauge_data[,8]~1, locations=dsp1,set=list(idp = 2))
  idw <- interpolate(bound_raster, gs)
  idwmask<-mask(idw,bound)
  plot(idwmask)
  date = i + 1964 #������
  newname<- paste('shm_TJ','idw',date,'tif',sep = ".")
  writeRaster(idwmask,newname)
  str1 = paste('��',date,'���ֵ���',sep='')
  print(str1)
}

#�������ȡ��csv����.
library(utils)
dir=list.files(pattern = "tif")
fns = Sys.glob(dir)
YEAR <- length(fns)  #����(�������ɵ�.tif�ļ��ĸ���)
p = matrix(0,204*243,YEAR)    #�ܹ�12*10��դ��ÿһ�д��һ�������(�޳���NAֵ����)

for (i in (1:YEAR)) 
{
  d = matrix(0,204,243)
  d[]<- raster(fns[i])
  dim(d) <- c(nrow(d)*ncol(d),1)      #�����ж�������ת��Ϊһ��
  p[,i]<-d[,1]                        #��ÿһ�����ӵ����ܱ���
}
write.csv(p,"D:/��������/griddata/gsh/111.csv") #���ɵı����а�NA��ɾ�������ֵ���ɵõ���ƽ��������