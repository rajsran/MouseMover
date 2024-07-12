import Cocoa
import SwiftUI

struct CustomMenuItemView: View {
    @AppStorage("moveInterval") private var moveInterval: Double = 5.0 // default to 1 second
    @AppStorage("runDuration") private var runDuration: Double = 900.0 

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Set Move Interval")
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                Text("5s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Slider(value: $moveInterval, in: 5.0...60.0, step: 5.0)
                    .accentColor(.blue)
                Text("60s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(Int(moveInterval)) seconds")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider().padding(.vertical, 5)

            Text("Set Timer Duration")
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                Text("15m")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Slider(value: $runDuration, in: 900...7200, step: 900) // 15 minutes to 2 hours
                    .accentColor(.blue)
                Text("120m")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(Int(runDuration / 60)) minutes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(width: 300)
    }
}

struct CustomMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        CustomMenuItemView()
    }
}

