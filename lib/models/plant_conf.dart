import 'package:intl/intl.dart';

class PlantConf {
  String defLightingValue(double min, double max) {
    if (min == 70.0 && max == 100.0) {
      return '1';
    } else if (min == 80.0 && max == 100.0) {
      return '2';
    } else {
      return '3';
    }
  }

  String defLighting(double min, double max) {
    if (min == 70.0 && max == 100.0) {
      return 'Sombra';
    } else if (min == 80.0 && max == 100.0) {
      return 'Meia-Sombra';
    } else {
      return 'Sol pleno';
    }
  }

  String defMoistureValue(double min, double max) {
    if (min == 10.0 && max == 20.0) {
      return '1';
    } else if (min == 45.0 && max == 55.0) {
      return '2';
    } else if (min == 60.0 && max == 70.0) {
      return '3';
    } else {
      return '4';
    }
  }

  String defMoisture(double min, double max) {
    if (min == 10.0 && max == 20.0) {
      return 'Baixa';
    } else if (min == 45.0 && max == 55.0) {
      return 'Média';
    } else if (min == 60.0 && max == 70.0) {
      return 'Média-Alta';
    } else {
      return 'Alta';
    }
  }

  int sunTime(String _type, int _time) {
    switch (_type) {
      case 'Sombra':
        if (_time >= 7200 && _time <= 7800) {
          return 0;
        } else if (_time < 7800) {
          return 1;
        } else {
          return 2;
        }
      case 'Meia-Sombra':
        if (_time >= 14400 && _time < 15000) {
          return 0;
        } else if (_time < 14400) {
          return 1;
        } else {
          return 2;
        }
      case 'Sol pleno':
        if (_time >= 25200) {
          return 0;
        } else if (_time < 25200) {
          return 1;
        }
    }
    return 0;
  }

  List<int> sunTimeValue(String _type) {
    switch (_type) {
      case 'Sombra':
        return [7200, 7800];

      case 'Meia-Sombra':
        return [14400, 15000];

      case 'Sol pleno':
        return [25200];
    }
    return [];
  }

  String readTimestamp(int timestamp) {
    int horas = timestamp ~/ 3600;
    var minutos = (timestamp - (horas * 3600)) / 60.0;
    return '${NumberFormat("0").format(horas.toInt())}:${NumberFormat("00").format(minutos.toInt())}h';
  }
}
