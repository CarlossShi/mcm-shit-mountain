library(rgl)
col.names=c("n","t")
for (i in 1:42)
{col.names<-c(col.names,paste(c("x","y","z"),i,sep=""))}
length(col.names)

###读取所有csv文件
getwd()
setwd("C:/Users/hasee/Desktop/18亚太赛/比赛开始了/2018 APMCM Problem A/csv daya")
temp = list.files(pattern="*.csv")
data<-list()
for (per in temp){
table<-read.table(per,header=FALSE,sep=",",col.names=col.names)
table_1<-list()
for (i in 1:42)
{table_1[[i]]<-as.data.frame(cbind(table[1:2],table[(3*i):(3*i+2)]))}
data[[per]]<-table_1}
###

##data[["aizhenjiang_g10.csv"]][[42]][180,]
##最大帧数max(data[["aizhenjiang_g10.csv"]][[42]][,1])最小帧数：1
##最大时间max(data[["aizhenjiang_g10.csv"]][[42]][,2])最小时间：0


##对某个人，画他的运动3d图
man<-"aizhenjiang_g10.csv"
max_n<-max(data[[man]][[42]][,1])

for (n in 1:max_n){
datum<-matrix(ncol=5,nrow=42)
for (i in 1:42)
{
datum[i,]<-as.matrix(data[[man]][[i]][n,])
}
x=datum[,3]
y=datum[,4]
z=datum[,5]
plot3d(x,y,z)
Sys.sleep
}
###

###kmeans聚类分析判断类大小的函数
wssplot<-function(data,nc=15,seed=1234)
{wss<-(nrow(data)-1)*sum(apply(data,2,var))
for (i in 2:nc){
set.seed(seed)
wss[i]<-sum(kmeans(data,centers=i)$withinss)}
plot(1:nc,wss,type="b",xlab="Number of Clusters",ylab="Within groups sum of squares")}
###


###42*42相关性矩阵
cor_matrix<-matrix(0,nrow=42,ncol=42)
for (per in temp){
max_n<-max(data[[per]][[42]][,1])
for (j in 3:5){
data_k<-matrix(ncol=max_n,nrow=42)
for (i in 1:42)
{data_k[i,]<-t(as.matrix(data[[per]][[i]][,j]))}
df<-scale(data_k)
#wssplot(df,nc=25)
set.seed(1234)
fit.km<-kmeans(df,25,nstart=25)
res<-fit.km$cluster

for (p in 1:41){
for (q in (p+1):42){
if (res[p]==res[q]){
cor_matrix[p,q]=cor_matrix[p,q]+1
}}}
}}
sum(sum(cor_matrix))
###用推荐系统的包做数据可视化
library(recommenderlab)
movie<-as(t(cor_matrix)+cor_matrix,"realRatingMatrix")
getRatingMatrix(movie)
image(movie)
###
###矩阵元素排序
col1<- c(cor_matrix[order(cor_matrix, decreasing = T)])
col1[col1!=0]
which(cor_matrix == 160,arr.ind = T)
###


poi<-c(40,41,16,17,15,30,29,13,14,18,19,20,21,38,39,11,12,9,10,5,6,34,35,4,5)
wei_m<-c(0.022,0.022,0.016,0.016,0.119,0.119,0.08,0.08,0.08,0.0265,0.0265,0.015,0.015,
0.009,0.009,0.1,0.1,0.0535,0.0535,0.007,0.007,0.006,0.006,0.006,0.006)
wei_f<-c(0.0185,0.0185,0.013,0.013,0.122,0.122,0.082,0.081,0.081,0.0255,0.0255,0.013,0.013,
0.006,0.006,0.1115,0.1115,0.0535,0.0535,0.005,0.005,0.005,0.005,0.005,0.005)



###计算每一帧的重心
getwd()
setwd("C:/Users/hasee/Desktop/18亚太赛/比赛开始了/2018 APMCM Problem A")
annex1<-as.matrix(read.table("Annex 1 Basic Data of Elderly People.csv",fill=TRUE,sep=","))

getwd()
setwd("C:/Users/hasee/Desktop/18亚太赛/比赛开始了/2018 APMCM Problem A/csv daya")
temp = list.files(pattern="*.csv")



