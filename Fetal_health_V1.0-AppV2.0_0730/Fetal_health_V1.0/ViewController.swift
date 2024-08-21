import UIKit
import AVFoundation
import MobileCoreServices
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var pandr: UIButton!
    var audioRecorder: AVAudioRecorder!
    var musicPlaying = false
    
    
    var fileName=""
    var audioProgress: Double?
    var storageAudioURL: URL?
  
    // change for total time at two places one here and other in reset timer. Addiitonally update the UI
     var totalTime: Int = 5
    

    //$$
    
    var countdownTimer: Timer!
    @IBOutlet weak var timerLabel: UILabel!
    var updateTimer: Timer!
    var recordingTimer: Timer!
    var remainingTime = 5
    //$$
     @IBOutlet weak var waveformView: WaveformView!
    //$$
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var PatientIDLbl: UILabel!
    var patientID = ""
    
    
    var additionalComments: String?
    var isSatisfactory: Bool?
    var currentDateAndTime = ""
    @IBOutlet weak var pandr_Pulse: UIButton!
    
    @IBOutlet weak var StopUS: UIButton!
    var togglebuttonchecked = false
    @IBOutlet weak var StopUSPulse: UIButton!
    var audioPlay:AVPlayer!

    @IBOutlet weak var groundTruthLbl: UILabel!
    var groundTruth = ""
    
    @IBOutlet weak var gestationWeeksLbl: UILabel!
    var gestationPeriod = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        PatientIDLbl.text = "Patient ID: "+patientID
        groundTruthLbl.text = "Ground Truth: "+groundTruth
        gestationWeeksLbl.text = "Gestation Period: "+gestationPeriod
