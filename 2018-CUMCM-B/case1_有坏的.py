import numpy as np
import pandas as pd
import networkx as nx
import random
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
t=0
v_pos = 1  # 初始位置为1，右侧依次为2、3、4
v_sit = 0  # 0停止，1移动，2上料，3下料、上料、清洗
rgv=np.array([[t,v_pos,v_sit]])

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
    cnc.append(np.array([[t, num, c_pos, c_sit]]))
    cnc_inf.append(np.array([num,p1,p21,p22,tc]))

    #储存了cnc的加工、上下料时间，是固定的信息

judge_cnc=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]]) #初始cnc加工→休息判断矩阵
judge_move=30000
judge_load=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
judge_layoff=np.array([[30000,30000,30000,30000,30000,30000,300000,300000]])
t_wait=0
load_num=0
layoff_num=0
result=np.array([[0,0,0,0]])
judge_cnc_break=0

print("stop")

for t in range(1,28800): #从第1秒到第5秒

    #print(t)
    #################################
    rgv_new =np.array([t, rgv[t-1,1], rgv[t-1,2]])# 0停止，1移动，2上料，3下熟料、上半熟料、清洗
    rgv=np.vstack((rgv, rgv_new))#t改变，其他rgv参数复制上一秒的信息
    for num in range(1, 9):
        cnc_new=np.array([t, cnc[num-1][t-1,1],cnc[num-1][t-1,2],cnc[num-1][t-1,3]])
        cnc[num-1]=np.vstack((cnc[num-1], cnc_new))#t改变，其他cnc参数复制上一秒的信息
    #################################
    if t == 654 or t == 4646 or t == 22654 or t==5874  or t==18674:
        num= random.randint(1,8)
        rgv[t, 2] = 0
        cnc_inf[num - 1][4] == 99999
        judge_cnc_break = t+random.randint(600, 1200)
        print(layoff_num, num, t,judge_cnc_break)
    for num in range(1, 9):
        if cnc[num-1][t,3]==2 and t>=judge_cnc[0,num-1] and t<judge_cnc[0,num-1]+1: #cnc加工完成，给rgv发信号
            cnc[num - 1][t, 3] = 1   #cnc从2（工作状态）到1（空闲，上有孰料状态）
        if t>=judge_cnc_break and t<judge_cnc_break+1:
            cnc_inf[num-1][4]=te
    #################################
    if rgv[t,2]==1:    #如果rgv上一秒在移动
        if t>=judge_move and t <judge_move+1:     #判断rgb移动是否完成
            rgv[t,2]=0     #rgv瞬间进入移动后的等待状态，按照算法，这里应当立即对cnc进行操作
            for num in range(1, 9):
                if cnc[num - 1][t, 3] == 1 and num==mov_pro:  # 如果cnc是空闲,上有孰料状态，目标机器匹配
                    rgv[t, 2] = 3
                    judge_layoff[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num = load_num + 1
                    layoff_num = layoff_num + 1
                    print("第%d个CNC在第%d秒开始下第%d个料" % (num, t, layoff_num))
                    print("第%d个CNC在第%d秒开始上第%d个料" % (num, t + cnc_inf[num - 1][4] / 2, load_num))
                    result_new = np.array([load_num, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result = np.vstack((result, result_new))
                    result[layoff_num, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 0 and num==mov_pro:  # 如果cnc也是空闲，无料状态（初始状态）,且目标机器匹配
                    rgv[t, 2] = 2  # rgv进入上料状态
                    judge_load[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num = load_num + 1
                    print("第%d个CNC在第%d秒开始上第%d个料" % (num, t, load_num))
                    result_new = np.array([load_num, num, t, 0])
                    result = np.vstack((result, result_new))
                    break  # 一个时间rgv只能进入一种状态，这里进入了上料状态
            continue     #移动结束连着上（下）料，继续循环,等待着在judge上下料跳出循环
        else:
            continue       #上一秒在移动，还未停止，继续循环，一直在移动，直到judge移动停止
    if rgv[t,2]==2 or rgv[t,2]==3:
        for num in range(1, 9):
            if t>=judge_load[0,num-1] and t <judge_load[0,num-1]+1:       #这个情况只有在最开始的时候情况
                cnc[num-1][t,3]=2   #cnc从0（空闲，上无料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  #当前时间加cnc工作时间，为cnc的预测空闲时间
                rgv[t,2]=0
            if t>=judge_layoff[0,num-1] and t <judge_layoff[0,num-1]+1:     #上下料同时进行
                cnc[num-1][t,3]=2 #cnc从1（空闲，上有孰料状态）到2（工作状态）
                judge_cnc[0, num - 1] = t + cnc_inf[num - 1][1]  #当前时间加cnc工作时间，为cnc的预测空闲时间
            if t >= judge_layoff[0, num - 1] +w and t <judge_layoff[0, num - 1]+w+1:  # 上下料同时进行
                rgv[t,2] = 0  #rgv清洗后再进入等待状态
                # rgv瞬间进入等待状态,因为我们判断下料后一定会上料，这里要不要直接跳过搜索空闲cnc的过程？
###################################################################
    if rgv[t,2]==0:  #如果rgv空闲
        cnc_stop_num=[]
        cnc_count_zeros=[]
        for num in range(1, 9):
            if cnc[num-1][t,3]==0 or cnc[num-1][t,3]==1:   #如果cnc也是空闲状态
                cnc_stop_num.append(cnc[num-1][t,1])   #调出空闲状态的cnc机号
            cnc_count_zeros.append(cnc[num-1][t,3])
##########################################################################################################################################################
        if cnc_stop_num == []:
            t_wait = t_wait + 1
            continue  # 跳出大循环，表示rgv处于等候状态
        else:
            t_wait = 0
            est_t = []
            for i in cnc_stop_num:  # 1-8中的几个数
                est_t.append(m_time(cnc[i - 1][t, 2], rgv[t, 1]) + cnc_inf[i - 1][4])
            mov_pro = cnc_stop_num[est_t.index(min(est_t))]  # 索引最小的估计时间对应的cnc的号码
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
            rgv[t, 2] = 1  # 0停止，1移动，2上料，3下料、上料、清洗
            judge_move = t + m_time(mov_pos, rgv[t, 1])
            rgv[t, 1] = mov_pos  # 移动开始，未知参数就变为目标位置
        elif mov_pos == rgv[t, 1]:  # 如果判断的移动位置和rgv所在位置相同，则立即进入 上料 或者 下料、上料、清洗 状态
            for num in range(1, 9):
                if cnc[num - 1][t, 3] == 1 and mov_pro == num:  # 如果cnc是空闲,上有孰料状态
                    rgv[t, 2] = 3
                    judge_layoff[0, num - 1] = t + cnc_inf[num - 1][4]
                    load_num = load_num + 1
                    layoff_num = layoff_num + 1
                    print("第%d个CNC在第%d秒开始下第%d个料" % (num, t, layoff_num))
                    print("第%d个CNC在第%d秒开始上第%d个料" % (num, t + cnc_inf[num - 1][4] / 2, load_num))
                    result_new = np.array([load_num, num, t + cnc_inf[num - 1][4] / 2, 0])
                    result = np.vstack((result, result_new))
                    result[layoff_num, 3] = t
                    break  # 一个时间rgv只能进入一种状态，这里进入了下料、上料、清洗状态
                if cnc[num - 1][t, 3] == 0 and mov_pro == num:  # 如果cnc也是空闲，无料状态（初始状态）
                    rgv[t, 2] = 2  # rgv进入上料状态
                    judge_load[0, num - 1] = t + cnc_inf[num - 1][4] / 2  # 假设空cnc上料时间为上下料时间的一半
                    load_num = load_num + 1
                    print("第%d个CNC在第%d秒开始上第%d个料" % (num, t, load_num))
                    result_new = np.array([load_num, num, t, 0])
                    result = np.vstack((result, result_new))
                    break  # 一个时间rgv只能进入一种状态，这里进入了上料状态

result_df = pd.DataFrame(result)
writer = pd.ExcelWriter('test_GA3.xlsx')
result_df.to_excel(writer,'page_1',float_format='%.5f') # float_format 控制精度
writer.save()
