from driver import Driver
from dispatcher import Dispatcher
from rider import Rider
from location import (Location, manhattan_distance, deserialize_location,
                      NotValidError)
from monitor import Monitor, Activity, RIDER, REQUEST
from event import RiderRequest, DriverRequest, Pickup, Dropoff, Cancellation
import pytest


# Test cases for Driver class
def test_driver_initialization() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    assert driver.id == "Driver1"
    assert driver.location == Location(0, 0)
    assert driver.speed == 10
    assert driver.is_idle


def test_driver_get_travel_time() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    assert driver.get_travel_time(Location(5, 5)) == 1


def test_driver_start_drive() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    travel_time = driver.start_drive(Location(3, 4))
    assert travel_time == 1
    assert not driver.is_idle


def test_driver_end_drive() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    driver.start_drive(Location(3, 4))
    driver.end_drive()
    assert driver.is_idle
    assert driver.location == Location(3, 4)


def test_driver_start_ride() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    ride_time = driver.start_ride(rider)
    assert ride_time == 1
    assert not driver.is_idle
    assert driver._destination == Location(5, 5)


def test_driver_end_ride() -> None:
    driver = Driver("Driver1", Location(0, 0), 10)
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    driver.start_ride(rider)
    driver.end_ride()
    assert driver.is_idle
    assert driver.location == Location(5, 5)


# Test cases for Dispatcher class
def test_dispatcher_request_driver_no_drivers() -> None:
    dispatcher = Dispatcher()
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    driver = dispatcher.request_driver(rider)
    assert driver is None
    assert rider in dispatcher._waiting_riders


def test_dispatcher_request_driver_with_idle_driver() -> None:
    dispatcher = Dispatcher()
    driver = Driver("Driver1", Location(0, 0), 10)
    dispatcher._all_drivers.append(driver)
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    assigned_driver = dispatcher.request_driver(rider)
    assert assigned_driver == driver


def test_dispatcher_request_rider_no_riders() -> None:
    dispatcher = Dispatcher()
    driver = Driver("Driver1", Location(0, 0), 10)
    assigned_rider = dispatcher.request_rider(driver)
    assert assigned_rider is None
    assert driver in dispatcher._all_drivers


def test_dispatcher_request_rider_with_waiting_rider() -> None:
    dispatcher = Dispatcher()
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    dispatcher._waiting_riders.append(rider)
    driver = Driver("Driver1", Location(0, 0), 10)
    assigned_rider = dispatcher.request_rider(driver)
    assert assigned_rider == rider
    assert not driver.is_idle


def test_dispatcher_cancel_ride() -> None:
    dispatcher = Dispatcher()
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    dispatcher._waiting_riders.append(rider)
    dispatcher.cancel_ride(rider)
    assert rider not in dispatcher._waiting_riders


# Test cases for Events
def test_rider_request_event() -> None:
    dispatcher = Dispatcher()
    monitor = Monitor()
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    event = RiderRequest(0, rider)
    new_events = event.do(dispatcher, monitor)
    assert len(new_events) == 1
    assert isinstance(new_events[0], Cancellation)


def test_driver_request_event() -> None:
    dispatcher = Dispatcher()
    monitor = Monitor()
    driver = Driver("Driver1", Location(0, 0), 10)
    event = DriverRequest(0, driver)
    new_events = event.do(dispatcher, monitor)
    assert len(new_events) == 0


def test_pickup_event() -> None:
    dispatcher = Dispatcher()
    monitor = Monitor()
    driver = Driver("Driver1", Location(0, 0), 10)
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    dispatcher._waiting_riders.append(rider)
    pickup_event = Pickup(0, rider, driver)
    new_events = pickup_event.do(dispatcher, monitor)
    assert len(new_events) == 1
    assert isinstance(new_events[0], Dropoff)


def test_dropoff_event() -> None:
    dispatcher = Dispatcher()
    monitor = Monitor()
    driver = Driver("Driver1", Location(0, 0), 10)
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    driver.start_ride(rider)
    dropoff_event = Dropoff(0, rider, driver)
    new_events = dropoff_event.do(dispatcher, monitor)
    assert len(new_events) == 1
    assert isinstance(new_events[0], DriverRequest)


def test_cancellation_event() -> None:
    dispatcher = Dispatcher()
    monitor = Monitor()
    rider = Rider("Rider1", 10, Location(1, 1), Location(5, 5))
    dispatcher._waiting_riders.append(rider)
    cancellation_event = Cancellation(0, rider)
    new_events = cancellation_event.do(dispatcher, monitor)
    assert len(new_events) == 0
    assert rider not in dispatcher._waiting_riders


# Test cases for Location class
def test_location_initialization() -> None:
    loc = Location(5, 10)
    assert loc.x == 5
    assert loc.y == 10


def test_manhattan_distance() -> None:
    loc1 = Location(0, 0)
    loc2 = Location(5, 10)
    assert manhattan_distance(loc1, loc2) == 15


def test_deserialize_location() -> None:
    loc_str = "5,10"
    loc = deserialize_location(loc_str)
    assert loc.x == 5
    assert loc.y == 10


def test_deserialize_invalid_location() -> None:
    with pytest.raises(NotValidError):
        deserialize_location("invalid")


if __name__ == "__main__":
    pytest.main(['test_driver_dispatcher_events.py'])
