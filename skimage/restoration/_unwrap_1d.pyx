#cython: cdivision=True
#cython: boundscheck=False
#cython: nonecheck=False
#cython: wraparound=False

cimport numpy as cnp
from libc.math cimport M_PI


def unwrap_1d(cnp.float64_t[::1] image, cnp.float64_t[::1] unwrapped_image):
    '''Phase unwrapping using the naive approach.'''
    cdef:
        Py_ssize_t i
        cnp.float64_t difference
        long periods = 0
    with nogil:
        unwrapped_image[0] = image[0]
        for i in range(1, image.shape[0]):
            difference = image[i] - image[i - 1]
            if difference > M_PI:
                periods -= 1
            elif difference < -M_PI:
                periods += 1
            unwrapped_image[i] = image[i] + 2 * M_PI * periods
