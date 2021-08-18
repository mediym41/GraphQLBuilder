//
//  CoreEncoder.swift
//  
//
//  Created by Mediym on 1/15/21.
//

final class CoreEncoder: Encoder {
    
    // for future use
    final class Config { }

    var data: CoreEncoderResult
    var config: Config
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    init(data: CoreEncoderResult = CoreEncoderResult(),
         config: CoreEncoder.Config = CoreEncoder.Config()) {
        self.data = data
        self.config = config
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        
        let passedData: KeyedContainerResult
        
        if case .keyed(let value) = data.value { // save
            passedData = value
        } else { // override
            passedData = KeyedContainerResult()
            data.value = .keyed(passedData)
        }
        
        let container = CoreKeyedEncodingContainer<Key>(data: passedData, config: config)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        let passedData: UnkeyedContainerResult
        
        if case .unkeyed(let value) = data.value { // save
            passedData = value
        } else { // override
            passedData = UnkeyedContainerResult()
            data.value = .unkeyed(passedData)
        }
        
        return CoreUnkeyedEncodingContainer(data: passedData, config: config)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        let singleValueResult = SingleValueContainerResult()
        data.value = .singleValue(singleValueResult)
            
        return CoreSingleValueEncodingContainer(data: singleValueResult, config: config)
    }

}
