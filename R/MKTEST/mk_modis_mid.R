library(trend)
library(utils)
library(raster)
library(sp)

######
setwd("E:/YANGTZE/MID/ET")

dir = list.files(pattern = "tif")
fns = Sys.glob(dir)
YEAR <- length(fns)  #����(����.tif�ļ��ĸ���)

######
nrow = 1384
ncol = 1711
p = array(0,dim=c(nrow,ncol,YEAR))
mkp = array(0,dim=c(nrow,ncol))
mkz = array(0,dim=c(nrow,ncol))


#��ȡդ�����ݵ���ά����
for (i in (1:YEAR))
{
  d = matrix(0,nrow,ncol)
  d[] <- raster(fns[i])
  p[,,i] <- d[]                        
}

#���Ƽ���
for (j in (1:nrow))
{
  for (k in (1:ncol))
  {
    timeseries = p[j,k,]
    mk <- mk.test(timeseries)
    mkp[j,k] <- mk$p.value
    mkz[j,k] <- mk$statistic
  }
}
# a<-p[62,1,]
# b<-p[63,1,]
# c<-p[64,1,]
# a
# b
# c
# mk1 <- mk.test(a)$statistic
# mk2 <- mk.test(b)$statistic
# mk3 <- mk.test(c)$statistic


######
# write.csv(mkz,"E:/YANGTZE/MID/mkzET_0.1.csv")
# write.csv(mkp,"E:/YANGTZE/MID/mkpET_0.1.csv")


pvalue = 0.1


nro <- nrow(mkp)
nco <- ncol(mkp)
trendpic = matrix(0,nrow,ncol)


#������ͼ
for (j in (1:nrow))
{
  for (k in (1:ncol))
  {
    if (is.na(mkz[j,k])|is.na(mkp[j,k])){
      trendpic[j,k] = 2
    } else if (mkp[j,k]<pvalue & mkz[j,k]<0){
      trendpic[j,k] = 0
    } else if (mkp[j,k]<pvalue & mkz[j,k]>0){
      trendpic[j,k] = 1
    } else {
      trendpic[j,k] = 2
    }
  }
}


setwd("E:/YANGTZE/MID")
######
GridTopology1km <- GridTopology(cellcentre.offset = c(110.2526646,25.98056863), cellsize = c(0.004811252243,0.004811252243),cells.dim = c(ncol,nrow))
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
newname <- paste('ET14','trend','tif',sep = ".")
writeRaster(ET05_1km.raster,newname)

# data <- read.csv(file = "s5.csv")
# Z = c(0)
# P1 = c(0)
# for (i in 1:nrow(data)) {
#   mk <- mk.test(as.numeric(data[i,]))
#   #ÿ����һ�μ�һ������
#   Z = c(Z,mk$statistic)
#   P1 = c(P1,mk$p.value)
# }
# Q = data.frame(Z,P1)
# write.table(Q,"s5mk.txt")
# #E = data$V1
# #pettitt.test(E)
# #print(mkp$p.value)