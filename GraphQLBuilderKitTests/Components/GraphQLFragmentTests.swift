//
//  GraphQLFragmentTests.swift
//
//
//  Created by Дмитрий Пащенко on 21.04.2021.
//

@testable
import GraphQLBuilderKit_v2
import XCTest

class GraphQLFragmentTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFragmentAsFieldString() throws {
        let expectedName = "foo"
        
        let sut = GraphQLFragment(alias: expectedName, on: "bar", fields: [
            GraphQLField(name: "first"),
            GraphQLField(name: "second") {
                GraphQLField(name: "third")
            }
        ])
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "...\(expectedName)")
    }
    
    func testFragmentAsBuiderString() throws {
        let sut = GraphQLFragment(alias: "foo", on: "bar", fieldsBlock: {
            GraphQLField(name: "first")
            GraphQLField(name: "second") {
                GraphQLField(name: "third")
                GraphQLFragment(alias: "subFoo", on: "subBar", fields: [
                    GraphQLField(name: "subFirst")
                ])
            }
        })
        
        let result = try sut.asGraphQLBuilderString()
        
        XCTAssertEqual(result, "fragment foo on bar {first second{third ...subFoo}}")
    }
    
    func testFragmentAsBuiderStringViaResultBuilder() throws {
        let sut = GraphQLFragment(alias: "foo", on: "bar", fieldsBlock: {
            GraphQLField(name: "first")
            GraphQLField(name: "second") {
                GraphQLField(name: "third")
                GraphQLFragment(alias: "subFoo", on: "subBar", fields: [
                    GraphQLField(name: "subFirst")
                ])
            }
        })
        
        let result = try sut.asGraphQLBuilderString()
        
        XCTAssertEqual(result, "fragment foo on bar {first second{third ...subFoo}}")
    }

    func testFragmentAsBuilderStringDebugAndReleaseEquation() throws {
        let sut = GraphQLFragment(alias: "foo", on: "bar", fieldsBlock: {
            GraphQLField(name: "first")
            GraphQLField(name: "second") {
                GraphQLField(name: "third")
                GraphQLFragment(alias: "subFoo", on: "subBar", fields: [
                    GraphQLField(name:"subFirst")
                ])
            }
        })
        
        let debugResult = try sut.asPrettyGraphQLBuilderString(level: 2, offset: 2)
        let releaseResult = try sut.asGraphQLBuilderString()
        
        XCTAssertNotEqual(debugResult, releaseResult)
        
        let filteredDebugResult = debugResult.preparedForCompare()
        let filteredReleaseResult = releaseResult.preparedForCompare()
            
        XCTAssertEqual(filteredDebugResult, filteredReleaseResult)
    }
    
    func testFragmentAsFieldStringDebugAndReleaseEquation() throws {
        let sut = GraphQLFragment(alias: "foo", on: "bar", fieldsBlock: {
            GraphQLField(name: "first")
            GraphQLField(name: "second") {
                GraphQLField(name: "third")
                GraphQLFragment(alias: "subFoo", on: "subBar", fields: [
                    GraphQLField(name: "subFirst")
                ])
            }
        })
        
        let debugResult = try sut.asPrettyGraphQLFieldString(level: 2, offset: 2)
        let releaseResult = try sut.asGraphQLFieldString()
        
        XCTAssertNotEqual(debugResult, releaseResult)
        
        let filteredDebugResult = debugResult.preparedForCompare()
        let filteredReleaseResult = releaseResult.preparedForCompare()
            
        XCTAssertEqual(filteredDebugResult, filteredReleaseResult)
    }
}

