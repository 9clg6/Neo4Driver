
# Neo4Dart

Neo4Dart is a Dart driver for Neo4j. 
The library uses the Neo4J REST API database. 

## Installation

Add Neo4Dart to your project's  `pubspec.yaml`  file and run `pub get`:

```yaml
dependencies:
  neo4dart:  
	  git:  
	    url: "https://github.com/ClementG63/Neo4Dart"  
		ref: main
```

## Usage
### Initialization :
```dart
NeoClient.withAuthorization(  
  username: '{database_username}',  
  password: '{database_password}',  
  databaseAddress: 'http://{database_address}:7474/',  
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
