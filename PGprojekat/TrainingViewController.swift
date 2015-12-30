//
//  TrainingViewController.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/29/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {

    var documentsPath: String!
    var player: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    
    @IBOutlet weak var wordTextView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let speechRecognizer = SpeechRecognizer()
    var wavData: WavData!
    var wavFolderPath: NSURL!
    var recordedURLS = [NSURL]()
    var isRecording = false
    
    private let cellID = "HMMCELL"
    
    
    //MARK: Pocetni setup tableview,files etc
    func initialSetup(){
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
        
        documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let documentsURL = NSURL(string: documentsPath)
        wavFolderPath = documentsURL?.URLByAppendingPathComponent("trainingFiles")
        
        try! NSFileManager.defaultManager().createDirectoryAtPath(wavFolderPath.path!, withIntermediateDirectories: true, attributes: nil)
        let list = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(wavFolderPath.path!)
        for i in 0..<list.count {
            
            if list[i].endsWith(".wav"){
                try! NSFileManager.defaultManager().removeItemAtPath((wavFolderPath.path?.stringByAppendingString("/\(list[i])"))!)
            }
            
        }
        
        reloadRecordedWavs()
    }
    
    //MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ucitavanje snimljenih wav-ova za training
    func reloadRecordedWavs() {
        
        recordedURLS.removeAll()
        let listOfDocs = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(wavFolderPath.path!)
        
        for i in 0..<listOfDocs.count {
            if (listOfDocs[i].endsWith(".wav")){
                recordedURLS.append(NSURL(string: (wavFolderPath.path?.stringByAppendingString("/\(listOfDocs[i])"))!)!)
            }
        }
        tableView.reloadData()
    }
    
    
    //MARK: Snimanje audio snimka
    @IBAction func recordButtonPressed(sender: UIButton) {
        recordAudio(sender)
    }
    
    func recordAudio(sender: UIButton?) {
        guard !isRecording else {
            sender?.setBackgroundImage(UIImage(named: "recIcon"), forState: .Normal)
            isRecording = false
            recorder.stop()
            reloadRecordedWavs()
            return
        }
        
        isRecording = true
        sender?.setBackgroundImage(UIImage(named: "stopRec"), forState: .Normal)
        let audioSession = AVAudioSession.sharedInstance()
        
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.setActive(true)
        audioSession.requestRecordPermission({(allowed: Bool) -> Void in print("Accepted")} )
        
        
        let settings: [String : AnyObject] = [
            AVFormatIDKey:Int(kAudioFormatLinearPCM),
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:1,
            //            AVEncoderBitRateKey:12800,
            AVLinearPCMBitDepthKey:16,
            //            AVLinearPCMIsNonInterleaved: true,
            AVLinearPCMIsFloatKey:false,
            AVLinearPCMIsBigEndianKey:true,
            //            AVLinearPCMIsNonInterleaved: true,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
        ]
        
        let date = NSDate()
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        
        let dfString = df.stringFromDate(date)
        
        let fullPath = wavFolderPath.path?.stringByAppendingString("/\(dfString).wav")
        
        recorder = try! AVAudioRecorder(URL: NSURL(string: fullPath!)!, settings: settings)
        recorder.delegate = self
        //        recorder.prepareToRecord()
        recorder.record()
        
        
    }
    
    //Pokretanje treninga za HMM i snimke
    @IBAction func trainButtonPressed(sender: UIButton) {
        let word = wordTextView.text!
        
        if word.characters.count < 2 {
            let alert = UIAlertController(title: "Upisite rec koju trenirate", message: "", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                return
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            trainHMM(word)
        }
        
    }
    
    func trainHMM(trainingWord: String){
        print(trainingWord)
        var wavDataArray = [WavData]()
        
        for i in 0..<recordedURLS.count {
            
            wavDataArray.append(speechRecognizer.recognizeSpeech(recordedURLS[i]))

        }
        
        print("***** COEFFS *****")
        for wav in wavDataArray {
            print(wav.cepstralCoefficientsForWindows.first)
        }
    }

    //MARK: TableView delegate and dataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        
        cell.textLabel?.text = recordedURLS[indexPath.row].lastPathComponent
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        wavData = speechRecognizer.recognizeSpeech(recordedURLS[indexPath.row])
        
        self.performSegueWithIdentifier("hmmShowResults", sender: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return recordedURLS.count
    }
    
    
    //MARK: Segue metodi
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "hmmShowResults" {
            if let dvc = segue.destinationViewController as? ResultViewController {
                dvc.wavData = self.wavData
            }
        }
    }

}
