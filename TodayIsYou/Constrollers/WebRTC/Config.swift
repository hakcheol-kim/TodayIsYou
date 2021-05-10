//
//  config.swift
//

import Foundation
import WebRTC

/// Set this to the machine's address which runs the signaling server
fileprivate let defaultSignalingServerUrl = URL(string: soketUrl)!

fileprivate let turns = ["turn:turn.todayisyou.co.kr:3478?transport=udp", "turn:turn.todayisyou.co.kr:3478?transport=tcp"]

/// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
//fileprivate let defaultIceServers = [RTCIceServer(urlStrings: turns, username: "youngsang", credential: "youngsang1234")]
fileprivate let defaultIceServers = [RTCIceServer.init(urlStrings: turns, username: "youngsang", credential: "youngsang1234", tlsCertPolicy: .insecureNoCheck)]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [RTCIceServer]

    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}
