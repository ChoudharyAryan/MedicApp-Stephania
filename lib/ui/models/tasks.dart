// ignore_for_file: public_member_api_docs, sort_constructors_first
class Task {
  int? id;
  String? name;
  String? dosage;
  int? isCompleted;
  String? recurrence;
  String? miligram;
  String? enddate;
  String? dosetime;

  Task({
    this.id,
    this.name,
    this.dosage,
    this.isCompleted,
    this.recurrence,
    this.miligram,
    this.enddate,
    this.dosetime,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    dosage = json['dosage'].toString();
    isCompleted = json['isCompleted'];
    recurrence = json['recurrence'];
    miligram = json['miligram'].toString();
    enddate = json['enddate'];
    dosetime = json['dosetime'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['dosage'] = int.parse(dosage ?? "0");
    data['recurrence'] = recurrence;
    data['isCompleted'] = isCompleted;
    data['miligram'] = miligram;
    data['enddate'] = enddate;
    data['dosetime'] = dosetime;

    return data;
  }
}
