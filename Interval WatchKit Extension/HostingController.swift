//
//  HostingController.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/9/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<HomeView> {
    override var body: HomeView {
        return HomeView(counters: DataController.main.counters, complicationCounter: DataController.main.complicationCounter)
    }
}