//        FirebaseApp.configure()
        timerLabel.text = "00:05"
    }
    
    
    // Everything happening from here
    //Sin20000Hz@-14.08dB16bit48000HzS
    private func setUpAudioCapture(pulse:Bool) {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({ result in
                    guard result else { return }
            })
            if (pulse == false){
                // Calling function Play audio -- continous wave
                PlayAudio(audiofile:"Sin20000Hz@-14.08dB16bit48000HzS")
                // Caling dunction Record and Write  -- continous wave
                RecordAndWriteAudio(type: "continous")
            }else{
                // Calling function Play audio -- not needed
                PlayAudio(audiofile:"Sin20000Hz@-14.08dB16bit48000HzS")
                // Caling dunction Record and Write  -- not needed
                RecordAndWriteAudio(type:"pulse")
            }
        } catch {
            print("ERROR: Failed to set up recording session.")
        }
    }

    
    
    func startTimer() {
        // Start the timer only if it's not already running
        if countdownTimer == nil {
            countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }

    @objc func updateTime() {
        timerLabel.text = "\(timeFormatted(totalTime))"

        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
            resetTimer()
        }
    }

    func endTimer() {
        // Invalidate the timer when the total time reaches 0
        countdownTimer?.invalidate()
        countdownTimer = nil // Set it to nil to indicate that the timer is not running
    }

    func resetTimer() {
        // Reset the total time to the initial value (5 seconds)
        totalTime = 5
        // Update the timer label to the initial value without restarting the timer
        timerLabel.text = "\(timeFormatted(totalTime))"
    }

    // Function to format time in MM:SS format
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    

    // Beep sound for feedback
    func loadBeepSound() {
        guard let path = Bundle.main.path(forResource: "beep", ofType: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading beep sound: \(error.localizedDescription)")
        }
    }
    
    
    func getFilePath(forFileName fileName: String) -> URL? {
        do {
            let documentPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentPath.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: fileURL.path) {
                // File exists, return its URL
                return fileURL
                
                
            } else {
                // File does not exist
                print("File not found: \(fileName)")
                return nil
            }
        } catch {
            // Handle errors related to obtaining the document directory
            print("Error getting file path: \(error.localizedDescription)")
            return nil
        }
    }
    
    func upload_file_to_firebase_storage(localURL: URL) {
        let randomID = UUID.init().uuidString
        let path = "Audio/\(randomID).wav"
        let uploadRef = Storage.storage().reference(withPath:path )
        let metaData = StorageMetadata()
        metaData.contentType = "audio/wav"
        
        uploadRef.putFile(from: localURL, metadata: metaData) { (downloadMetadata, error) in
            if let error = error {
                print("Oh no! got an error! \(error.localizedDescription)")
                return
            }
            print("Put is complete and I got this back:  \( String(describing: downloadMetadata))")
            
            
            
            let db = Firestore.firestore()
            let documentID = self.fileName
            
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy_HH:mm:ss"
            let ts = dateFormatter.string(from: Date())
            do{
                try db.collection("patients").document(documentID).setData([ "PatientID":self.patientID , "Timestamp":ts ,"Ground Truth":self.groundTruth ,"Gestation Period":self.gestationPeriod ,"Audio URL":path,"Recording Satisfactory":self.isSatisfactory , "Additional Comments": self.additionalComments, ])

            }
            catch{
                print(error.localizedDescription)
            }
        }
            
        
        
        
        }
        
                  
        
            
        
    
    
    
    
    
    
    
    

     // Function to show the recording saved alert
     func showRecordingSavedAlert() {
         let alertController = UIAlertController(title: "Recording Saved!", message: "Was the recording satisfactory?", preferredStyle: .alert)

         // Add a text input field for additional comments
         alertController.addTextField { textField in
             textField.placeholder = "Additional comments"
         }
         
         
         var fp=self.getFilePath(forFileName: self.fileName ?? "default value")
         print("**************fp",fp!.absoluteString)
         self.upload_file_to_firebase_storage(localURL: fp!)
         

         // Action for the "Satisfactory" button
         let satisfactoryAction = UIAlertAction(title: "Satisfactory", style: .default) { [weak self] _ in
             // Handle satisfactory action
             self?.additionalComments = alertController.textFields?.first?.text
             self?.isSatisfactory = true
             print(self?.additionalComments, self?.isSatisfactory)
             // Pop back to the root view controller in the navigation stack
            
             
             self?.navigationController?.popToRootViewController(animated: true)

                   // Reset the state of the initial screen
            if let PatientIDViewController = self?.navigationController?.viewControllers.first as? PatientIDViewController {
                PatientIDViewController.resetInitialState()
                   }
             
         }

         // Action for the "Re-record" button
         let reRecordAction = UIAlertAction(title: "Re-record", style: .default) { [weak self] _ in
             
             self?.additionalComments = alertController.textFields?.first?.text
             self?.isSatisfactory = false
             self?.stopRecording()
             print(self?.additionalComments, self?.isSatisfactory)
 
         }
         
         // Update firestore with values
         let db = Firestore.firestore()
         let documentRef = db.collection("patients").document(self.fileName)
         let updatedData: [String: Any] = [
            "Satisfactory":self.isSatisfactory,
            "Additional Comments": self.additionalComments,  // Example of an integer field
         ]
         documentRef.updateData(updatedData) { error in
             if let error = error {
                 print("Error updating document: \(error)")
             } else {
                 print("Document successfully updated")
             }
         }
         
         
         
         
         reRecordAction.setValue(UIColor.red, forKey: "titleTextColor")
         
         // Add actions to the alert controller
      
         alertController.addAction(satisfactoryAction)
         alertController.addAction(reRecordAction)
         // Present the alert controller
         present(alertController, animated: true, completion: nil)
     }
  
    //$$
    func stopRecording() {
        print("Stopping recording")
         audioRecorder.stop()
         updateTimer.invalidate()
         recordingTimer.invalidate()
        self.pandr.isEnabled = true
         remainingTime = 5
         timerLabel.text = "00:05"
        
        DispatchQueue.main.async {
               self.waveformView.update(with: [])
           }
        
        waveformView.update(with: [])
        accumulatedSamples.removeAll()
        samplesBuffer.removeAll()

     }
    
    @objc func updateRecordingTimer() {
        remainingTime -= 1
        timerLabel.text = String(format: "00:%02d", remainingTime)

        if remainingTime <= 0 {
            stopRecording()
        }
    }
    var accumulatedSamples: [CGFloat] = []

    
    var samplesBuffer: [CGFloat] = []

    @objc func updateWaveform() {
        guard audioRecorder.isRecording else { return }
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePower(forChannel: 0)
        let normalizedValue = pow(10, averagePower / 20)
        samplesBuffer.append(CGFloat(normalizedValue))

        // Aggregate every N samples into one data point
        let aggregationInterval = 10
        if samplesBuffer.count >= aggregationInterval {
            let aggregatedSamples = stride(from: 0, to: samplesBuffer.count, by: aggregationInterval).map { startIndex in
                let endIndex = min(startIndex + aggregationInterval, samplesBuffer.count)
                let chunk = samplesBuffer[startIndex..<endIndex]
                return chunk.reduce(0, +) / CGFloat(chunk.count) // Average of the chunk
            }
            waveformView.update(with: aggregatedSamples)
            samplesBuffer.removeAll()  // Clear buffer after processing
        }
    }

