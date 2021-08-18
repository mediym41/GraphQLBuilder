//
//  main.swift
//  
//
//  Created by Дмитрий Пащенко on 11.10.2020.
//

import Foundation
import GraphQLBuilderKit

let variable = GraphQLVariable(key: "filters", value: ["is_new", "top_sale"])

let operation = GraphQLOperation(kind: .query, alias: "Products") {
    GraphQLField(name: "category_listing") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
        }
        GraphQLField(name: "banners") {
            GraphQLField(name: "id")
            GraphQLField(name: "caption", alias: "title")
            GraphQLField(name: "url_image")
                .with(arguments: ["size": 200])
        }
        GraphQLField(name: "products") {
            GraphQLField(name: "id")
            GraphQLField(name: "title")
            GraphQLField(name: "price")
            GraphQLField(name: "image")
                .with(arguments: ["size": 250])
        }
    }.with(variables: ["listing_filters": variable])
}.with(variables: [variable])

let graphQLQuery = try operation.asPrettyGraphQLBuilderString()
print("=== GraphQL Query === ")
print(graphQLQuery, "\n\n")

if let graphQLRequestData = try GraphQLBuilder.buildRequestData(operation: operation) {
    let string = String(data: graphQLRequestData, encoding: .utf8)!
    print("=== GraphQL Request ===")
    print(string)
}


