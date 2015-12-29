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
        loadWavFiles()
        loadTableView()
        }
    
    
    // MARK: Pustanje .wav-a, citanje, racunanje thresholda, uzimanje reci i FFT
    func playAudioFile(url: NSURL){
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
        } catch { }
        
        
        player.prepareToPlay()

        player.play()
       
        let wavFileReader = WavFileReader()
        
        wavData = wavFileReader.readWavFileData(url)
        let windowSize = 20
        let minWindowFrequency = 1000/windowSize
        let numberOfWindows = wavData.wavLength*1000.0 / Float(windowSize)
        pickerData = [String](count: Int(numberOfWindows), repeatedValue: "")
        for i in 0..<Int(numberOfWindows) {
                pickerData[i]=("Window \(i+1)")
        }
        
        
        let dotsPerWindow = Int(round((wavData.wavLength * Float(wavData.sampleRate)) / numberOfWindows))
        wavData.SamplesPerWindow = dotsPerWindow
        wavData.minWindowFrequency = minWindowFrequency
        var tmpMatrix = [[Double]]()
        var tmpMatrixRaw = [[Double]]()
        
        for _ in 0..<Int(numberOfWindows) {
            tmpMatrix.append(Array(count:dotsPerWindow, repeatedValue:0.0))
            tmpMatrixRaw.append(Array(count:dotsPerWindow, repeatedValue:0.0))
        }
        
        for (var i=0;i<Int(numberOfWindows);i++){
            for (var j=0;j<dotsPerWindow;j++){
                tmpMatrix[i][j]=wavData.data[i*wavData.SamplesPerWindow+j]
                tmpMatrixRaw[i][j]=wavData.rawData[i*wavData.SamplesPerWindow+j]
            }
        }
        wavData.dataForWindows = tmpMatrix
        wavData.rawDataForWindows = tmpMatrixRaw
        print(dotsPerWindow)
        
        wavData.countThreshold(windowSize, dotsPerWindow: dotsPerWindow)
        wavData.wordWindowRange = getWordSignal(wavData, numberOfWindows: numberOfWindows)
        getWordSignalWithSpace(wavData, numberOfWindows: numberOfWindows)
        
        
        //DFT
        let dft = DFT()
        let postFFT = dft.doFFTforWordWindows(wavData.wordRawDataForWindows)
    
        //MFCC
        let mfcc = MFCC(wavData: wavData)
        let coefficients = mfcc.doMFCC(postFFT)
        
        //DCT
        let dct = DCT()
        dct.doDCT(mfcc.filterBankSize, numberOfFilters: mfcc.filterBankSize-2, withData: coefficients)
        
        performSegueWithIdentifier("showResults", sender: self)
    }
    
    
    // MARK: Secenje reci iz signala
    func getWordSignal(wavFile: WavData, numberOfWindows: Float) -> (Int, Int) {
        
        var currentWindowAverage = 0.0
        var maybeArray = [Int]()
        var wordWindows = [Int]()
        var sum = 0.0
        
        for i in 0..<Int(numberOfWindows) {
            sum += wavFile.dataForWindows[i].getAverage()
        }
        
        
        for(var i=0;i<Int(numberOfWindows);i++){
            currentWindowAverage = wavFile.dataForWindows[i].getAverage()

            if currentWindowAverage > wavFile.threshold + 2*wavFile.deviation {
                maybeArray.append(i)
            }
        }

        print(maybeArray)
        for(var i = 0; i < maybeArray.count-1; i++){
            let razlika = maybeArray[i+1] - maybeArray[i]
            if razlika <= 7 {
                for(var j = 0; j <= razlika;j++){
                    if !wordWindows.contains(maybeArray[i]+j){
                        wordWindows.append(maybeArray[i]+j)
                    }
                }
            }
            else {
                print(maybeArray[i])
                if maybeArray.count - i > i{
                    wordWindows.removeAll()
                }
            }
        }
        
        var lastIndex = 0

        var max = (start: 0, end: wordWindows.count, cost: 0)
        var tmp = (start: 0, end: 0, cost: 0)
        for(var i = 0;i<wordWindows.count-1;i++){
            
            if wordWindows[i]+1 != wordWindows[i+1] {
                tmp.end = i+1
                tmp.start = lastIndex
                if tmp.cost >= max.cost {
                    max = tmp
                    
                }
                tmp.cost = 0
                lastIndex = i+1
            } else {
                tmp.cost++
            }
            
        }
       
//        print(maybeArray)
        wordWindows = Array(wordWindows[Range<Int>(start: max.start, end: max.end)])
        print(wordWindows)
        
        for(var i=0;i<wordWindows.count;i++){
            
            wavData.wordData.appendContentsOf(wavData.dataForWindows[wordWindows[i]])
            wavData.wordRawDataForWindows.append(wavData.rawDataForWindows[wordWindows[i]])
            
        }
        print("RAW DATA: \(wavData.wordRawDataForWindows.count)")
        print("COUNT: \(wordWindows.count)")
        print(wavData.wordData.count/wavData.SamplesPerWindow)
        
        return (wordWindows.first!, wordWindows.last!)
    }
    
    
    
    func getWordSignalWithSpace(wavFile: WavData, numberOfWindows: Float){
        
        var currentWindowAverage = 0.0
//        var maybeArray = [Int]()
//        var wordWindows = [Double]()
        var brojac = 0
        var beginningIndex = 0
        var previousIndex = 0
        
        for(var i=0;i<Int(numberOfWindows);i++){
            currentWindowAverage = wavFile.dataForWindows[i].getAverage()
            
            if currentWindowAverage > wavFile.threshold + 2*wavFile.deviation {
                
                if brojac == 0 {
                    beginningIndex = i
                    previousIndex = i
                    brojac++
                } else {
                    if previousIndex > i-6 {
                        brojac += i-previousIndex
                        previousIndex = i
                    } else {
                        previousIndex = i
                        beginningIndex = i
                        brojac = 1
                    }
                }
                if(brojac >= 6) {
                    print("Start: \(beginningIndex)")
                    break
                }
                
//                maybeArray.append(i)
            }
        }
        
        
        var brojacRev = 0
        var beginningIndexRev = 0
        var previousIndexRev = 0
        
        for(var i=Int(numberOfWindows)-1;i>0;i--){
            currentWindowAverage = wavFile.dataForWindows[i].getAverage()
            
            if currentWindowAverage > wavFile.threshold + 2*wavFile.deviation {
                
                if brojacRev == 0 {
                    beginningIndexRev = i
                    previousIndexRev = i
                    brojacRev++
                } else {
                    if previousIndexRev < i+6 {
                        brojacRev += previousIndexRev-i
                        previousIndexRev = i
                    } else {
                        previousIndexRev = i
                        beginningIndexRev = i
                        brojacRev = 1
                    }
                }
                if(brojacRev >= 6) {
                    print("END: \(beginningIndexRev)")
                    break
                }
                
                //                maybeArray.append(i)
            }
        }
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



