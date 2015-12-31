//
//  HMM.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/29/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class HMM: NSObject {
    
    var numberOfStates = 0
    var allCoeffSequences = [[[Double]]]()
    
    var segmentedArrays = [[[[Double]]]]()
    
    
    init(numberOfWordWindows: Int) {
        self.numberOfStates = Int(round(Double(numberOfWordWindows)*20.0/1000.0 * 20.0))
        print("Number of states: \(self.numberOfStates)")
        print(numberOfWordWindows)
    }
    
    
    
    func hmmTraining(coefficientSequences: [[[Double]]]){
        
        print("****** TRAINING *******")
        allCoeffSequences = coefficientSequences
        for var coeffSeq in allCoeffSequences {
            var segmentSize = Int(floor(Double(coeffSeq.count)/Double(numberOfStates)))
            
            var start = 0
            var wordArray = [[[Double]]]()
            for (var i=0; i<numberOfStates; ++i){
                
                if segmentSize < Int(floor(Double(coeffSeq.count - start)/Double(numberOfStates-i))) {
                    segmentSize++
                }
                let length = min(coeffSeq.count - start, segmentSize)
                let segmentArray:[[Double]] = Array(coeffSeq[start..<start+length])
                wordArray.append(segmentArray)
                print(" \(i) --> \(start) --> \(coeffSeq[start..<start+length].count)")
                 start += segmentSize
            }
            segmentedArrays.append(wordArray)
            print(coeffSeq.count)
            
            
            
        }
        
        var averageVectorsAll = [[[Double]]]()
        
        for i in 0..<numberOfStates {
            var averageVectors = [[Double]]()
            for segment in segmentedArrays {
                for j in 0..<segment[i].count {
                    averageVectors.append(segment[i][j])
                }
            }
            averageVectorsAll.append(averageVectors)
        }
        print(averageVectorsAll[0])
        print("MIDDLE \(getMiddleVector(averageVectorsAll[0]))")
        print(segmentedArrays[0].count)
        print(allCoeffSequences.count)
    }
    
    //MARK: helpful vectors functions
    func eucledeanDist(one: [Double], two: [Double]) -> Double {
        
        var sum = 0.0
        for i in 0..<one.count {
            sum += pow(two[i]-one[i],2)
        }
        return sqrt(sum)
    }

    func getMiddleVector(vectors: [[Double]]) -> [Double] {
        
        var sumArray = [Double](count: vectors[0].count, repeatedValue: 0.0)
        for vector in vectors {
            sumArray += vector
            print(sumArray.count)
        }
        sumArray /= Double(vectors.count)
        return sumArray
    }
}
