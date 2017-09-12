# extremeRetinotopy
Project repository to analyze retinotopy data collected by Heidi Baseler

## Running MATLAB Analysis

The main script to run for the MATLAB portion of the analysis is to simply run
the `extremeRetinotopy_MASTER.m` script.

## Running Python Analysis

All the Python analysis was done in an IPython Notebook located at
`fsAverage.ipynb`. To actually open and run the analysis, install the
dependencies (numpy, pandas, scipy, matplotlib, seaborn, nibabel) and most
importantly install the IPython/Jupyter notebook environment.

    $ pip install -r requirements.txt

Once installed, in the local directory, run in the terminal:

    $ jupyter notebook

### Running Tests

There is a small number of tests for utility functions in the file `tests.py`.
These tests can be run using `py.test`.

## Visualizing surface files

To visualize the resulting surface files, the [MRlyze](https://github.com/gkaguirrelab/MRlyze)
and [freesurferMatlabLibrary](https://github.com/gkaguirrelab/freesurferMatlabLibrary)
should be downloaded from GitHub and installed to the MATLAB path. Then, to
actually visualize a file, the `surface_plot` utility function does the trick:

    >> surface_plot('extremeEcc', '/home/adel/aguirre/extremeRetinotopy/averages/avg.ecc.sym.nii.gz', 'fsaverage_sym', 'lh')

The relevant parameters for the map type for the extreme retinotopy project are
`pol`, `extremeEcc`, `co`, and `sig`.
