import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController locationController = TextEditingController();

  Future<void> getWeather(BuildContext context) async {
    await dotenv.load();
    final apiKey = dotenv.env['83b36484de8034ef6854755254d905f8'];
    final location = locationController.text.trim();

    if (location.isEmpty) {
      // Show an error if the location is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a location.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final String cityName = data['name'];
      final double temperature = data['main']['temp'];
      final int humidity = data['main']['humidity'];
      final double windSpeed = data['wind']['speed'];
      final String description = data['weather'][0]['description'];

      // Display weather details in a Card
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Weather in $cityName'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.thermostat, color: Colors.blue),
                      title: Text('Temperature'),
                      subtitle: Text('${temperature.toStringAsFixed(2)}°C'),
                    ),
                    ListTile(
                      leading: Icon(Icons.wb_sunny, color: Colors.yellow),
                      title: Text('Description'),
                      subtitle: Text(description),
                    ),
                    ListTile(
                      leading: Icon(Icons.opacity, color: Colors.lightBlue),
                      title: Text('Humidity'),
                      subtitle: Text('$humidity%'),
                    ),
                    ListTile(
                      leading: Icon(Icons.air, color: Colors.cyan),
                      title: Text('Wind Speed'),
                      subtitle: Text('$windSpeed m/s'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch weather data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Enter Location (City, Country)',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => getWeather(context),
                child: Text('Get Weather'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
