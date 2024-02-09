import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: LatLng(10.0110607466113, 76.37059038932293),
          initialZoom: 13,
          onTap: (tapPosition, point) async {
            final response = await sendHttpRequest(point.latitude, point.longitude);
            showSnackBar(context, response);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/msuteu/clse664o401dj01qs7ll7d6i0/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibXN1dGV1IiwiYSI6ImNsNjBtcmZtaDAxdWIzZXAzaXh2MWpjNnoifQ.L5xob1M0ve9CSDs_Upje-A',
            additionalOptions: const {
              'accessToken':
              'pk.eyJ1IjoibXN1dGV1IiwiYSI6ImNsNjBtcmZtaDAxdWIzZXAzaXh2MWpjNnoifQ.L5xob1M0ve9CSDs_Upje-A'
            },
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () {
                  print("object");
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>> sendHttpRequest(double lat, double lng) async {
  final API = "b7e9010beabd8a74c0f3959dd7660bd1";
  final String apiUrl =
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&appid=$API';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> weatherList = jsonResponse['list'];
      WeatherData weatherData = WeatherData.fromJson(weatherList[0]);
      return {
        'status': 1,
        'DateTime': weatherData.dateTime,
        'Temperature': weatherData.temperature,
        'Wind Speed': weatherData.windSpeed,
        'Clouds': weatherData.clouds,
      };
    } else {
      print('Error: ${response.statusCode}');
      return {'status': 0};
    }
  } catch (error) {
    print('Error: $error');
    return {'status': 0};
  }
}

void showSnackBar(BuildContext context, Map<String, dynamic> response) {
  ScaffoldMessenger.of(context).clearSnackBars();
  if (response['status'] == 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DateTime: ${response['DateTime']}'),
            Text('Temperature: ${response['Temperature']}'),
            Text('Wind Speed: ${response['Wind Speed']}'),
            Text('Clouds: ${response['Clouds']}'),
          ],
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error fetching weather data'),
      ),
    );
  }
}

class WeatherData {
  final DateTime dateTime;
  final double temperature;
  final double windSpeed;
  final int clouds;

  WeatherData({
    required this.dateTime,
    required this.temperature,
    required this.windSpeed,
    required this.clouds,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      clouds: json['clouds']['all'],
    );
  }
}
