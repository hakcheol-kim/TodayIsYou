//
//  AppDelegate.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import CoreData
import Firebase
import CryptoSwift
import FirebaseMessaging
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView?
    var pushHandler:PushMessageDelegate? = nil
    
    static var ins: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var mainNavigationCtrl: BaseNavigationController {
        return AppDelegate.ins.window?.rootViewController as! BaseNavigationController
    }
    var mainViewCtrl: MainViewController {
        return AppDelegate.ins.mainNavigationCtrl.viewControllers.first as! MainViewController
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        self.registApnsPushKey()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light

        callIntroViewCtrl()
        
        return true
    }
 
    func callTempView() {
        let vc = MemberInfoViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callIntroViewCtrl() {
        let vc = IntroViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callJoinTermVc() {
        let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callMainViewCtrl() {
        let vc = MainViewController.instantiateFromStoryboard(.main)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func openUrl(_ url:String, completion: ((_ success:Bool) -> Void)?) {
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let requestUrl = URL.init(string: encodedUrl) else {
            completion?(false)
            return
        }
        UIApplication.shared.open(requestUrl, options: [:]) { (success) in
            completion?(success)
        }
    }
    func removeApnsPushKey() {
        Messaging.messaging().delegate = nil
    }
    func registApnsPushKey() {
        Messaging.messaging().delegate = self
        self.registerForRemoteNoti()
    }
    func registerForRemoteNoti() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted: Bool, error:Error?) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView == nil {
                self.loadingView = UIView(frame: UIScreen.main.bounds)
            }
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 100000
            self.loadingView?.startAnimation(raduis: 25.0)
            
            //혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다. 10초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
                if let loadingView = AppDelegate.ins.window!.viewWithTag(100000) {
                    loadingView.removeFromSuperview()
                }
            }
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView != nil {
                self.loadingView!.stopAnimation()
                self.loadingView?.removeFromSuperview()
            }
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if deviceToken.count == 0 {
            return
        }
        print("==== apns token:\(deviceToken.hexString)")
        //파이어베이스에 푸쉬토큰 등록
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
    }
    
    // 앱이 백그라운드에있는 동안 알림 메시지를 받으면
    //이 콜백은 사용자가 애플리케이션을 시작하는 알림을 탭할 때까지 실행되지 않습니다.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        var topicStr = "todayisyou_w"
        if "남" == ShareData.ins.mySex.rawValue {
            topicStr = "todayisyou_m"
        }
        Messaging.messaging().subscribe(toTopic: topicStr)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("=== apn token regist failed")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodayIsYou")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
           
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
               let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func setPushData(_ userInfo:[String:Any]) {
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any], let body = alert["body"] as? String else {
            return
        }
        
        guard let json = body.convertJsonStringToDict() else {
            return
        }
        guard  let info =  json["message"] as? [String:Any], let msg_cmd = info["msg_cmd"] as? String else {
            return
        }
        
        let sender = json["sender"]
        let type:PushType = PushType.getPushType(msg_cmd)
        
        if type == .camNo { //거절
            
//            String from_user_id = jsonParse.get("from_user_id").toString();
//            String no_msg = jsonParse.get("msg").toString();
//
//            DLog.d(DEBUG_TAG, "CAM_NO from_user_id : " + from_user_id);
//            DLog.d(DEBUG_TAG, "CAM_NO no_msg : " + no_msg);
//
//            if("CAM_NO".equals(no_msg)){//거절
//
//                sendCamNoBroadcast("CAM_NO","CAM_NO");
//
//            }else if("CAM_CANCEL".equals(no_msg)){//취소
//                sendCamNoBroadcast("CAM_CANCEL","CAM_NO");
//            }
        }
        else if type == .reSend {
            
//            String from_user_id = jsonParse.get("from_user_id").toString();
//
//            DLog.d(DEBUG_TAG, "##superApp.myPushYn : " + superApp.myPushYn);
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//
//                boolean isForeground = Util.isForeground(mContext);
//                boolean isAppIsInBackground = Util.isAppIsInBackground(mContext);
//                DLog.d(DEBUG_TAG, "##isForeground: " + isForeground);
//                DLog.d(DEBUG_TAG, "##isAppIsInBackground : " + isAppIsInBackground);
//
//                if(!isAppIsInBackground){//어플 실행중 아닐때(어플이 실행 되어 있지만)
//                    sendRandomMsgBroadcast(msg,msg_cmd);
//                }else{
//                    notiMessage = "";
//                    notiMessage = msg;
//                    //알림.사진노출
//                    getUserImg(from_user_id);
//                }
//            }
        }
        else if  type == .rdCam {
            
//            String message_key = jsonParse.get("message_key").toString();
//            String from_user_id = jsonParse.get("from_user_id").toString();
//            String room_key = jsonParse.get("room_key").toString();
//            String user_id = jsonParse.get("user_id").toString();
//
//            //영상신청채팅로컬디비에저장
//            ChatMsgVo vo = new ChatMsgVo();
//            vo.setMemo("[CAM_TALK]저와 영상 채팅 해요 ^^");
//            vo.setFrom_user_id(from_user_id);
//            vo.setReg_date(Util.getCurrentDate("yyyy-MM-dd HH:mm:ss"));
//            vo.setTo_user_id(superApp.myUserId);
//            vo.setMessage_key(message_key);
//            vo.setRead_yn("Y");
//
//            //로컬디비저장
//            superApp.mDbManager.setMessage(vo);
//
//            if((superApp.STRPACKAGENAME + ".view.RandomCamStartActivity").equals(Util.getTopActivity(this, superApp.STRPACKAGENAME))) {
//                sendRandomCamBroadcast(msg);//from_user_id가 상대임
//            }else{
//                if(!"N".equals(superApp.myPushYn)) {
//                    notiMessage = "";
//                    notiMessage = msg;
//                    //알림.사진노출
//                    getUserImg(from_user_id);
//
//                }
//
//            }
        }
        else if type == .chat {
            var param:[String:Any] = info
            param["to_user_id"] = ShareData.ins.myId
            param["point_user_id"] = ShareData.ins.myId
            param["reg_date"] = Date()
            param["type"] = 0
            param["read_yn"] = false
            
            if let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as? String, notiYn == "N" {
                param["read_yn"] = true
            }
            DBManager.ins.insertChatMessage(param) { (success, error) in
            }
            AppDelegate.ins.mainViewCtrl.updateUnReadMessageCount()
            if let handler = pushHandler {
                handler.processPushMessage(type, param)
            }
        }
        else if  type == .msgDel {//대화 삭제
            //로컬 디비에서 삭제
            guard let seq = info["seq"] as? String, let _ = info["to_user_id"] else {
                return
            }
            DBManager.ins.deleteChatMessage(messageKey: seq) { (success, error) in
            }
            AppDelegate.ins.mainViewCtrl.updateUnReadMessageCount()
            if let handler = pushHandler {
                handler.processPushMessage(type, info)
            }
        }
        else if "CAM" == msg_cmd {
            
//            String message_key = jsonParse.get("message_key").toString();
//            String from_user_id = jsonParse.get("from_user_id").toString();
//            String room_key = jsonParse.get("room_key").toString();
//            String user_id = jsonParse.get("user_id").toString();
//
//            //영상신청채팅로컬디비에저장
//            ChatMsgVo vo = new ChatMsgVo();
//            vo.setMemo("[CAM_TALK]저와 영상 채팅 해요 ^^");
//            vo.setFrom_user_id(from_user_id);
//            vo.setReg_date(Util.getCurrentDate("yyyy-MM-dd HH:mm:ss"));
//            vo.setTo_user_id(superApp.myUserId);
//            vo.setMessage_key(message_key);
//            vo.setRead_yn("N");
//
//            //로컬디비저장
//            superApp.mDbManager.setMessage(vo);
//
//            boolean isAppIsInBackground = Util.isAppIsInBackground(mContext);
//
//            DLog.d(DEBUG_TAG, "##CAM isAppIsInBackground : " + isAppIsInBackground);
//            DLog.d(DEBUG_TAG, "##CAM superApp.myPushYn : " + superApp.myPushYn);
//
//            if(!"N".equals(superApp.myPushYn)) {
//                if(!isAppIsInBackground) {//어플 실행중 아닐때(어플이 실행 되어 있지만)
//                    sendRandomMsgBroadcast(msg, msg_cmd);
//                }else{
//                    notiMessage = "";
//                    notiMessage = msg;
//                    //알림.사진노출
//                    getUserImg(from_user_id);
//                }
//
//            }
        }
        else if "PHONE" == msg_cmd {
            
//            String message_key = jsonParse.get("message_key").toString();
//            String from_user_id = jsonParse.get("from_user_id").toString();
//            String room_key = jsonParse.get("room_key").toString();
//            String user_id = jsonParse.get("user_id").toString();
//
//            //영상신청채팅로컬디비에저장
//            ChatMsgVo vo = new ChatMsgVo();
//            vo.setMemo("[PHONE_TALK]저와 음성 통화 해요 ^^");
//            vo.setFrom_user_id(from_user_id);
//            vo.setReg_date(Util.getCurrentDate("yyyy-MM-dd HH:mm:ss"));
//            vo.setTo_user_id(superApp.myUserId);
//            vo.setMessage_key(message_key);
//            vo.setRead_yn("N");
//
//            //로컬디비저장
//            superApp.mDbManager.setMessage(vo);
//
//            boolean isAppIsInBackground = Util.isAppIsInBackground(mContext);
//
//            DLog.d(DEBUG_TAG, "##PHONE isAppIsInBackground : " + isAppIsInBackground);
//            DLog.d(DEBUG_TAG, "##PHONE superApp.myPushYn : " + superApp.myPushYn);
//
//            if(!"N".equals(superApp.myPushYn)) {
//                if(!isAppIsInBackground) {//어플 실행중 아닐때(어플이 실행 되어 있지만)
//
//                    DLog.d(DEBUG_TAG, "##PHONE 1");
//
//                    sendRandomMsgBroadcast(msg, msg_cmd);
//                }else{
//
//                    DLog.d(DEBUG_TAG, "##PHONE 2");
//
//                    notiMessage = "";
//                    notiMessage = msg;
//                    //알림.사진노출
//                    getUserImg(from_user_id);
//                }
//
//            }
        }
        else if "NOTICE" == msg_cmd {
            
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//                String title = jsonParse.get("title").toString();
//                String memo = jsonParse.get("memo").toString();
//                getNoticeNoti("공지사항 알림", title, memo);
//            }
            
        }
        else if "QNA_Answer" == msg_cmd {
            
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//                getQnaNoti("메세지 알림","메세지가 있습니다.","Q&A 답변이 등록 되었습니다.");
//            }
            
        }
        else if "QNA_Manager" == msg_cmd {
//
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//                getQnaNoti("메세지 알림","메세지가 있습니다.","관리자 메세지가 있습니다.");
//            }
            
        }
        else if "COMMENT_MEMO" == msg_cmd {
            
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//                String memo = jsonParse.get("memo").toString();
//                getCommentNoti("메세지 알림","메세지가 있습니다.",memo);
//            }
            
        }
        else if "COMMENT_GIFT" == msg_cmd {
//
//            if(!"N".equals(superApp.myPushYn)) {//푸쉬없음은 제외
//                String memo = jsonParse.get("memo").toString();
//                getCommentNoti("메세지 알림","메세지가 있습니다.",memo);
//            }
            
        }
        else if "BLOCK" == msg_cmd {
            
//            String block_memo = jsonParse.get("block_memo").toString();
//            DLog.d(DEBUG_TAG, "##seq[1] : " + block_memo);
//            getBlockNoti("메세지 알림","메세지가 있습니다.","관리자 전달 사항이 있습니다.",block_memo);
//            superApp.isBlock = true;
//
//        }else if("CAM_MGS".equals(msg_cmd)){
//
//            DLog.d(DEBUG_TAG, "##msg : " + msg);
//            sendBroadcast("room_out", "room_out");
//
//        }else if("CONNECT".equals(msg_cmd)){
//            DLog.d(DEBUG_TAG, "##msg : " + msg);
//            String user_id = jsonParse.get("user_id").toString();
//            String user_name = jsonParse.get("user_name").toString();
//            String user_sex = jsonParse.get("user_sex").toString();
//            String user_age = jsonParse.get("user_age").toString();
//
//            String mesageStr = user_name+"," +user_sex+","+user_age+" 유저님이 접속 했습니다";
//
//            String user_img = jsonParse.get("user_img").toString();
//            String talk_img = jsonParse.get("talk_user_img").toString();
//            String cam_img = jsonParse.get("cam_user_img").toString();
//            String  file_name = "";
//            if("".equals(user_img)){
//                if(!"".equals(cam_img)){
//                    file_name = cam_img;
//                }else{
//                    file_name = talk_img;
//                }
//            }else{
//                file_name = user_img;
//            }
//
//            if ("".equals(file_name)) {
//                mChatLargeIcon = BitmapFactory.decodeResource(getResources(), R.drawable.titlebar_icon);
//                getConnectNoti("유저접속알림", "새로운 유저가 접속했습니다", mesageStr);
//
//            }else {
//
//                String file_name_url = superApp.HOME_URL+"upload/talk/"+user_id+"/thum/crop_"+file_name;
//
//                Glide.with(mContext)
//                    .asBitmap()
//                    .load(file_name_url)
//                    .listener(new RequestListener<Bitmap>() {
//                        @Override
//                        public boolean onLoadFailed(@Nullable GlideException e, Object o, Target<Bitmap> target, boolean b) {
//                            mChatLargeIcon = BitmapFactory.decodeResource(getResources(), R.drawable.titlebar_icon);
//                            getConnectNoti("유저접속알림", "새로운 유저가 접속했습니다", mesageStr);
//                            return false;
//                        }
//
//                        @Override
//                        public boolean onResourceReady(Bitmap bitmap, Object o, Target<Bitmap> target, DataSource dataSource, boolean b) {
//                            mChatLargeIcon = Util.getCircularBitmap(bitmap);
//                            getConnectNoti("유저접속알림", "새로운 유저가 접속했습니다", mesageStr);
//                            return false;
//                        }
//                    }
//                    ).submit();
//            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let userInfo = notification.request.content.userInfo as? [String:Any] else {
            return
        }
        self.setPushData(userInfo)
        print("push data: ==== \(userInfo)")
        
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        
        //푸쉬 데이터를 어느화면으로 보낼지 판단 한고 보내 주는것 처리해야한다.
        //아직 화면 푸쉬 타입에 따른 화면 정리 안됨
//        ShareData.ins.dfsSetValue(userInfo, forKey: DfsKey.pushData)
    }

    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("===== error: fcm token key not receive")
            return
        }
        print("==== fcm token: \(fcmToken)")
        guard let userId = ShareData.ins.dfsObjectForKey(DfsKey.userId) else {
            return
        }
        let param = ["fcm_token":fcmToken, "user_id": userId]
//        ApiManager.ins.requestReigstPushToken(param: ["fcm_token":fcmToken]) { (res) in
//
//            if res["isSuccess"].stringValue == "01" {
//                let fcm_cnt = res["fcm_cnt"].intValue
//                if fcm_cnt > 1 {
//                }
//            }
//            else {
//                self.window?.makeToast("fcm token update error")
//            }
//        } failure: { (error) in
//            self.window?.makeToast("fcm token update error")
//        }

        ApiManager.ins.requestUpdateFcmToken(param: param) { (res) in
            if res["isSuccess"].stringValue == "01"{
            }
            else {
                self.window?.makeToast("fcm token update error")
            }
        } failure: { (error) in
            self.window?.makeToast("fcm token update error")
        }
    }
}

