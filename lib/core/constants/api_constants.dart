class ApiConstants {
  static const String baseUrl = 'https://api.aroundu.in';
  
  static String getEventDetailUrl(String eventId) {
    return '/match/lobby/public/$eventId/detail';
  }
  
  static Map<String, String> getHeaders(String? token) {
    final headers = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': 'https://www.aroundu.in',
      'Referer': 'https://www.aroundu.in/',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
