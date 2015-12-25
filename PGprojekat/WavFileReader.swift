//
//  WavFileReader.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/13/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class WavFileReader: NSObject {
        
    func readWavFileData(url: NSURL) -> WavData {
        
        
        
        var wavData=WavData()
        
        let data = NSData(contentsOfFile: url.absoluteString)!
    
        wavData.fileSize = getChunkValue(data, from: 4, length: 4, isBigEndian: false)+8
        wavData.fmtChunkSize = getChunkValue(data, from: 16, length: 4, isBigEndian: false)
        wavData.numberOfChannels = getChunkValue(data, from: 22, length: 2, isBigEndian: false)
        wavData.sampleRate = getChunkValue(data, from: 24, length: 4, isBigEndian: false)
        wavData.byteRate = getChunkValue(data, from: 28, length: 4, isBigEndian: false)
        wavData.blockSize = getChunkValue(data, from:32, length: 2, isBigEndian: false)
        wavData.bitsPerSample = getChunkValue(data, from:34, length: 2, isBigEndian: false)
        
        
        let numberFllrOrData = getChunkValue(data, from: 36, length: 4, isBigEndian: true)
        wavData.fmtChunkSize = 0;
        
        var fllrOffset = 0;
        
        if numberFllrOrData != 1684108385 {
            wavData.FLLRsize = getChunkValue(data, from: 40, length: 4, isBigEndian: false)
            fllrOffset = wavData.FLLRsize+8;
            wavData.dataSize = getChunkValue(data, from:40+fllrOffset, length: 4, isBigEndian: false)
        } else {
            wavData.dataSize = getChunkValue(data, from:40, length: 4, isBigEndian: false)
        }
        
        wavData.wavLength = Float(wavData.dataSize) / Float(wavData.byteRate)
       
        for var i = 0; i<wavData.dataSize; i+=wavData.blockSize {
            
            let length = wavData.blockSize/wavData.numberOfChannels
            
            if wavData.numberOfChannels == 2 {
                let sigL = getChunkValue(data, from: 44+i+fllrOffset, length: length, isBigEndian: false, isRawData: false)
                let sigR = getChunkValue(data, from: 44+i+length+fllrOffset, length: length, isBigEndian: false, isRawData: false)
                wavData.data.append(Double((sigL+sigR)/2))
                let sigLRaw = getChunkValue(data, from: 44+i+fllrOffset, length: length, isBigEndian: false, isRawData: true)
                let sigRRaw = getChunkValue(data, from: 44+i+length+fllrOffset, length: length, isBigEndian: false, isRawData: true)
                wavData.rawData.append(Double((sigLRaw+sigRRaw)/2))
            } else {
                let sig = getChunkValue(data, from: 44+i+fllrOffset, length: length, isBigEndian: false, isRawData:false)
                let sigRaw = getChunkValue(data, from: 44+i+fllrOffset, length: length, isBigEndian: false, isRawData:true)
                wavData.data.append(Double(sig))
                wavData.rawData.append(Double(sigRaw))
            }
        }

//        print(wavData.rawData)
        return wavData
    }
    
    
    
    func getChunkValue(data:NSData, from: Int, length: Int, isBigEndian:Bool) -> Int {
    
        let sub = data.subdataWithRange(NSRange(location: from, length: length))
        var out:UInt32 = 0
       
        sub.getBytes(&out, range: NSRange(location: 0, length: sub.length))
        
        if isBigEndian {
            out = CFSwapInt32HostToBig(out)
        }
        
        return Int(out)
    }
    
    func getChunkValue(data:NSData, from: Int, length: Int, isBigEndian:Bool, isRawData:Bool) -> Int {
        
        let sub = data.subdataWithRange(NSRange(location: from, length: length))
        var out:Int16 = 0
        
        sub.getBytes(&out, range: NSRange(location: 0, length: sub.length))
        
        if isBigEndian {
//            out = CFSwapInt32HostToBig(out)
        }
        
        if isRawData {
            return Int(out)
            
            // podeliti sa 32767 ako treba double value od -1 do 1
        }
        else {
            return Int(pow(Double(out),2.0))
//            return Int(abs(out))
        }
    }
    

}
