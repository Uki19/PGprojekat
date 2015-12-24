//
//  WavData.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/16/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import Foundation


struct WavData : CustomStringConvertible {
    var sampleRate:Int = 0
    var bitsPerSample:Int = 0
    var numberOfChannels = 0
    var byteRate:Int = 0
    var fileSize:Int = 0
    var fmtChunkSize:Int = 0
    var dataSize:Int = 0
    var blockSize:Int = 0
    var wavLength:Float = 0
    var FLLRsize: Int = 0
    var SamplesPerWindow: Int = 0
    var threshold: Double = 0
    var deviation: Double = 0
    var minWindowFrequency: Int = 0
    var wordWindowRange: (start: Int, end: Int) = (0,0)
    
    var data:[Double] = [Double]()
    var dataForWindows: [[Double]] = [[Double]]()
    var wordData:[Double] = [Double]()
    var rawData:[Double] = [Double]()
    var rawDataForWindows: [[Double]] = [[Double]]()
    
    var description:String {
    
        return "Sample Rate: \(sampleRate)\n" +
        "Bits per sample: \(bitsPerSample)\n" +
        "Number of channels: \(numberOfChannels)\n" +
        "Byte rate: \(byteRate)\n" +
        "Block size: \(blockSize)\n" +
        "Data size: \(dataSize)\n" +
        "Length: \(wavLength) seconds"
        
    }
    
    mutating func countThreshold(windowSize: Int, dotsPerWindow:Int)  {
        
        var threshold = 0.0
        var sum = 0.0
        let thresholdFrame = dotsPerWindow*100/windowSize
        let thresholdNumberOfWindows = 100/windowSize
        print(thresholdFrame)
        
        for(var i = 0; i < thresholdFrame;i++){
            sum += data[i+thresholdFrame]
        }
        
        threshold = sum/Double(thresholdFrame)
        print("Threshold = \(threshold)")
        self.threshold = threshold
        
        var sqrSum = 0.0
        
        for(var i = 0; i < thresholdNumberOfWindows ;i++){
            let diff = dataForWindows[i].getAverage()-threshold
            sqrSum += pow(diff,2)
        }
        
        let variation = sqrSum/Double(thresholdNumberOfWindows)
        
        print(variation)
        self.deviation = sqrt(variation)
        print("Deviation = \(self.deviation)")
     
    }
}

func + (left: String, right: String) -> String {
    var newString = left
    newString.appendContentsOf(right)
    return newString
}
