# Measuring protocol

## Setup

The calibration setup consists of:

- Intel Realsense T465 camera at 12 FPS (software limited)
- Nvidia Jetson Nano controller
- 3 m Linear rail (useful 2.50 m)
- Slider
- ArUco marker id 6 and 100 mm wide

The whole setup is mounted on an optical plate bench.

## Protocol

In order to assess markers accuracy, 10 runs are performed:

- 2 runs moving parallel to the marker in order to assess accuracy along z axis,
- 2 runs moving perpendicular to the marker in order to assess accuracy along x axis,
- 2 runs moving at a 30° angle relative to the marker in order to assess accuracy around y axis,
- 2 runs moving at a 45° angle relative to the marker in order to assess accuracy around y axis,
- 2 runs moving at a 60° angle relative to the marker in order to assess accuracy around y axis,

Each run is performed by manually moving the slider along the rail from the beginning to the end and back, trying to avoid high speed variations.

Before each run it is necessary to write down the timestamp in order to easily retrieve the results.
