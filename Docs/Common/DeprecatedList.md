
|版本 | 平台 |废弃接口 | 废弃说明                                              | 替代接口                                                                                                                          |
|--- |--- |--- |---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
|3.21.100| ALL |PreMeetingService.showMeetingDetailView(string meeting_id, string current_sub_meeting_id)| SDK新版内部实现更改，需要使用新版的替代函数                           | PreMeetingService.showMeetingDetailView(string meeting_id, string current_sub_meeting_id, string start_time, bool is_history) |
|3.21.100| ALL |PreMeetingCallback.onShowScreenCastViewResult| 该回调事件函数已由更统一的`onActionResult`替代，对应 `action_type`为`ShowScreenCastView` |PreMeetingCallback.onActionResult(int action_type, int code, string msg) |
|3.21.200| ALL |InMeetingService.leaveMeeting(bool end_meeting) | 新版参数做了更改，新参数`int leave_meeting_type`扩展了功能 |  InMeetingService.leaveMeeting(int leave_meeting_type) |
|3.30.305| iOS |InMeetingService. instance() | 直接使用`InMeetingService` 获取实例可能存在时序问题，影响后续功能。 | TencentMeetingSDK.instance.getInMeetingService |
|3.30.305| iOS |PreMeetingService. instance() | 直接使用`PreMeetingService` 获取实例可能存在时序问题，影响后续功能。 | TencentMeetingSDK.instance.getPreMeetingService |
|3.30.305| iOS |AccountService.instance() | 直接使用`AccountService` 获取实例可能存在时序问题，影响后续功能。 | TencentMeetingSDK.instance.getAccountService |
|3.30.305| iOS |UserConfigService.instance() | 直接使用`UserConfigService` 获取实例可能存在时序问题，影响后续功能。 | TencentMeetingSDK.instance.getUserConfigService |
