//
//  MFCC.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/22/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class MFCC: NSObject {
    
    var filterBankSize = 26
    var filterBank = [Double]()
    var wavData: WavData
    var filterMinFreq = 0.0
    var filterMaxFreq = 0.0
    
    
    init(wavData:WavData) {
        self.wavData = wavData
        filterMaxFreq = Double(wavData.sampleRate)/2.0
        filterMinFreq = Double(wavData.sampleRate/wavData.SamplesPerWindow)
    }
    
    
    // MARK: Metoda za izvrsavanje MFCC-a i racunanje koeficijenata za sve prozore
    func doMFCC(postFFTarray: [[Double]]) -> [[Double]]  {
        
        var coefficients = Array(count: postFFTarray.count, repeatedValue: [Double]())
        
        let filterCoeffs = createFilterBank()
        
        for var k = 0; k < postFFTarray.count; k++ {
            var windowCoeff = [Double]()
            for var i = 0; i<filterBankSize;i++ {
                var sum = 0.0
                for var j = 0; j<wavData.SamplesPerWindow/2;j++ {
                    sum += postFFTarray[k][j] * filterCoeffs[i][j]
                }
                windowCoeff.append(log(sum))
//                windowCoeff.append(sum)
            }
            coefficients[k] = windowCoeff
        }
        print(coefficients[8])
        
        return coefficients
    }
    
 
    // MARK: Racunanje filterBanka i njihovih y-vrednosti radi mnozenja sa power spectrumom
    func createFilterBank() -> [[Double]] {
        
        var convertedBank = [Double]()
        
        let convertedMinFreq = 1125.0 * log(1.0+filterMinFreq/700)
        
        let convertedMaxFreq = 1125.0 * log(1.0+filterMaxFreq/700)
        
        let span = (convertedMaxFreq - convertedMinFreq) / (Double(filterBankSize)+1.0)
        
        print(convertedMinFreq)
        print(convertedMaxFreq)
        
        convertedBank.append(convertedMinFreq)
        for(var i = 1; i<=filterBankSize; i++){
            convertedBank.append(convertedBank[i-1]+span)
        }
        convertedBank.append(convertedMaxFreq)
        print(convertedBank)
        
        var convertBackArray = [Double]()
        
        for i in 0..<convertedBank.count {
            let a = 700*(pow(M_E,convertedBank[i]/1125) - 1)
            convertBackArray.append(a)
        }
        
        print(convertBackArray)
        
        var fftFilterBins = [Double]()
        
        for i in 0..<convertBackArray.count {
            let a = floor((Double(wavData.SamplesPerWindow)+1)*convertBackArray[i]/Double(wavData.sampleRate))
            print(a)
            fftFilterBins.append(a)
        }
        
    
        var filterCoff = Array(count: filterBankSize, repeatedValue: [Double]())
        for var j=1; j<=filterBankSize; j++ {
            var oneFilterCoffs = [Double]()
            for var i=0; i<=wavData.SamplesPerWindow/2;i++ {
                
                if Double(i) < fftFilterBins[j-1] {
                    oneFilterCoffs.append(0.0)
                }
                
                if Double(i) >= fftFilterBins[j-1] && Double(i) <= fftFilterBins[j] {
                    let number = (Double(i) - fftFilterBins[j-1])/(fftFilterBins[j] - fftFilterBins[j-1])
                    oneFilterCoffs.append(number)
                }
                
                if Double(i) >= fftFilterBins[j] && Double(i) <= fftFilterBins[j+1] {
                    let number = (fftFilterBins[j+1] - Double(i))/(fftFilterBins[j+1] - fftFilterBins[j])
                    oneFilterCoffs.append(number)
                }
                
                if Double(i) > fftFilterBins[j+1] {
                    oneFilterCoffs.append(0.0)
                }
                filterCoff[j-1] = oneFilterCoffs
            }
        }
        return filterCoff;
    }
}
