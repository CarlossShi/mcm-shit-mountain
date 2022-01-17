import numpy as np
import pandas as pd
import networkx as nx
import itertools as it

from collections import Counter

def m_time(pos1,pos2): #计算rgv在两点间运动的最短时间
    d=abs(pos1-pos2)
    if d==1:
        return m1
    elif d==2:
        return m2
    elif d==3:
        return m3
    elif d==0:
        return 0
#m1,m2,m3,p1,p21,p22,to,te,w=20,33,46,400,400,378,10,50,50
#m1,m2,m3,p1,p21,p22,to,te,w=20,33,46,560,400,378,28,31,25
#m1,m2,m3,p1,p21,p22,to,te,w=23,41,59,580,280,500,30,35,30
m1,m2,m3,p1,p21,p22,to,te,w=18,32,46,545,455,182,27,32,25

data=[]
aaa=0

# for set_c84 in list(set(list(it.permutations("11111222",8))))
set_c84=('2','1','2','1','1','2','1','1')
#aaa = aaa + 1
t=0
v_pos = 1  # 初始位置为1，右侧依次为2、3、4
v_sit = 0  # 0停止，1移动，2上料，3下料、上料、清洗
rgv=np.array([[t,v_pos,v_sit]])
#set_c84=('1', '2', '1', '2', '2', '1', '1', '2')
c_sit=0 #表示cnc的作业状态，0为空闲且无孰料，1为空闲且有孰料，2为工作中
cnc=[]
cnc_inf=[]
c_pos=0 #表示初始位置，无实际意义
for num in range(1,9):
    if num==1 or num==2:
        c_pos=1
    elif num==3 or num==4:
        c_pos=2
    elif num==5 or num==6:
        c_pos=3
    elif num==7 or num==8:
        c_pos=4
    if num==1 or num==3 or num==5 or num==7:
        tc=to
    else:
        tc=te
    if set_c84[num-1] == '1':
        cnc.append(np.array([[t, num, c_pos, c_sit,1]]))
        cnc_inf.append(np.array([num,p21,p21,p22,tc,1]))
    if set_c84[num-1] == '2':
        cnc.append(np.array([[t, num, c_pos, c_sit,2]]))
        cnc_inf.append(np.array([num, p22, p21, p22, tc,2]))
    #储存了cnc的加工、上下料时间，是固定的信息

judge_cnc=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]]) #初始cnc加工→休息判断矩阵
judge_move=30000
judge_load=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
judge_layoff=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
t_wait=0
load_num_1=0
load_num_2=0
layoff_num_1=0
layoff_num_2=0
pri_num=0
result_1=np.array([[0,0,0,0]])
result_2=np.array([[0,0,0,0]])
judge_load_4=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
judge_layoff_3=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
judge_layoff_5=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])

