"""Dispatcher for the simulation"""

from typing import Optional
from driver import Driver
from rider import Rider


class Dispatcher:
    """A dispatcher fulfills requests from riders and drivers for a
    ride-sharing service.

    When a rider requests a driver, the dispatcher assigns a driver to the
    rider. If no driver is available, the rider is placed on a waiting
    list for the next available driver. A rider that has not yet been
    picked up by a driver may cancel their request.

    When a driver requests a rider, the dispatcher assigns a rider from
    the waiting list to the driver. If there is no rider on the waiting list
    the dispatcher does nothing. Once a driver requests a rider, the driver
    is registered with the dispatcher, and will be used to fulfill future
    rider requests.
    """

    _all_drivers: list[Driver]
    _waiting_riders: list[Rider]

    def __init__(self) -> None:
        """Initialize a Dispatcher.

        """
        self._all_drivers = []
        self._waiting_riders = []

    def __str__(self) -> str:
        """Return a string representation.
        """
        return (f"All Drivers: {self._all_drivers} and Waiting Riders: "
                f"{self._waiting_riders}")

    def request_driver(self, rider: Rider) -> Optional[Driver]:
        """Return a driver for the rider, or None if no driver is available.

        Add the rider to the waiting list if there is no available driver.
        """
        idle_drivers = [drv for drv in self._all_drivers
                        if drv.is_idle]

        if not idle_drivers:
            self._waiting_riders.append(rider)
            return None
        else:
            closest_driver = idle_drivers[0]
            closest_travel_time = closest_driver.get_travel_time(rider.origin)

            for driver in idle_drivers[1:]:
                travel_time = driver.get_travel_time(rider.origin)
                if travel_time < closest_travel_time:
                    closest_driver = driver
                    closest_travel_time = travel_time

            return closest_driver

    def request_rider(self, driver: Driver) -> Optional[Rider]:
        """Return a rider for the driver, or None if no rider is available.

        If this is a new driver, register the driver for future rider requests.
        """
        if driver not in self._all_drivers:
            self._all_drivers.append(driver)

        if self._waiting_riders:
            rider = self._waiting_riders.pop(0)
            driver.is_idle = False
            driver.start_drive(rider.origin)
            return rider

        return None

    def cancel_ride(self, rider: Rider) -> None:
        """Cancel the ride for rider.

        """
        rider.change_to_cancelled()
        if rider in self._waiting_riders:
            self._waiting_riders.remove(rider)


if __name__ == '__main__':
    import python_ta

    python_ta.check_all(config={'extra-imports': ['typing', 'driver', 'rider']})
