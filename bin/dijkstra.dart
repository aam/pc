import "dart:math";
import "dart:io";

abstract class HeapElement {
  int get key;
}

class MinHeap<T extends HeapElement> {
  List<T> heap;
  int heapSize = 0;

  MinHeap(List<HeapElement> values) {
    heap = values;
    heapSize = values.length;
    heapify();
  }

  toString() => "${heap}";

  heapify() {
    for (var i = 0; i < heapSize; i++) {
      bubbleUp(i);
    }
  }

  bubbleUp(index) {
    while (index > 0) {
      var parent = index >> 1;
      if (heap[index].key < heap[parent].key) {
        swap(index, parent);
        index = parent;
      } else {
        break;
      }
    }
  }

  extractMin() => extractAt(0);

  extractAt(i) {
    var result = heap[i];
    heap[i] = heap[heapSize - 1];
    heapSize--;
    heap.removeLast();
    pushDown(0);
    return result;
  }

  swap(i, j) {
    var t = heap[i];
    heap[i] = heap[j];
    heap[j] = t;
  }

  pushDown(index) {
    if (heapSize < 2) {
      return;
    }
    while (2 * index < heapSize) { // has children
      if (2 * index + 1 < heapSize) {
        // index has two children
        var minson = min(heap[2 * index].key, heap[2 * index + 1].key);
        var minsonIndex = heap[2 * index] == minson ? 2 * index : 2 * index + 1;
        if (heap[index].key > minson.key) {
          swap(index, minsonIndex);
          index = minsonIndex;
        } else {
          break;
        }
      } else {
        // index has one child
        if (heap[index].key > heap[2 * index].key) {
          swap(index, 2 * index);
          index = 2 * index;
        } else {
          break;
        }
      }
    }
  }
}

class Node extends HeapElement {
  int node;
  int minDistance = 1000000;
  get key => minDistance;
  var incoming = new List<Edge>();
  var outgoing = new List<Edge>();
  
  Node(this.node);
  
  toString() => "$node($minDistance)";
}

class Edge {
  Node from;
  Node to;
  int weight;
  Edge(this.from, this.to, this.weight) {
    from.outgoing.add(this);
    to.incoming.add(this);
  }
  
  toString() => "$from-($weight)->$to";
}

class Graph {
  var nodes = new List<Node>();
  var edges = new List<Edge>();
  var intToNode = {};

  Graph(String filename) {
    var f = new File(filename);
    var lines = f.readAsLinesSync();
    edges = [];
    for (var line in lines) {
      var l = line.split("\t");
      var from = int.parse(l[0]);
      for (var to_weight in l.skip(1).where((s) => s.isNotEmpty)) {
        var s = to_weight.split(",").map((s) => int.parse(s)).toList();
        edges.add(new Edge(
            getOrAddNode(from), 
            getOrAddNode(s[0]),
            s[1]));
      }
    }
    print(edges);
  }
  
  toString() => "$nodes";
  
  getOrAddNode(n) {
    if (intToNode.containsKey(n)) {
      return intToNode[n];
    } else {
      var node = new Node(n);
      nodes.add(node);
      intToNode[n] = node;
      return node;
    }
  }
}

var X = new Set<Node>(); // nodes we found minimum path to
var frontier = new Set<Node>();

addToX(Node n) {
  X.add(n);
  frontier.remove(n);
  for(Edge outgoing in n.outgoing) {
    if (!X.contains(outgoing.to)) {
      if (n.minDistance + outgoing.weight < outgoing.to.minDistance) {
        outgoing.to.minDistance = n.minDistance + outgoing.weight;
      }
      frontier.add(outgoing.to);
    }
  }
}

void main() {
  var graph = new Graph("dijkstraData.txt");
  
  var start = graph.getOrAddNode(1);
  start.minDistance = 0;
  addToX(start);

  while (X.length < graph.nodes.length) {
    print("X=$X");
    print("frontier=$frontier");
    print(graph);
    Node minNode = null;
    for (Node n in frontier) {
      if (minNode == null || n.minDistance < minNode.minDistance) {
        minNode = n;
      }
    }
    print("got $minNode");
    addToX(minNode);
  }
  print(graph);
  
  var result = [7,37,59,82,99,115,133,165,188,197].map((x) =>
    graph.intToNode[x].minDistance).join(",");
  print(result);
}