for t in range(1,28800): #从第1秒到第5秒
    #print(t)
    #################################
    rgv_new =np.array([t, rgv[t-1,1], rgv[t-1,2]])# # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
    rgv=np.vstack((rgv, rgv_new))#t改变，其他rgv参数复制上一秒的信息
    for num in range(1, 9):
        cnc_new=np.array([t, cnc[num-1][t-1,1],cnc[num-1][t-1,2],cnc[num-1][t-1,3],cnc[num-1][t-1,4]])
        cnc[num-1]=np.vstack((cnc[num-1], cnc_new))#t改变，其他cnc参数复制上一秒的信息
    #################################
    for num in range(1, 9):
        if cnc[num-1][t,3]==2 and t>=judge_cnc[0,num-1] and t<judge_cnc[0,num-1]+1: #cnc加工完成，给rgv发信号
            cnc[num - 1][t, 3] = 1   #cnc从2（工作状态）到1（空闲，上有孰料状态）
    #################################
    if rgv[t,2]==1:    #如果rgv上一秒在移动
        if t>=judge_move and t <judge_move+1:     #判断rgb移动是否完成
            rgv[t,2]=0     #rgv瞬间进入移动后的等待状态，按照算法，这里应当立即对cnc进行操作
            for num in range(1, 9):
                if cnc[num - 1][t, 3] == 1 and num==mov_pro and cnc[num - 1][t, 4] == 2:  # 如果cnc是空闲,上有孰料状态，目标机器匹配
                    rgv[t, 2] = 3 # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_layoff_3[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num_2 = load_num_2 + 1
                    layoff_num_2 = layoff_num_2 + 1
                    print("第%d道工序的第%d号CNC在第%d秒开始下第%d个料" % (cnc[num - 1][t, 4],num, t, layoff_num_2))
                    print("第%d道工序的第%d个CNC在第%d秒开始上第%d个料" % (cnc[num - 1][t, 4],num, t + cnc_inf[num - 1][4] / 2, load_num_2))
                    result_new_2 = np.array([load_num_2, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result_2 = np.vstack((result_2, result_new_2))
                    result_2[layoff_num_2, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 1 and num==mov_pro and cnc[num - 1][t, 4] == 1:  # 如果cnc是空闲,上有孰料状态，目标机器匹配
                    rgv[t, 2] = 5 # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_layoff_5[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num_1= load_num_1 + 1
                    layoff_num_1 = layoff_num_1 + 1
                    print("第%d道工序的第%d号CNC在第%d秒开始下第%d个料" % (cnc[num - 1][t, 4],num, t, layoff_num_1))
                    print("第%d道工序的第%d个CNC在第%d秒开始上第%d个料" % (cnc[num - 1][t, 4],num, t + cnc_inf[num - 1][4] / 2, load_num_1))
                    result_new_1 = np.array([load_num_1, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result_1 = np.vstack((result_1, result_new_1))
                    result_1[layoff_num_1, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 0 and num == mov_pro and cnc[num - 1][t, 4] == 1:  # 如果第一道工序的cnc也是空闲，无料状态（初始状态）,且目标机器匹配
                    rgv[t, 2] = 2  # 0停止，1移动，2上生料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_load[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num_1 = load_num_1 + 1  # 第几个产品
                    print("第%d道工序的第%d号CNC在第%d秒开始上第%d个料" % ( cnc[num - 1][t, 4],num, t, load_num_1))
                    result_new_1 = np.array([load_num_1, num, t, 0,])
                    result_1 = np.vstack((result_1, result_new_1))
                    break  # 一个时间rgv只能进入一种状态，这里进入了2上生料状态
                if cnc[num - 1][t, 3] == 0 and num == mov_pro and cnc[num - 1][t, 4] == 2:  # 如果第二道工序的cnc也是空闲，无料状态（初始状态）,且目标机器匹配
                    rgv[t, 2] = 4 #手上有半熟料，只去上半熟料
                    judge_load_4[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num_2 = load_num_2 + 1  # 第几个产品
                    print("第%d道工序的第%d号CNC在第%d秒开始上第%d个料" % ( cnc[num - 1][t, 4],num, t, load_num_2))
                    result_new_2 = np.array([load_num_2, num, t, 0, ])
                    result_2 = np.vstack((result_2, result_new_2))
                    break
            continue     #移动结束连着上（下）料，继续循环,等待着在judge上下料跳出循环
        else:
            continue       #上一秒在移动，还未停止，继续循环，一直在移动，直到judge移动停止
    if rgv[t,2]==2 or rgv[t,2]==3 or rgv[t,2]==4 or rgv[t,2]==5:
        for num in range(1, 9):
            if t>=judge_load[0,num-1] and t <judge_load[0,num-1]+1:       #这个情况只有在最开始的时候情况
                cnc[num-1][t,3]=2   #cnc从0（空闲，上无料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  #当前时间加cnc工作时间，为cnc的预测空闲时间
                rgv[t,2]=0
            if t>=judge_load_4[0,num-1] and t <judge_load_4[0,num-1]+1:       #这个情况只有在最开始的时候情况
                cnc[num-1][t,3]=2   #cnc从0（空闲，上无料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  #当前时间加cnc工作时间，为cnc的预测空闲时间
                rgv[t,2]=0
            if t>=judge_layoff_3[0,num-1] and t <judge_layoff_3[0,num-1]+1:     #上下料同时进行
                cnc[num-1][t,3]=2 #cnc从1（空闲，上有孰料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  #当前时间加cnc工作时间，为cnc的预测空闲时间
            if t >= judge_layoff_3[0, num - 1] +w and t <judge_layoff_3[0, num - 1]+w+1:  # 上下料同时进行
                rgv[t,2] = 0  #rgv清洗后再进入等待状态
            if t >= judge_layoff_5[0, num - 1] and t < judge_layoff_5[0, num - 1] + 1:  # 上下料同时进行
                cnc[num - 1][t, 3] = 2  # cnc从1（空闲，上有孰料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  # 当前时间加cnc工作时间，为cnc的预测空闲时间
            if t >= judge_layoff_5[0, num - 1] + w and t < judge_layoff_5[0, num - 1] + w + 1:  # 上下料同时进行
                rgv[t, 2] = 0  # rgv清洗后再进入等待状态
                # rgv瞬间进入等待状态,因为我们判断下料后一定会上料，这里要不要直接跳过搜索空闲cnc的过程？
###################################################################
    if rgv[t,2]==0:  #如果rgv空闲
        cnc_stop_num_1 = []
        cnc_stop_num_2 = []
        for num in range(1, 9):
            if cnc[num-1][t,3]==0 or cnc[num-1][t,3]==1:   #如果cnc也是空闲状态
                if cnc [num-1][t,4]==1:
                    cnc_stop_num_1.append(cnc[num-1][t,1])   #调出空闲状态的第一道工序的cnc机号
                if cnc [num-1][t,4]==2:
                    cnc_stop_num_2.append(cnc[num-1][t,1])   #调出空闲状态的第二道工序的cnc机号
##########################################################################################################################################################
# 0停止，1移动，2上生料，3下熟料、上半熟料、清洗,4上半熟料，5下半熟料，上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
        tt = t
        if tt == 1:
            sit_bef = 2  ##第一秒直接去找第一道工序的cnc
        else:
            sit_bef = rgv[tt, 2]
            while sit_bef == 0:  # 偷看rgv等待前在干什么，一定不会是移动状态
                sit_bef = rgv[tt, 2]
                tt=tt-1

        if cnc_stop_num_1 == [] and (sit_bef==2 or sit_bef==3 or sit_bef==4) or cnc_stop_num_2==[] and sit_bef==5:
            t_wait = t_wait + 1
            continue  # 跳出大循环，表示rgv处于等候状态
        else:
            if sit_bef==2 or sit_bef==3 or sit_bef==4: #手上没东西
                est_1 = []
                for i in cnc_stop_num_1:  # 1-8中的几个数
                    est_1.append(m_time(cnc[i - 1][t, 2], rgv[t, 1]) + cnc_inf[i - 1][4])  # 贪心：使它能以最快速度启动
                mov_pro_1 = cnc_stop_num_1[est_1.index(min(est_1))]  # 索引最小的估计时间对应的第一道工序的cnc的号码
                mov_pro=mov_pro_1
            if sit_bef==5:  #手上有东西
                est_2 = []
                for i in cnc_stop_num_2:  # 1-8中的几个数
                    est_2.append(m_time(cnc[i - 1][t, 2], rgv[t, 1]) + cnc_inf[i - 1][4])
                mov_pro_2 = cnc_stop_num_2[est_2.index(min(est_2))]  # 索引最小的估计时间对应的第一道工序的cnc的号码
                mov_pro=mov_pro_2
# 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
            ##################################################################################
        mov_pos = 0
        if mov_pro == 1 or mov_pro == 2:
            mov_pos = 1
        elif mov_pro == 3 or mov_pro == 4:
            mov_pos = 2
        elif mov_pro == 5 or mov_pro == 6:
            mov_pos = 3
        elif mov_pro == 7 or mov_pro == 8:
            mov_pos = 4  # 计算目标机位（mov_pro 1-8）所在的位置（mov_pos 1-4）
        if mov_pos != rgv[t, 1]:  # 如果判断的移动位置和rgv所在位置不同，则立即进入移动状态
            rgv[t, 2] = 1  # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
            judge_move = t + m_time(mov_pos, rgv[t, 1])
            rgv[t, 1] = mov_pos  # 移动开始，未知参数就变为目标位置
        elif mov_pos == rgv[t, 1]:  # 如果判断的移动位置和rgv所在位置相同，则立即进入 上料 或者 下料、上料、清洗 状态
            for num in range(1, 9):
                if cnc[num - 1][t, 3] == 1 and num==mov_pro and cnc[num - 1][t, 4] == 2:  # 如果cnc是空闲,上有孰料状态，目标机器匹配
                    rgv[t, 2] = 3 # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_layoff_3[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num_2 = load_num_2 + 1
                    layoff_num_2 = layoff_num_2 + 1
                    print("第%d道工序的第%d号CNC在第%d秒开始下第%d个料" % (cnc[num - 1][t, 4],num, t, layoff_num_2))
                    print("第%d道工序的第%d个CNC在第%d秒开始上第%d个料" % (cnc[num - 1][t, 4],num, t + cnc_inf[num - 1][4] / 2, load_num_2))
                    result_new_2 = np.array([load_num_2, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result_2 = np.vstack((result_2, result_new_2))
                    result_2[layoff_num_2, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 1 and num==mov_pro and cnc[num - 1][t, 4] == 1:  # 如果cnc是空闲,上有孰料状态，目标机器匹配
                    rgv[t, 2] = 5 # 0停止，1移动，2上料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_layoff_5[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num_1= load_num_1 + 1
                    layoff_num_1 = layoff_num_1 + 1
                    print("第%d道工序的第%d号CNC在第%d秒开始下第%d个料" % (cnc[num - 1][t, 4],num, t, layoff_num_1))
                    print("第%d道工序的第%d个CNC在第%d秒开始上第%d个料" % (cnc[num - 1][t, 4],num, t + cnc_inf[num - 1][4] / 2, load_num_1))
                    result_new_1 = np.array([load_num_1, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result_1 = np.vstack((result_1, result_new_1))
                    result_1[layoff_num_1, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 0 and num == mov_pro and cnc[num - 1][t, 4] == 1:  # 如果第一道工序的cnc也是空闲，无料状态（初始状态）,且目标机器匹配
                    rgv[t, 2] = 2  # 0停止，1移动，2上生料，3下熟料、上半熟料、清洗，4上半熟料，5下半熟料,上生料;cnc的作业状态，0为空闲且无熟料，1为空闲且有熟料，2为工作中
                    judge_load[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num_1 = load_num_1 + 1  # 第几个产品
                    print("第%d道工序的第%d号CNC在第%d秒开始上第%d个料" % ( cnc[num - 1][t, 4],num, t, load_num_1))
                    result_new_1 = np.array([load_num_1, num, t, 0,])
                    result_1 = np.vstack((result_1, result_new_1))
                    break  # 一个时间rgv只能进入一种状态，这里进入了2上生料状态
                if cnc[num - 1][t, 3] == 0 and num == mov_pro and cnc[num - 1][t, 4] == 2:  # 如果第二道工序的cnc也是空闲，无料状态（初始状态）,且目标机器匹配
                    rgv[t, 2] = 4 #手上有半熟料，只去上半熟料
                    judge_load_4[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num_2 = load_num_2 + 1  # 第几个产品
                    print("第%d道工序的第%d号CNC在第%d秒开始上第%d个料" % ( cnc[num - 1][t, 4], num,t, load_num_2))
                    result_new_2 = np.array([load_num_2, num, t, 0, ])
                    result_2 = np.vstack((result_2, result_new_2))
                    break

print(aaa,set_c84,load_num_2,t_wait)


print(result_1)
result_df_1 = pd.DataFrame(result_1)
writer_1 = pd.ExcelWriter('result_1.xlsx')
result_df_1.to_excel(writer_1,'page_1',float_format='%.5f') # float_format 控制精度
writer_1.save()

result_df_2 = pd.DataFrame(result_2)
writer_2 = pd.ExcelWriter('result_2.xlsx')
result_df_2.to_excel(writer_2,'page_1',float_format='%.5f') # float_format 控制精度
writer_2.save()