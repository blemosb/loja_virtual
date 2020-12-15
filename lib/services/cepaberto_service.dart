import 'dart:io';
import 'package:dio/dio.dart';
import 'package:loja_virtual/models/cepaberto_address.dart';

const token = '7c47851fdc09a6cae8ecd3f635b741e3';

class CepAbertoService {

  Future<CepAbertoAddress> getAddressFromCep(String cep) async {
    final cleanCep = cep.replaceAll('.', '').replaceAll('-', '');
    final endpoint = "https://www.cepaberto.com/api/v3/cep?cep=$cleanCep";

    final Dio dio = Dio();

    dio.options.headers[HttpHeaders.authorizationHeader] = 'Token token=$token';

    try { //se a requisição foi ok
      final response = await dio.get<Map<String, dynamic>>(endpoint);

      if(response.data.isEmpty){ //se retornou vazio
        return Future.error('CEP Inválido');
      }

      print(response.data);
    } on DioError catch (e){ //se deu erro na requisição, pode ser falta de internet por exemplo...
      return Future.error('Erro ao buscar CEP');
    }
  }
}