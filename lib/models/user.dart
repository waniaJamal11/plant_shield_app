class User {
  String firstName;
  String lastName;
  String email;
  String username;
  String profilePicture;

  User(
      {this.firstName = '',
      this.lastName = '',
      this.email = '',
      this.username = '',
      this.profilePicture = ''});

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'profilePicture': profilePicture
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }
}
