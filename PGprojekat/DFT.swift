//
//  DFT.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/10/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit
import Accelerate

class DFT: NSObject {
    
    
    // MARK: FFT funkcija za transformaciju iz vremenskog u frekvencioni domen
    func fft(var input: [Double]) -> [Double] {
        
        let closestTwoPow = ceil(log2(Float(input.count)))
        
        let razlika = Int(pow(2,closestTwoPow)) - input.count
        for _ in 0..<razlika {
            input.append(0.0)
        }
        
        var real = [Double](input)
        real = addHammingFunction(real)

        var imaginary = [Double](count: input.count, repeatedValue: 0.0)
        var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
        let length = vDSP_Length(floor(log2(Float(input.count))))

        let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetupD(length, radix)
        vDSP_fft_zipD(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
        
//        for i in 0..<real.count {
//            splitComplex.imagp[i] /= Double(real.count)
//            splitComplex.realp[i] /= Double(real.count)
//        }
//        
//        for i in 0..<real.count {
//            print("DFT \(i):Real - \(splitComplex.realp[i]) Imag - \(splitComplex.imagp[i])")
//        }
        
        var magnitudes = [Double](count: input.count, repeatedValue: 0.0)
        vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
        
        var normalizedMagnitudes = [Double](count: input.count, repeatedValue: 0.0)
        vDSP_vsmulD(sqrtArray(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
        
        vDSP_destroy_fftsetupD(weights)
        
        return normalizedMagnitudes
    }
    
//DFT funkcija - ignorisati
    func dft(input: [Double]) -> [Double]{
    
        var arg = 0.0
        var cosarg = 0.0
        var sinarg = 0.0
        var magnitudeArray = [Double]()
        var inputImag = [Double](count:input.count, repeatedValue: 0.0)
        let m = input.count
        var outputReal = [Double](count:m, repeatedValue: 0.0)
        var outputImag = [Double](count:m, repeatedValue: 0.0)
        
        for var i = 0;i < m;i++ {
            
            for var k = 0; k < m; k++ {
                arg = 2.0 * M_PI * Double(k) * Double(i)/Double(m)
                cosarg = cos(arg)
                sinarg = sin(arg)
                outputReal[k] += input[k] * cosarg + inputImag[k] * sinarg
                outputImag[k] += -input[k] * sinarg + inputImag[k] * cosarg
            }
            
        }
        
        for i in 0..<outputReal.count {
            print("DFT \(i):Real - \(outputReal[i]) Imag - \(outputImag[i])")
        }
        
        for var i = 0; i < m; i++ {
//            outputReal[i] /= Double(m)
//            outputImag[i] /= Double(m)
            magnitudeArray.append(sqrt(outputReal[i]*outputReal[i]+outputImag[i]*outputImag[i]))
        }
        
        return magnitudeArray
    }
    
    func doFFTforWordWindows(input: [[Double]]) -> [[Double]]{
        
        var fftForWindows = Array(count: input.count, repeatedValue: [Double]())
        
        for var i = 0;i<input.count;i++ {
            let windowFFT = self.fft(input[i])
            fftForWindows[i]=windowFFT
        }
        return fftForWindows
    }
    
    //MARK: Dodavanje prozorske funkcije - Hamming
    func addHammingFunction(input: [Double]) -> [Double]{
        
        var tmpArray = [Double](input)
        
        for i in 0..<input.count {
            
            tmpArray[i]  = input[i] * 0.54 - 0.46*cos((2.0 * M_PI * Double(i))/Double(input.count - 1))
            
        }
        return tmpArray
    }
    
    
    func sqrtArray(arrayD: [Double]) -> [Double] {
        var retArray = [Double]()
        for d in arrayD {
            retArray.append(sqrt(d))
        }
        return retArray
        
    }

}
