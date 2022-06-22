//
//  GraphQLInlineFragmentTests.swift
//  GraphQLBuilderKitTests
//
//  Created by Дмитрий Пащенко on 22.06.2022.
//

@testable
import GraphQLBuilderKit_v2
import XCTest

class GraphQLInlineFragmentTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInlineFragmentWithoutFieldsViaParams() throws {
        let sut = GraphQLInlineFragment(on: "foo", fields: [])
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "... on foo{}")
    }

    func testInlineFragmentWithFieldsViaParams() throws {
        let sut = GraphQLInlineFragment(on: "foo", fields: [
            GraphQLField(name: "field"),
            GraphQLFragment(alias: "FragmentAlias", on: "Node", fields: [
                GraphQLField(name: "fragment_field")
            ])
        ])
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "... on foo{field ...FragmentAlias}")
    }
    
    func testInlineFragmentWithFieldsViaResultBuilder() throws {
        let sut = GraphQLInlineFragment(on: "foo") {
            GraphQLField(name: "field")
            GraphQLFragment(alias: "FragmentAlias", on: "Node") {
                GraphQLField(name: "fragment_field")
            }
        }
        
        let result = try sut.asGraphQLFieldString()
        
        XCTAssertEqual(result, "... on foo{field ...FragmentAlias}")
    }
    
    func testDebugStringSync() throws {
        let sut = GraphQLInlineFragment(on: "foo") {
            GraphQLField(name: "field")
            GraphQLFragment(alias: "FragmentAlias", on: "Node") {
                GraphQLField(name: "fragment_field")
            }
        }
        
        let result1 = try sut.asGraphQLFieldString()
            .preparedForCompare()
        let result2 = try sut.asPrettyGraphQLFieldString()
            .preparedForCompare()
        
        XCTAssertEqual(result1, result2)
    }

}
