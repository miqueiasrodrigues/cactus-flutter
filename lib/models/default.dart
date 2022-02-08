class Default {
  String getPlantUrl() {
    return 'https://image.flaticon.com/icons/png/512/628/628323.png';
  }

  String getUserUrl() {
    return 'https://image.flaticon.com/icons/png/512/847/847969.png';
  }

  String getId() {
    return DateTime.now()
        .toString()
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .toString();
  }
}
