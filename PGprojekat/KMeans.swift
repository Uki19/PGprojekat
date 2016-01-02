//
//  K-Means.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 1/1/16.
//  Copyright © 2016 Uros Zivaljevic. All rights reserved.
//

import UIKit

class KMeans: NSObject {
    
    var membership: [Int]?
    var clusterSizes: [Int]?
    
    var objects = [[Double]]()
    
    var clusters = [[Double]]()
    
    var n = 0
    var k = 0
    
    func initialMembership() {
        var start = 0
        var segmentSize = Int(floor(Double(n)/Double(k)))
        
        clusterSizes = [Int](count:k, repeatedValue: 0)
        
        for i in 0..<self.k {
            
            if segmentSize < Int(floor(Double(n - start)/Double(k-i))) {
                segmentSize++
            }
            let length = min(n - start, segmentSize)
            for j in 0..<length {
                self.membership![start+j] = i
                clusterSizes![i]++
            }
            start += segmentSize
        }
        
        print(clusterSizes)
        var offset = 0
        for i in 0..<k {
            var stateAverage = [[Double]]()
            for j in 0..<clusterSizes![i] {
                stateAverage.append(objects[offset+j])
            }
            clusters.append(getMiddleVector(stateAverage))
            offset += clusterSizes![i]
        }
    }
    
    func performKMeans(data: [[Double]], clusters: [[Double]], k: Int, threshold: Float = 0.000001){
    
        objects = data
//        self.clusters = clusters
        n = objects.count
        self.k = k
        membership = [Int](count: n, repeatedValue: -1)
        initialMembership()
        print(self.membership!)
        
        var error:Float = 0.0
//        var previousError:Float = 0.0
        
        repeat {
            
            error = 0
//            var newCentroids = Array(clusters)
            var newClusterSizes = [Int](count: k, repeatedValue: 0)
            
            for i in 0..<n {
                
                let clusterIndex = findNearestCluster(objects[i], centroids: self.clusters, k: self.k)
                if membership![i] != clusterIndex {
                    error += 1
                    membership![i] = clusterIndex
                }
                newClusterSizes[clusterIndex]++
//                newCentroids[clusterIndex] += objects[i]
            }
            
//            for i in 0..<k {
//                let size = newClusterSizes[i]
//                if size > 0 {
//                    
//                    self.clusters[i] = newCentroids[i] / Double(size)
//                }
//            }
            
            clusterSizes = newClusterSizes
            countClusterCentroid()
//            previousError = error
            print("SIZES: \(clusterSizes)")
        for i in 0..<objects.count-1 {
            print(objects[i].getAverage())
            }
        } while error > 0
    
    }
    
    func countClusterCentroid(){
        var offset = 0
        for i in 0..<k {
            var stateAverage = [[Double]]()
            if clusterSizes![i] > 0 {
                for j in 0..<clusterSizes![i] {
                    stateAverage.append(objects[offset+j])
                }
                clusters[i] = getMiddleVector(stateAverage)
                offset += clusterSizes![i]
            }
        }
    }
    
    func findNearestCluster(object: [Double], centroids: [[Double]], k: Int) -> Int {
        
//        var minDistance = Double.infinity
        var clusterIndex = 0
        let indexOfObject = self.objects.indexOf({$0 == object})!
        if indexOfObject == self.objects.count-1 || indexOfObject==0 || (membership![indexOfObject] == membership![indexOfObject+1] && membership![indexOfObject] == membership![indexOfObject-1]) {
            return membership![indexOfObject]
        }
        if membership![indexOfObject]+1 != k {
            if membership![indexOfObject] != membership![indexOfObject+1] {
                let distA = eucledeanDist(object, two: centroids[membership![indexOfObject]+1])
                let distB = eucledeanDist(object, two: centroids[membership![indexOfObject]])
                if distA < distB {
    //                minDistance = distA
                    clusterIndex = membership![indexOfObject]+1
                } else {
    //                minDistance = distB
                    clusterIndex = membership![indexOfObject]
                }
            }
        }
        if membership![indexOfObject] != membership![indexOfObject-1] && indexOfObject-1 != -1 {
            let distA = eucledeanDist(object, two: centroids[membership![indexOfObject]-1])
            let distB = eucledeanDist(object, two: centroids[membership![indexOfObject]])
            if distA < distB {
//                minDistance = distA
                clusterIndex = membership![indexOfObject]-1
            } else {
//                minDistance = distB
                clusterIndex = membership![indexOfObject]
            }
        }
//        var difference = 1
//        if indexOfObject == self.objects.count - 1 || membership![indexOfObject] == k - 1 {
//            difference = -1
//        }
//        if indexOfObject == 0 || indexOfObject == self.objects.count - 1 || membership![indexOfObject] == 0 || membership![indexOfObject] == k-1 {
//            let distA = eucledeanDist(object, two: centroids[membership![indexOfObject]+difference])
//            let distB = eucledeanDist(object, two: centroids[membership![indexOfObject]])
//            if distA < distB {
//                minDistance = distA
//                clusterIndex = membership![indexOfObject]+difference
//            } else {
//                minDistance = distB
//                clusterIndex = membership![indexOfObject]
//            }
//        } else {
//            for i in 0..<3 {
//                let distance = eucledeanDist(object, two: centroids[membership![indexOfObject]-1+i])
//                if distance < minDistance {
//                    minDistance = distance
//                    clusterIndex = i
//                }
//            }
//        }
        return clusterIndex
        
    }
    
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
        }
        sumArray /= Double(vectors.count)
        return sumArray
    }

}
