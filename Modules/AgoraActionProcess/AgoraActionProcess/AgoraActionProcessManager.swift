//
//  AgoraActionProcessManager.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation
import AgoraActionProcess.OCFile.HTTP

public typealias AgoraActionHTTPSuccess = (AgoraActionResult) -> Void
public typealias AgoraActionHTTPFailure = (Error) -> Void

public class AgoraActionProcessManager {
    
    fileprivate var config: AgoraActionConfig = AgoraActionConfig()
    
    fileprivate init() {
    }
    
    public convenience init(_ config: AgoraActionConfig) {
        self.init()
        self.config = config
    }
    
    public func setAgoraAction(options: AgoraActionOptions, success: AgoraActionHTTPSuccess?, failure: AgoraActionHTTPFailure?) {
        
        // /invitation/apps/{appId}/v1/rooms/{roomUuid}/process/{processUuid}
        let urlString = "\(self.config.baseURL)/invitation/apps/\(self.config.appId)/v1/rooms/\(self.config.roomUuid)/process/\(options.processUuid)"

        let params = ["maxWait":options.maxWait, "timeout":options.timeout, "action":options.actionType.rawValue] as [String : Any]
        let headers = self.headers();
        
        AgoraActionHTTPClient.put(urlString, params: params, headers: headers) { (dictionary) in
            
            guard let dic = dictionary as? [String : Any],
                  let code = dic["code"] as? Int,
                  let msg = dic["msg"] as? String else {
                
                success?(AgoraActionResult(code: AgoraActionHTTPOK, msg: ""))
                return;
            }

            success?(AgoraActionResult(code: code, msg: msg))
            
        } failure: { (error, code) in
            failure?(error)
        }
    }
    
    public func deleteAgoraAction(processUuid: String, success: AgoraActionHTTPSuccess?, failure: AgoraActionHTTPFailure?) {
        
        // /invitation/apps/{appId}/v1/rooms/{roomUuid}/process/{processUuid}
        let urlString = "\(self.config.baseURL)/invitation/apps/\(self.config.appId)/v1/rooms/\(self.config.roomUuid)/process/\(processUuid)"

        let params = [:] as! [String: Any]
        let headers = self.headers();
        
        AgoraActionHTTPClient.put(urlString, params: params, headers: headers) { (dictionary) in
            
            var result: AgoraActionResult
            
            guard let dic = dictionary as? [String : Any],
                  let code = dic["code"] as? Int,
                  let msg = dic["msg"] as? String else {
                
                success?(AgoraActionResult(code: AgoraActionHTTPOK, msg: ""))
                return;
            }
            
            result = AgoraActionResult(code: code, msg: msg)
            success?(result)
            
        } failure: { (error, code) in
            failure?(error)
        }
    }
    
    public func startAgoraActionProcess(options: AgoraActionStartOptions, success: AgoraActionHTTPSuccess?, failure: AgoraActionHTTPFailure?) {
        
        // /invi    tation/apps/{appId}/v1/rooms/{roomUuid}/users/{toUserUuid}/process/{processUuid}
        let urlString = "\(self.config.baseURL)/invitation/apps/\(self.config.appId)/v1/rooms/\(self.config.roomUuid)/users/\(options.toUserUuid)/process/\(options.processUuid)"

        let params = ["fromUserUuid":options.fromUserUuid, "payload":options.payload] as [String : Any]
        let headers = self.headers();
        
        AgoraActionHTTPClient.post(urlString, params: params, headers: headers) { (dictionary) in
            
            var result: AgoraActionResult
            
            guard let dic = dictionary as? [String : Any],
                  let code = dic["code"] as? Int,
                  let msg = dic["msg"] as? String else {
                
                success?(AgoraActionResult(code: AgoraActionHTTPOK, msg: ""))
                return;
            }
            
            result = AgoraActionResult(code: code, msg: msg)
            success?(result)
            
        } failure: { (error, code) in
            failure?(error)
        }
    }
    
    public func stopAgoraActionProcess(options: AgoraActionStopOptions, success: AgoraActionHTTPSuccess?, failure: AgoraActionHTTPFailure?) {
        
        // /invitation/apps/{appId}/v1/rooms/{roomUuid}/users/{toUserUuid}/process/{processUuid}
        let urlString = "\(self.config.baseURL)/invitation/apps/\(self.config.appId)/v1/rooms/\(self.config.roomUuid)/users/\(options.toUserUuid)/process/\(options.processUuid)"

        let params = ["action":options.actionType.rawValue, "fromUserUuid":options.fromUserUuid, "payload":options.payload] as [String : Any]
        let headers = self.headers();
        
        AgoraActionHTTPClient.del(urlString, params: params, headers: headers) { (dictionary) in
            
            var result: AgoraActionResult
            
            guard let dic = dictionary as? [String : Any],
                  let code = dic["code"] as? Int,
                  let msg = dic["msg"] as? String else {
                
                success?(AgoraActionResult(code: AgoraActionHTTPOK, msg: ""))
                return;
            }
            
            result = AgoraActionResult(code: code, msg: msg)
            success?(result)
            
        } failure: { (error, code) in
            failure?(error)
        }
    }
}

extension AgoraActionProcessManager {
    fileprivate func headers() -> [String : String] {
        let authString = "\(self.config.customerId):\(self.config.customerCertificate)"
        var baseAuthString = ""
        if let data = authString.data(using: .utf8) {
            baseAuthString = data.base64EncodedString()
        }
        return ["Content-Type":"application/json",
                "authorization":"Basic \(baseAuthString)",
                "token":self.config.userToken];
    }
}
