import 'dart:io';

import '../../../../core/network/result.dart';
import '../../data/models/leave_request_model.dart';

abstract class LeaveRepository {
  Future<Result<List<LeaveRequestModel>>> getLeaveRequests();

  Future<Result<LeaveRequestModel>> createLeaveRequest({
    required DateTime date,
    required String reasonType,
    String? note,
    File? attachment,
  });
}
