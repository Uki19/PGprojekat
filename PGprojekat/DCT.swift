//
//  DCT.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/29/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit
import Accelerate

class DCT: NSObject {
    
    private var numberOfCoeffs = 0
    private var numberOfFilters = 0
    
    func doDCT(numberOfCoeffs: Int, numberOfFilters: Int, withData data: [[Double]]) -> [[Double]] {
        
        self.numberOfCoeffs = numberOfCoeffs
        self.numberOfFilters = numberOfFilters
        
        var allWindowsCepstrum = Array(count: data.count, repeatedValue: [Double]())

        for i in 0..<data.count {
            allWindowsCepstrum[i]=self.doSingleDCT(data[i])
        }
    
        
        
        print("CEPSTRUM COEFFS: \(allWindowsCepstrum[8])")
        
       return allWindowsCepstrum
    }
    
    func doSingleDCT(data: [Double]) -> [Double] {
        
        var cepstrum = [Double](count: numberOfCoeffs, repeatedValue: 0.0)
        
        for (var n=0; n<numberOfCoeffs;n++){
            for (var i=0; i<numberOfCoeffs; i++){
                cepstrum[n] += data[i] * cos(Double(n) * (Double(i)+1/2) * M_PI/Double(numberOfCoeffs))
//                cepstrum[n] += data[i]*cos(M_PI/Double(numberOfCoeffs)*(Double(i)+1/2)*Double(n))
                
            }
        }
        
        //APPLE accelerate DCT method - ignore
//        let dctSetup = vDSP_DCT_CreateSetup(nil, UInt(numberOfCoeffs), vDSP_DCT_Type.II)
//        var out = [Float](count: numberOfCoeffs, repeatedValue: 0.0)
//        var input = [Float]()
//        for i in 0..<data.count {
//            
//            input.append(Float(data[i]))
//            
//        }
//        vDSP_DCT_Execute(dctSetup, input, &out)
        
        
        return cepstrum
    }
    

}
