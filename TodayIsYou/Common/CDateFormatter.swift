//
//  CDateFormatter.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/30.
//

import UIKit

class CDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.calendar = Calendar(identifier: .gregorian)
        self.locale = Locale(identifier: "en_US_POSIX")    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
