# extremeRetinotopy
Project repository to analyze retinotopy data collected by Heidi Baseler

## Running MATLAB Analysis

The main script to run for the MATLAB portion of the analysis is to simply run
the `extremeRetinotopy_MASTER.m` script.

## Running Python Analysis

All the Python analysis was done in an IPython Notebook located at
`fsAverage.ipynb`. To actually open and run the analysis, install the
dependencies (numpy, pandas, scipy, matplotlib, seaborn, nibabel) and most
importantly install the IPython/Jupyter notebook environment. Then in the local
directory, run in the terminal:

    $ jupyter notebook

## Visualizing surface files

To visualize the resulting surface files, the [MRlyze](https://github.com/gkaguirrelab/MRlyze)
and [freesurferMatlabLibrary](https://github.com/gkaguirrelab/freesurferMatlabLibrary)
should be downloaded from GitHub and installed to the MATLAB path. Then, to
actually visualize a file, the `surface_plot` utility function does the trick:

    >> surface_plot('co', '/home/adel/aguirre/extremeRetinotopy/averages/avg.lh.ecc.sym.nii.gz', 'fsaverage_sym', 'lh')
