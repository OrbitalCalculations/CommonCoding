//
//  SingleEncoding.swift
//  
//
//  Created by Natchanon Luangsomboon on 16/2/2563 BE.
//

import Foundation

class SingleValueStorage: TemporaryEncodingStorage {
    var value: TemporaryEncodingStorage = NilOptimizableStorage()

    func finalize() -> EncodingStorage {
        value.finalize()
    }
}

struct SingleValueBinaryEncodingContainer: SingleValueEncodingContainer {
    let storage: SingleValueStorage, context: EncodingContext

    var codingPath: [CodingKey] { context.codingPath }

    mutating func encodeNil() throws {
        storage.value = NilOptimizableStorage()
    }

    mutating func encode(_ value: String) throws {
        context.register(string: value)
        storage.value = StringOptimizableStorage(string: value)
    }

    mutating func encode(_ value: Bool) throws { try encode(value ? 1 : 0 as UInt8) }
    mutating func encode(_ value: Double) throws { try encode(value.bitPattern) }
    mutating func encode(_ value: Float) throws { try encode(value.bitPattern) }
    mutating func encode(_ value: Int) throws { try encode(Int64(value)) }
    mutating func encode(_ value: UInt) throws { try encode(UInt64(value)) }

    mutating func encode<T>(_ value: T) throws where T: Encodable, T: FixedWidthInteger {
        storage.value = FixedWidthOptimizableStorage(
            raw: withUnsafePointer(to: value) {
                Data(buffer: .init(start: $0, count: 1))
            }
        )
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: InternalEncoder(storage: storage, context: context))
    }
}