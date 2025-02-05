cimport numpy as cnp
cimport cython
cnp.import_array()


ctypedef fused np_ints:
    cnp.int32_t
    cnp.int64_t

ctypedef fused np_uints:
    cnp.uint32_t
    cnp.uint64_t


@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.wraparound(False)
def reconstruction_loop(cnp.ndarray[dtype=np_uints, ndim=1,
                                    negative_indices=False, mode='c'] aranks,
                        cnp.ndarray[dtype=np_ints, ndim=1,
                                    negative_indices=False, mode='c'] aprev,
                        cnp.ndarray[dtype=np_ints, ndim=1,
                                    negative_indices=False, mode='c'] anext,
                        cnp.ndarray[dtype=np_ints, ndim=1,
                                    negative_indices=False, mode='c'] astrides,
                        Py_ssize_t current_idx,
                        Py_ssize_t image_stride):
    """The inner loop for reconstruction.

    This algorithm uses the rank-order of pixels. If low intensity pixels have
    a low rank and high intensity pixels have a high rank, then this loop
    performs reconstruction by dilation. If this ranking is reversed, the
    result is reconstruction by erosion.

    For each pixel in the seed image, check its neighbors. If its neighbor's
    rank is below that of the current pixel, replace the neighbor's rank with
    the rank of the current pixel. This dilation is limited by the mask, i.e.
    the rank at each pixel cannot exceed the mask as that pixel.

    Parameters
    ----------
    aranks : array
        The rank order of the flattened seed and mask images.
    aprev, anext: arrays
        Indices of previous and next pixels in rank sorted order.
    astrides : array
        Strides to neighbors of the current pixel.
    current_idx : int
        Index of highest-ranked pixel used as starting point in loop.
    image_stride : int
        Stride between seed image and mask image in `aranks`.
    """
    cdef unsigned int neighbor_rank, current_rank, mask_rank
    cdef int i, neighbor_idx, current_link, nprev, nnext
    cdef int nstrides = astrides.shape[0]
    cdef np_uints *ranks = <np_uints *>(aranks.data)
    cdef np_ints *prev = <np_ints *>(aprev.data)
    cdef np_ints *next = <np_ints *>(anext.data)
    cdef np_ints *strides = <np_ints *>(astrides.data)

    with nogil:
        while current_idx != -1:
            if current_idx < image_stride:
                current_rank = ranks[current_idx]
                if current_rank == 0:
                    break
                for i in range(nstrides):
                    neighbor_idx = current_idx + strides[i]
                    neighbor_rank = ranks[neighbor_idx]
                    # Only propagate neighbors ranked below the current rank
                    if neighbor_rank < current_rank:
                        mask_rank = ranks[neighbor_idx + image_stride]
                        # Only propagate neighbors ranked below the mask rank
                        if neighbor_rank < mask_rank:
                            # Raise the neighbor to the mask rank if
                            # the mask ranked below the current rank
                            if mask_rank < current_rank:
                                current_link = neighbor_idx + image_stride
                                ranks[neighbor_idx] = mask_rank
                            else:
                                current_link = current_idx
                                ranks[neighbor_idx] = current_rank
                            # unlink the neighbor
                            nprev = prev[neighbor_idx]
                            nnext = next[neighbor_idx]
                            next[nprev] = nnext
                            if nnext != -1:
                                prev[nnext] = nprev
                            # link to the neighbor after the current link
                            nnext = next[current_link]
                            next[neighbor_idx] = nnext
                            prev[neighbor_idx] = current_link
                            if nnext >= 0:
                                prev[nnext] = neighbor_idx
                                next[current_link] = neighbor_idx
            current_idx = next[current_idx]
