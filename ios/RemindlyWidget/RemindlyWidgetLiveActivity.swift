import ActivityKit
import WidgetKit
import SwiftUI

struct RemindlyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var startTime: Int
        var endTime: Int
    }

    // Fixed non-changing properties about your activity go here!
}

struct RemindlyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RemindlyWidgetAttributes.self) { context in
            // Lock Screen/Banner UI
            VStack {
                HStack {
                    Image("AppIcon") // Ensure this asset exists or use systemImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text("Current Task")
                            .font(.headline)
                        
                        // Countdown timer
                        Text(timerInterval: Date(timeIntervalSince1970: TimeInterval(context.state.startTime) / 1000)...Date(timeIntervalSince1970: TimeInterval(context.state.endTime) / 1000), countsDown: true)
                            .font(.title2)
                            .monospacedDigit()
                    }
                    
                    Spacer()
                    
                    // Progress ring or similar could go here
                }
                .padding()
            }
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image("AppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(10)
                        .padding(.leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    // Countdown
                    Text(timerInterval: Date(timeIntervalSince1970: TimeInterval(context.state.startTime) / 1000)...Date(timeIntervalSince1970: TimeInterval(context.state.endTime) / 1000), countsDown: true)
                        .font(.title2)
                        .monospacedDigit()
                        .padding(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Focus on your task")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Image("AppIcon") // Small icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .cornerRadius(5)
            } compactTrailing: {
                // Compact timer
                Text(timerInterval: Date(timeIntervalSince1970: TimeInterval(context.state.startTime) / 1000)...Date(timeIntervalSince1970: TimeInterval(context.state.endTime) / 1000), countsDown: true)
                    .monospacedDigit()
                    .frame(width: 50)
            } minimal: {
                Image("AppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .cornerRadius(5)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
