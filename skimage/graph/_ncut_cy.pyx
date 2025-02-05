# cython: cdivision=True
# cython: boundscheck=False
# cython: nonecheck=False
# cython: wraparound=False
cimport numpy as cnp
import numpy as np
cnp.import_array()


def argmin2(cnp.float64_t[:] array):
    """Return the index of the 2nd smallest value in an array.

    Parameters
    ----------
    array : array
        The array to process.

    Returns
    -------
    min_idx2 : int
        The index of the second smallest value.
    """
    cdef cnp.float64_t min1 = np.inf
    cdef cnp.float64_t min2 = np.inf
    cdef Py_ssize_t min_idx1 = 0
    cdef Py_ssize_t min_idx2 = 0
    cdef Py_ssize_t i = 0
    cdef Py_ssize_t n = array.shape[0]

    for i in range(n):
        x = array[i]
        if x < min1:
            min2 = min1
            min_idx2 = min_idx1
            min1 = x
            min_idx1 = i
        elif x > min1 and x < min2:
            min2 = x
            min_idx2 = i
        i += 1

    return min_idx2


def cut_cost(cut, W):
    """Return the total weight of crossing edges in a bi-partition.

    Parameters
    ----------
    cut : array
        A array of booleans. Elements set to `True` belong to one
        set.
    W : array
        The weight matrix of the graph.

    Returns
    -------
    cost : float
        The total weight of crossing edges.
    """
    cdef cnp.ndarray[cnp.uint8_t, cast = True] cut_mask = np.array(cut)
    cdef Py_ssize_t num_cols
    cdef cnp.int32_t row, col
    cdef cnp.int32_t[:] indices = W.indices
    cdef cnp.int32_t[:] indptr = W.indptr
    cdef cnp.float64_t[:] data = W.data.astype(np.float64)
    cdef cnp.int32_t row_index
    cdef cnp.float64_t cost = 0

    num_cols = W.shape[1]

    for col in range(num_cols):
        for row_index in range(indptr[col], indptr[col + 1]):
            row = indices[row_index]
            if cut_mask[row] != cut_mask[col]:
                cost += data[row_index]

    return cost * 0.5
