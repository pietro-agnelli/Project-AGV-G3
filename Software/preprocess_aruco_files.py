import pandas as pd
import os, glob

TESTS_DIR = './Tests/20231218/01_raw/'
PREPROCESSED_DIR = './Tests/20231218/02_preprocessing'

for test in glob.glob(os.path.join(TESTS_DIR, '*___ARUCO_2023_12_15_12_26*.csv')):
    df = pd.read_csv(test,index_col=False)
    for r in df.index:
        if df.loc[r,'id_marker'] > 7 or df.loc[r,'id_marker'] < 1:
            df.drop(r,inplace=True)
    if len(df) == 0:
        continue
    df.to_csv(os.path.join(PREPROCESSED_DIR, os.path.split(test)[-1]),index=False,)

