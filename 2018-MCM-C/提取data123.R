rm(list=ls(all=TRUE))
func.time <- proc.time()
library(MASS)
library(mvtnorm)
MCM<-read.table("ProblemCData.csv",header=TRUE,sep=",",colClasses=c("character","character","numeric","numeric"))
EXD<-read.table("ExtraData.csv",header=TRUE,sep=",",colClasses=c("character","numeric","numeric"))
no<-c("Pe","NG","Co","NP","RE","NI","NIS","TC","RS","IS","CS","TS","TEV","EPS","E")
st<-c("AZ","CA","NM","TX")
ye<-c(1960:2009)
socmx<-array(0,c(15,15,50,4),dimnames=list(no,no,ye,st))
for(i in ye)
{
for(j in st)
{
attach(MCM)
CLACB<-MCM[MSN=="CLACB"&Year==i&StateCode==j,][1,4]
CLCCB<-MCM[MSN=="CLCCB"&Year==i&StateCode==j,][1,4]
CLEIB<-MCM[MSN=="CLEIB"&Year==i&StateCode==j,][1,4]
CLICB<-MCM[MSN=="CLICB"&Year==i&StateCode==j,][1,4]
CLRCB<-MCM[MSN=="CLRCB"&Year==i&StateCode==j,][1,4]
CLTCB<-MCM[MSN=="CLTCB"&Year==i&StateCode==j,][1,4]
ELISB<-MCM[MSN=="ELISB"&Year==i&StateCode==j,][1,4]
ELNIB<-MCM[MSN=="ELNIB"&Year==i&StateCode==j,][1,4]
ESACB<-MCM[MSN=="ESACB"&Year==i&StateCode==j,][1,4]
ESCCB<-MCM[MSN=="ESCCB"&Year==i&StateCode==j,][1,4]
ESICB<-MCM[MSN=="ESICB"&Year==i&StateCode==j,][1,4]
ESRCB<-MCM[MSN=="ESRCB"&Year==i&StateCode==j,][1,4]
NGACB<-MCM[MSN=="NGACB"&Year==i&StateCode==j,][1,4]
NGCCB<-MCM[MSN=="NGCCB"&Year==i&StateCode==j,][1,4]
NGEIB<-MCM[MSN=="NGEIB"&Year==i&StateCode==j,][1,4]
NGICB<-MCM[MSN=="NGICB"&Year==i&StateCode==j,][1,4]
NGRCB<-MCM[MSN=="NGRCB"&Year==i&StateCode==j,][1,4]
NNTCB<-MCM[MSN=="NNTCB"&Year==i&StateCode==j,][1,4]
NUETB<-MCM[MSN=="NUETB"&Year==i&StateCode==j,][1,4]
PAACB<-MCM[MSN=="PAACB"&Year==i&StateCode==j,][1,4]
PACCB<-MCM[MSN=="PACCB"&Year==i&StateCode==j,][1,4]
PAEIB<-MCM[MSN=="PAEIB"&Year==i&StateCode==j,][1,4]
PAICB<-MCM[MSN=="PAICB"&Year==i&StateCode==j,][1,4]
PARCB<-MCM[MSN=="PARCB"&Year==i&StateCode==j,][1,4]
PMTCB<-MCM[MSN=="PMTCB"&Year==i&StateCode==j,][1,4]
RETCB<-MCM[MSN=="RETCB"&Year==i&StateCode==j,][1,4]
TEACB<-MCM[MSN=="TEACB"&Year==i&StateCode==j,][1,4]
TECCB<-MCM[MSN=="TECCB"&Year==i&StateCode==j,][1,4]
TEICB<-MCM[MSN=="TEICB"&Year==i&StateCode==j,][1,4]
TERCB<-MCM[MSN=="TERCB"&Year==i&StateCode==j,][1,4]
TETCB<-MCM[MSN=="TETCB"&Year==i&StateCode==j,][1,4]
ESTCB<-MCM[MSN=="ESTCB"&Year==i&StateCode==j,][1,4]
TETXB<-MCM[MSN=="TETXB"&Year==i&StateCode==j,][1,4]
detach(MCM)
if (j=="AZ") jn=1
if (j=="CA") jn=2
if (j=="NM") jn=3
if (j=="TX") jn=4
socmx[1,8,i-1959,jn]<-PMTCB/TETCB*100
socmx[2,8,i-1959,jn]<-NNTCB/TETCB*100
socmx[3,8,i-1959,jn]<-CLTCB/TETCB*100
socmx[4,8,i-1959,jn]<-NUETB/TETCB*100
socmx[5,8,i-1959,jn]<-RETCB/TETCB*100
socmx[6,8,i-1959,jn]<-ELNIB/TETCB*100
socmx[7,8,i-1959,jn]<-ELISB/TETCB*100
socmx[1,9,i-1959,jn]<-PARCB/TETCB*100
socmx[2,9,i-1959,jn]<-NGRCB/TETCB*100
socmx[3,9,i-1959,jn]<-CLRCB/TETCB*100
socmx[15,9,i-1959,jn]<-ESRCB/ESTCB*100
socmx[1,10,i-1959,jn]<-PAICB/TETCB*100
socmx[2,10,i-1959,jn]<-NGICB/TETCB*100
socmx[3,10,i-1959,jn]<-CLICB/TETCB*100
socmx[15,10,i-1959,jn]<-ESICB/ESTCB*100
socmx[1,11,i-1959,jn]<-PACCB/TETCB*100
socmx[2,11,i-1959,jn]<-NGCCB/TETCB*100
socmx[3,11,i-1959,jn]<-CLCCB/TETCB*100
socmx[15,11,i-1959,jn]<-ESCCB/ESTCB*100
socmx[1,12,i-1959,jn]<-PAACB/TETCB*100
socmx[2,12,i-1959,jn]<-NGACB/TETCB*100
socmx[3,12,i-1959,jn]<-CLACB/TETCB*100
socmx[15,12,i-1959,jn]<-ESACB/ESTCB*100
socmx[9,13,i-1959,jn]<-TERCB/TETXB*100
socmx[10,13,i-1959,jn]<-TEICB/TETXB*100
socmx[11,13,i-1959,jn]<-TECCB/TETXB*100
socmx[12,13,i-1959,jn]<-TEACB/TETXB*100
socmx[1,14,i-1959,jn]<-PAEIB/TETCB*100
socmx[2,14,i-1959,jn]<-NGEIB/TETCB*100
socmx[3,14,i-1959,jn]<-CLEIB/TETCB*100
socmx[4,14,i-1959,jn]<-NUETB/TETCB*100
socmx[5,14,i-1959,jn]<-RETCB/TETCB*100
socmx[14,15,i-1959,jn]<-(PAEIB+NGEIB+CLEIB+NUETB+RETCB)/ESTCB*100
}}

