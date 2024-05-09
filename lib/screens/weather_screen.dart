import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/widget/hourly_forcast_widgets.dart';
import 'package:intl/intl.dart';

import 'package:weather_app/src/api_call.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  @override
  void initState() {
    super.initState();
    weather = fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: (() {
                setState(() {
                  weather = fetchWeatherData();
                });
              }),
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      // temperature == 0
      //     ? const Center(
      //         child: CircularProgressIndicator.adaptive(
      //         semanticsLabel: "WeatherApp",
      //       ))
      //     :
      body: FutureBuilder(
          future: weather,
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapShot.hasError) {
              return Center(
                child: Text(
                  snapShot.error.toString(),
                ),
              );
            }
            final items = snapShot.data!["list"];
            final double temperature =
                snapShot.data!["list"][1]["main"]['temp'];
            final int pressure = snapShot.data!["list"][1]["main"]['pressure'];
            final int humidity = snapShot.data!["list"][1]["main"]['humidity'];
            final String label =
                snapShot.data!["list"][2]["weather"][0]['main'];
            final String description =
                snapShot.data!["list"][2]["weather"][0]['description'];
            final double windSpeed = snapShot.data!["list"][3]["wind"]['speed'];

            // IconData icon;
            Widget weatherIcon;
            switch (label.toLowerCase()) {
              case "clouds":
                weatherIcon = const Icon(
                  Icons.cloud,
                  color: Colors.white,
                  size: 100,
                );
              case "clear sky":
                weatherIcon = const Icon(
                  Icons.sunny,
                  color: Colors.amber,
                );
              case "rain":
                weatherIcon = const Icon(
                  Icons.cloudy_snowing,
                  color: Colors.white,
                );
                break;
              default:
                weatherIcon = const Icon(
                  Icons.cloud,
                  color: Colors.white,
                );
            }
            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main cards
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.blueGrey,
                      elevation: 300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$temperature k",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                // Main card icon
                                weatherIcon,
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Additional information widget
                  WeatherInfo(
                    items: items,
                  ),
                  // weather forecast widget

                  AdditionalInfo(
                    humidity: humidity,
                    pressure: pressure,
                    windSpeed: windSpeed,
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final List<dynamic> items;
  const WeatherInfo({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Hourly Forecast",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     // mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       for (int element = 0; element < 5; element++)
        //         HourlyForcastItem(
        //           time: DateTime.parse(items[element + 1]['dt_txt'].toString())
        //               .hour,
        //           icon: items[element + 1]["weather"][0]["main"] ==
        //                       "Clouds".toLowerCase() ||
        //                   items[element + 1]["weather"][0]["main"] ==
        //                       "Rain".toLowerCase()
        //               ? Icons.cloud
        //               : Icons.sunny,
        //           temperature: items[element + 1]['main']['temp'].toString(),
        //         ),
        //     ],
        //   ),
        // ),
        SizedBox(
          height: 135,
          child: ListView.builder(
            shrinkWrap: true,
            primary: true,
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              final hourlyForcast = items[index + 1];
              final hourlyForcastTemp =
                  hourlyForcast['main']['temp'].toString();
              final hourlyForcastIcon = hourlyForcast["weather"][0]["main"];
              final time = DateTime.parse(hourlyForcast['dt_txt'].toString());
              return HourlyForcastItem(
                time: DateFormat.Hm().format(time),
                icon: hourlyForcastIcon == "Clouds".toLowerCase() ||
                        hourlyForcastIcon == "Rain".toLowerCase()
                    ? Icons.cloud
                    : Icons.sunny,
                temperature: hourlyForcastTemp,
              );
            },
          ),
        )
      ],
    );
  }
}

class AdditionalInfo extends StatelessWidget {
  final int humidity;
  final int pressure;
  final double windSpeed;

  const AdditionalInfo({
    super.key,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                "Additional Information",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AdditionInfoWidget(
                label: "Humidity",
                icon: Icons.water_drop,
                value: "$humidity",
              ),
              AdditionInfoWidget(
                label: "Wind Speed",
                icon: Icons.air,
                value: "$windSpeed",
              ),
              AdditionInfoWidget(
                label: "Pressure",
                icon: Icons.beach_access_rounded,
                value: "$pressure",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdditionInfoWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionInfoWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
  });

  // String title = title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 38,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
