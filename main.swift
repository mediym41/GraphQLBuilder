//
//  main.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 12.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

import Foundation

print("Hello, World!")
//
//struct Alias: GraphQLParameterValue {
//    var asGraphQLParameter: Any {
//        return key
//    }
//
//    let key: String
//}
//
//let aliases1: [Alias] = [Alias(key: "ververvv")]
//let aliases: [Int] = [12, 13, 14]
//let parameters:[BuilderQueryParameter] = [BuilderQueryParameter(queryKey: "category", value: 1, rawType: Int.typeDescription), BuilderQueryParameter(queryKey: "filters", value: aliases, rawType: Int.typeDescription), BuilderQueryParameter(queryKey: "filters1", value: aliases1, rawType: Int.typeDescription)]
//
//let parentFragment = GraphQLFragment(withAlias: "ParentFields", onName: "Category", fields: ["id", "caption"])
//
//let childRequest = GraphQLRequest(name: "parent", fields: [parentFragment])
//let parentRequest = GraphQLRequest(name: "parent", fields: [parentFragment, childRequest])
//
//let categoryRequest = GraphQLRequest(name: "category")
//    .with(fields: ["id", "caption"])
//    .with(subRequests: [parentRequest])
//
//let catalogRequest = GraphQLRequest(name: "catalog")
//    .with(parameters: parameters)
//    .with(fields: ["all_filters", "popular_filters", "possible_sorts", GraphQLFieldWithParameter(fieldName: "imageUrl", parameters: ["size": 640])])
//    .with(subRequests: [categoryRequest])
//let rootQuery = GraphQLQuery(withAlias: "FiltersIOS")
////    .with(parameters: parameters)
//    .with(requests: [catalogRequest])
//    .with(fragments: [parentFragment])
//
////print(rootQuery.build())
//
//let value = GraphQLQuery(type: .Query, alias: "FunctionBuilder") {
//    GraphQLRequest(name: "catalog") {
//        "id"
//        "caption"
//    }
//}

//print(value.build())
//
//do {
//    let query: String = try GraphQLBuilder.build(query: rootQuery)
//    debugPrint(query)
//} catch let error {
//    debugPrint(error)
//}


struct GetSubCategoriesByCategoryApiPayload {
    
    // MARK: - Initialization
    
    init(categoryId: String?, isSmart: Bool, categoryAlias: String?) {
        self.categoryId = categoryId.flatMap(Int.init)
        self.isSmart = isSmart
        self.categoryAlias = categoryAlias
    }

    // MARK: - Properties
    
    let categoryId: Int?
    let isSmart: Bool
    let categoryAlias: String?
    
    struct IOFilter: GraphQLParameterValue, GraphQLTypeDescription {
        var name: String
        var value: Bool
        
