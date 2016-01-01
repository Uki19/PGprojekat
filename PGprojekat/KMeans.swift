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
    
    func performKMeans(data: [[Double]], clusters: [[Double]], k: Int, threshold: Float = 0.0001){
    
        objects = data
        self.clusters = clusters
        n = objects.count
        self.k = k
        membership = [Int](count: n, repeatedValue: -1)
        clusterSizes = [Int](count:k, repeatedValue: 0)
        var error:Float = 0.0
        var previousError:Float = 0.0
        
        repeat {
            
            error = 0
            var newCentroids = Array(clusters)
            var newClusterSizes = [Int](count: k, repeatedValue: 0)
            
            for i in 0..<n {
                
                let clusterIndex = findNearestCluster(objects[i], centroids: self.clusters, k: self.k)
                if membership![i] != clusterIndex {
                    error += 1
                    membership![i] = clusterIndex
                }
                newClusterSizes[clusterIndex]++
                newCentroids[clusterIndex] += objects[i]
            }
            
            for i in 0..<k {
                let size = newClusterSizes[i]
                if size > 0 {
                    
                    self.clusters[i] = newCentroids[i] / Double(size)
                }
            }
            
            clusterSizes = newClusterSizes
            previousError = error
            
        } while abs(error - previousError) > threshold
    
    }
    
    func findNearestCluster(object: [Double], centroids: [[Double]], k: Int) -> Int {
        
        var minDistance = Double.infinity
        var clusterIndex = 0
        for i in 0..<k {
            let distance = eucledeanDist(object, two: centroids[i])
            if distance < minDistance {
                minDistance = distance
                clusterIndex = i
            }
        }
        return clusterIndex
        
    }
    
    func eucledeanDist(one: [Double], two: [Double]) -> Double {
        
        var sum = 0.0
        for i in 0..<one.count {
            sum += pow(two[i]-one[i],2)
        }
        return sqrt(sum)
    }

}
