import numpy as np
import scipy.stats


def circ_average(a, high=2*np.pi, low=0, axis=None, weights=None):
    """
    Compute the weighted circular average along the specified axis for
    samples in a range.

    Parameters
    ----------
    a : array_like
        Array containing data to be averaged. If `a` is not an array, a
        conversion is attempted.
    high : float or int, optional
        High boundary for circular mean range.  Default is ``2*pi``.
    low : float or int, optional
        Low boundary for circular mean range.  Default is 0.
    axis : int, optional
        Axis along which to average `a`. If `None`, averaging is done over
        the flattened array.
    weights : array_like, optional
        An array of weights associated with the values in `a`. Each value in
        `a` contributes to the average according to its associated weight.
        The weights array can either be 1-D (in which case its length must be
        the size of `a` along the given axis) or of the same shape as `a`.
        If `weights=None`, then all data in `a` are assumed to have a
        weight equal to one.
    """
    if not isinstance(a, np.matrix):
        a = np.asarray(a)

    if weights is None:
        return scipy.stats.circmean(samples=a, high=high, low=low, axis=axis)

    wgt = np.asarray(weights)
    if a.shape != wgt.shape:
        raise TypeError("Length of weights not compatible with specified axis.")

    scl = wgt.sum(axis=axis, dtype=np.result_type(a.dtype, wgt.dtype))
    if (scl == 0.0).any():
        raise ZeroDivisionError("Weights sum to zero, can't be normalized")

    return np.multiply(a, wgt).sum(axis) / scl
