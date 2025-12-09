//
//  RemindlyWidgetBundle.swift
//  RemindlyWidget
//
//  Created by sanjeev ram prasad on 08/12/25.
//

import WidgetKit
import SwiftUI

@main
struct RemindlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        RemindlyWidget()
        RemindlyWidgetControl()
        RemindlyWidgetLiveActivity()
    }
}
