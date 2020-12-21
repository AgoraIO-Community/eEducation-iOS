//
//  AgoraActionObjectOC.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation

@objcMembers public class AgoraActionConfigOC: NSObject {
    public var appId: String = ""
    public var roomUuid: String = ""
    public var userToken: String = ""
    public var customerId: String = ""
    public var customerCertificate: String = ""
    
    public var baseURL: String = ""
}

@objc public enum AgoraActionTypeOC: Int {
    case apply = 1, invitation, accept, reject, cancel
}

@objcMembers public class AgoraActionOptionsOC: NSObject {
    
    public var actionType: AgoraActionTypeOC = .apply
    
    // How many people are allowed to apply / invite at the same time
    // 最多允许接受多少人同时申请/邀请
    public var maxWait: Int = 4
    // Unresponsive timeout (seconds)
    // 未响应超时时间(秒)
    public var timeout: Int = 10
    
    public var processUuid: String = ""
}

@objcMembers public class AgoraActionStartOptionsOC: NSObject {
    public var toUserUuid: String = ""
    public var processUuid: String = ""
    public var fromUserUuid: String = ""
    public var payload: [String: Any] = [:]
}

@objcMembers public class AgoraActionStopOptionsOC: NSObject {
    public var toUserUuid: String = ""
    public var processUuid: String = ""
    public var action: AgoraActionTypeOC = .accept
    public var fromUserUuid: String = ""
    public var payload: [String: Any] = [:]
}

// response
@objcMembers public class AgoraActionResultOC: NSObject {
    public var code: Int = 0
    public var msg: String = ""
}
