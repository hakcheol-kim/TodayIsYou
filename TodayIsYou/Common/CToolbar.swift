//
//  CToolbar.swift
//  StartCode
//
//  Created by 김학철 on 2020/11/14.
//

import UIKit
enum BarItem {
    case up, down, keyboardDown
}

let TAG_TOOL_BAR_UP = 9000
let TAG_TOOL_BAR_DOWN = 9001
let TAG_TOOL_KEYBOARD_DOWN = 9002

class CToolbar: UIToolbar {
    var itemColor:UIColor = UIColor.systemBlue
    var barItems:[BarItem] = []
    
    var btnKeyboardDown:UIBarButtonItem?
    var btnUp:UIBarButtonItem?
    var btnDown:UIBarButtonItem?
    
    convenience init(barItems:[BarItem], itemColor:UIColor = RGB(139, 0, 255)) {
        self.init()
    
        self.itemColor = itemColor
        self.barItems = barItems
    }
   
    func addTarget(_ target: UIViewController, selctor:Selector) {
        self.barStyle = .default
        self.tintColor = barTintColor
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        
        guard barItems.isEmpty == false else {
            return
        }
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        for type in barItems {
            if type == .keyboardDown {
                self.btnKeyboardDown = UIBarButtonItem.init(image: UIImage.init(systemName: "keyboard.chevron.compact.down"), style: .plain, target: target, action: selctor)
                self.btnKeyboardDown?.tintColor = itemColor
                self.btnKeyboardDown?.tag = TAG_TOOL_KEYBOARD_DOWN
            }
            else if type == .up {
                self.btnUp = UIBarButtonItem.init(image: UIImage.init(systemName: "chevron.up"), style: .plain, target: target, action: selctor)
                self.btnUp?.tintColor = itemColor
                self.btnUp?.tag = TAG_TOOL_BAR_UP
            }
            else if type == .down {
                self.btnDown = UIBarButtonItem.init(image: UIImage.init(systemName: "chevron.down"), style: .plain, target: target, action: selctor)
                self.btnDown?.tintColor = itemColor
                self.btnDown?.tag = TAG_TOOL_BAR_DOWN
            }
        }
        var items:[UIBarButtonItem] = []
        if let up = self.btnUp {
            items.append(up)
        }
        if let down = self.btnDown {
            items.append(down)
        }
        items.append(spacer)
        if let keyDown = self.btnKeyboardDown {
            items.append(keyDown)
        }
        self.setItems(items, animated: true)
    }
}
