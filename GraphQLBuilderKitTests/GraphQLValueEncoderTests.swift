//
//  GraphQLValueEncoderTests.swift
//  GraphQLBuilderKitTests
//
//  Created by Mediym on 1/18/21.
//

@testable
import GraphQLBuilderKit
import XCTest

class GraphQLValueEncoderTests: XCTestCase {

    var sut: GraphQLValueEncoder!
    
    override func setUpWithError() throws {
        sut = GraphQLValueEncoder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCorrectEncoding() {
        // Given
        let nestedEntity = ComplexEncodableEntity.NestedEntity(id: .random(in: -100...100), name: nil, age: nil, nicknames: [randomString(), randomString(), randomString(), randomString(), randomString()])
        
        let entity = ComplexEncodableEntity(id: .random(in: -100...100), name: randomString(), age: .random(in: -100...100), phone: randomString(), aliases: [randomString(), randomString(), randomString()], nestedEntities: [nestedEntity, nestedEntity, nestedEntity, nestedEntity], nestedEntity: nestedEntity)
        
        sut.shouldEncodeNils = false
        sut.shouldWrapKeys = true
        
        // When
        guard let encoded: String = try? sut.encode(value: entity),
              let encodedData = encoded.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        // Then
        let jsonDecoder = JSONDecoder()
        guard let decoded = try? jsonDecoder.decode(ComplexEncodableEntity.self, from: encodedData) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(entity, decoded)
    }
    
    struct NilContainableEntity: Encodable {
        var id: Int?
        var name: String?
        var arrayOfStrings: [String?]?
        var arrayOfEntities: [NilContainableEntity?]
        
        enum CodingKeys: String, CodingKey {
            case id, name, arrayOfStrings, arrayOfEntities
            case nested
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(arrayOfStrings, forKey: .arrayOfStrings)
            
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .arrayOfEntities)
            
            for (index, item) in arrayOfEntities.enumerated() {
                if index == 2 {
                    var nestedNestedContainer = nestedContainer.nestedContainer(keyedBy: CodingKeys.self)
                    try nestedNestedContainer.encode(item?.name, forKey: .name)
                    try nestedNestedContainer.encode(item?.id, forKey: .id)
                } else {
                    try nestedContainer.encode(item)
                }
            }
        }
        
    }
    
