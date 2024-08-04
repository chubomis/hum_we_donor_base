"""Locations for the simulation"""

from __future__ import annotations


class Location:
    """A two-dimensional location."""
    x: int
    y: int

    def __init__(self, row: int, column: int) -> None:
        """Initialize a location.

        Precondition: row and column >= 0.
        """
        self.x = row
        self.y = column

    def __str__(self) -> str:
        """Return a string representation.
        >>> l = Location(12, 2)
        >>> print(l)
        12, 2
        """
        row = str(self.x)
        column = str(self.y)
        return row + ", " + column

    def __eq__(self, other: Location) -> bool:
        """Return True if self equals other, and false otherwise.
        >>> l1 = (32, 1)
        >>> l2 = (32, 32)
        >>> l1 == l2
        False
        """
        if self.x == other.x and self.y == other.y:
            return True
        else:
            return False


def manhattan_distance(origin: Location, destination: Location) -> int:
    """Return the Manhattan distance between the origin and the destination.

    """
    origin_x = origin.x
    origin_y = origin.y
    dest_x = destination.x
    dest_y = destination.y
    return abs(origin_x - dest_x) + abs(origin_y - dest_y)


class NotValidError(Exception):
    """Exception raised when not valid string is inputted."""

    def __str__(self) -> str:
        """Return a string representation of this error."""
        return 'Not a valid input'


def deserialize_location(location_str: str) -> Location:
    """Deserialize a location.

    location_str: A location in the format 'row,col'
    >>> s = "#12,123"
    >>> print(deserialize_location(s))
    12, 123
    """
    loc = location_str.split(',')

    try:
        return Location(int(loc[0]), int(loc[1]))
    except IndexError:
        raise NotValidError
    except ValueError:
        raise NotValidError


if __name__ == '__main__':
    import python_ta

    python_ta.check_all()
