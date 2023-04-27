#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep  7 14:26:33 2021
Events 152: Session 2 analysis
@author: bezdek
Modifed by Sophie Su June 29
"""
import pandas as pd
import matplotlib.pyplot as plt
import math
import numpy as np
from scipy import stats
from scipy.stats import zscore
from scipy.interpolate import interp1d
from glob import glob
import csv
import seaborn as sns
import string
from string import digits


# Participants segmented coarse then fine, or fine then coarse. there are differences in the column names, so it's important to load participants separately by condition:
# Sophie: updated the list of participants as of July 11.2022
cf_subjects = ['e152006','e152007','e152009','e152010','e152014','e152016',
               'e152018','e152022','e152024','e152028','e152029','e152030','e152032','e152034','e152036','e152037','e152038','e152042',
               'e152045','e152047','e152050','e152052']
fc_subjects = ['e152005','e152008','e152011','e152013','e152017','e152019',
               'e152021','e152023','e152025','e152026','e152027','e152031','e152033','e152035','e152039','e152040','e152041',
               'e153043','e152044','e152046','e152049','e152051']
# subjects with split segmentation files that need a workaround: e152019, e152026, e152027, e152028, e152029,e152037




'''
segmentation
'''

# Load testing files:
s2files=glob('/Users/dcllab/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e*.csv')
print(s2files)
segdf=pd.DataFrame()
for s2file in s2files:
    try:
        #s2file='/Users/bezdek/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152011_exp152_session_2_2021_Aug_30_1305.csv'
        sub=s2file.split('/')[-1].split('_')[0]
        if sub in ['e152003','e152004']:
            pass
            #df=pd.read_csv(s2file)
            #df['key_resp.keys']=df['key_resp.keys'].combine_first(df['key_resp_7.keys'])
            #df['key_resp.rt']=df['key_resp.rt'].combine_first(df['key_resp_7.rt'])
            #df['key_resp.keys']=df['key_resp.keys'].combine_first(df['key_resp_8.keys'])
            #df['key_resp.rt']=df['key_resp.rt'].combine_first(df['key_resp_8.rt'])
            #df['key_resp.keys']=df['key_resp.keys'].combine_first(df['key_resp_9.keys'])
            #df['key_resp.rt']=df['key_resp.rt'].combine_first(df['key_resp_9.rt'])
            #df['recog_resp.corr'] = np.where(((df['key_resp.keys']=='right') & (df['corrAns']=='right')) | ((df['key_resp.keys']=='left') & (df['corrAns']=='left') ), 1, 0)
            #df=df.rename(columns={'key_resp.keys':'recog_resp.keys','key_resp.rt':'recog_resp.rt'})
            #df=df[['movie','task','image','corrAns','trial_type','recog_resp.keys','recog_resp.corr','recog_resp.rt']]        
        elif sub in fc_subjects:
            print(sub)
            df=pd.read_csv(s2file)
            # select columns and rows:
            df=df[['movie','task','segment_coarse.rt','segment_fine.rt']]
            df['order']='fine_coarse'
            df = df[(df.task == 'segment') & (df.movie != 'legos2')]
            df['sub']=sub
            segdf=pd.concat([segdf,df],ignore_index=True) 
        elif sub in cf_subjects:
            print(sub)
            if s2file == '~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152037_exp152_session_2_2022_Mar_12_1202.csv':
                pass
            else:
                #s2file='~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152037_exp152_session_2_2022_Mar_12_1229.csv'
                df=pd.read_csv(s2file)
                # select columns and rows:
                df=df[['movie','task','segment_2.rt','segment.rt']]
                df=df.rename(columns={'segment_2.rt':'segment_coarse.rt','segment.rt':'segment_fine.rt'})
                df['order']='coarse_fine'
                df = df[(df.task == 'segment') & (df.movie != 'legos2')]
                df['sub']=sub
                segdf=pd.concat([segdf,df],ignore_index=True) 
    except:
        print(s2file)
# manually add split segmentation files:
# subjects with split segmentation files that need a workaround: 
# e152015, e152019, e1522020, e152026, e152027, e152028, e152029
# check if subject sub-14 (e152019) has no coarse boundaries, sub-32 (e152037) was fixed to not double boundaries.
sub='e152015'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152015_v4_exp152_session_2_2021_Sep_28_1121.csv')
# select columns and rows:
df=df[['movie','task','segment_fine.rt']]
df['order']='fine'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152019'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152019_exp152_session_2_2021_Nov_12_1104.csv')
# select columns and rows:
df=df[['movie','task','segment_fine.rt']]
df['order']='fine'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152020'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152020v2_exp152_session_2_2021_Nov_13_0921.csv')
# select columns and rows:
df=df[['movie','task','segment_2.rt','segment.rt']]
df=df.rename(columns={'segment_2.rt':'segment_coarse.rt','segment.rt':'segment_fine.rt'})
df['order']='coarse_fine'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
#sub='e152026'
#df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152026_2_exp152_session_2_2021_Nov_22_1544.csv')
## select columns and rows:
#df=df[['movie','task','segment_coarse.rt','segment_fine.rt']]
#df['order']='fine_coarse'
#df = df[(df.task == 'segment') & (df.movie != 'legos2')]
#df['sub']=sub
#segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152027'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152027-2_exp152_session_2_2021_Dec_11_1432.csv')
# select columns and rows:
df=df[['movie','task','segment_coarse.rt','segment_fine.rt']]
df['order']='fine_coarse'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
#sub='e152028'
#df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152028_exp152_session_2_2021_Dec_17_0842.csv')
## select columns and rows:
#df=df[['movie','task','segment_2.rt','segment.rt']]
#df=df.rename(columns={'segment_2.rt':'segment_coarse.rt','segment.rt':'segment_fine.rt'})
#df['order']='coarse_fine'
#df = df[(df.task == 'segment') & (df.movie != 'legos2')]
#df['sub']=sub
#segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152029'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152029_exp152_session_2_2021_Dec_18_1018.csv')
# select columns and rows:
df=df[['movie','task','segment_2.rt']]
df=df.rename(columns={'segment_2.rt':'segment_coarse.rt'})
df['order']='coarse_fine'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152029_exp152_session_2_2021_Dec_18_1153.csv')
# select columns and rows:
df=df[['movie','task','segment.rt']]
df=df.rename(columns={'segment.rt':'segment_fine.rt'})
df['order']='coarse_fine'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152003'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152003_exp152_session_2_2021_May_17_1059.csv')
# select columns and rows:
df=df[['movie','task','segment.rt']]
df=df.rename(columns={'segment.rt':'segment_coarse.rt'})
df['order']='coarse'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
sub='e152004'
df=pd.read_csv('~/Box/DCL_ARCHIVE/Documents/Events/exp152_fMRIneuralmechanisms/exp152_Session_2/data/e152004_exp152_session_2_2021_May_18_1411.csv')
# select columns and rows:
df=df[['movie','task','segment.rt']]
df=df.rename(columns={'segment.rt':'segment_coarse.rt'})
df['order']='coarse'
df = df[(df.task == 'segment') & (df.movie != 'legos2')]
df['sub']=sub
segdf=pd.concat([segdf,df],ignore_index=True) 
segdf.to_csv("segmentation.csv",index=False)