    func testWithNilEncoding() throws {
        // Given
        let value = NilContainableEntity(id: nil, name: "name", arrayOfStrings: ["first", nil, "second"], arrayOfEntities: [
            NilContainableEntity(id: 1,
                                 name: "name_1",
                                 arrayOfStrings: ["value_1"],
                                 arrayOfEntities: [
                                    NilContainableEntity(id: 2,
                                                         name: "name_2",
                                                         arrayOfStrings: ["value_2"],
                                                         arrayOfEntities: [])
                                 ]),
            nil,
            NilContainableEntity(id: 2,
                                 name: nil,
                                 arrayOfStrings: nil,
                                 arrayOfEntities: [])
        ])
        
        // When
        guard let result: String = try? sut.encode(value: value) else {
            XCTFail()
            return
        }
        
        // Then
        let filteredResult = result.replacingOccurrences(of: " ", with: "")
        
        XCTAssertTrue(filteredResult.contains(###""arrayOfStrings":["first",null,"second"]"###))
        XCTAssertTrue(filteredResult.contains(###""id":null"###))
        XCTAssertTrue(filteredResult.contains(###""name":null"###))
    }
    
    func testWithoutNilEncoding() throws {
        // Given
        let value = NilContainableEntity(id: nil, name: "name", arrayOfStrings: ["first", nil, "second"], arrayOfEntities: [
            NilContainableEntity(id: 1,
                                 name: "name_1",
                                 arrayOfStrings: ["value_1"],
                                 arrayOfEntities: [
                                    NilContainableEntity(id: 2,
                                                         name: "name_2",
                                                         arrayOfStrings: ["value_2"],
                                                         arrayOfEntities: [])
                                 ]),
            nil,
            NilContainableEntity(id: 2,
                                 name: nil,
                                 arrayOfStrings: nil,
                                 arrayOfEntities: [])
        ])
        
        sut.shouldEncodeNils = false
        
        // When
        guard let result: String = try? sut.encode(value: value) else {
            XCTFail()
            return
        }
        
        // Then
        let filteredResult = result.replacingOccurrences(of: " ", with: "")
        
        XCTAssertFalse(filteredResult.contains(###""arrayOfStrings":["first",null,"second"]"###))
        XCTAssertFalse(filteredResult.contains(###""id":null"###))
        XCTAssertFalse(filteredResult.contains(###""name":null"###))
    }
    
    struct ForKeyEncodingTestsEntity: Encodable {
        var id: Int
        var name: String
    }
    
    func testKeysWithoutQuotesEncoding() {
        // Given
        let value = ForKeyEncodingTestsEntity(id: 1, name: "foo")
        sut.shouldWrapKeys = false
        
        // When
        guard let result: String = try? sut.encode(value: value) else {
            XCTFail()
            return
        }
        
        // Then
        let filteredResult = result.replacingOccurrences(of: " ", with: "")
        
        XCTAssertTrue(filteredResult.contains(###"id:1"###))
        XCTAssertTrue(filteredResult.contains(###"name:"foo""###))
    }
    
    func testKeysWithQuotesEncoding() {
        // Given
        let value = ForKeyEncodingTestsEntity(id: 1, name: "foo")
        sut.shouldWrapKeys = true
        
        // When
        guard let result: String = try? sut.encode(value: value) else {
            XCTFail()
            return
        }
        
        // Then
        let filteredResult = result.replacingOccurrences(of: " ", with: "")
        
        XCTAssertTrue(filteredResult.contains(###""id":1"###))
        XCTAssertTrue(filteredResult.contains(###""name":"foo""###))
    }
    
    struct ComplexEncodableEntity: Codable, Equatable {
        struct NestedEntity: Codable, Equatable {
            var id: Int
            var name: String?
            var age: Int?
            var nicknames: [String]
            
            enum CodingKeys: String, CodingKey {
                case id, name, age, nicknames
            }
            
            static func == (lhs: NestedEntity, rhs: NestedEntity) -> Bool {
                return lhs.id == rhs.id &&
                    lhs.name == rhs.name &&
                    lhs.age == rhs.age &&
                    lhs.nicknames.containsSameElements(as: rhs.nicknames)
            }
            
        }
        
        var id: Int
        var name: String
        var age: Int
        var phone: String?
        var aliases: [String]
        var nestedEntities: [NestedEntity]
        var nestedEntity: NestedEntity?
        
        static func == (lhs: ComplexEncodableEntity, rhs: ComplexEncodableEntity) -> Bool {
            return lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.age == rhs.age &&
                lhs.phone == rhs.phone &&
                lhs.aliases.containsSameElements(as: rhs.aliases) &&
                lhs.nestedEntities.containsSameElements(as: rhs.nestedEntities) &&
                lhs.nestedEntity == rhs.nestedEntity
        }
    }
    
    struct StringWithoutQuotesKeyedEntity: Encodable {
        var string: String
        
        enum CodingKeys: String, CodingKey {
            case string
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(StringWithoutQuotes(string), forKey: .string)
        }
    }
    
    func testStringWithoutQuotesEncoding() {
        // Given
        let value = StringWithoutQuotesKeyedEntity(string: "foo bar")
        
        // When
        let result: String? = try? sut.encode(value: value)

        // Then
        XCTAssertEqual(result, ###"{"string": foo bar}"###)
    }

    func testJsonEncoderPerformanceExample() throws {
        let nestedEntity = ComplexEncodableEntity.NestedEntity(id: .random(in: -100...100), name: randomString(), age: .random(in: -100...100), nicknames: [randomString(), randomString(), randomString(), randomString(), randomString()])
        
        let entity = ComplexEncodableEntity(id: .random(in: -100...100), name: randomString(), age: .random(in: -100...100), phone: randomString(), aliases: [randomString(), randomString(), randomString()], nestedEntities: [nestedEntity, nestedEntity, nestedEntity, nestedEntity], nestedEntity: nestedEntity)
        
        // This is an example of a performance test case.
        self.measure {
            for _ in 0..<100 {
                let jsonEncoder = JSONEncoder()
                _ = try? jsonEncoder.encode(entity)
            }
        }
    }
    
    func testGraphQLValueEncoderPerformanceExample() throws {
        let nestedEntity = ComplexEncodableEntity.NestedEntity(id: .random(in: -100...100), name: randomString(), age: .random(in: -100...100), nicknames: [randomString(), randomString(), randomString(), randomString(), randomString()])
        
        let entity = ComplexEncodableEntity(id: .random(in: -100...100), name: randomString(), age: .random(in: -100...100), phone: randomString(), aliases: [randomString(), randomString(), randomString()], nestedEntities: [nestedEntity, nestedEntity, nestedEntity, nestedEntity], nestedEntity: nestedEntity)
        
        // This is an example of a performance test case.
        self.measure {
            for _ in 0..<100 {
                let jsonEncoder = GraphQLValueEncoder()
                let data: String? = try? jsonEncoder.encode(value: entity)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func randomString() -> String {
        return Int.random(in: -100 ... 100).description
    }

}
