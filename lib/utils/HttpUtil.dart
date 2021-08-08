import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpUtil {
  static CookieJar cookieJar = CookieJar();

  static String baseUrl = 'https://drive.sakura-bbs.cn';

  static BaseOptions normalOption = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  static Dio dio = Dio(normalOption);

  static List<Dio> getCountDios(int count) {
    List<Dio> dios = [];
    for (int i = 0; i < count; i++) {
      Dio dio = Dio(normalOption);
      dio.interceptors.add(CookieManager(cookieJar));
      dios.add(dio);
    }
    return dios;
  }
}

class GetCookieInterceptor extends CookieManager {
  GetCookieInterceptor(CookieJar cookieJar) : super(cookieJar);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var cookies = response.headers[HttpHeaders.setCookieHeader];
    if (cookies != null) {
      _saveCookie(cookies[0]);
    }
    handler.next(response);
  }

  void _saveCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(HttpHeaders.cookieHeader, cookie.toString());
  }
}
