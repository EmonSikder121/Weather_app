import 'package:flutter/material.dart';
import 'package:weather_pb_bitm/utils/constants.dart';
import 'package:weather_pb_bitm/utils/helper_functions.dart';

import '../models/forecast_weather_model.dart';

class ForecastItemView extends StatelessWidget {
  final ForecastItem item;
  final String unitSymbol;
  const ForecastItemView({Key? key, required this.item, required this.unitSymbol}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        color: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Text(getFormattedDate(item.dt!, 'HH:mm'), style: TextStyle(fontSize: 16, color: Colors.white),),
              trailing: Image.network('$iconPrefix${item.weather![0].icon}$iconSuffix', width: 60, height: 60,),
              title: Text('${getFormattedDate(item.dt!, 'EEEE')} ${item.main!.temp!.round()}$degree$unitSymbol', style: TextStyle(fontSize: 20, color: Colors.white),),
              subtitle: Text(item.weather![0].description!, style: TextStyle(fontSize: 17, color: Colors.white),),
            )
          ],
        ),
      ),
    );
  }
}
