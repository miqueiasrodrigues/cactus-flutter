class Plant {
  final String plantId;
  final String title;
  final String imageUrl;

  final String arduino;
  final String date;

  final double moistureMin;
  final double moistureMax;
  final double moisture;

  final double temperatureMin;
  final double temperatureMax;
  final double temperature;

  final double lightingMin;
  final double lightingMax;
  final double lighting;

  final int timer;
  final bool situation;

  final String ssid;
  final String pass;

  final Map<String, dynamic> register;

  const Plant({
    this.plantId = '',
    required this.arduino,
    required this.date,
    required this.title,
    required this.imageUrl,
    required this.moistureMin,
    required this.moistureMax,
    this.moisture = 0,
    required this.temperatureMin,
    required this.temperatureMax,
    this.temperature = 0,
    required this.lightingMin,
    required this.lightingMax,
    this.lighting = 0,
    required this.situation,
    required this.timer,
    required this.register,
    required this.ssid,
    required this.pass,
  });
}
