import pandas as pd
import os, glob

TESTS_DIR = './Tests/20231222/01_raw/'
PREPROCESSED_DIR = './Tests/20231222/02_preprocessing/'

for test in glob.glob(os.path.join(TESTS_DIR, 'POSE_DATA__2023_12_22*.csv')):
    df = pd.read_csv(test, index_col=False)
    if len(df) == 0:
        continue
    df.to_csv(os.path.join(PREPROCESSED_DIR, os.path.split(test)[-1]),index=False)