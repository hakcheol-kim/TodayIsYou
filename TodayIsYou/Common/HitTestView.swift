//
//  HitTestView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/16.
//

import UIKit

class HitTestView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        perform(#selector(actionNotification), with: nil, afterDelay: 0)
        return hitView
    }
    @objc func actionNotification() {
        NotificationCenter.default.post(name: Notification.Name(CNotiName.hitTest), object: nil)
    }
}
