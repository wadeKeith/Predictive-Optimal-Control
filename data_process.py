import numpy as np
import pandas as pd


for i in range(1,6087):
    df = pd.read_csv('data/data_ls/1 (%d).csv' %i, encoding='gbk', low_memory=False)
    data = np.array(df)
    for j in range(0,len(df)-1):
        data[j,4] = (data[j+1,3]-data[j,3])*10
    df1 = pd.DataFrame(data)
    df1.columns = ['Vehicle_ID','Total_Frames','v_length','v_Vel','v_Acc','Space_Headway','actual_space']


    df1.reset_index(drop=True,inplace=True)
    df1.to_csv('data/data_ls_2/1 (%d).csv' %i,index=False)
    # df2 = pd.read_csv('data/data_ls_2/1 (%d).csv' %i, encoding='gbk', low_memory=False)
