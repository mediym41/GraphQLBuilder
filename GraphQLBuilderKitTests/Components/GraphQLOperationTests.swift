//
//  GraphQLFieldTests.swift
//
//
//  Created by Дмитрий Пащенко on 21.04.2021.
//

@testable
import GraphQLBuilderKit_v2
import XCTest

class GraphQLOperationTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testQueryKind() throws {
        
        let sut = GraphQLOperation(kind: .query, alias: "foo")
        
        let result = try sut.asGraphQLBuilderString()
        
        XCTAssertEqual(result, "query foo{}")
    }
    
    func testMutationKind() throws {
        
        let sut = GraphQLOperation(kind: .mutation, alias: "foo")
        
        let result = try sut.asGraphQLBuilderString()
        
        XCTAssertEqual(result, "mutation foo{}")
    }
    
    func testNoneKind() throws {
        
        let sut = GraphQLOperation(kind: .none, alias: "foo")
        
        let result = try sut.asGraphQLBuilderString()
        
        XCTAssertEqual(result, "foo{}")
    }
    
    struct EncodableVariable: Encodable, GraphQLTypeDescription {
        var val1 = 12
        var dict = ["key": "value"]
    }
    
    func testFullOperationEncoding() throws {
        let variables = [
            GraphQLVariable(key: "key1", value: "value2", rawType: "String"),
            GraphQLVariable(key: "key2", value: EncodableVariable(), rawType: EncodableVariable.self)
        ]
        
        let fragment1 = GraphQLFragment(alias: "frag1", on: "Fragment1", fieldsBlock: {
            GraphQLField(name: "foo")
                .with(arguments: ["key": 200])
            GraphQLField(name: "bar")
        })
        
        let fragment2 = GraphQLFragment(alias: "frag2", on: "Fragment2", fieldsBlock: {
            GraphQLField("some_key")
            fragment1
        })
        
        
        let sut = GraphQLOperation(kind: .query, alias: "foo", variables: variables, fields: [
            GraphQLField(name: "root") {
                GraphQLField(name: "node1")
                    .with(arguments: ["arg1": "val1", "arg2": 2])
                GraphQLField(name: "node2")
                    .with(arguments: ["object": EncodableVariable()])
                fragment2
            },
            GraphQLField(name: "another_root") {
                fragment1
                GraphQLField(name: "node3")
            }
        ], fragments: [fragment1, fragment2])
        
        var result = try sut.asGraphQLBuilderString()
        
        let queryWithAlias = result.prefix(9)
        result = String(result.dropFirst(9))
        XCTAssertEqual(queryWithAlias, "query foo")
        
        guard let variablesIndexBeforeStart = result.firstIndex(of: "("),
              let variablesIndexEnd = result.firstIndex(of: ")")
        else {
            XCTFail("Not found variables")
            return
        }
        
        let variablesIndexStart = result.index(after: variablesIndexBeforeStart)
        
        let variablesString = result[variablesIndexStart ..< variablesIndexEnd]
            .components(separatedBy: ",")
        guard Set(variablesString) == Set(["$key1:String","$key2:EncodableVariable!"]) else {
            XCTFail("\(variablesString) not equal \(["$key1:String","$key2:EncodableVariable!"])")
            return
        }
        
        result = String(result[result.index(after: variablesIndexEnd)...])
        
        // root -> node1
        let rootNode1 = result.prefix(11)
        result = String(result.dropFirst(11))
        XCTAssertEqual(rootNode1, "{root{node1")
        
        // root -> node1 arguments
        guard let node1ArgumentsIndexBeforeStart = result.firstIndex(of: "("),
              let node1ArgumentsIndexEnd = result.firstIndex(of: ")")
        else {
            XCTFail("Not found node1 arguments")
            return
        }
        
        let node1ArgumentsIndexStart = result.index(after: node1ArgumentsIndexBeforeStart)
        
        let node1ArgumentsString = result[node1ArgumentsIndexStart ..< node1ArgumentsIndexEnd]
            .components(separatedBy: ",")
        guard Set(node1ArgumentsString) == Set(["arg2:2","arg1:\"val1\""]) else {
            XCTFail("\(node1ArgumentsString) not equal \(["arg2:2","arg1:\"val1\""])")
            return
        }
        
        result = String(result[result.index(after: node1ArgumentsIndexEnd)...])
            .trimmingCharacters(in: .whitespaces)
        
        // root -> node2
        let rootNode2 = result.prefix(5)
        result = String(result.dropFirst(5))
        XCTAssertEqual(rootNode2, "node2")
        
        // root -> node2 arguments
        guard let node2ArgumentsIndexBeforeStart = result.firstIndex(of: "("),
              let node2ArgumentsIndexEnd = result.firstIndex(of: ")")
        else {
            XCTFail("Not found node2 arguments")
            return
        }
        
        let node2ArgumentsIndexStart = result.index(after: node2ArgumentsIndexBeforeStart)
        
        var node2ArgumentsString = String(result[node2ArgumentsIndexStart ..< node2ArgumentsIndexEnd])
        
        let firstPartOfnode2ArgumentsString = node2ArgumentsString.prefix(8)
        node2ArgumentsString = String(node2ArgumentsString.dropFirst(8))
        XCTAssertEqual(firstPartOfnode2ArgumentsString, "object:{")
        
        let lastPartOfnode2ArgumentsString = node2ArgumentsString.suffix(1)
        node2ArgumentsString = String(node2ArgumentsString.dropLast(1))
        XCTAssertEqual(lastPartOfnode2ArgumentsString, "}")
        
        let node2ArgumentItems = node2ArgumentsString.components(separatedBy: ",")
            
        guard Set(node2ArgumentItems) == Set(["val1: 12","dict: {key: \"value\"}"]) else {
            XCTFail("\(node2ArgumentItems) not equal \(["val1: 12","dict: {key: \"value\"}"])")
            return
        }
        
        result = String(result[result.index(after: node2ArgumentsIndexEnd)...])
            .trimmingCharacters(in: .whitespaces)
        
        // static part

        XCTAssertEqual(result, "...frag2} another_root{...frag1 node3} ...frag1 ...frag2}fragment frag1 on Fragment1 {foo(key:200) bar} fragment frag2 on Fragment2 {some_key ...frag1}")
    }
    
}
