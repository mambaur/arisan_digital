import 'dart:convert';

import 'package:arisan_digital/models/member_model.dart';
import 'package:arisan_digital/models/response_model.dart';
import 'package:arisan_digital/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MemberRepository {
  final _baseURL = dotenv.env['BASE_URL'].toString();
  final AuthRepository _authRepo = AuthRepository();
  String? _token;

  Future getToken() async {
    _token = await _authRepo.getToken();
  }

  Future<ResponseModel?> createMember(MemberModel member) async {
    await getToken();
    try {
      final response = await http.post(Uri.parse('$_baseURL/member/store'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'group_id': member.group!.id,
            'name': member.name,
            'gender': _gender(member.gender ?? ''),
            'no_telp': member.noTelp,
            'no_whatsapp': member.noTelp,
            // 'no_whatsapp': member.noWhatsapp,
            'email': member.email,
          }));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  String _gender(String param) {
    if (param == 'Laki-laki') return 'male';
    return 'female';
  }

  Future<MemberModel?> showMember(int id) async {
    await getToken();
    try {
      final response = await http.get(Uri.parse('$_baseURL/member/$id'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return MemberModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> updateMember(MemberModel member) async {
    await getToken();
    try {
      final response =
          await http.patch(Uri.parse('$_baseURL/member/update/${member.id}'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'name': member.name,
                'no_telp': member.noTelp,
                'no_whatsapp': member.noTelp,
                'gender': _gender(member.gender ?? ''),
                // 'no_whatsapp': member.noWhatsapp,
                'email': member.email,
              }));

      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> updateStatusPaid(MemberModel member) async {
    await getToken();
    try {
      final response = await http.patch(
          Uri.parse('$_baseURL/member/update/status-paid/${member.id}'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'date_paid': member.datePaid,
            'status_paid': member.statusPaid,
            'nominal_paid': member.nominalPaid
          }));
      // print(response.body);
      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> updateStatusActive(MemberModel member) async {
    await getToken();
    try {
      final response = await http.patch(
          Uri.parse('$_baseURL/member/update/status-active/${member.id}'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'status_active': member.statusActive,
          }));

      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> resetStatusPaid(MemberModel member) async {
    await getToken();
    try {
      final response = await http.patch(
          Uri.parse('$_baseURL/member/reset/status-paid/${member.id}'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });

      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> deleteMember(int id) async {
    await getToken();
    try {
      final response = await http
          .delete(Uri.parse('$_baseURL/member/delete/$id'), headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json'
      });

      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> sendRemainder(int groupId) async {
    await getToken();
    try {
      final response = await http.post(
          Uri.parse('$_baseURL/members/mail/reminder/$groupId'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json'
          });

      // Error handling
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ResponseModel.fromJson(jsonResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}