library(BB)
result<-list()
for (man in temp){
name<-strsplit(man,"_")[[1]][1]
max_n<-max(data[[man]][[42]][,1])
if (annex1[which(annex1 == name,arr.ind = T)[1,1],3]=="Male"){
wei<-wei_m}
if (annex1[which(annex1 == name,arr.ind = T)[1,1],3]=="Female"){
wei<-wei_f}

gmat<-matrix(ncol=5,nrow=max_n)
for (i in 1:max_n){
gx=c(0)
gy=c(0)
gz=c(0)
for (j in 1:25){
gx<-gx+data[[man]][[poi[j]]][i,][1,3]*wei[j]
gy<-gy+data[[man]][[poi[j]]][i,][1,4]*wei[j]
gz<-gz+data[[man]][[poi[j]]][i,][1,5]*wei[j]}
gmat[i,]<-c(i,data[[man]][[1]][i,][1,2],gx,gy,gz)
}
###对xy坐标进行旋转变换，使得人尽量走直线
#man<-"aizhenjiang_g10.csv"
#name<-"aizhenjiang"
#max_n<-max(data[[man]][[42]][,1])

data_rot<-data
sum_var_temp=0
for (i in c(3,4,5,6,34,35)){
sum_var_temp<-sum_var_temp+var(data[[man]][[i]][[4]])}
res=matrix(c(0,sum_var_temp)) #储存最小方差时的a和方差的矩阵

for (a in seq(from=-pi/4,to=pi/4,by=pi/3600)){ ###找出最小样本方差时的a
sum_var_new=0
for (i in c(3,4,5,6,34,35)){  ###让脚尽量走直线
old<-as.matrix(data[[man]][[i]][3:4])
rot<-matrix(c(cos(a),sin(a),-sin(a),cos(a)),nrow=2,byrow=TRUE)
new<-old%*%rot
sum_var_new<-sum_var_new+var(new[,2])}
if (sum_var_new<sum_var_temp){
res[1,1]<-a
res[2,1]<-sum_var_new
sum_var_temp<-sum_var_new
print(res)
}}
a=res[1,1]
for (i in 1:42){
old<-as.matrix(data[[man]][[i]][3:4])
rot<-matrix(c(cos(a),sin(a),-sin(a),cos(a)),nrow=2,byrow=TRUE)
new<-old%*%rot
data_rot[[man]][[i]][3:4]<-new[,1:2]}
res

###平衡模型可视化
###重心在前面给出，人变后要重新计算重心

sco1<-c()
sco2<-c()
t<-c()
plot(c(-500,500), c(-500,500), type="n", main="test draw.ellipse")
for (n in 1:max_n){

x6<-data_rot[[man]][[6]][n,][1,3]
y6<-data_rot[[man]][[6]][n,][1,4]
x5<-data_rot[[man]][[5]][n,][1,3]
y5<-data_rot[[man]][[5]][n,][1,4]
x35<-data_rot[[man]][[35]][n,][1,3]
y35<-data_rot[[man]][[35]][n,][1,4]
x34<-data_rot[[man]][[34]][n,][1,3]
y34<-data_rot[[man]][[34]][n,][1,4]
x4<-data_rot[[man]][[4]][n,][1,3]
y4<-data_rot[[man]][[4]][n,][1,4]
x3<-data_rot[[man]][[3]][n,][1,3]
y3<-data_rot[[man]][[3]][n,][1,4]
lx<-x6
ly<-y6
rx<-x5
ry<-y5
if(x35>x34){
fx<-x35
fy<-y35
bx<-x3
by<-y3
}
if(x35<=x34){
fx<-x34
fy<-y35
bx<-x4
by<-y4}

aa<-matrix(c(ly^2,ry^2,fy^2,by^2,
		-2*lx,-2*rx,-2*fx,-2*bx,
		-2*ly,-2*ry,-2*fy,-2*by,
		1,1,1,1),4,4)
bb<-c(-lx^2,-rx^2,-fx^2,-bx^2)
abpq<-solve(aa,bb)
p<-abpq[2]
q<-abpq[3]/abpq[1]
if (p^2+abpq[1]*q^2-abpq[4]<=0){
print(paste(man,"椭圆长轴＜=0"))
next}
a<-sqrt(p^2+abpq[1]*q^2-abpq[4])
if (a^2/abpq[1]<=0){
print(paste(man,"椭圆短轴＜=0"))
next}
b<-sqrt(a^2/abpq[1])  ###理论上说a大于b，因为要迈开步子

#plot(c(-500,500), c(-500,500), type="n", main="test draw.ellipse")

text(450,470,paste("t =",data_rot[[man]][[1]][n,2]))
draw.ellipse(0,0,b,a,border='black',col='white')

points(y5-q,x5-p)
points(y6-q,x6-p)
points(y35-q,x35-p)
points(y34-q,x34-p)
points(y3-q,x3-p)
points(y4-q,x4-p)
lines(c(y35-q,y6-q),c(x35-p,x6-p))
lines(c(y4-q,y6-q),c(x4-p,x6-p))
lines(c(y35-q,y4-q),c(x35-p,x4-p))
lines(c(y34-q,y5-q),c(x34-p,x5-p))
lines(c(y3-q,y5-q),c(x3-p,x5-p))
lines(c(y34-q,y3-q),c(x34-p,x3-p))

gx<-gmat[n,3]
gy<-gmat[n,4]
gz<-gmat[n,5]
points(gy-q,gx-p,col="red")
if(((gx-p)^2+(gy-q)^2)/a/b>1.5){
print("重心与椭圆中心距离与椭圆半径的比值>1.5，不符合常理")
next}
sco1[n]<-((gx-p)^2+(gy-q)^2)/a/b  ###重心与椭圆中心距离与椭圆半径的比值
sco2[n]<-sqrt((gx-p)^2+(gy-q)^2)/gz
t[n]<-data_rot[[man]][[1]][n,2]
Sys.sleep(0.2)
rect(xleft = 350, ybottom = 390, xright = 530, ytop = 530,border="white",col="white")
}
t<-na.omit(t)
sco1<-na.omit(sco1)
sco2<-na.omit(sco2)
plot(t,sco1,type="b",col="blue",pch=15,xlab="Time",ylab="Equilibrium Index")
#lines(t,sco2,type="b",col="red",pch=17)
#legend("topleft",inset=.05,c("Index 1","Index 2"),pch=c(15,17),col=c("blue","red"))
legend("topleft",inset=.05,"Index 1",pch=15,col="blue")

result[[man]]<-matrix(c(t,sco1,sco2),ncol=3)}




