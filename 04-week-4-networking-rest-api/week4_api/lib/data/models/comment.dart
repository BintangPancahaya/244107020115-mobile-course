/// Model Comment dari endpoint GET /comments?postId={id}.
/// fromJson dibuat aman null: field hilang / tipe salah -> nilai default,
/// sehingga tidak crash "type 'Null' is not a subtype of ...".
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // Perbaikan: versi awal memakai `as num?` yang tetap crash bila server
      // mengirim String (mis. "9"). Sekarang dicek dengan `is num` dulu.
      postId: _toInt(json['postId']),
      id: _toInt(json['id']),
      // Cast defensif: hanya String yang diterima, selain itu ''.
      name: _toStr(json['name']),
      email: _toStr(json['email']),
      body: _toStr(json['body']),
    );
  }

  static int _toInt(Object? v) => v is num ? v.toInt() : 0;
  static String _toStr(Object? v) => v is String ? v : '';

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
