import SwiftUI
import ReplayKit

struct ContentView: View {
    @State private var relayURL = SharedConfig.relayURL
    @State private var pairingCode = SharedConfig.pairingCode.isEmpty ? SharedConfig.makePairingCode() : SharedConfig.pairingCode

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Text("School District 203")
                    .font(.largeTitle.bold())

                Text("iPhone Screen Broadcast")
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("PAIRING CODE")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(pairingCode)
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .monospacedDigit()
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Windows relay address")
                        .font(.headline)
                    TextField("ws://192.168.1.25:8080", text: $relayURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .textFieldStyle(.roundedBorder)
                }

                Button("Generate New Code") {
                    pairingCode = SharedConfig.makePairingCode()
                    SharedConfig.pairingCode = pairingCode
                }
                .buttonStyle(.bordered)

                BroadcastPicker()
                    .frame(height: 54)

                Text("Tap Start Broadcast, choose District203Broadcast, then open any app. The ReplayKit extension keeps sending your screen while the broadcast is active.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .onAppear {
                SharedConfig.pairingCode = pairingCode
            }
            .onChange(of: relayURL) { _, value in
                SharedConfig.relayURL = value
            }
            .onChange(of: pairingCode) { _, value in
                SharedConfig.pairingCode = value
            }
        }
    }
}

struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = "org.schooldistrict203.connect.broadcast"
        picker.showsMicrophoneButton = false
        if let button = picker.subviews.compactMap({ $0 as? UIButton }).first {
            button.setTitle("Start Broadcast", for: .normal)
        }
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}