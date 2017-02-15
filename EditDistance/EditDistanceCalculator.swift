//
//  EditDistance.swift
//  EditDistance
//
//  Copyright © 2017年 kahayash. All rights reserved.
//

import Foundation

struct Point {
    let x: Int
    let y: Int
    let k: Int
}

enum Edit {
    case add
    case common
    case delete
}

struct Ses<T> {
    let edit: Edit
    let c: T
    let index: Int
}

struct Ctl {
    let reverse: Bool
    var path : [Int]
    var pathPosition: [Int: Point]
}

class EditDistanceCalculator<T: Comparable> {
    let xAxis: [T]
    let yAxis: [T]
    let xAxisLength: Int
    let yAxisLength: Int
    let offset: Int
    
    var ctl: Ctl
    var lcs = [T]()
    var ses = [Ses<T>]()
    var editDistance = 0
    
    init(from: [T], to: [T]) {
        let fromCount = from.count
        let toCount = to.count
        
        if fromCount >= toCount {
            self.xAxis = to
            self.yAxis = from
            self.xAxisLength = toCount
            self.yAxisLength = fromCount
            self.ctl = Ctl(reverse: true, path: [], pathPosition: [:])
        } else {
            self.xAxis = from
            self.yAxis = to
            self.xAxisLength = fromCount
            self.yAxisLength = toCount
            self.ctl = Ctl(reverse: false, path: [], pathPosition: [:])
        }
        self.offset = self.xAxisLength + 1
    }
    
    func compose() -> [Ses<T>] {
        let delta = self.yAxisLength - self.xAxisLength
        let size = self.xAxisLength + self.yAxisLength + 3
        
        var fp = Array(repeating: -1, count: size)
        self.ctl.path = Array(repeating: -1, count: size)
        self.ctl.pathPosition = [:]
        self.lcs = [T]()
        self.ses = [Ses]()
        
        var p = 0
        while(true) {
            if -p <= delta {
                for k in -p..<delta {
                    fp[k + offset] = self.snake(k: k, p: fp[k - 1 + offset] + 1, pp: fp[k + 1 + offset])
                }
            }
            
            if delta <= delta + p {
                for k in stride(from: delta + p, to: delta, by: -1) {
                    fp[k + offset] = self.snake(k: k, p: fp[k - 1 + offset] + 1, pp: fp[k + 1 + offset])
                }
            }
            
            fp[delta + offset] = self.snake(k: delta, p: fp[delta - 1 + offset] + 1, pp: fp[delta + 1 + offset])

            
            if fp[delta + offset] >= yAxisLength {
                editDistance = delta + 2 * p
                break
            }
            
            p += 1
        }

        var r = ctl.path[delta + offset]
        var epc = [Int: Point]()
        while (r != -1) {
            epc[epc.count] = Point(x: ctl.pathPosition[r]!.x, y: ctl.pathPosition[r]!.y, k: -1)
            r = ctl.pathPosition[r]!.k
        }
        
        self.recordSeq(epc: epc)
        return self.ses
    }
    
    
    func snake(k: Int, p: Int, pp: Int) -> Int {
        var r = 0
        if p > pp {
            r = ctl.path[k - 1 + offset]
        } else {
            r = ctl.path[k + 1 + offset]
        }
        
        var y = max(p, pp)
        var x = y - k
        
        while(x < self.xAxisLength && y < self.yAxisLength && xAxis[x] == yAxis[y]) {
            x += 1
            y += 1
        }
        
        ctl.path[k + offset] = ctl.pathPosition.count
        ctl.pathPosition[ctl.pathPosition.count] = Point(x: x, y: y, k: r)
        
        return y
    }
    
    func recordSeq(epc: [Int: Point]) {
        var pxIdx = 0, pyIdx = 0
        
        for i in stride(from: epc.count - 1, to: -1, by: -1) {
            while (pxIdx < epc[i]!.x) || (pyIdx < epc[i]!.y) {
                if (epc[i]!.y - epc[i]!.x) > (pyIdx - pxIdx) {
                    let elem = self.yAxis[pyIdx]
                    if ctl.reverse {
                        self.ses.append(Ses(edit: .delete, c: elem, index: pyIdx))
                    } else {
                        self.ses.append(Ses(edit: .add, c: elem, index: pyIdx))
                    }
                    pyIdx += 1
                } else if (epc[i]!.y - epc[i]!.x) < (pyIdx - pxIdx) {
                    let elem = self.xAxis[pxIdx]
                    if ctl.reverse {
                        self.ses.append(Ses(edit: .add, c: elem, index: pxIdx))
                    } else {
                        self.ses.append(Ses(edit: .delete, c: elem, index: pxIdx))
                    }
                    pxIdx += 1
                } else {
                    let elem = self.xAxis[pxIdx]
                    self.lcs.append(elem)
                    if ctl.reverse {
                        self.ses.append(Ses(edit: .common, c: elem, index: pxIdx))
                    } else {
                        self.ses.append(Ses(edit: .common, c: elem, index: pyIdx))
                    }
                    pxIdx += 1
                    pyIdx += 1
                }
            }
        }
    }
}
