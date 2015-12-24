//
//  MFCC.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/22/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class MFCC: NSObject {
    
    var filterBankSize = 10
    var filterBank = [Double]()
    var wavData: WavData
    var filterMinFreq = 0.0
    var filterMaxFreq = 0.0
    
    
    init(wavData:WavData) {
        self.wavData = wavData
        filterMaxFreq = Double(wavData.sampleRate)/2.0
        filterMinFreq = Double(wavData.sampleRate/wavData.SamplesPerWindow)
    }
    

    
    func computeFilterBank(){
        
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
        
        for i in 0..<convertBackArray.count {
            let a = floor((Double(wavData.SamplesPerWindow)+1)*convertBackArray[i]/Double(wavData.sampleRate))
            print(a)
        }
    }
  

}
