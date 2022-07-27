/// Metadata
class Meta {
  late int id;
  late String type;
  late bool deleted;

  ///Constructs meta with [id], [type] and deletion state [deleted]
  Meta({required this.id,required this.type, required this.deleted});

  /// Construct Meta from [json]
  Meta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    deleted = json['deleted'];
  }
}
