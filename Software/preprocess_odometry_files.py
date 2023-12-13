import pandas as pd
import os, glob

TESTS_DIR = './Tests/20231201/01_raw/'
PREPROCESSED_DIR = './Tests/20231201/02_preprocessing/'

for test in glob.glob(os.path.join(TESTS_DIR, 'POSE_DATA__2023_12_01_*.csv')):
    df = pd.read_csv(test)
    df.to_csv(os.path.join(PREPROCESSED_DIR, os.path.split(test)[-1]))

