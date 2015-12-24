//
//  ResultViewController.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/17/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit
import Charts

class ResultViewController: UIViewController,ChartViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var dftChart: BarChartView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var fullSignalChart: SignalView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var wordSignalChart: SignalView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var pickerData = [String]()
    
    var wavData: WavData!
    var dftMaker: DFT!
    
    func customizeChart(){
        
        dftChart.descriptionText = ""
        
        
//       contentView.frame.size.height = dftChart.frame.origin.x + dftChart.frame.size.height+50
//        windowPicker.delegate = self;
//        windowPicker.dataSource = self;
        
    }
    
    func randomInit(){
        
         dftMaker = DFT()
         descriptionTextView.text = wavData.description
    }
    
    func doFFTdata(window:Int = 0){
        
        let preDftArray = wavData.rawDataForWindows[window];
        
        
        let postDftArray = dftMaker.fft(preDftArray)
        
        updateChartData(postDftArray, minFrequency: wavData.minWindowFrequency)
        
       
        
    }
    
    
    func initPickerView(){
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        for (var i = 0; i<wavData.dataForWindows.count;i++){
            pickerData.append("Window \(i+1)")
        }
        
    }
    
    func setWholeSignalChart(){
        
        timeLabel.text = "\(Double(wavData.wordWindowRange.start*20)/1000.0) - \(Double(wavData.wordWindowRange.end*20)/1000.0)"
        fullSignalChart.data = wavData.data
        wordSignalChart.data = wavData.wordData
        fullSignalChart.prepBgImage()
        wordSignalChart.prepBgImage()
}
    
    func updateChartData(chartData: [Double], minFrequency: Int){
        
        
        var dataEntries: [BarChartDataEntry] = []
        var frequencies: [String] = []
        
        for i in 1..<chartData.count {
            let dataEntry = BarChartDataEntry(value: chartData[i], xIndex: i)
            dataEntries.append(dataEntry)
            frequencies.append("\(i*minFrequency)")
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Amplitude")
        chartDataSet
        chartDataSet.colors = [UIColor.redColor()]
        let chartData = BarChartData(xVals: frequencies, dataSet: chartDataSet)
        dftChart.data = chartData
        
    }

    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        doFFTdata(row)
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomInit()
        customizeChart()
        doFFTdata()
        initPickerView()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setWholeSignalChart()
    }

}
