# -*- coding: utf-8 -*-
import pytest
import numpy as np
import scipy as sp
from circ_average import circ_average


def transform_rh_polar(rh_pol_data):
    """Transforms polar angles from the right hemisphere to be centered around
    0, going from -π to +π. The angles are mirrored horizontally, such that 0 ↔
    ±π, although this has a bias towards +π"""
    return np.pi - rh_pol_data % (2 * np.pi)

test_angles = [
    (0, np.pi),
    (np.pi, 0),
    (-np.pi, 0),
    (np.pi - 1, 1),
    (1 - np.pi, -1),
    (np.pi / 2, np.pi / 2),
    (-np.pi / 2, -np.pi / 2)
]


@pytest.mark.parametrize("angle,expected", test_angles)
def test_transform_angle(angle, expected):
    assert transform_rh_polar(angle) == expected


class TestCircAverage():
    def test_no_weights(self):
        expected = 3.136593
        assert circ_average([-3.14, 3.13]) == pytest.approx(expected)

    def test_high_360(self):
        x = np.array([355, 5, 2, 359, 10, 350])
        expected = 0.167690146
        assert circ_average(x, high=360) == pytest.approx(expected)

    def test_small(self):
        x = np.array([20, 21, 22, 18, 19, 20.5, 19.2])
        expected = x.mean()
        assert circ_average(x, high=360) == pytest.approx(expected)

    def test_axis(self):
        x = np.array([[355, 5, 2, 359, 10, 350],
                      [351, 7, 4, 352, 9, 349],
                      [357, 9, 8, 358, 4, 356]])
        M1 = circ_average(x, high=360)
        M2 = circ_average(x.ravel(), high=360)
        np.testing.assert_allclose(M1, M2, rtol=1e-14)

        M1 = circ_average(x, high=360, axis=1)
        M2 = [circ_average(x[i], high=360) for i in range(x.shape[0])]
        np.testing.assert_allclose(M1, M2, rtol=1e-14)

        M1 = circ_average(x, high=360, axis=0)
        M2 = [circ_average(x[:, i], high=360) for i in range(x.shape[1])]
        np.testing.assert_allclose(M1, M2, rtol=1e-14)

    def test_array_like(self):
        x = [355, 5, 2, 359, 10, 350]
        np.testing.assert_allclose(circ_average(x, high=360),
                                   0.167690146, rtol=1e-7)

    def test_empty(self):
        assert np.isnan(circ_average([]))

    def test_scalar(self):
        x = 1.
        M1 = x
        M2 = circ_average(x)
        np.testing.assert_allclose(M2, M1, rtol=1e-5)

    def test_range(self):
        m = circ_average(np.arange(0, 2, 0.1), np.pi, -np.pi)
        assert m < np.pi
        assert m > -np.pi
