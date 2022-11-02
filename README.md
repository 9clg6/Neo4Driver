
# Neo4Driver

![enter image description here](https://github.com/ClementG63/Neo4Driver/blob/main/screenshots/neo4dart_splash.png?raw=true)

Neo4Driver is a Dart driver for Neo4j. The library uses the Neo4J HTTP API database.

## Installation

Add Neo4Driver to your project's  `pubspec.yaml`  file and run `pub get`:

```yaml
dependencies:
  neo4driver:
    git: 
      url: https://github.com/milogrunge/Neo4Driver.git
      ref: main
```

## Usage
### Initialization :
```dart
NeoClient.withAuthorization(  
  username: '{database_username}',  
  password: '{database_password}',  
  databaseAddress: 'http://{database_address}:7474/', 
  databaseName: '{database_address}',   
);
```

### Usage post-initialization :
```dart
await NeoClient().createRelationship(  
  startNodeId: 1,  
  endNodeId: 2,  
  relationshipLabel: "rel_label",  
  properties: {
	  "Property1": "value1",
	  "Property2": 2,
  },  
);
```

### Features

 - findRelationshipById
 - findAllRelationship
 - findRelationshipWithStartNodeIdEndNodeId
 - findRelationshipWithNodeProperties
 - isRelationshipExistsBetweenTwoNodes
 - updateNodeById
 - updateRelationshipById
 - findAllNodesByProperties
 - findAllNodes
 - findNodeById
 - findAllNodesByLabel
 - getNodesWithHighestProperty
 - computeShortestPathDijkstra
 - computeDistanceBetweenTwoPoints
 - createGraphProjection
 - createRelationship
 - createRelationshipFromNodeToNodes
 - createNodeWithNode
 - createNode
 - deleteNodeById
 - deleteAllNode
