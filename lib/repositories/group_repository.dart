import 'dart:convert';

import 'package:arisan_digital/models/group_model.dart';
import 'package:arisan_digital/models/member_model.dart';
import 'package:arisan_digital/models/response_model.dart';
import 'package:arisan_digital/repositories/auth_repository.dart';
import 'package:arisan_digital/utils/generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupRepository {
  final _baseURL = dotenv.env['BASE_URL'].toString();
  final AuthRepository _authRepo = AuthRepository();
  String? _token;

  Future getToken() async {
    _token = await _authRepo.getToken();
  }

  Future<List<GroupModel>?> getGroups() async {
    try {
      await getToken();
      final response = await http.get(Uri.parse('$_baseURL/groups'), headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json'
      });

      // print(response.body);

      if (response.statusCode == 200) {
        Iterable iterable = json.decode(response.body)['data'];
        List<GroupModel> listGroups =
            iterable.map((e) => GroupModel.fromJson(e)).toList();
        return listGroups;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<List<MemberModel>?> getMemberGroups(int id) async {
    try {
      await getToken();
      final response = await http.get(Uri.parse('$_baseURL/group/members/$id'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json'
          });
      // print(response.body);
      if (response.statusCode == 200) {
        Iterable iterable = json.decode(response.body)['data'];
        List<MemberModel> listMembers =
            iterable.map((e) => MemberModel.fromJson(e)).toList();
        return listMembers;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<GroupModel?> showGroup(int id) async {
    try {
      await getToken();
      final response = await http.get(Uri.parse('$_baseURL/group/$id'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return GroupModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<GroupModel?> showGuestGroup(String code) async {
    try {
      await getToken();
      final response = await http.get(Uri.parse('$_baseURL/guest/group/$code'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return GroupModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<ResponseModel?> createGroup(GroupModel group) async {
    try {
      await getToken();
      final response = await http.post(Uri.parse('$_baseURL/group/store'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': group.name,
            'periods_type': periodsTypeEn(group.periodsType ?? ''),
            'periods_date': group.periodsDate,
            'dues': group.dues,
            'target': group.target ?? '',
            'code': Generator.randomCode()
            // 'notes': group.notes,
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

  String periodsTypeEn(String periodsType) {
    if (periodsType.toLowerCase() == 'mingguan') {
      return 'weekly';
    } else if (periodsType.toLowerCase() == 'bulanan') {
      return 'monthly';
    } else if (periodsType.toLowerCase() == 'tahunan') {
      return 'annual';
    }
    return 'monthly';
  }

  Future<ResponseModel?> updateGroup(GroupModel group) async {
    try {
      await getToken();
      final response =
          await http.patch(Uri.parse('$_baseURL/group/update/${group.id}'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'name': group.name,
                'periods_type': periodsTypeEn(group.periodsType ?? ''),
                'periods_date': group.periodsDate,
                'dues': group.dues,
                'target': group.target ?? '',
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

  Future<ResponseModel?> updateStatusGroup(int id,
      {StatusGroup? status = StatusGroup.active}) async {
    try {
      await getToken();
      final response =
          await http.patch(Uri.parse('$_baseURL/group/update/status/$id'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'status': status == StatusGroup.active ? 'active' : 'inactive',
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

  Future<ResponseModel?> updateNotesGroup(int id, {String? notes}) async {
    try {
      await getToken();
      final response =
          await http.patch(Uri.parse('$_baseURL/group/update/notes/$id'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'notes': notes,
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

  Future<ResponseModel?> updateDateGroup(int id, {String? date}) async {
    try {
      await getToken();
      final response =
          await http.patch(Uri.parse('$_baseURL/group/update/periods-date/$id'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'periods_date': date,
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

  Future<ResponseModel?> deleteGroup(int id) async {
    try {
      await getToken();
      final response = await http
          .delete(Uri.parse('$_baseURL/group/delete/$id'), headers: {
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

  Future<String?> getGroupCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupCode = prefs.getString("group_code");
    return groupCode;
  }

  Future setGroupCode(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("group_code", code);
  }

  Future removeGroupCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("group_code");
  }
}
