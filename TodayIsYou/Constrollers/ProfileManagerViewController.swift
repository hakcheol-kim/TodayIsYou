//
//  ProfileManagerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
class ProfileManagerViewController: BaseViewController {
    @IBOutlet weak var btnPofile: UIButton!
    @IBOutlet weak var tfNIckName: CTextField!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnAge: UIButton!
    
    let accessoryView = CToolbar.init(barItems: [.keyboardDown])
    
    var data:JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "프로필 수정", #selector(actionNaviBack))
        tfNIckName.inputAccessoryView = accessoryView
        accessoryView.addTarget(self, selctor: #selector(actionKeybardDown))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.removeKeyboardNotification()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    
    }
    
}
