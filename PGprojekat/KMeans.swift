//
//  K-Means.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 1/1/16.
//  Copyright © 2016 Uros Zivaljevic. All rights reserved.
//

import UIKit
import GameplayKit

class KMeans: NSObject {
    
    var membership: [[Int]]?
    var clusterSizes: [[Int]]?
    
    var objects = [[[Double]]]()
    
    var clusters = [[Double]]()
    
    var n = 0
    var k = 0
    
    var numberOfSegments = 0
    
    
    //MARK: Inicijalni setup, memebership, pocetni clusteri - skoro podjednako podeljeni
    func initialSetup() {
        var start = 0
        
        clusterSizes = [[Int]]()
        
        for segment in 0..<numberOfSegments {
            start = 0
            var tmpClusterSizes = [Int](count:k, repeatedValue: 0)
            self.n = objects[segment].count
            var segmentSize = Int(floor(Double(n)/Double(k)))
            for i in 0..<self.k {
                
                if segmentSize < Int(floor(Double(n - start)/Double(k-i))) {
                    segmentSize++
                }
                let length = min(n - start, segmentSize)
                for j in 0..<length {
                    self.membership![segment][start+j] = i
                    tmpClusterSizes[i]++
                }
                start += segmentSize
            }
           clusterSizes?.append(tmpClusterSizes)
        }
        
        print(clusterSizes)
    
        let tmpClusters = [Double](count: (objects.first?.first?.count)! , repeatedValue: 0.0)
        clusters = Array(count:k, repeatedValue: tmpClusters)
        countClusterCentroid()
        
    }
    
    
    //MARK: DOING K - MEANS HERE
    func performKMeans(data: [[[Double]]], k: Int, threshold: Float = 0.000001){
        
        numberOfSegments = data.count
        objects = data
//        for obj in objects {
//            print("OBJECTS: \(obj.debugPrint())")
//        }
        n = objects.count
        self.k = k
        membership = [[Int]]()
        for segment in 0..<numberOfSegments {
            let tmpSegMembership = [Int](count:objects[segment].count, repeatedValue: -1)
            membership!.append(tmpSegMembership)
        }
        initialSetup()
        var error:Float = 0.0
//        var previousError:Float = 0.0
        
        repeat {
            
            error = 0
//            var newCentroids = Array(clusters)
            let tmpClusterSizes = [Int](count: k, repeatedValue: 0)
            var newClusterSizes = Array(count: numberOfSegments, repeatedValue: tmpClusterSizes)
            
            for segment in 0..<numberOfSegments {
                self.n = objects[segment].count
                for i in 0..<n {
                    let clusterIndex = findNearestCluster(objects[segment][i], centroids: self.clusters, k: self.k, segment: segment)
                    if membership![segment][i] != clusterIndex {
                        error += 1
                        membership![segment][i] = clusterIndex
                    }
                    newClusterSizes[segment][clusterIndex]++
    //                newCentroids[clusterIndex] += objects[i]
                }
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
            print("MEMBERSHIP: \(membership)")
//        for i in 0..<objects.count-1 {
//            print(objects[i].getAverage())
//            }
        } while error > 0
    
    }
    
    //MARK: Racunanje centroida za clustere - average svih prozora svih segmenata prvog stanja
    func countClusterCentroid(){
        
        var offsets = [Int](count: numberOfSegments, repeatedValue: 0)
        for i in 0..<k {
            var stateAverage = [[Double]]()
            for j in 0..<numberOfSegments {
                for k in 0..<clusterSizes![j][i] {
                    stateAverage.append(objects[j][offsets[j]+k])
                }
                offsets[j]+=clusterSizes![j][i]
            }
            clusters[i] = getMiddleVector(stateAverage)
//            print("STATE --> \(i) --> STATE AVG: \(stateAverage.debugPrint())")
//            print("AVERAGE --> \(i) --> \(clusters[i])")
        }
    }
    
    
    //MARK: Pronalazenje najblizeg clustera - ne moze bilo koji, samo susedni
    func findNearestCluster(object: [Double], centroids: [[Double]], k: Int, segment: Int) -> Int {
        
//        var minDistance = Double.infinity
        
        var clusterIndex = 0
        let size = self.objects[segment].count
        let indexOfObject = self.objects[segment].indexOf({$0 == object})!
        if indexOfObject == size-1 || indexOfObject==0 || (membership![segment][indexOfObject] == membership![segment][indexOfObject+1] && membership![segment][indexOfObject] == membership![segment][indexOfObject-1]) {
            return membership![segment][indexOfObject]
        }
        if membership![segment][indexOfObject]+1 != k {
            if membership![segment][indexOfObject] != membership![segment][indexOfObject+1] {
                let distA = eucledeanDist(object, two: centroids[membership![segment][indexOfObject]+1])
                let distB = eucledeanDist(object, two: centroids[membership![segment][indexOfObject]])
                if distA < distB {
                    clusterIndex = membership![segment][indexOfObject]+1
                } else {
                    clusterIndex = membership![segment][indexOfObject]
                }
            }
        }
        if membership![segment][indexOfObject] != membership![segment][indexOfObject-1] && indexOfObject-1 != -1 {
            let distA = eucledeanDist(object, two: centroids[membership![segment][indexOfObject]-1])
            let distB = eucledeanDist(object, two: centroids[membership![segment][indexOfObject]])
            if distA < distB {
                clusterIndex = membership![segment][indexOfObject]-1
            } else {
                clusterIndex = membership![segment][indexOfObject]
            }
        }
        return clusterIndex
        
    }
    
    
    //MARK: vector funkcije
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
