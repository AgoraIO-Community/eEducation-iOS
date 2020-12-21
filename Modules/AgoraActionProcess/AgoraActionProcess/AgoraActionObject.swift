//
//  AgoraActionObject.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation

public let AgoraActionHTTPOK = 0

public struct AgoraActionConfig {
    var appId: String = ""
    var roomUuid: String = ""
    var userToken: String = ""
    var customerId: String = ""
    var customerCertificate: String = ""
    
    var baseURL: String = ""
}

public enum AgoraActionType: Int {
    case apply = 1, invitation, accept, reject, cancel
}

public struct AgoraActionOptions {
    
    var actionType: AgoraActionType = .apply
    
    // How many people are allowed to apply / invite at the same time
    // 最多允许接受多少人同时申请/邀请
    var maxWait: Int = 4
    // Unresponsive timeout (seconds)
    // 未响应超时时间(秒)
    var timeout: Int = 10
    
    var processUuid: String = ""
}

public struct AgoraActionStartOptions {
    var toUserUuid: String = ""
    var processUuid: String = ""
    var fromUserUuid: String = ""
    var payload: [String: Any] = [:]
}

public struct AgoraActionStopOptions {
    var toUserUuid: String = ""
    var processUuid: String = ""
    var action: AgoraActionType = .accept
    var fromUserUuid: String = ""
    var payload: [String: Any] = [:]
    var waitAck: Int = 1
}

// response
public struct AgoraActionResult {
    var code: Int = AgoraActionHTTPOK
    var msg: String = ""
}
