//
//  CoreKeyedEncodingContainer.swift
//  GraphQLBuilderKit
//
//  Created by Mediym on 1/15/21.
//

final class CoreKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] = []

    var data: KeyedContainerResult
    var config: CoreEncoder.Config

    init(data: KeyedContainerResult, config: CoreEncoder.Config) {
        self.data = data
        self.config = config
    }
    
    func encodeNil(forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(nil)
    }

    func encode(_ value: Bool, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: String, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value, useQuotes: true)
    }

    func encode(_ value: Double, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Float, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Int, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Int8, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Int16, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Int32, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: Int64, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: UInt, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
        data.values[key.stringValue] = .singleValue(data: value)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoder = CoreEncoder()
        try value.encode(to: encoder)
        
        if let encodedValue = encoder.data.value {
            data.values[key.stringValue] = encodedValue
        }
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        
        let nestedData = KeyedContainerResult()
        data.values[key.stringValue] = .keyed(nestedData)
        
        
        let container = CoreKeyedEncodingContainer<NestedKey>(data: nestedData, config: config)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let nestedData = UnkeyedContainerResult()
        data.values[key.stringValue] = .unkeyed(nestedData)
        
        return CoreUnkeyedEncodingContainer(data: nestedData, config: config)
    }

    func superEncoder() -> Encoder {
        if let superKey = Key(stringValue: "super") {
            return superEncoder(forKey: superKey)
        } else {
            let nestedData = CoreEncoderResult(value: .keyed(data))
            return CoreEncoder(data: nestedData, config: config)
        }
    }

    func superEncoder(forKey key: Key) -> Encoder {
        let nestedData = CoreEncoderResult(value: nil)
        data.values[key.stringValue] = .unknown(nestedData)
        
        return CoreEncoder(data: nestedData, config: config)
    }
}
