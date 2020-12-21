//
//  AgoraActionProcessManagerOC.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation

public typealias AgoraActionHTTPSuccessOC = (AgoraActionResultOC) -> Void
public typealias AgoraActionHTTPFailureOC = (Error) -> Void

public class AgoraActionProcessManagerOC: NSObject {
    
    fileprivate var manager: AgoraActionProcessManager?
    
    fileprivate var config: AgoraActionConfig = AgoraActionConfig()
    
    fileprivate override init() {
    }
    
    @objc public convenience init(_ config: AgoraActionConfigOC) {
        self.init()
        
        self.config = AgoraActionConfig(appId: config.appId, roomUuid: config.roomUuid, userToken: config.userToken, customerId: config.customerId, customerCertificate: config.customerCertificate, baseURL: config.baseURL)
        self.manager = AgoraActionProcessManager(self.config)
    }
    
    @objc public func setAgoraAction(options: AgoraActionOptionsOC, success: AgoraActionHTTPSuccessOC?, failure: AgoraActionHTTPFailureOC?) {
        
        let rawValue = options.actionType.rawValue
        let swiftoOtions = AgoraActionOptions(actionType: AgoraActionType(rawValue: rawValue) ?? .apply, maxWait: options.maxWait, timeout: options.timeout, processUuid: options.processUuid)
        
        self.manager?.setAgoraAction(options: swiftoOtions, success: {[weak self] (result) in
            
            if let ocResult = self?.mapToAgoraActionResultOC(result) {
                success?(ocResult)
            }

        }, failure:failure)
    }
    
    @objc public func deleteAgoraAction(processUuid: String, success: AgoraActionHTTPSuccessOC?, failure: AgoraActionHTTPFailureOC?) {
        
        self.manager?.deleteAgoraAction(processUuid: processUuid, success: {[weak self] (result) in
            
            if let ocResult = self?.mapToAgoraActionResultOC(result) {
                success?(ocResult)
            }
            
        }, failure: failure)
    }
    
    @objc public func startAgoraActionProcess(options: AgoraActionStartOptionsOC, success: AgoraActionHTTPSuccessOC?, failure: AgoraActionHTTPFailureOC?) {
        
        let swiftOptions = AgoraActionStartOptions(toUserUuid: options.toUserUuid, processUuid: options.processUuid, fromUserUuid: options.fromUserUuid, payload: options.payload)
        
        self.manager?.startAgoraActionProcess(options: swiftOptions, success: {[weak self] (result) in
            
            if let ocResult = self?.mapToAgoraActionResultOC(result) {
                success?(ocResult)
            }
            
        }, failure: failure)
    }
    
    @objc public func stopAgoraActionProcess(options: AgoraActionStopOptionsOC, success: AgoraActionHTTPSuccessOC?, failure: AgoraActionHTTPFailureOC?) {
        
        let rawValue = options.action.rawValue
        
        let swiftOptions = AgoraActionStopOptions(toUserUuid: options.toUserUuid, processUuid: options.processUuid, action: AgoraActionType(rawValue: rawValue) ?? .accept, fromUserUuid: options.fromUserUuid, payload: options.payload, waitAck: options.waitAck)
        
        self.manager?.stopAgoraActionProcess(options: swiftOptions, success: {[weak self] (result) in
            
            if let ocResult = self?.mapToAgoraActionResultOC(result) {
                success?(ocResult)
            }
            
        }, failure: failure)
    }
}

extension AgoraActionProcessManagerOC {
    fileprivate func mapToAgoraActionResultOC(_ result: AgoraActionResult) -> AgoraActionResultOC {
        let ocResult = AgoraActionResultOC()
        ocResult.code = result.code
        ocResult.msg = result.msg
        return ocResult
    }
}