        var asGraphQLEncodableValue: Any {
            return [
                "name": name,
                "value": value,
                "meta_data": [
                    "fisrt": true,
                    "second": [
                        "name": "Dima",
                        "years": 21
                    ]
                ]
            ]
        }
    }
    
    
    var body: GraphQLOperation {
        let categoryVariable = categoryId.flatMap { value -> GraphQLVariable? in
            guard !isSmart else {
                return nil
            }
            
            return GraphQLVariable(key: "category", value: value, rawType: Int.self)
        }
        
        let smartcatVariable = categoryId.flatMap { value -> GraphQLVariable? in
            guard isSmart else {
                return nil
            }
            
            return GraphQLVariable(key: "smartcat", value: value, rawType: Int.self)
        }
        
        let aliasVariable = categoryAlias.map { GraphQLVariable(key: "category_alias", value: $0, rawType: String.self) }
        
        let filters: [IOFilter]? = [IOFilter(name: "new", value: true)]
        let filtersVariable = GraphQLVariable(key: "filters", value: filters, rawType: [IOFilter]?.self)
        
                
        let childrenFragment = GraphQLFragment(alias: "SmartcatBaseFields", on: "Smartcat") {
            GraphQLField(name: "id")
            GraphQLField(name: "url_image_640x640")
            GraphQLField(name: "caption")
        }
        
        return GraphQLOperation(kind: .query, alias: "CatalogIOS") {
            GraphQLField(name: "catalog") {
                GraphQLField(name: "applied_filters")
                            
                GraphQLField(name: "smartcat") {
                    GraphQLField(name: "id")
                    GraphQLField(name: "url_image_640x640")
                    GraphQLField(name: "caption")
                    
                    GraphQLField(name: "children_categories") {
                        GraphQLField(name: "id")
                        GraphQLField(name: "parents")
                        GraphQLField(name: "is_mobile_prohibited")
                        
                        GraphQLField(name: "children") {
                            childrenFragment
                        }
                        
                        GraphQLField(name: "children_smartcats") {
                            childrenFragment
                        }
                    }
                }
                
                GraphQLField(name: "children_smartcats") {
                    GraphQLField(name: "id")
                    GraphQLField(name: "url_image_640x640")
                    GraphQLField(name: "caption")
                    
                    GraphQLField(name: "children_categories") {
                        childrenFragment
                    }
                    GraphQLField(name: "children_smartcats") {
                        childrenFragment
                    }
                }
                
                GraphQLField(name: "custom_view") {
                    GraphQLField(name: "id")
                    GraphQLField(name: "jsonData")
                }
            }
            .with(variables: [categoryVariable, smartcatVariable, aliasVariable, filtersVariable])
            .with(arguments: ["offset": 10])
        }
        .with(variables: [categoryVariable, smartcatVariable, aliasVariable, filtersVariable])
        .with(fragments: [childrenFragment])
    }
}

var categoryId: Int? = 123
var isSmart: Bool = false
var categoryAlias: String? = "123"


let api = GetSubCategoriesByCategoryApiPayload(categoryId: "123", isSmart: true, categoryAlias: nil)

//print(api.body.asPrettyGraphQLBuilderString(offset: 4))
//print(try! GraphQLBuilder.build(operation: api.body))
//raphQLBuilder.build(operation: opeartion)
//
print(api.body.asPrettyGraphQLBuilderString(offset: 2))
//print(result)

let categoryVariable = categoryId.flatMap { value -> GraphQLVariable? in
    guard !isSmart else {
        return nil
    }
    
    return GraphQLVariable(key: "category", value: value, rawType: Int.self)
}

let smartcatVariable = categoryId.flatMap { value -> GraphQLVariable? in
    guard isSmart else {
        return nil
    }
    
    return GraphQLVariable(key: "smartcat", value: value, rawType: Int.self)
}

let aliasVariable = categoryAlias.map { GraphQLVariable(key: "category_alias", value: $0, rawType: String.self) }


let categoryRequest = GraphQLField(name: "category")
    .with(fields: ["id", "url_image_640x640", "caption", "parents"])
    .with(fields: [/* ... */])

let catalogRequest = GraphQLField(name: "catalog")
    .with(fields: ["applied_filters"])
    .with(variables: [categoryVariable, smartcatVariable, aliasVariable])

let operation = GraphQLOperation(kind: .query, alias: "CatalogIOS")
    .with(fields: [catalogRequest])
    .with(variables: [categoryVariable, smartcatVariable, aliasVariable])

print(operation.asPrettyGraphQLBuilderString())


//query CatalogIOS(
//  $category: Int,
//  $smartcat: Int,
//  $category_alias: String
//) {
//  catalog(
//    category: $category,
//    smartcat: $smartcat,
//    category_alias: $category_alias
//  ) {
//    applied_filters
//    category {
//      id
//      url_image_640x640
//      caption
//      parents
//      children {
//        id
//        caption
//        url_image_640x640
//        parents
//        is_mobile_prohibited
//        children {
//          id
//          caption
//          url_image_640x640
//        }
//        children_smartcats {
//          id
//          caption
//          url_image_640x640
//        }
//      }
//      children_smartcats {
//        id
//        url_image_640x640
//        caption
//        children_categories {
//          id
//          caption
//          url_image_640x640
//        }
//        children_smartcats {
//          id
//          caption
//          url_image_640x640
//        }
//      }
//    }
//  }
//}
//



