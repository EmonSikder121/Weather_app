import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_pb_bitm/customwidgets/forecast_item_view.dart';
import 'package:weather_pb_bitm/pages/settings_page.dart';
import 'package:weather_pb_bitm/utils/constants.dart';
import 'package:weather_pb_bitm/utils/helper_functions.dart';
import 'package:weather_pb_bitm/utils/location_service.dart';

import '../providers/app_data_provider.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({Key? key}) : super(key: key);

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late AppDataProvider provider;
  bool isFirst = true;

  @override
  void didChangeDependencies() {
    if (isFirst) {
      provider = Provider.of<AppDataProvider>(context);
      _init();
      isFirst = false;
    }

    super.didChangeDependencies();
  }

  _init() async {
    try {
      final position = await determinePosition();
      provider.setNewPosition(position.latitude, position.longitude);
      provider.setTempUnitData(await getTempStatus());
      //print('${position.latitude} ${position.longitude}');
      provider.getData();
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Image.asset(
                'images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          provider.hasDataLoaded
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.my_location),
                        ),
                        IconButton(
                          onPressed: () {
                            showSearch(context: context, delegate: _CitySearchDelegate()).then((value) {
                              if(value != null && value.isNotEmpty) {
                                provider.convertCityToLatLng(value).then((value) {
                                  showMsg(context, value);
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.search),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsPage()));
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                      backgroundColor: Colors.transparent,
                      expandedHeight: MediaQuery.of(context).size.height * 0.60,
                      floating: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getFormattedDate(provider.currentWeatherModel!.dt!, 'EEEE, MMMM dd, yyyy'),
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white70),
                              ),
                              Text(
                                '${provider.currentWeatherModel!.name},${provider.currentWeatherModel!.sys!.country!}',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white70),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '${provider.currentWeatherModel!.main!.temp!.round()}$degree${provider.unitSymbol}',
                                  style: TextStyle(
                                      fontSize: 80, color: Colors.white),
                                ),
                              ),
                              Text(
                                'Feels like: ${provider.currentWeatherModel!.main!.feelsLike!.round()}$degree${provider.unitSymbol}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white70),
                              ),
                              Image.network('$iconPrefix${provider.currentWeatherModel!.weather![0].icon}$iconSuffix', width: 50, height: 50,),
                              Text(
                                provider.currentWeatherModel!.weather![0].description!,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                          provider.forecastWeatherModel!.list!.map((item) => ForecastItemView(item: item, unitSymbol: provider.unitSymbol,)).toList()),
                    ),
                  ],
                )
              : const Positioned.fill(
                  child: Center(
                    child: Text(
                      'Please wait...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      leading: const Icon(Icons.search),
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty ? cities :
        cities.where((city) => city.toLowerCase().startsWith(query)).toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          close(context, filteredList[index]);
        },
        title: Text(filteredList[index]),
      ),
    );
  }

}
