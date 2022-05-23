class Meta {
  late int id;
  late String type;
  late bool deleted;

  Meta({required this.id,required this.type,required this.deleted});

  Meta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    deleted = json['deleted'];
  }
}
