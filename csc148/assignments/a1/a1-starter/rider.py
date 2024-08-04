"""
The rider module contains the Rider class. It also contains
constants that represent the status of the rider.

=== Constants ===
WAITING: A constant used for the waiting rider status.
CANCELLED: A constant used for the cancelled rider status.
SATISFIED: A constant used for the satisfied rider status
"""
from __future__ import annotations
from location import Location


WAITING = "waiting"
CANCELLED = "cancelled"
SATISFIED = "satisfied"


class Rider:
    """A rider for a ride-sharing service.

    === Attributes ===
    id: A unique identifier for the rider.
    origin: The origin location of the rider.
    destination: The location where rider wants to go.
    patience: How long the rider will wait before cancelling a ride.
    """

    id: str
    origin: Location
    is_idle: bool
    speed: int
    destination: Location
    status: str
    patience: int

    def __init__(self, identifier: str, patience: int, origin: Location,
                 destination: Location) -> None:
        """Initialize a Rider.

        """

        self.origin = origin
        self.id = identifier
        self.destination = destination
        self.status = WAITING
        self.patience = patience

    def __str__(self) -> str:
        """Return a string representation."""
        return (f"Rider's identifier: {self.id} Rider's location: "
                f"{self.origin} " f"Rider's Status: {self.status}")

    def __eq__(self, other: Rider) -> bool:
        """Return True if self equals other, and false otherwise.

        """
        return self.id == other.id

    def change_to_waiting(self) -> None:
        """Change self.status to WAITING
        """
        self.status = WAITING

    def change_to_cancelled(self) -> None:
        """Change self.status to CANCELLED.
        """
        self.status = CANCELLED

    def change_to_satisfied(self) -> None:
        """Change self.status to SATISFIED.
        """
        self.status = SATISFIED


if __name__ == '__main__':
    import python_ta

    python_ta.check_all(config={'extra-imports': ['location']})
