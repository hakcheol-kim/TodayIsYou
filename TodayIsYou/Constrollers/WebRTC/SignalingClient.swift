//
//  Signaling.swift
//  NoonCam
//

import Foundation
import SocketIO
import Starscream
import WebRTC

struct MSG: Codable {
    var type: String
    var sdp: String?
    var candidate: String?
}


protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    
    func signalClientDidReady(_ signalClient: SignalingClient)
    func signalClientDidRoomOut(_ signalClient: SignalingClient)
    func signalClientDidToRoomOut(_ signalClient: SignalingClient)
    func signalClientDidCallNo(_ signalClient: SignalingClient)
    func signalClientChatMessage(_ signalClient: SignalingClient, msg: String)
}

protocol CallPushSender: AnyObject {
    func requestSendPushMessage(to id: String, _ name: String, roomKey: String)
}



final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    var delegate: SignalClientDelegate?
    
    private var webSocket: WebSocketProvider
    var socket: SocketIOClient?
    
    let connectionType: ConnectionType
    
    let userId: String
    let userName: String
    let roomKey: String
    
    init(connectionType: ConnectionType, _ webSocket: WebSocketProvider, to userId: String, _ userName: String, roomKey: String = Utility.roomKeyCam()) {
        self.webSocket = webSocket
        self.socket = (webSocket as! WebSocket).socket
        
        self.connectionType = connectionType
        
        self.userId = userId
        self.userName = userName
        self.roomKey = roomKey
        
        configureSocketEventListeners()
    }
    
    func configureSocketEventListeners() {
        socket?.on(clientEvent: .connect) {data, ack in
            print(">>> socket connected")
            self.delegate?.signalClientDidConnect(self)
            self.join()
        }
        
        socket?.on("join_ok") {data, ack in
            print("join_ok <<<")
            guard let result = data[0] as? String, result == "join_ok" else {
                return
            }
            
            // 발신 / 수신 구분
            if self.connectionType == .offer {
                print(">>> send call_yn")
                // 발신할 경우
                self.callYn(to: self.userId, self.userName, roomKey: self.roomKey)
                // 푸시 요청
//                self.requestSendPushMessage(to: self.userId, self.userName, roomKey: self.roomKey)
            } else {
                print(">>> send call_ok")
                // 수신할 경우
                self.callOk(to: self.userId, self.userName, roomKey: self.roomKey)
            }
        }

        // 발신의 경우에만 "call_ok"를 되돌려 받는다.
        socket?.on("call_ok") {data, ack in
            print("call_ok <<<")
            self.delegate?.signalClientDidReady(self)
        }
        
        socket?.on("call_no") {data, ack in
            print("call_no <<<")
            self.delegate?.signalClientDidCallNo(self)
        }
        
        socket?.on("room_out") {data, ack in
            print("room_out <<<")
            self.delegate?.signalClientDidRoomOut(self)
        }
        
        socket?.on("room_user_cnt") {data, ack in
            print("room_user_cnt <<<")
            self.delegate?.signalClientDidToRoomOut(self)
            // TODO 채팅 신청 취소 user cnt == 0
        }
        
        /// 선물 채팅메시지로 표시
        socket?.on("send_gift") {data, ack in
            print("send_gift <<<")
            
            guard let message = data[0] as? String else { return }
            
            let splits = message.components(separatedBy: "^#$%^")
            
            let name = splits[0]
            let value = splits[1]
            
            // 채팅메시지
            self.delegate?.signalClientChatMessage(self, msg: "\(name): 🎁 \(name)님에게 선물 \(value)을 받았습니다.")
        }
        
        socket?.on("cam_video_no") {data, ack in
            print("cam_video_no <<<")
            // TODO 캡쳐기능 OFF
        }
        
        socket?.on("cam_chat_msg") {data, ack in
            print("cam_chat_msg <<<")
            
            guard let message = data[0] as? String else { return }
            
            let splits = message.components(separatedBy: "^#$%^")
            
            // let id = splits[0];
            let name = splits[1];
            let msg = splits[2];
            
            guard !msg.contains("JOOS") else { return }
            
            // 채팅메시지
            self.delegate?.signalClientChatMessage(self, msg: "\(name): \(msg)")
        }
        
        socket?.on("room_error_out") {data, ack in
            print("room_error_out <<<")
            self.delegate?.signalClientDidRoomOut(self)
        }
        
        socket?.on("to_room_out") {data, ack in
            print("to_room_out <<<")
            self.delegate?.signalClientDidToRoomOut(self)
        }
        
        socket?.on("message") {data, ack in
            if let message = data[0] as? Dictionary<String, Any> {
                // 메시지를 시그널로 부터 받으면 WebRTC sdb/candidate 을 설정한다.
                if message["type"] as! String == "answer" {
                    if self.connectionType == .offer {
                        // print("<<< message(answer) sdp : \(message["sdp"]!)")
                        self.delegate?.signalClient(self, didReceiveRemoteSdp: RTCSessionDescription(type: .answer, sdp: message["sdp"] as! String))
                    }
                } else if message["type"] as! String == "offer" {
                    if self.connectionType == .answer {
                        // print("<<< message(offer) sdp : \(message["sdp"]!)")
                        self.delegate?.signalClient(self, didReceiveRemoteSdp: RTCSessionDescription(type: .offer, sdp: message["sdp"] as! String))
                    }
                } else if message["type"] as! String == "candidate" {
                    // print("<<< message candidate : \(message["candidate"]!)")
                    self.delegate?.signalClient(self, didReceiveCandidate: RTCIceCandidate(
                        sdp: message["candidate"] as! String,
                        sdpMLineIndex: Int32(message["label"] as! String)!,
                        sdpMid: message["id"] as? String))
                }
            }
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print(">>> socket disconnected")
            self.delegate?.signalClientDidDisconnect(self)
        }
    }
    
    func join() {
        let myId = ShareData.ins.myId
        let myName = ShareData.ins.myName
        emit(type: "join", message: "\(myId)^#$%^\(myName)")
    }
    
    func callYn(to id: String, _ name: String, roomKey: String) {
        let myId = ShareData.ins.myId
        let myName = ShareData.ins.myName
        emit(type: "call_yn", message: "\(myId)^#$%^\(myName)^#$%^\(roomKey)^#$%^\(id)^#$%^\(name)")
    }
    
    func callOk(to id: String, _ name: String, roomKey: String) {
        let myId = ShareData.ins.myId
        let myName = ShareData.ins.myName
        emit(type: "call_ok", message: "\(myId)^#$%^\(myName)^#$%^\(roomKey)^#$%^\(id)^#$%^\(name)")
    }
    
    func sendMessage(to id: String, message: String, roomKey: String) {
        let myId = ShareData.ins.myId
        let myName = ShareData.ins.myName
        emit(type: "cam_chat_msg", message: "\(myId)^#$%^\(myName)^#$%^\(roomKey)^#$%^\(id)^#$%^\(message)")
    }
    
    func emit(type: String, message: String) {
        print(">>> *emit* \(type): \(message)")
        socket?.emit("msg", with: [["type": type, "message": message]])
    }
    
    // MARK --
    
    public func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    public func disconnect() {
        self.webSocket.disconnect()
    }
    
    // WebRTC에서 전달받은 SDP정보를 Socket으로 상대에게 넘겨줘야한다.
    func send(type: String, sdp rtcSdp: RTCSessionDescription) {
        self.send(message: [
            [
                "type": type,
                "to_user_id": self.userId,
                "sdp": rtcSdp.sdp,
                "room_key": self.roomKey
            ]
        ])
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        self.send(message: [
            [
                "type": "candidate",
                "id": rtcIceCandidate.sdpMid as Any,
                "candidate": rtcIceCandidate.sdp,
                "to_user_id": self.userId,
                "label": rtcIceCandidate.sdpMLineIndex,
                "room_key": self.roomKey
            ]
        ])
    }
    
    func send(message: [Any]) {
        self.socket?.emit("message", with: message)
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }
    }
}


// MARK -- Push for calling message when offering
extension SignalingClient: CallPushSender {
    func requestSendPushMessage(to id: String, _ name: String, roomKey: String) {
        guard let url = URL(string: "http://211.233.15.31:8080/api/talk/insertVcChatMsg.do") else {
            return
        }
        
        guard let myName = ShareData.ins.dfsGet(DfsKey.userName) as? String else {
            return
        }
        let myId = ShareData.ins.myId
        
        let body = "room_key=\(roomKey)&from_user_id=\(myId)&from_user_name=\(myName )&from_user_sex=\("여")&to_user_id=\(id)&to_user_name=\(name)&out_point=\(30000)"
            .data(using: .utf8, allowLossyConversion: false)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let result = json?["Result"] as? [String: Any] else { return }
            guard let success = result["isSuccess"] as? String, success == "01" else { return }
            
            print("Sent a push message completely. -> (\(id), \(name))")
            
            // For Web
            self.emit(type: "cam_manager_msg", message: "\(myId)^#$%^\(myName)^#$%^\(roomKey)^#$%^\(id)^#$%^\(name)")
        }
        task.resume();
    }
}
