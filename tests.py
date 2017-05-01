# -*- coding: utf-8 -*-
import pytest
import numpy as np


def transform_rh_polar(rh_pol_data):
    """Transforms polar angles from the right hemisphere to be centered around
    0, going from -π to +π"""
    return np.pi - rh_pol_data % (2 * np.pi)

test_angles = [
    (0, np.pi),
    (np.pi, 0),
    (np.pi - 1, 1),
    (1 - np.pi, -1),
    (np.pi / 2, np.pi / 2),
    (-np.pi / 2, -np.pi / 2)
]


@pytest.mark.parametrize("angle,expected", test_angles)
def test_transform_angle(angle, expected):
    assert transform_rh_polar(angle) == expected
