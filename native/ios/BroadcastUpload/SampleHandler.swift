import ReplayKit
import CoreImage
import UIKit

final class SampleHandler: RPBroadcastSampleHandler {
    private var socket: URLSessionWebSocketTask?
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    private var lastFrameTime: CFTimeInterval = 0
    private let minimumFrameInterval: CFTimeInterval = 1.0 / 12.0

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let relay = SharedConfig.relayURL
        let code = SharedConfig.pairingCode

        guard let url = URL(string: relay), !code.isEmpty else {
            finishBroadcastWithError(NSError(domain: "District203Broadcast", code: 1, userInfo: [NSLocalizedDescriptionKey: "Open the app first and set the relay address and pairing code."]))
            return
        }

        let task = URLSession(configuration: .default).webSocketTask(with: url)
        socket = task
        task.resume()

        let join = "{\"type\":\"broadcaster\",\"code\":\"\(code)\"}"
        task.send(.string(join)) { [weak self] error in
            if let error {
                self?.finishBroadcastWithError(error)
            }
        }
    }

    override func broadcastPaused() {}
    override func broadcastResumed() {}

    override func broadcastFinished() {
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video,
              let socket,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let now = CACurrentMediaTime()
        guard now - lastFrameTime >= minimumFrameInterval else { return }
        lastFrameTime = now

        let image = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cg = ciContext.createCGImage(image, from: image.extent) else { return }
        let uiImage = UIImage(cgImage: cg)
        guard let jpeg = uiImage.jpegData(compressionQuality: 0.55) else { return }

        socket.send(.data(jpeg)) { _ in }
    }
}