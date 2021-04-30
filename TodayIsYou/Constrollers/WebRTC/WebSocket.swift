//
//  WebSocket.swift
//

import Foundation
import SocketIO
import WebRTC

class WebSocket: NSObject, WebSocketProvider {
    
    var delegate: WebSocketProviderDelegate?
    
    private let url: URL
    
    private var manager: SocketManager!
    var socket: SocketIOClient?
    
    init(url: URL) {
        self.url = url
        
        super.init()
        
        manager = SocketManager.init(
            socketURL: self.url,
            config: [
                .log(true),
                .reconnects(false),
                .forceWebsockets(true),
                .secure(true),
                .sessionDelegate(self)
        ])
        socket = manager.defaultSocket
    }
    
    func connect() {
        self.socket?.connect()
        self.delegate?.webSocketDidConnect(self)
    }
    
    func send(data: Data) {
        // print(">>>>> socket: send data ==> \(String(data: data, encoding: .utf8))")
    }
    
    func disconnect() {
        self.socket?.disconnect()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}


extension WebSocket: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print(challenge.protectionSpace.authenticationMethod)
        // `NSURLAuthenticationMethodClientCertificate`
        // indicates the server requested a client certificate.
        if challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard let file = Bundle.main.url(forResource: "todayisyou", withExtension: "p12"),
            let p12Data = try? Data(contentsOf: file) else {
                // Loading of the p12 file's data failed.
                completionHandler(.performDefaultHandling, nil)
                return
        }
        
        print(String(data: p12Data, encoding: .utf8) ?? "NO data")
        
        // Interpret the data in the P12 data blob with
        // a little helper class called `PKCS12`.
        let password = "todayisyou123#" // Obviously this should be stored or entered more securely.
        let p12Contents = PKCS12(pkcs12Data: p12Data, password: password)
        guard let identity = p12Contents.identity else {
            // Creating a PKCS12 never fails, but interpretting th contained data can. So again, no identity? We fall back to default.
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // In my case, and as Apple recommends,
        // we do not pass the certificate chain into
        // the URLCredential used to respond to the challenge.
        let credential = URLCredential(identity: identity, certificates: nil, persistence: .none)
        challenge.sender?.use(credential, for: challenge)
        completionHandler(.useCredential, credential)
    }
}

private class PKCS12 {
    
    let label: String?
    let keyID: NSData?
    let trust: SecTrust?
    let certChain: [SecTrust]?
    let identity: SecIdentity?
    
    
    public init(pkcs12Data: Data, password: String) {
        let importPasswordOption: NSDictionary = [kSecImportExportPassphrase as NSString: password]
        var items: CFArray?
        let secError: OSStatus = SecPKCS12Import(pkcs12Data as NSData, importPasswordOption, &items)
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                NSLog("Incorrect password?")
            }
            fatalError("Error trying to import PKCS12 data")
        }
        guard let theItemsCFArray = items else { fatalError() }
        let theItemsNSArray: NSArray = theItemsCFArray as NSArray
        guard let dictArray = theItemsNSArray as? [[String: AnyObject]] else {
            fatalError()
        }
        func f<T>(key: CFString) -> T? {
            for dict in dictArray {
                if let value = dict[key as String] as? T {
                    return value
                }
            }
            return nil
        }
        self.label = f(key: kSecImportItemLabel)
        self.keyID = f(key: kSecImportItemKeyID)
        self.trust = f(key: kSecImportItemTrust)
        self.certChain = f(key: kSecImportItemCertChain)
        self.identity = f(key: kSecImportItemIdentity)
    }
}
