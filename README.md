# GraphQLBuilder

GraphQLBuilder библиотека для построения GraphQL запросов в декларативном стиле, написанная на языке программирование Swift 5.4, c использованием result builders.

## Requirements
Для использования данной библиотеки требуется Xcode 12.5x или Swift 5.4x.

## Example

Прежде всего вам нужно описать GraphQL запрос, при помощи GraphQLOperation.

```swift
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
```

Чтоб закодировать полученную операцию в строку Вам нужно использовать метод asGraphQLBuilderString, а если вам нужна форматированная версия то asPrettyGraphQLBuilderString. Последний метод удобен для отладки Вашего запроса.

```swift
let graphQLQuery = try operation.asPrettyGraphQLBuilderString()
```
Полученный результат
```
query Products ($filters: [String!]!) {
  category_listing(listing_filters: $filters) {
    info {
      count
      pages
    }
    banners {
      id
      title: caption
      url_image(size: 200)
    }
    products {
      id
      title
      price
      image(size: 250)
    }
  }
} 

```

Если Вам нужно представить GraphQL операцию в формате JSON, как того требует спецификация, Вы можете использовать GraphQLBuilder, благодаря методам `static func buildRequestData(operation: GraphQLOperation) throws -> Data?` или же `static func buildRequestString(operation: GraphQLOperation) throws -> String?`, в зависимости что вам нужно.

```swift
let graphQLRequestData = try GraphQLBuilder.buildRequestData(operation: operation)
```

Полученный результат

```
{
  "variables": {
    "filters": [
      "is_new",
      "top_sale"
    ]
  },
  "operationName": "Products",
  "query": "query Products($filters:[String!]!){category_listing(listing_filters:$filters){info{count pages} banners{id title:caption url_image(size:200)} products{id title price image(size:250)}}}"
}
```

Многие методы помечены как `throws` и возвращают опционал, это нужно для гибкости и дальнейшего расширения системы. Как правило, ошибки никогда не бросаются и всегда есть возвращаемое значение.

## Installation

### Swift Package Manager
For projects using a `.xcodeproj` the best method is to navigate to `File > Swift Packages > Add Package Dependency...`. From there just simply enter `link` as the package repository url and use the master branch or the most recent version. Master will always be inline with the newest release. The other method is to simply add `.package(url: "n", from: "1.0.5")` to your `Package.swift` file's `dependencies`.