XXX<-NULL
for(i in 1:7)
{
j=8
for (t in ye)
 {LB<-data.frame(i=i,j=j,t=t-1959,ni=no[i],nj=no[j],x=socmx[i,j,t-1959,4],pop=EXD[EXD$State=="TX"&EXD$Year==t,][1,3])
XXX<-rbind(XXX,LB)
}
}
data1<-XXX   ##各大能源板块占总消耗能源的比重
write.table(data1,"data1.txt",sep=",")
#####################################################
XXX<-NULL
for(i in 9:12)
{
j=13
for (t in ye)
 {LB<-data.frame(i=i,j=j,t=t-1959,ni=no[i],nj=no[j],x=socmx[i,j,t-1959,4],pop=EXD[EXD$State=="TX"&EXD$Year==t,][1,3])
XXX<-rbind(XXX,LB)
}
}
data2<-XXX   ##各大部门消耗能源占总消耗能源的比重
write.table(data2,"data2.txt",sep=",")
#####################################################
XXX<-NULL
for(j in 9:12)
{
i=15
for (t in ye)
 {LB<-data.frame(i=i,j=j,t=t-1959,ni=no[i],nj=no[j],x=socmx[i,j,t-1959,4],pop=EXD[EXD$State=="TX"&EXD$Year==t,][1,3])
XXX<-rbind(XXX,LB)
}
}
data3<-XXX   ##电能供给各大部门的比重
write.table(data3,"data3.txt",sep=",")



