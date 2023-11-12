/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/




import UIKit
import RealityKit
import ARKit
import Combine
import AVFoundation
import Photos
import ReplayKit
import AVKit


struct PoseFrame {
    var timestamp: TimeInterval
    var bodyPosition: SIMD3<Float>
    var bodyRotation: simd_quatf
    var jointPositions: [String: SIMD3<Float>] // Keyed by joint name
}


class ViewController: UIViewController, ARSessionDelegate, RPPreviewViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var recordingTimer: Timer?
    
    var audioPlayer: AVAudioPlayer?
    var captureSession: AVCaptureSession?
    
    var screenRecorder = RPScreenRecorder.shared()





    @IBOutlet var arView: ARView!

    @IBOutlet weak var recordButton: UIButton!
    var isRecording = false
    
    var currentRecording: [PoseFrame] = []
    var recordings: [[PoseFrame]] = []
    
    @IBOutlet weak var checkScore: UIButton!
  
    @IBAction func computeScore(_ sender: Any) {
//        compareLastTwoRecordings()
        selectVideo()
        
    }
    @IBAction func recordButtonTapped(_ sender: Any) {
        if isRecording {
            stopRecording()
            recordings.append(currentRecording)
            verifyRecordingData()
            currentRecording = []
            recordButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
        }

    }
    
    
    func verifyRecordingData() {
            print("Total recordings: \(recordings.count)")
            if let lastRecording = recordings.last {
                print("Last recording frame count: \(lastRecording.count)")
                // Optionally, print details of the last frame of the last recording
                if let lastFrame = lastRecording.last {
                    print("Last frame details: \(lastFrame)")
                }
            }
        }
    


    
    func startRecording() {
        guard screenRecorder.isAvailable else {
               print("Screen recording is not available")
               return
           }

           screenRecorder.startRecording { [weak self] (error) in
               guard error == nil else {
                   print("There was an error starting the recording.")
                   return
               }

               // Play the audio file
               self?.playAudioFile()

               DispatchQueue.main.async {
                   self?.isRecording = true
                   self?.showToast(message: "Starting Recording")
               }
           }
//        isRecording = true
//        showToast(message: "Starting Recording")
    }

    
    @objc func stopRecording() {
        screenRecorder.stopRecording { [weak self] (previewController, error) in
                guard let previewController = previewController else {
                    print("Preview controller is not available.")
                    return
                }
            previewController.previewControllerDelegate = self
                DispatchQueue.main.async {
                    self?.isRecording = false
                    self?.showToast(message: "Recording Stopped")
                    
                    self?.audioPlayer?.stop()
                    self?.present(previewController, animated: true, completion: nil)
                    // Handle the preview here and upload the video
                }
            }
//        isRecording = false
//        showToast(message: "Recording Stopped")
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            previewController.dismiss(animated: true, completion: nil)
        }
    
    func playAudioFile() {
        guard let audioUrl = Bundle.main.url(forResource: "Tyla_-_Water", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer?.play()
        } catch {
            print("Couldn't play the audio file.")
        }
    }
    
    func selectVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let url = info[.mediaURL] as? URL else { return }
        // Now you have the URL of the video
        uploadVideo(url)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }

    
    func uploadVideo(_ videoURL: URL) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://8a6a-68-65-175-125.ngrok-free.app/put-video")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add the video data
        let videoData = try? Data(contentsOf: videoURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(videoURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(videoData!)
        body.append("\r\n".data(using: .utf8)!)

        // Close the body with the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            // Handle the response here
            
        }
        task.resume()
    }





    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let currentFrame = session.currentFrame {
            let timestamp = currentFrame.timestamp
            for anchor in anchors {
                guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                
                let transform = bodyAnchor.transform
                // Update the position of the character anchor's position.
                let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
                characterAnchor.position = bodyPosition + characterOffset
                // Also copy over the rotation of the body anchor, because the skeleton's pose
                // in the world is relative to the body anchor's rotation.
                characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
                
                let bodyRotation = computeRotation(from: transform)
                
                if let character = character, character.parent == nil {
                    // Attach the character to its anchor as soon as
                    // 1. the body anchor was detected and
                    // 2. the character was loaded.
                    characterAnchor.addChild(character)
                }
                if isRecording {
                            if let bodyAnchor = anchors.compactMap({ $0 as? ARBodyAnchor }).first {
                                let frameData = extractPoseData(from: bodyAnchor, at: timestamp)
                                currentRecording.append(frameData)
                            }
                        }
            }
        }
    }
    
    func computeRotation(from matrix: simd_float4x4) -> simd_quatf {
        return simd_quaternion(matrix)
    }
    
    func printBodyPose(from bodyAnchor: ARBodyAnchor, rotation: simd_quatf) {
        // Extract and print the body position information
        let bodyPosition = bodyAnchor.transform.columns.3
        print("Body Position: \(bodyPosition)")

        // Print the computed rotation
        print("Body Rotation (Quaternion): \(rotation)")

        // If you want to print joint positions
        for (joint, transform) in bodyAnchor.skeleton.jointModelTransforms.enumerated() {
            let jointName = ARSkeletonDefinition.defaultBody3D.jointNames[joint]
            let jointPosition = transform.columns.3
            print("Joint \(jointName): \(jointPosition)")
        }
    }
    
    func extractPoseData(from bodyAnchor: ARBodyAnchor, at timestamp: TimeInterval) -> PoseFrame {
        let bodyPosition = SIMD3<Float>(bodyAnchor.transform.columns.3.x,
                                        bodyAnchor.transform.columns.3.y,
                                        bodyAnchor.transform.columns.3.z)
        let bodyRotation = computeRotation(from: bodyAnchor.transform)

        var jointPositions = [String: SIMD3<Float>]()
        for (joint, transform) in bodyAnchor.skeleton.jointModelTransforms.enumerated() {
            let jointName = ARSkeletonDefinition.defaultBody3D.jointNames[joint]
            let jointPosition = SIMD3<Float>(transform.columns.3.x,
                                             transform.columns.3.y,
                                             transform.columns.3.z)
            jointPositions[jointName] = jointPosition
        }

        return PoseFrame(timestamp: timestamp, bodyPosition: bodyPosition, bodyRotation: bodyRotation, jointPositions: jointPositions)
    }
    
    func comparePoses(recording1: [PoseFrame], recording2: [PoseFrame], sampleRate: Int) -> Double {
        guard !recording1.isEmpty && !recording2.isEmpty else {
            return 0.0
        }

        let sampleCount = min(recording1.count, recording2.count) / sampleRate
        var totalDistance = 0.0

        for i in 0..<sampleCount {
            let index1 = min(i * sampleRate, recording1.count - 1)
            let index2 = min(i * sampleRate, recording2.count - 1)

            let frame1 = recording1[index1]
            let frame2 = recording2[index2]

            var frameDistance = 0.0
            var jointCount = 0

            for joint in frame1.jointPositions.keys {
                if let position1 = frame1.jointPositions[joint], let position2 = frame2.jointPositions[joint] {
                    frameDistance += distanceBetween(position1, position2)
                    jointCount += 1
                }
            }

            if jointCount > 0 {
                totalDistance += (frameDistance / Double(jointCount))
            }
        }

        return totalDistance / Double(sampleCount)
    }


    func distanceBetween(_ position1: SIMD3<Float>, _ position2: SIMD3<Float>) -> Double {
        let diff = position1 - position2
        return sqrt(Double(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z))
    }
    
    func showToast(message : String, duration: TimeInterval = 3.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 150, y: self.view.frame.size.height - 100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    func compareLastTwoRecordings() {
        if recordings.count < 2 {
            showToast(message: "Not enough recordings. Please record at least two sessions to compare.")
            print("Not enough recordings. Please record at least two sessions to compare.")
            return
        }

        let lastRecording = recordings[recordings.count - 1]
        let secondLastRecording = recordings[recordings.count - 2]

        let similarityScore = comparePoses(recording1: secondLastRecording, recording2: lastRecording, sampleRate: 10)

        showToast(message: "score: \(similarityScore)")
        print("Similarity score between the last two recordings: \(similarityScore)")
    }



}