## Table of Contents
   * [Operations and Fields](#operations-and-fields)
   * [Arguments](#arguments)
        * [Optionals](#optionals)
   * [Alias](#alias)
   * [Fragments](#fragments)
   * [Operation Name](#operation-name)
   * [Variables](#variables)
   * [Directives](#directives)
   * [Mutations](#mutations)
   * [Custom Types](#custom-types)
        * [GraphQL Enums](#graphql-enums)
        * [GraphQLTypeDescription](#graphqltypedescription)

## Usage

GraphQLBuilder поддерживает основные возможности GraphQL. Писать GraphQL запросы лучше всего в декларативном стиле, в связи с тем, что такой код лучше читать и легче поддерживать. Большая часть системы базируется на функционале resultBuider добавленого в Swift 5.4.

### Operations and Fields
[GraphQL Operations](https://graphql.org/learn/queries/#fields) [GraphQL Fields](https://graphql.org/learn/queries/#fields) 

GraphQL is all about querying specific fields on objects and returning only what is needed. With GraphQLBuilder constructing objects with fields is a breeze.

##### Swift
```swift
GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
            GraphQLField(name: "next")
            GraphQLField(name: "prev")
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }
}
```

##### GraphQL Query
```graphql
query CharactersRequest {
  characters {
    info {
      count
      pages
      next
      prev
    }
    result {
      id
      name
      status
      type
    }
  }
}
```

### Arguments

[GraphQL Arguments](https://graphql.org/learn/queries/#arguments)

Arguments are a key part of GraphQL and allow for much more refined queries. GraphQLBuilder supports arguments on both objects and fields.

The only requirement is that the value for the argument conforms to `Encodable` protocol. Core types such as `String`, `Int`, `Bool` etc. will already conform. 

##### Swift
```swift
let charactersOperation = GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
            GraphQLField(name: "next")
            GraphQLField(name: "prev")
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }
    .with(variables: ["filter": filterVariable])
    .with(arguments: [
            "page": 2,
            "filters": [
                "status": "Alive",
                "gender": "Female"
            ]
    ])
}
```
##### GraphQL Query
```graphql
query CharactersRequest {
  characters(filter: $character_filter, page: 2, filters: {gender: "Female",status: "Alive"}) {
    info {
      count
      pages
      next
      prev
    }
    result {
      id
      name
      status
      type
    }
  }
}
```

Если Вы используете передачу параметров через аргументы и у Вас разные типы значений в литерале словаря, то компилятор Swift-а определить Ваш словарь как `[String: Any]`, по-этому стоит ему помочь вызвав вычисляемое свойство asEncodable. Все значения Вашего словаря должен реализовывать протокол Encodable.

```swift
// ...
.with(arguments: [
        "page": 2,
        "filters": [
            "status": "Alive",
            "gender": "Female",
            "meta": [
                "status": 1,
                "should_be_popular": true
            ].asEncodable
        ].asEncodable
])
```

#### Optionals

По-умолчанию опцональные значения аргументов со значением nil не будут вставляться в GraphQL запрос. Данный функционал добавлен в систему как конфиг в `GraphQLValueEncoder` и `CoreEncoder.Config`, если кому-то понадобиться такая надстройка - добавлю в следующей версии.

```swift
GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
            GraphQLField(name: "next")
            GraphQLField(name: "prev")
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }
    .with(arguments: [
            "page": 2,
            "filters": [
                "status": "Alive",
                "gender": "Female",
                "type": nil
            ]
    ])
}
```

##### GraphQL Query
```graphql
query CharactersRequest {
  characters(filter: $character_filter, page: 2, filters: {status: "Alive",gender: "Female"}) {
    info {
      count
      pages
      next
      prev
    }
    result {
      id
      name
      status
      type
    }
  }
}
```
### Alias

[GraphQL Alias](https://graphql.org/learn/queries/#aliases)

Aliases are key when querying a single object multiple times in the same request.

##### Swift
```swift
GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
            GraphQLField(name: "next", alias: "next_page")
            GraphQLField(name: "prev", alias: "prev_page")
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }
}
```

##### GraphQL Query

```graphql
query CharactersRequest {
  characters(page: 2) {
    info {
      count
      pages
      next_page: next
      prev_page: prev
    }
    result {
      id
      name
      status
      type
    }
  }
}
```

### Fragments

[GraphQL Fragments](https://graphql.org/learn/queries/#fragments)

GraphQL fragments can help when building complicated queries. GraphQLBuilder makes them extremely simple and allows the proper references to be placed exactly where they would be in the query. With the help of a `GraphQLFragment` can be added to the objects that require the fields and the `GraphQLFragment` can be added to the operation itself.

##### Swift
```swift
let episodeFragment = GraphQLFragment(alias: "BaseEpisode", on: "Episode") {
    GraphQLField(name: "id")
    GraphQLField(name: "name")
}

GraphQLOperation(kind: .query, alias: "Episodes") {
    GraphQLField(name: "episode") {
        episodeFragment
        GraphQLField(name: "characters") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "episode")
                .with(fragments: [characterFragment])
        }
    }.with(arguments: ["id": 1])
}.with(fragments: [episodeFragment])
```

##### GraphQL Query
```graphql
query Episodes {
  episode(id: 1) {
    characters {
      id
      name
      episode {
        ...BaseEpisode
      }
    }
    ...BaseEpisode
  }
}

fragment BaseEpisode on Episode {
    id
    name
}
```

### Operation Name

[GraphQL Operation Name](https://graphql.org/learn/queries/#operation-name)

Operation names aren't required but can make the queries more unique.

```swift
GraphQLOperation(kind: .query, alias: "Episode") {
    GraphQLField(name: "episode") {
        GraphQLField(name: "id")
        GraphQLField(name: "name")
    }
}
```

##### GraphQL Query
```graphql
query Episode {
  episode {
    id
    name
  }
}
```

### Variables

[GraphQL Variables](https://graphql.org/learn/queries/#variables)

Since direct JSON is not needed when making queries in SociableWeaver, variables can and should be define in a method and passed into the query as arguments.

##### Swift
```swift
struct FilterCharacter: Encodable, GraphQLTypeDescription {
    let name: String?
    let status: String?
    let species: String?
    let type: String?
    let gender: String?
}

let filterCharacterObject = FilterCharacter(name: nil,
                                            status: "Alive",
                                            species: nil,
                                            type: nil,
                                            gender: "Female")
let filterVariable = GraphQLVariable(key: "character_filter",
                                     value: filterCharacterObject,
                                     rawType: FilterCharacter.self)

let charactersOperation = GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        GraphQLField(name: "info") {
            GraphQLField(name: "count")
            GraphQLField(name: "pages")
            GraphQLField(name: "next")
            GraphQLField(name: "prev")
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }
    .with(variables: ["filter": filterVariable])
    .with(arguments: ["page": 2])
}.with(variables: [filterVariable])
```

##### GraphQL Query
```graphql
query CharactersRequest ($character_filter: FilterCharacter!) {
  characters(filter: $character_filter, page: 2) {
    info {
      count
      pages
      next
      prev
    }
    result {
      id
      name
      status
      type
    }
  }
}
```

Значение переменных будет получено при кодировании операции в JSON.

##### Swift
```swift 
let encodedOperation = try GraphQLBuilder.buildRequestString(operation: operation)
```
##### JSON
```graphql
{
  "operationName": "CharactersRequest",
  "query": "query CharactersRequest($character_filter:FilterCharacter!){characters(filter:$character_filter,page:2){info{count pages next prev} result{id name status type}}}",
  "variables": {
    "character_filter": {
      "status": "Alive",
      "gender": "Female"
    }
  }
}
```

### Directives

[GraphQL Directives](https://graphql.org/learn/queries/#directives)

Дерективы напрямую не добавлены в библиотеку, но их поведение можно легко воспроизвести через управление потоком в Swift

Directives in GraphQL allows the server to affect execution of the query. The two directives are `@include` and `@skip` both of which can be added to fields or included fragments. 

```swift
let includePaginationInfo = false

GraphQLOperation(kind: .query, alias: "CharactersRequest") {
    GraphQLField(name: "characters") {
        if includePaginationInfo {
            GraphQLField(name: "info") {
                GraphQLField(name: "count")
                GraphQLField(name: "pages")
                GraphQLField(name: "next", alias: "next_page")
                GraphQLField(name: "prev", alias: "prev_page")
            }
        }
        GraphQLField(name: "result") {
            GraphQLField(name: "id")
            GraphQLField(name: "name")
            GraphQLField(name: "status")
            GraphQLField(name: "type")
        }
    }.with(arguments: ["page": 2])
}
```

##### GraphQL Query
```graphql
query CharactersRequest {
  characters(page: 2) {
    result {
      id
      name
      status
      type
    }
  }
}
```

### Mutations

[GraphQL Mutations](https://graphql.org/learn/queries/#mutations)

Mutations work the same as simple queries and should be used when data is supposed to be written. An `Object.schemaName` will replace the name of the Object or Key included in the initializer. Для передачи значений Вы можете использовать как и аргументы

##### Swift
```swift
GraphQLOperation(kind: .mutation, alias: "Product") {
    GraphQLField(name: "create_product") {
        GraphQLField(name: "id")
        GraphQLField(name: "name")
        GraphQLField(name: "price")
    }.with(arguments: [
        "product": [
            "name": "Food",
            "price": 100
        ].asEncodable
    ])
}
```

##### GraphQL Mutation
```graphql
mutation Product {
  create_product(product: {price: 100,name: "Food"}) {
    id
    name
    price
  }
}
```

### Custom Types

SociableWeaver provides a couple of custom types that help to build more natural looking queries. These types may or may not have been included in examples but will also be defined in this section to provide more clarity.

#### GraphQL Enums

GraphQL перечисления передаются в виде строкового литерала без ковычек, для этого был создан специальный тип `StringWithoutQuotes` или же удобное вычилсяемое свойство для строк `withoutQuotes`, которое сконвертирует Вашу строку в `StringWithoutQuotes` 

##### Swift
```swift
GraphQLOperation(kind: .query, alias: "Enumeration") {
    GraphQLField(name: "products") {
        GraphQLField(name: "id")
    }.with(arguments: ["type": "ORDERED".withoutQuotes])
}
```

##### GraphQL Query

```graphql
query Enumeration {
  products(type: ORDERED) {
    id
  }
}
```

#### GraphQLTypeDescription

Переменные GraphQL требуют явного определения типа который будет передаваться в запросе, для большего удобства был добавлен специальный протокол `GraphQLTypeDescription`, он уже реализован для всех базовых типов свифта, и имеет дэфолтную реализацию. Он уже имеет базовую реализацию, и Вам ничего не нужно будет реализовывать для поддержки этой функциональности, достатчно лишь указать что Ваш тип реализует данный протокол. Для типов, реализующих протокол `GraphQLTypeDescription`, при создании `GraphQLVariable` не нужно будет явно указывать тип.

##### Swift 

```swift
struct MyType: Encodable, GraphQLTypeDescription {
    let id: Int
    let name: String
}

let value = MyType(id: 1, name: "name")
let variable = GraphQLVariable(key: "my_type", value: value, rawType: MyType?.self)

GraphQLOperation(kind: .mutation, alias: "Product") {
    GraphQLField(name: "create_product") {
        GraphQLField(name: "id")
        GraphQLField(name: "name")
        GraphQLField(name: "price")
    }.with(variables: ["my_var": variable])
}.with(variables: [variable])
```
##### GraphQL Query

```graphql
mutation Product ($my_type: MyType) {
  create_product(my_var: $my_type) {
    id
    name
    price
  }
}
```

## TODO List
- Добавить тесты в виде запросов на существующие GraphQL Api
- Добавить встроенную [пагинацию](https://graphql.org/learn/pagination/)
- Добавить поддержку [GraphQL Inline Fragments](https://graphql.org/learn/queries/#inline-fragments)
- Добавить поддержку [GraphQL Meta Fields](https://graphql.org/learn/queries/#meta-fields)

## License

GraphQLBuilder is released under the [MIT License](LICENSE).
