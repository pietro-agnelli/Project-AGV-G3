import pandas as pd
import os, glob
import matplotlib.pyplot as plt

PREPROCESSED_DIR = './Tests/20231222/02_preprocessing'

for test in glob.glob(os.path.join(PREPROCESSED_DIR, '*___ARUCO_2023_12_22*.csv'))[-1:]:
    df = pd.read_csv(test)
    fig, ((ax1, ax2, ax3), (ax4, ax5, ax6)) = plt.subplots(
    2, 3, sharex=True, figsize=(10, 6), constrained_layout=True
    )

    ax1.plot(df['frame'][0:-1], df["x"][0:-1])
    ax1.set_ylabel(r"x position")

    ax2.plot(df['frame'][0:-1],df["y"][0:-1])
    ax2.set_ylabel(r"y position")

    ax3.plot(df['frame'][0:-1], df["z"][0:-1])
    ax3.set_ylabel(r"z position")

    ax4.plot(df['frame'][0:-1], df["roll"][0:-1])
    ax4.set_ylabel(r"roll")

    ax5.plot(df['frame'][0:-1], df["pitch"][0:-1])
    ax5.set_ylabel(r"pitch")

    ax6.plot(df['frame'][0:-1], df["yaw"][0:-1])
    ax6.set_ylabel(r"yaw")

    fig.align_labels()
    plt.suptitle(str(os.path.split(test)[-1]), fontsize=16)
    plt.show()