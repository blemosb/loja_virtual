class Address { //classe para o app chamar o endereço e nao depender da api

  Address({this.street, this.number, this.complement, this.district,
    this.zipCode, this.city, this.state, this.lat, this.long});

  String street;
  String number;
  String complement;
  String district;
  String zipCode;
  String city;
  String state;

  double lat;
  double long;

}