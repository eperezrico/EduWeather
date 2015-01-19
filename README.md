# EduWeather

This is a test project in Swift that shows weather conditions using the OpenWeatherMap API.


Remarks:

- WeatherKit framework demonstrates the use of access control, expossing only the useful stuff to the UI
- ServerRequest provides a basic network stack
- Use of GCD demonstrates background processing in a serial queue in order to avoid interfering with the main thread (even when is not necessary in this project because the very limited user interaction).
- Basic parsing of the json objects to Swift structures
- Basic use of location services
- Swift NSTimer wrapper


Current features:

- Displays city, current temperature, minimum temperature, maximum temperature, humidity and pressure
- Displays current conditions icon
- Toggle Celsius/Farenheit by tapping on the temperature label
- Change city by taping on the city label. A tet field allows to enter a new city or a part of it.
- Refresh occurs when:
  - location changes by more than 3 km
  - the app is activated
  - every minute

Future improvements:

- Persist the Celsius/Farenheit setting
- Request and display forecast information
- Add a list of preferred cities persist it
- Use the tile server to display conditions on a map using MapKit
