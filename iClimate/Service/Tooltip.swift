//
//  Tooltip.swift
//  iClimate
//
//  Created by Sagar Modi on 31/01/2024.
//

import Foundation
import TipKit

struct ShowInfoTip: Tip {
    var title: Text {
        Text("Info")
    }
    
    var message: Text? {
        Text("shows only if app is in background.")
    }
    
    var image: Image? {
        Image(systemName: "questionmark.circle.fill")
    }
}
