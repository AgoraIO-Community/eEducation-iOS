//
//  SafeCollection.swift
//  AgoraEducation
//
//  Created by SRS on 2020/11/18.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

public struct SafeCollection<Base: Collection> {
    
    fileprivate var _base: Base
    public init(_ base: Base) {
        _base = base
    }
    
    public typealias Index = Base.Index
    public var startIndex: Index {
        return _base.startIndex
    }
    
    public var endIndex: Index {
        return _base.endIndex
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element? {
        if _base.distance(from: startIndex, to: index) >= 0 && _base.distance(from: index, to: endIndex) > 0 {
            return _base[index]
        }
        return nil
    }
    
    public subscript(bounds: Range<Base.Index>) -> Base.SubSequence? {
        if _base.distance(from: startIndex, to: bounds.lowerBound) >= 0 && _base.distance(from: bounds.upperBound, to: endIndex) >= 0 {
            return _base[bounds]
        }
        return nil
    }
   
    var safe: SafeCollection<Base> { //Allows to chain ".safe" without side effects
        return self
    }
}


public extension Collection {
    var safe: SafeCollection<Self> {
        return SafeCollection(self)
    }
}
