//
//  CoreEncoderTests.swift
//  GraphQLBuilderExample
//
//  Created by Mediym on 1/17/21.
//

@testable
import GraphQLBuilderKit_v2
import XCTest

extension ContainerResult {
    
    var keyed: KeyedContainerResult? {
        if case .keyed(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    var unkeyed: UnkeyedContainerResult? {
        if case .unkeyed(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    var single: SingleValueContainerResult? {
        if case .singleValue(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
}

class CoreEncoderTests: XCTestCase {

    var sut: CoreEncoder!
    
    override func setUpWithError() throws {
        sut = CoreEncoder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Single
    
    func testIntSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = 1
        
        let value: Int = 1
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testDoubleSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = 3.14
        
        let value: Double = 3.14
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testBoolSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = true
        
        let value: Bool = true
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testStringSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = "\"foo\""
        
        let value: String = "foo"
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testOptionalSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = 12
        
        let value: Int? = 12
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testNilSingleEncoding() throws {
        // Given
        let expectedResult: ContainerResult = nil
        
        let value: Int? = nil
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    // MARK: - Unkeyed
    
    func testPrimitivesUnkeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [1, 2, 3, 4, 5]
        
        let value: [Int] = [1, 2, 3, 4, 5]
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testOptionalsUnkeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = ["\"1\"", "\"2\"", nil, nil, "\"5\""]
        
        let value: [String?] = ["1", "2", nil, nil, "5"]
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testUnkeyedKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            [
                "id": 1,
                "name": "\"2\"",
                "price": 4.1,
                "isAuthorized": true
            ],
            [
                "id":2,
                "name": "\"3\"",
                "price": 4.2,
                "isAuthorized": false
            ],
            [
                "id": 3,
                "name": "\"4\"",
                "price": 1.4,
                "isAuthorized": true
            ]
        ]
        
        let value: [KeyedSimpleEntity] = [
            KeyedSimpleEntity(id: 1, name: "2", price: 4.1, isAuthorized: true),
            KeyedSimpleEntity(id: 2, name: "3", price: 4.2, isAuthorized: false),
            KeyedSimpleEntity(id: 3, name: "4", price: 1.4, isAuthorized: true)
        ]
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class KeyedNestedUnkeyedEntity: Encodable {
        var first: String
        var second: String
        var third: String?
        var fourth: String?
        var fifth: String?
        
        init(first: String, second: String, third: String? = nil, fourth: String? = nil, fifth: String? = nil) {
            self.first = first
            self.second = second
            self.third = third
            self.fourth = fourth
            self.fifth = fifth
        }
        
        enum CodingKeys: String, CodingKey {
            case second
            case third
            case fourth
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(first)
            try container.encode(fifth)
            var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self)
            try nestedContainer.encode(second, forKey: .second)
            try nestedContainer.encode(third, forKey: .third)
            try nestedContainer.encode(fourth, forKey: .fourth)
        }
    }
    
    func testKeyedNestedUnkeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "\"first\"",
            [
                "second": "\"second\"",
                "third": nil,
                "fourth": "\"fourth\""
            ],
            "\"fifth\"",
        ]
        
        let value = KeyedNestedUnkeyedEntity(first: "first", second: "second", third: nil, fourth: "fourth", fifth: "fifth")
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class InheritanceBaseUnkeyedEntity: Encodable {
        var first: String
        var second: String
        
        init(first: String, second: String) {
            self.first = first
            self.second = second
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(first)
            try container.encode(second)
        }
    }
    
    class InheritanceDerivedUnkeyedEntity: InheritanceBaseUnkeyedEntity {
        var third: String
        
        var isSuperViaUnkeyedContainer: Bool
        
        init(first: String, second: String, third: String, isSuperViaUnkeyedContainer: Bool) {
            self.third = third
            self.isSuperViaUnkeyedContainer = isSuperViaUnkeyedContainer
            super.init(first: first, second: second)
        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(third)
            
            if isSuperViaUnkeyedContainer {
                try super.encode(to: container.superEncoder())
            } else {
                try super.encode(to: encoder)
            }
        }
    }
    
    func testInheritanceWithoutSuperEncoderUnkeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "\"first\"",
            "\"second\"",
            "\"third\""
        ]
        
        let value = InheritanceDerivedUnkeyedEntity(first: "first", second: "second", third: "third", isSuperViaUnkeyedContainer: false)
        
        // When
        try value.encode(to: sut)
                
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testInheritanceWithSuperEncoderUnkeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            [
                "\"first\"",
                "\"second\""
            ],
            "\"third\""
        ]
        
        let value = InheritanceDerivedUnkeyedEntity(first: "first", second: "second", third: "third", isSuperViaUnkeyedContainer: true)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    // MARK: - Keyed
    
    struct KeyedSimpleEntity: Encodable {
        let id: Int
        let name: String
        let price: Double
        let isAuthorized: Bool
    }

    func testKeyedPrimitivesEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": 1,
            "name": "\"2\"",
            "price": 3.14,
            "isAuthorized": "false"
        ]
        
        let value = KeyedSimpleEntity(id: 1, name: "2", price: 3.14, isAuthorized: false)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    struct KeyedRequiredOptionalsEntity: Encodable {
        let id: Int?
        let name: String?
        let price: Double?
        let isAuthorized: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case price
            case isAuthorized
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(price, forKey: .price)
            try container.encode(isAuthorized, forKey: .isAuthorized)
        }
    }
    
    func testKeyedRequiredOptionalsEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": 1,
            "name": "\"2\"",
            "price": nil,
            "isAuthorized": nil
        ]
        
