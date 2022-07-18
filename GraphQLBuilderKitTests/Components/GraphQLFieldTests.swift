//
//  GraphQLFieldTests.swift
//  
//
//  Created by Дмитрий Пащенко on 21.04.2021.
//

@testable
import GraphQLBuilderKit
import XCTest

class GraphQLFieldTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testName() throws {
        let sut = GraphQLField(name: "foo")
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "foo")
    }
    
    func testAlias() throws {
        let sut = GraphQLField(name: "foo", alias: "bar")
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "bar:foo")
    }
    
    func testVariables() throws {
        let sut = GraphQLField(name: "foo", variables: [
            "first": .init(key: "first_var", value: "Does not matter", rawType: "Does not matter"),
            "second": .init(key: "second_var", value: "Does not matter", rawType: "Does not matter")
        ])
        
        let result = try sut.asGraphQLFieldString()
        
        // Then
        let firstIndex = result.index(after: try XCTUnwrap(result.firstIndex(of: "(")))
        let lastIndex = try XCTUnwrap(result.lastIndex(of: ")"))
    
        XCTAssertEqual(result[..<firstIndex], "foo(")
        XCTAssertEqual(result[lastIndex..<result.endIndex], ")")
    
        let variables = Set(result[firstIndex..<lastIndex].components(separatedBy: ","))
        XCTAssertEqual(variables, ["first:$first_var", "second:$second_var"])
    }
    
    func testArguments() throws {
        let nilValue: Int? = nil
        let sut = GraphQLField(name: "foo", arguments: [
            "optional": nilValue.wrapOrNull,
            "integer": 1,
            "double": 0.5,
            "bool": false,
            "string": "text",
            "object": [
                "string": "escape: \n \t \r \" \\"
            ].asEncodable
        ])
        
        let result = try sut.asGraphQLFieldString()

        // Then
        let firstIndex = result.index(after: try XCTUnwrap(result.firstIndex(of: "(")))
        let lastIndex = try XCTUnwrap(result.lastIndex(of: ")"))
    
        XCTAssertEqual(result[..<firstIndex], "foo(")
        XCTAssertEqual(result[lastIndex..<result.endIndex], ")")
    
        let arguments = Set(result[firstIndex..<lastIndex].components(separatedBy: ","))
        XCTAssertEqual(arguments, [
            "optional:null",
            "integer:1",
            "string:\"text\"",
            "double:0.5",
            "object:{string: \"escape: \\n \\t \\r \\\" \\\\\"}",
            "bool:false"
        ])
    }
    
    func testArgumentValuesEscaping() throws {
        let sut = GraphQLField(name: "foo", arguments: [
            "object": [
                "string": "escape: \n \t \r \" \\",
                "object": [
                    "string": "escape: \n \t \r \" \\"
                ].asEncodable
            ].asEncodable
        ])
        
        let result = try sut.asGraphQLFieldString()

        // Then
        let firstIndex = result.index(after: try XCTUnwrap(result.firstIndex(of: "(")))
        let lastIndex = try XCTUnwrap(result.lastIndex(of: ")"))
    
        XCTAssertEqual(result[..<firstIndex], "foo(")
        XCTAssertEqual(result[lastIndex..<result.endIndex], ")")
    
        
        let arguments = result[firstIndex..<lastIndex]
        XCTAssertTrue(arguments.contains("string: \"escape: \\n \\t \\r \\\" \\\\\""))
        XCTAssertTrue(arguments.contains("object: {string: \"escape: \\n \\t \\r \\\" \\\\\"}"))
    }
    
    func testArgumentValueWithoutQuotes() throws {
        let sut = GraphQLField(name: "foo", arguments: [
            "value": "string".withoutQuotes
        ])
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "foo(value:string)")
    }
    
    func testSubfields() throws {
        let sut = GraphQLField(name: "foo") {
            GraphQLField(name: "bar")
            GraphQLField(name: "baz") {
                GraphQLField(name: "bat")
            }
        }
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "foo{bar baz{bat}}")
    }
    
    func testFragments() throws {
        let fragment1 = GraphQLFragment(alias: "Fragment1", on: "Fragment") {
            GraphQLField("bar")
        }
        let fragment2 = GraphQLFragment(alias: "Fragment2", on: "Fragment") {
            GraphQLField("baz")
        }
        let sut = GraphQLField(name: "foo") {
            fragment1
            fragment2
        }
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "foo{...Fragment1 ...Fragment2}")
    }
    
    func testDebugStringSync() throws {
        let fragment = GraphQLFragment(alias: "Fragment", on: "Fragment") {
            GraphQLField(name: "foo")
        }
        let sut = GraphQLField(name: "bar", alias: "alias") {
            GraphQLField(name: "baz")
            GraphQLField(name: "bat") {
                GraphQLField(name: "any")
            }
            .with(arguments: ["arg1": "val1"])
        }
        .with(arguments: [
                "arg2": false,
                "arg3": [
                    "arg3": "\n \t \r \" \\",
                    "arg4": 123
                ].asEncodable
        ])
        .with(variables: ["var1": GraphQLVariable(key: "var1", value: "val3", rawType: "String")])
        .with(fields: [fragment])
     
        let result1 = try sut.asGraphQLFieldString()
            .preparedForCompare()
        let result2 = try sut.asPrettyGraphQLFieldString()
            .preparedForCompare()
        
        XCTAssertEqual(result1, result2)
    }
}

