import SwiftUI

struct ContentView: View {
    var body: some View {
        HostsView()
    }
}

#Preview {
    ContentView()
        .environmentObject(HostsFileManager())
}
