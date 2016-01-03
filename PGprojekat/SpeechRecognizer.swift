//
//  SpeechRecognizer.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/29/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class SpeechRecognizer: NSObject {
    
    var wavData: WavData!
    
    
    //MARK: RecognizeSpeech - svi step-ovi speech recognitiona nad wav-om
    func recognizeSpeech(wavUrl: NSURL) -> WavData {
        
        let wavFileReader = WavFileReader()
        
        wavData = wavFileReader.readWavFileData(wavUrl)
        let windowSize = 20
        let minWindowFrequency = 1000/windowSize
        let numberOfWindows = wavData.wavLength*1000.0 / Float(windowSize)
        
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
        let cepstrumCoeffs = dct.doDCT(mfcc.filterBankSize, numberOfFilters: mfcc.filterBankSize-2, withData: coefficients)
        wavData.cepstralCoefficientsForWindows = cepstrumCoeffs
        return wavData
    }
    
    // MARK: Secenje reci iz signala
    func getWordSignal(wavFile: WavData, numberOfWindows: Float) -> (Int?, Int?) {
        
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
            if razlika <= 5 {
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
        
        return (wordWindows.first, wordWindows.last)
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

}
