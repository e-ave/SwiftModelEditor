//
//  IncDecOps.swift
//  ModelViewer
//
// Restoration of the very useful ++ and -- operators that were
// removed for a not very good reason. 
// Borrowed from: http://stackoverflow.com/a/36896464
//

import Foundation

prefix operator ++
postfix operator ++

prefix operator --
postfix operator --


// Increment
prefix func ++( x: inout Int) -> Int {
    x += 1
    return x
}

postfix func ++(x: inout Int) -> Int {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout UInt) -> UInt {
    x += 1
    return x
}

postfix func ++(x: inout UInt) -> UInt {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Int8) -> Int8 {
    x += 1
    return x
}

postfix func ++(x: inout Int8) -> Int8 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout UInt8) -> UInt8 {
    x += 1
    return x
}

postfix func ++(x: inout UInt8) -> UInt8 {
    x += 1
    return (x - 1)
}
prefix func ++(x: inout Int16) -> Int16 {
    x += 1
    return x
}

postfix func ++(x: inout Int16) -> Int16 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout UInt16) -> UInt16 {
    x += 1
    return x
}

postfix func ++(x: inout UInt16) -> UInt16 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Int32) -> Int32 {
    x += 1
    return x
}

postfix func ++(x: inout Int32) -> Int32 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout UInt32) -> UInt32 {
    x += 1
    return x
}

postfix func ++(x: inout UInt32) -> UInt32 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Int64) -> Int64 {
    x += 1
    return x
}

postfix func ++(x: inout Int64) -> Int64 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout UInt64) -> UInt64 {
    x += 1
    return x
}

postfix func ++(x: inout UInt64) -> UInt64 {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Double) -> Double {
    x += 1
    return x
}

postfix func ++(x: inout Double) -> Double {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Float) -> Float {
    x += 1
    return x
}

postfix func ++(x: inout Float) -> Float {
    x += 1
    return (x - 1)
}

prefix func ++(x: inout Float80) -> Float80 {
    x += 1
    return x
}

postfix func ++(x: inout Float80) -> Float80 {
    x += 1
    return (x - 1)
}

// Decrement
prefix func --(x: inout Int) -> Int {
    x -= 1
    return x
}

postfix func --(x: inout Int) -> Int {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout UInt) -> UInt {
    x -= 1
    return x
}

postfix func --(x: inout UInt) -> UInt {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Int8) -> Int8 {
    x -= 1
    return x
}

postfix func --(x: inout Int8) -> Int8 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout UInt8) -> UInt8 {
    x -= 1
    return x
}

postfix func --(x: inout UInt8) -> UInt8 {
    x -= 1
    return (x + 1)
}
prefix func --(x: inout Int16) -> Int16 {
    x -= 1
    return x
}

postfix func --(x: inout Int16) -> Int16 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout UInt16) -> UInt16 {
    x -= 1
    return x
}

postfix func --(x: inout UInt16) -> UInt16 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Int32) -> Int32 {
    x -= 1
    return x
}

postfix func --(x: inout Int32) -> Int32 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout UInt32) -> UInt32 {
    x -= 1
    return x
}

postfix func --(x: inout UInt32) -> UInt32 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Int64) -> Int64 {
    x -= 1
    return x
}

postfix func --(x: inout Int64) -> Int64 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout UInt64) -> UInt64 {
    x -= 1
    return x
}

postfix func --(x: inout UInt64) -> UInt64 {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Double) -> Double {
    x -= 1
    return x
}

postfix func --(x: inout Double) -> Double {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Float) -> Float {
    x -= 1
    return x
}

postfix func --(x: inout Float) -> Float {
    x -= 1
    return (x + 1)
}

prefix func --(x: inout Float80) -> Float80 {
    x -= 1
    return x
}

postfix func --(x: inout Float80) -> Float80 {
    x -= 1
    return (x + 1)
}
