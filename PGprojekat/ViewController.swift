//
//  ViewController.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/9/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import OpenAL
import Charts

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recButton: UIButton!
    
    var documentsPath: String!
    var player: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    
    var wavData: WavData!

    var pickerData = [String]()
    
    var wavFiles = [NSURL]()
    var cellID = "WavCell"
    
    var isRecording = false
    
    func loadTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        recButton.imageView?.contentMode = .ScaleAspectFit
//        recButton.addTarget(self,action:"startRecording:", forControlEvents: UIControlEvents.TouchDown)
        
        recButton.addTarget(self, action: "startStopRecording:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    

    
    // MARK: Ucitavanje .wav fajlova
    func loadWavFiles(){
        
        let bundle = NSBundle.mainBundle()
        
        let pathForWav = bundle.pathsForResourcesOfType("wav", inDirectory: nil)
        
        wavFiles.removeAll()
        for i in 0..<pathForWav.count {
            wavFiles.append(NSURL(string: pathForWav[i])!)
        
        }
        
        documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        let listOfDocs = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsPath)
        
        for i in 0..<listOfDocs.count {
            if (listOfDocs[i].endsWith(".wav")){
                wavFiles.append(NSURL(string: documentsPath.stringByAppendingString("/\(listOfDocs[i])"))!)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func deleteAllinDocuments(sender: UIBarButtonItem) {
        
        let listOfDocs = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsPath)
        for i in 0..<listOfDocs.count {
            if (listOfDocs[i].endsWith(".wav")){
                    try! NSFileManager.defaultManager().removeItemAtPath(documentsPath.stringByAppendingString("/\(listOfDocs[i])"))
            }
        }
        loadWavFiles()
    }
    
    
    // MARK: Snimanje i cuvanje zvuka
    func startStopRecording(sender: UIButton){
        
        guard !isRecording else {
            sender.setBackgroundImage(UIImage(named: "recIcon"), forState: .Normal)
            isRecording = false
            recorder.stop()
            loadWavFiles()
            return
        }
        
        isRecording = true
        sender.setBackgroundImage(UIImage(named: "stopRec"), forState: .Normal)
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
        
        let fullPath = documentsPath.stringByAppendingString("/\(dfString).wav")
        
        recorder = try! AVAudioRecorder(URL: NSURL(string: fullPath)!, settings: settings)
        recorder.delegate = self
//        recorder.prepareToRecord()
        recorder.record()
        
    }
    
    //MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableView()
        loadWavFiles()
        }
    
    
    // MARK: Pustanje .wav-a, citanje, racunanje thresholda, uzimanje reci i FFT
    func playAudioFile(url: NSURL){
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
        } catch { }
        
        
        player.prepareToPlay()

        player.play()
        
        
        wavData = SpeechRecognizer().recognizeSpeech(url)
       
        performSegueWithIdentifier("showResults", sender: self)
    }
    
    
    
    
    //MARK: data za prozor
    func getDataForWindow(data: [Double], window: Int, samplesPerWindow: Int) -> [Double]{
        var windowData = [Double]()
      
        
        for var i = (window-1)*samplesPerWindow;i < samplesPerWindow*window; i++ {
            windowData.append(data[i]);
        }

        return windowData;
    }
    
    // MARK: Table View delegat i dataSource metode

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wavFiles.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)!
        
        cell.textLabel?.text = wavFiles[indexPath.row].lastPathComponent!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        playAudioFile(wavFiles[indexPath.row])
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let sendAction = UITableViewRowAction(style: .Default, title: "Send", handler: {(action: UITableViewRowAction, indPath:NSIndexPath) in self.sendEmail(indPath)})
        
        sendAction.backgroundColor = UIColor.darkGrayColor()
        
        return [sendAction]
    }
    
    // MARK: MailCompsoer metode
    func sendEmail(indexPath: NSIndexPath){
        
        let mfm = MFMailComposeViewController()
        mfm.mailComposeDelegate = self
        mfm.setToRecipients(["justfootball19@hotmail.com"])
        mfm.setSubject("Snimak")
        
        let currentPath = wavFiles[indexPath.row]
        
        mfm.addAttachmentData(NSData(contentsOfFile: currentPath.absoluteString)!, mimeType: "audio/wav", fileName: "pg-proj-snimak")
        self.presentViewController(mfm, animated: true, completion: nil)
        
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showResults" {
            if segue.destinationViewController is ResultViewController {
                (segue.destinationViewController as! ResultViewController).wavData = self.wavData
            }
            
        }
    }
}



