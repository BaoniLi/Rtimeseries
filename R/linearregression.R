library(trend)
library(utils)
library(raster)
library(sp)

######
setwd("D:/202111/NH/UP/TE")

dir = list.files(pattern = "tif")
fns = Sys.glob(dir)
YEAR <- length(fns)  #����(����.tif�ļ��ĸ���)

######
nrow = 968
ncol = 1518
p = array(0,dim=c(nrow,ncol,YEAR))
coe = array(0,dim=c(nrow,ncol))
x = c(1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017)
nn = 53

#��ȡդ�����ݵ���ά����
for (i in (1:YEAR))
{
  d = matrix(0,nrow,ncol)
  # raster1 <- paste('RH','idw',i,'tif',sep = ".") #####################################
  d[] <- raster(fns[i])
  p[,,i] <- d[]                        
}

#���Ƽ���
for (j in (1:nrow))
{
  for (k in (1:ncol))
  {
    y = p[j,k,]
    if (sum(is.na(y))>0){
      coe[j,k] = NA
    } else {
      fit <- lm(y~x)
      coe[j,k] <- fit$coefficients[2]
    }
  }
}


trendpic = matrix(0,nrow,ncol)


#������ͼ
for (j in (1:nrow))
{
  for (k in (1:ncol))
  {
    trendpic[j,k] = coe[j,k]
  }
}

setwd("D:/202111/NH/UP")
######
GridTopology1km <- GridTopology(cellcentre.offset = c(101.9422626,27.66348163), cellsize = c(0.004811252243,0.004811252243),cells.dim = c(ncol,nrow))

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
newname <- paste('TE','tif',sep = ".")
writeRaster(ET05_1km.raster,newname)