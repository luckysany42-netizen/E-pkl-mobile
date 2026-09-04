class LeaveRequestModel {
  final int id;
  final DateTime date;
  final String reasonType;
  final String? note;
  final String? attachment;
  final String status;

  const LeaveRequestModel({
    required this.id,
    required this.date,
    required this.reasonType,
    required this.note,
    required this.attachment,
    required this.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      date: DateTime.parse(json['date'].toString()).toLocal(),
      reasonType: json['reason_type']?.toString() ?? '',
      note: json['note']?.toString(),
      attachment: json['attachment']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}
