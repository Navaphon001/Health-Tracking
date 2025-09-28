class TokenResponse {
  final String accessToken;
  final String tokenType;

  TokenResponse({required this.accessToken, this.tokenType = 'bearer'});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] != null ? json['token_type'] as String : 'bearer',
    );
  }
}