###对result分析
getwd()
setwd("C:/Users/hasee/Desktop/18亚太赛/比赛开始了/2018 APMCM Problem A")
annex1<-as.matrix(read.table("Annex 1 Basic Data of Elderly People.csv",fill=TRUE,sep=","))

getwd()
setwd("C:/Users/hasee/Desktop/18亚太赛/比赛开始了/2018 APMCM Problem A/csv daya")
temp = list.files(pattern="*.csv")


man<-"hanyingchun_g9.csv"

name<-c()
max_sco1<-c()
mean_sco1<-c()
var_sco1<-c()  ###样本方差
max_sco2<-c()
mean_sco2<-c()
var_sco2<-c()
n=1
for (man in temp){
name[n]<-strsplit(man,"_")[[1]][1]
m<-length(result[[man]][,2])
mm<-round(m/8):round(7*m/8)
plot(result[[man]][,1],result[[man]][,2],type="b",col="blue",xlab="Time",ylab="Equilibrium Index",main=man)
lines(result[[man]][,1],result[[man]][,3],type="b",col="red")
max_sco1[n]<-max(result[[man]][mm,2],na.rm=TRUE)
mean_sco1[n]<-mean(result[[man]][mm,2],na.rm=TRUE)
var_sco1[n]<-var(result[[man]][mm,2],na.rm=TRUE)
max_sco2[n]<-max(result[[man]][mm,3],na.rm=TRUE)
mean_sco2[n]<-mean(result[[man]][mm,3],na.rm=TRUE)
var_sco2[n]<-var(result[[man]][mm,3],na.rm=TRUE)
n=n+1}

ndata<-data.frame(name,max_sco1,mean_sco1,var_sco1,
max_sco2,mean_sco2,var_sco2)
ndata<-data.frame(name,
max_sco1,rx1=rank(ndata$max_sco1),mean_sco1,rm1=rank(ndata$mean_sco1),var_sco1,
max_sco2,rx2=rank(ndata$max_sco2),mean_sco2,rm2=rank(ndata$mean_sco2),var_sco2)
ndata<-data.frame(name,
max_sco1,rx1=rank(ndata$max_sco1),mean_sco1,rm1=rank(ndata$mean_sco1),var_sco1,
max_sco2,rx2=rank(ndata$max_sco2),mean_sco2,rm2=rank(ndata$mean_sco2),var_sco2,
risk=ndata[[3]]+ndata[[5]]+ndata[[8]]+ndata[[10]])

ndata[order(ndata[,12],decreasing = T),]
n1<-ndata[c(1,2,4)][ndata[2]>1,]
n2<-n1[n1[3]>0.3,]
