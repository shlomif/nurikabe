#!/usr/bin/env python
from TAP.Simple import *
from ctypes import *

plan(24)

NK_SOLVE_ERROR__SUCCESS = 0
NK_SOLVE_ERROR__ALLOC_FAILED = 1
NK_SOLVE_ERROR__X_OUT_OF_BOUNDS = 2
NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS = 3

NK_SOLVE_VERDICT__UNKNOWN = 0
NK_SOLVE_VERDICT__WHITE = 1
NK_SOLVE_VERDICT__BLACK = 2

nk_solve = CDLL("./libnk-solve.so")

verdict_mat_create = nk_solve.nk_solve_verdict_matrix_create
verdict_mat_free = nk_solve.nk_solve_verdict_matrix_free

class Mat:
    def __init__(self):
        self.matrix = c_void_p()

    def create(self, height, width):
        return nk_solve.nk_solve_verdict_matrix_create(
                c_int(height), c_int(width), byref(self.matrix)
                )

    def free(self):
        return nk_solve.nk_solve_verdict_matrix_free(self.matrix)

    def set(self, y, x, v):
        return nk_solve.nk_solve_verdict_matrix_set(
                self.matrix,
                c_int(y), c_int(x),
                c_int(v)
                )

    def get(self, y, x):
        value = c_int(-1)
        ret_code = nk_solve.nk_solve_verdict_matrix_get(
                self.matrix,
                c_int(y), c_int(x),
                byref(value)
                )
        return (ret_code,value.value)

def test_create_and_free():
    m = Mat()
    # TEST
    eq_ok (
            m.create(10, 5),
            NK_SOLVE_ERROR__SUCCESS,
            "nk_solve_verdict_matrix_create correct error value"
            )

    # TEST
    ok (m.matrix, "matrix is allocated")

    # TEST
    eq_ok (
            m.free(),
            NK_SOLVE_ERROR__SUCCESS,
            "nk_solve_verdict_matrix_free was successful"
            )

test_create_and_free()

def test_off_by_one():
    m = Mat()
    # TEST
    eq_ok (
            m.create(1, 3),
            NK_SOLVE_ERROR__SUCCESS,
            "off_by_one create"
            )

    # TEST
    ok (m.matrix, "off_by_one matrix is allocated")

    # TEST
    eq_ok (
            m.set(0, 2, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__SUCCESS,
            "off_by_one value set.",
        )

    # TEST
    eq_ok (
            m.free(),
            NK_SOLVE_ERROR__SUCCESS,
            "off_by_one free was successful"
            )

test_off_by_one()

def test_set_and_get():
    m = Mat()
    # TEST
    eq_ok (
            m.create(10, 5),
            NK_SOLVE_ERROR__SUCCESS,
            "nk_solve_verdict_matrix_create correct error value"
            )

    # TEST
    ok (m.matrix, "matrix is allocated")

    # TEST
    eq_ok (
            m.set(12,2, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS,
            "Y is out of bounds",
        )

    # TEST
    eq_ok (
            m.set(0,5, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__X_OUT_OF_BOUNDS,
            "X is out of bounds",
        )

    # TEST
    eq_ok (
            m.set(-1,2, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS,
            "Y (= -1) is out of bounds",
        )

    # TEST
    eq_ok (
            m.set(0,-2, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__X_OUT_OF_BOUNDS,
            "X (= -2) is out of bounds",
        )

    # TEST
    eq_ok (
            m.set(3,3, NK_SOLVE_VERDICT__BLACK),
            NK_SOLVE_ERROR__SUCCESS,
            "Set in coordinates is successful."
        )

    # TEST
    eq_ok (
            m.get(0,0),
            (NK_SOLVE_ERROR__SUCCESS, NK_SOLVE_VERDICT__UNKNOWN),
            "Get in (0,0) is unknown."
        )

    # TEST
    eq_ok (
            m.get(3,3),
            (NK_SOLVE_ERROR__SUCCESS, NK_SOLVE_VERDICT__BLACK),
            "Get in (3,3) is black."
        )

    # TEST
    eq_ok (
            m.set(3,1, NK_SOLVE_VERDICT__WHITE),
            NK_SOLVE_ERROR__SUCCESS,
            "Set in (3,1) is successful."
        )

    # TEST
    eq_ok (
            m.get(3,2),
            (NK_SOLVE_ERROR__SUCCESS, NK_SOLVE_VERDICT__UNKNOWN),
            "Get (3,2) (which was not set)"
        );

    # TEST
    eq_ok (
            m.get(3,4),
            (NK_SOLVE_ERROR__SUCCESS, NK_SOLVE_VERDICT__UNKNOWN),
            "Get in (3,4) is black. (2nd time)"
        )

    # TEST
    eq_ok (
            m.get(12,2),
            (NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS, -1),
            "get (12,2) out of y bounds")

    # TEST
    eq_ok (
            m.get(-1,2),
            (NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS, -1),
            "get (-1,2) out of y bounds")

    # TEST
    eq_ok (
            m.get(3,100),
            (NK_SOLVE_ERROR__X_OUT_OF_BOUNDS, -1),
            "get (3,100) out of x bounds")

    # TEST
    eq_ok (
            m.get(2,-1),
            (NK_SOLVE_ERROR__X_OUT_OF_BOUNDS, -1),
            "get (2,-1) out of X bounds")

    # TEST
    eq_ok (
            m.free(),
            NK_SOLVE_ERROR__SUCCESS,
            "nk_solve_verdict_matrix_free was successful"
            )



test_set_and_get()