        let value = KeyedRequiredOptionalsEntity(id: 1, name: "2", price: nil, isAuthorized: nil)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }

    struct KeyedNotRequiredOptionalsEntity: Encodable {
        let id: Int?
        let name: String?
        let price: Double?
        let isAuthorized: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case price
            case isAuthorized
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(price, forKey: .price)
            try container.encodeIfPresent(isAuthorized, forKey: .isAuthorized)
        }
    }
    
    func testKeyedNotRequiredOptionalsEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": 1,
            "name": "\"2\""
        ]
        
        let value = KeyedNotRequiredOptionalsEntity(id: 1, name: "2", price: nil, isAuthorized: nil)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class ComplexEntity: Encodable {
        let id: Int
        let name: String?
        let parent: ComplexEntity?
        let children: [ComplexEntity?]
        
        init(id: Int, name: String?, parent: CoreEncoderTests.ComplexEntity?, children: [CoreEncoderTests.ComplexEntity?]) {
            self.id = id
            self.name = name
            self.parent = parent
            self.children = children
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case parent
            case children
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(parent, forKey: .parent)
            try container.encode(children, forKey: .children)
        }
    }
    
    func testComplexKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": 1,
            "name": "\"Root\"",
            "parent": nil,
            "children": [
                [
                    "id": 2,
                    "name": "\"Second1\"",
                    "parent": [
                        "id": 1,
                        "name": "\"Root\"",
                        "parent": nil,
                        "children": []
                    ],
                    "children": [
                        [
                            "id": 3,
                            "name": "\"Third1\"",
                            "parent": [
                                "id": 2,
                                "name": "\"Second1\"",
                                "parent": nil,
                                "children": []
                            ],
                            "children": []
                        ]
                    ]
                ],
                nil,
                [
                    "id": 4,
                    "name": "\"Second2\"",
                    "parent": [
                        "id": 1,
                        "name": "\"Root\"",
                        "parent": nil,
                        "children": []
                    ],
                    "children":[
                        [
                            "id": 5,
                            "name": "\"Third2\"",
                            "parent": [
                                "id": 4,
                                "name": "\"Second2\"",
                                "parent": nil,
                                "children": []
                            ],
                            "children": []
                        ]
                    ]
                ]
            ]
        ]
                
        let value = ComplexEntity(id: 1, name: "Root", parent: nil, children: [
            ComplexEntity(id: 2, name: "Second1", parent: ComplexEntity(id: 1, name: "Root", parent: nil, children: []), children: [
                ComplexEntity(id: 3, name: "Third1", parent: ComplexEntity(id: 2, name: "Second1", parent: nil, children: []), children: [])
            ]),
            nil,
            ComplexEntity(id: 4, name: "Second2", parent: ComplexEntity(id: 1, name: "Root", parent: nil, children: []), children: [
                ComplexEntity(id: 5, name: "Third2", parent: ComplexEntity(id: 4, name: "Second2", parent: nil, children: []), children: []),
            ])
        ])
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class KeyedNestedKeyedContainer: Encodable {
        var id: Int
        var name: String
        var age: Int
        var phone: String?
        
        init(id: Int, name: String, age: Int, phone: String? = nil) {
            self.id = id
            self.name = name
            self.age = age
            self.phone = phone
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case info
            case personal
            case name
            case age
            case phone
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            var secondLevel = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .info)
            var thirdLevel = secondLevel.nestedContainer(keyedBy: CodingKeys.self, forKey: .personal)
            try thirdLevel.encode(name, forKey: .name)
            try thirdLevel.encode(age, forKey: .age)
            try thirdLevel.encode(phone, forKey: .phone)
        }
    }
    
    func testKeyedNestedKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": 1,
            "info": [
                "personal": [
                    "name": "\"foo\"",
                    "age": 21,
                    "phone": "\"+380991111111\""
                ]
            ]
            
            
        ]
        
        let value = KeyedNestedKeyedContainer(id: 1, name: "foo", age: 21, phone: "+380991111111")
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class UnkeyedNestedKeyedContainer: Encodable {
        var id: String
        var first: String
        var second: String
        var third: String?
        var fourth: String?
        var fifth: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case numbers
        }
        
        init(id: String, first: String, second: String, third: String? = nil, fourth: String? = nil, fifth: String?) {
            self.id = id
            self.first = first
            self.second = second
            self.third = third
            self.fourth = fourth
            self.fifth = fifth
        }

                
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .numbers)
            
            try nestedContainer.encode(first)
            try nestedContainer.encode(fifth)
            var nestedContainer2 = nestedContainer.nestedUnkeyedContainer()
            try nestedContainer2.encode(second)
            let sequence = [third, fourth]
            try nestedContainer2.encode(contentsOf: sequence)
        }
    }
    
    func testUnkeyedNestedKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "id": "\"id\"",
            "numbers": [
                "\"first\"",
                [
                    "\"second\"",
                    nil,
                    "\"fourth\""
                ],
                nil]
        ]
        
        let value = UnkeyedNestedKeyedContainer(id: "id", first: "first", second: "second", third: nil, fourth: "fourth", fifth: nil)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class InheritanceBaseKeyedEntity: Encodable {
        var name: String
        var age: Int
        
        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case age
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(age, forKey: .age)
        }
    }
    
    class InheritanceDerivedKeyedEntity: InheritanceBaseKeyedEntity {
        var phone: String
        
        var isSuperViaKeyedContainer: Bool
        
        init(name: String, age: Int, phone: String, isSuperViaKeyedContainer: Bool) {
            self.phone = phone
            self.isSuperViaKeyedContainer = isSuperViaKeyedContainer
            super.init(name: name, age: age)
        }
        
        enum CodingKeys: String, CodingKey {
            case phone
            case parent
        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(phone, forKey: .phone)
            
            if isSuperViaKeyedContainer {
                try super.encode(to: container.superEncoder(forKey: .parent))
            } else {
                try super.encode(to: encoder)
            }
        }
    }
    
    func testInheritanceWithoutSuperEncoderKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "age": 21,
            "name": "\"name\"",
            "phone": "\"phone\""
        ]
        
        let value = InheritanceDerivedKeyedEntity(name: "name", age: 21, phone: "phone", isSuperViaKeyedContainer: false)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testInheritanceWithSuperKeyEncoderKeyedEncoding() throws {
        // Given
        let expectedResult: ContainerResult = [
            "parent": [
                "age": 21,
                "name": "\"name\""
            ],
            "phone": "\"phone\""
        ]
        
        let value = InheritanceDerivedKeyedEntity(name: "name", age: 21, phone: "phone", isSuperViaKeyedContainer: true)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    class InheritanceBaseSwitchableEntity: Encodable {
        var first: String
        var second: String
        
        var isBaseKeyedEncodable: Bool
        
        init(first: String, second: String, isBaseKeyedEncodable: Bool) {
            self.first = first
            self.second = second
            self.isBaseKeyedEncodable = isBaseKeyedEncodable
        }
        
        enum CodingKeys: String, CodingKey {
            case first
            case second
        }
                
        func encode(to encoder: Encoder) throws {
            if isBaseKeyedEncodable {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(first, forKey: .first)
                try container.encode(second, forKey: .second)
            } else {
                var container = encoder.unkeyedContainer()
                try container.encode(first)
                try container.encode(second)
            }
            

        }
    }
    
    class InheritanceDerivedSwitchableEntity: InheritanceBaseSwitchableEntity {
        var third: String
        
        var isDeriveKeyedEncodable: Bool
        
        init(first: String, second: String, isBaseKeyedEncodable: Bool, third: String, isDeriveKeyedEncodable: Bool) {
            self.third = third
            self.isDeriveKeyedEncodable = isDeriveKeyedEncodable
            super.init(first: first, second: second, isBaseKeyedEncodable: isBaseKeyedEncodable)
        }
        
        enum CodingKeys: String, CodingKey {
            case third
            case parent
        }
        
        override func encode(to encoder: Encoder) throws {
            if isDeriveKeyedEncodable {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(third, forKey: .third)
                try super.encode(to: container.superEncoder(forKey: .parent))
            } else {
                var container = encoder.unkeyedContainer()
                try container.encode(third)
                try super.encode(to: container.superEncoder())
            }
        }
    }
    
    func testInheritanceWithSuperKeyEncoderAndKeyedSwitchedContainerEncoding() throws {
        
        // Given
        let expectedResult: ContainerResult = [
            "third": "\"third\"",
            "parent": [
                "\"first\"",
                "\"second\""
            ]
        ]
        
        let value = InheritanceDerivedSwitchableEntity(first: "first", second: "second", isBaseKeyedEncodable: false, third: "third", isDeriveKeyedEncodable: true)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testInheritanceWithSuperKeyEncoderAndUnkeyedSwitchedContainerEncoding() throws {
        
        // Given
        let expectedResult: ContainerResult = [
            
            "\"third\"",
            [
                "first": "\"first\"",
                "second": "\"second\""
            ]
        ]
        
        let value = InheritanceDerivedSwitchableEntity(first: "first", second: "second", isBaseKeyedEncodable: true, third: "third", isDeriveKeyedEncodable: false)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    // MARK: Error states
    
    class EmptyEncodableEntity: Encodable {
        
        enum Strategy {
            case single
            case unkeyed
            case keyed
        }
        
        var strategy: Strategy?
        
        init(strategy: Strategy?) {
            self.strategy = strategy
        }
        
        enum CodingKeys: String, CodingKey {
            case stub
        }
        
        func encode(to encoder: Encoder) throws {
            switch strategy {
            case .single:
                _ = encoder.singleValueContainer()
                
            case .unkeyed:
                _ = encoder.unkeyedContainer()
                
            case .keyed:
                _ = encoder.container(keyedBy: CodingKeys.self)
                
            case .none:
                break
            }
        }
    }
    
    func testEmptySingleEncoding() throws {
        // Given
        let value = EmptyEncodableEntity(strategy: .single)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, .singleValue(nil))
    }
    
    func testEmptyUnkeyedEncoding() throws {
        // Given
        let value = EmptyEncodableEntity(strategy: .unkeyed)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, .unkeyed([]))
    }
    
    func testEmptyKeyedEncoding() throws {
        // Given
        let value = EmptyEncodableEntity(strategy: .keyed)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, .keyed([:]))
    }
    
    func testEmptyEncoding() throws {
        // Given
        let value = EmptyEncodableEntity(strategy: nil)
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertNil(sut.data.value)
    }
    
    func testStringWithQutesEncoding() throws {
        // Given
        let expectedResult: ContainerResult = "\"foo bar\""
        
        let value = String("foo bar")
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
    func testStringWithoutQutesEncoding() throws {
        // Given
        let expectedResult: ContainerResult = "foo bar"
        
        let value = StringWithoutQuotes("foo bar")
        
        // When
        try value.encode(to: sut)
        
        // Then
        XCTAssertEqual(sut.data.value, expectedResult)
    }
    
}

