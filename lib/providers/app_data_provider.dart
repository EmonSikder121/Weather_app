import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:weather_pb_bitm/models/current_weather_model.dart';
import 'package:weather_pb_bitm/models/forecast_weather_model.dart';

import '../utils/constants.dart';

class AppDataProvider extends ChangeNotifier {
  double latitude = 0.0, longitude = 0.0;
  CurrentWeatherModel? currentWeatherModel;
  ForecastWeatherModel? forecastWeatherModel;
  String unit = metric;
  String unitSymbol = unitSymbolCelsius;

  bool get hasDataLoaded => currentWeatherModel != null &&
      forecastWeatherModel != null;

  setNewPosition(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  setTempUnitData(bool status) {
    unit = status ? imperial : metric;
    unitSymbol = status ? unitSymbolFahrenheit : unitSymbolCelsius;
  }

  getData() {
    _getCurrentData();
    _getForecastData();
  }

  void _getCurrentData() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key';
    try {
      final response = await get(Uri.parse(url));
      if(response.statusCode == 200) {
        final map = json.decode(response.body);
        currentWeatherModel = CurrentWeatherModel.fromJson(map);
        //print(currentWeatherModel?.main?.temp);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {
      print(error.toString());
    }
  }

  void _getForecastData() async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key';
    try {
      final response = await get(Uri.parse(url));
      if(response.statusCode == 200) {
        final map = json.decode(response.body);
        forecastWeatherModel = ForecastWeatherModel.fromJson(map);
        //print(forecastWeatherModel?.list?.length);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {
      print(error.toString());
    }
  }

  Future<String> convertCityToLatLng(String city) async {
    try {
      final locationList = await locationFromAddress(city);
      if(locationList.isNotEmpty) {
        final location = locationList.first;
        latitude = location.latitude;
        longitude = location.longitude;
        getData();
        return 'Fetching data for $city';
      } else {
        return 'could not found location';
      }
    } catch (error) {
      print(error.toString());
      return error.toString();
    }
  }
}