
|版本 |废弃接口 | 废弃说明                                              | 替代接口                                                                                                                          |
|--- |--- |---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
|3.21.100|PreMeetingService.showMeetingDetailView(string meeting_id, string current_sub_meeting_id)| SDK新版内部实现更改，需要使用新版的替代函数                           | PreMeetingService.showMeetingDetailView(string meeting_id, string current_sub_meeting_id, string start_time, bool is_history) |
|3.21.100|PreMeetingCallback.onShowScreenCastViewResult| 该回调事件函数已由更统一的`onActionResult`替代，对应 `action_type`为`ShowScreenCastView` |PreMeetingCallback.onActionResult(int action_type, int code, string msg) |
|3.21.200|InMeetingService.leaveMeeting(bool end_meeting) | 新版参数做了更改，新参数`int leave_meeting_type`扩展了功能 |  InMeetingService.leaveMeeting(int leave_meeting_type) |
