# EduWeather

# EduWeather

This is a test project in Swift that shows weather conditions using the OpenWeatherMap API.


Remarks:

- WeatherKit framework demonstrates the use of access control, exposing only the useful stuff to the UI
- ServerRequest provides a basic network stack
- Use of GCD demonstrates background processing in a serial queue in order to avoid interfering with the main thread (even when is not necessary in this project because the very limited user interaction).
- Basic parsing of the json objects to Swift structures
- Basic use of location services
- Swift NSTimer wrapper


Current features:

- Displays city, current temperature, minimum temperature, maximum temperature, humidity and pressure
- Displays current conditions icon
- Toggle Celsius/Fahrenheit by tapping on the temperature label
- Persisting Celsius/Fahrenheit setting
- Persisting custom city/current location setting
- Change city by taping on the city label. A tet field allows to enter a new city or a part of it.
- Refresh occurs when:
- location changes by more than 3 km
- the app is activated
- every minute

Future improvements:

- Request and display forecast information
- Add a list of preferred cities persist it
- Use the tile server to display conditions on a map using MapKit
- Implement a generic json parser that produces swift structures instead of the custom one
- The city got grom the API is not very human friendly some times, a more sophisticated approach is probably required, something like using reverse google's reverse geocoding to get the city name
- The WeatherKit framework is too specific, a framework should be more generic and reusable, specially if it is intended for open source. In a real application there should probably be another layer modeling the logic of the app. Part of that logic could be contained in the view controllers, but I'm a fan of keeping the view controllers thin. On the other hand, concentrating much logic in a single model class is also a problem, so good judgement must be used here to draw the lines. In this example however, there is not enough behavior yet to clearly identify the modules, and it was easier to put all the logic in the framework.