//    @objc func updateWaveform() {
//        guard audioRecorder.isRecording else { return }
//        audioRecorder.updateMeters()
//        let averagePower = audioRecorder.averagePower(forChannel: 0)
//        let normalizedValue = pow(10, averagePower / 20)
//        accumulatedSamples.append(CGFloat(normalizedValue))
//
//        // Update the waveform view with the accumulated samples every 10 updates (for example)
//        if accumulatedSamples.count >= 10 {
//            waveformView.update(with: accumulatedSamples)
//            accumulatedSamples.removeAll()  // Clear the accumulated samples after updating
//        }
//    }



    //$$
    
    
    // on clicking Record button
    @IBAction func pandr(_ sender: Any) {
        DispatchQueue.global().async {
                // Call the first function   NOT playing the first time the app is built???????
            self.loadBeepSound()
            self.audioPlayer?.play()

                // Introduce a time delay (e.g., 0.5 seconds for 0.1 second beep)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Call the second function after the delay
                
                //$$
                self.accumulatedSamples.removeAll() // Clear previous samples

                self.pandr.isEnabled = false
                self.recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateRecordingTimer), userInfo: nil, repeats: true)
                self.waveformView.waveformColor = UIColor(hex: "#e85484") // Example hex code

                //$$
                
                    self.startTimer()
                self.setUpAudioCapture(pulse:false)
                self.showToast(message: "Playing and Recording Ultrasound!", font: .systemFont(ofSize: 11.0))

                }
            }
   // calling setting up function to start
            
        
            
            
            
    }
  
 
    
    // Function to play ultrasound audio through speaker
    func PlayAudio(audiofile:String) {
        guard let pathToSound = Bundle.main.path(forResource: audiofile, ofType: "wav") else
        { return }
         let url = URL(fileURLWithPath: pathToSound )
        
        do{
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true,options: .notifyOthersOnDeactivation)
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
             player = AVQueuePlayer(playerItem: item)
            
            // playing audio in continous loop
            playerLooper = AVPlayerLooper(player: player, templateItem: item)

            player.play()

        }catch{
            //error handling
        }
}
    
    
    // on press stop button
    @IBAction func StopUS(_ sender: Any) {


        if let recorder = audioRecorder {
            if recorder.isRecording {
                audioRecorder?.stop()
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    self.showToast(message: "Recording Stoped!", font: .systemFont(ofSize: 11.0))

                    try audioSession.setActive(false)
                } catch _ {
                }
            }}
    
        if let player = audioPlay {
                // if player.playing {
                     player.pause()
                // }
             }
//        if((audioRecorder.isRecording) != false){
//            audioRecorder.stop()
//            audioRecorder = nil
//        }
        

    }
    
  

    @IBAction func stopRecordingTapped(_ sender: Any) {
        stopRecording()

    }
    
    
    func RecordAndWriteAudio(type:String) {
//        var fileName=""
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyy_HHmmss" // Specify the desired date and time format
        
        let currentDateAndTime = dateFormatter.string(from: Date())
      
            
            if (type=="continous"){
                
//                fileName = "Patient ID*\(patientID)_Timestamp*\(currentDateAndTime)__RecSatisfactory*\(isSatisfactoryString)__Feedback*\(commentsString).wav"
                fileName = "Patient ID*\(patientID)_Timestamp*\(currentDateAndTime).wav"
            }else{
                // not needed
                fileName = "Pulse_AudioFile_\(UUID().uuidString).wav"
                
            
        }
       // var fileName = "AudioFile_\(UUID().uuidString).wav"
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     
        let audioFilename = documentPath.appendingPathComponent(fileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
            do {
                 audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                // Total recording timer set for X sec
                    audioRecorder.delegate = self

                    audioRecorder.record(forDuration: 5.0)
                    audioRecorder.isMeteringEnabled = true
                
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        self.audioRecorder.updateMeters()
                        let db = self.audioRecorder.averagePower(forChannel: 0)
//                        print(db)
                    }
                
                //$$
                updateTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateWaveform), userInfo: nil, repeats: true)
                //$$

            } catch {
                print("ERROR: Failed to start recording process.")
            }
     
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // Recording finished successfully
            loadBeepSound()
            audioPlayer?.play()
            showRecordingSavedAlert()
        } else {
            print("ppp")
            // Recording finished with an error
        }
    }
    
//    @IBAction func ImportAudio(_ sender: Any) {
//        
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        present(documentPicker,animated: true, completion: nil)
//    }
//}

//extension ViewController: UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        
//       guard let selctedAudioFileURL = urls.first else {
//            return
//        }
//    }
//    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2-95, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        var rgb: UInt32 = 0
        Scanner(string: hexSanitized).scanHexInt32(&rgb)
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
