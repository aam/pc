import "dart:math";
import "dart:io";

class MinHeap {
  List<int> heap;
  int heapSize = 0;

  MinHeap(List<int> values) {
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
      if (heap[index] < heap[parent]) {
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
        var minson = min(heap[2 * index], heap[2 * index + 1]);
        var minsonIndex = heap[2 * index] == minson ? 2 * index : 2 * index + 1;
        if (heap[index] > minson) {
          swap(index, minsonIndex);
          index = minsonIndex;
        } else {
          break;
        }
      } else {
        // index has one child
        if (heap[index] > heap[2 * index]) {
          swap(index, 2 * index);
          index = 2 * index;
        } else {
          break;
        }
      }
    }
  }
}

class Node {
  int node;
  int minDistance;
  List<Edge> incoming;
  List<Edge> outgoing;
  
  Node(this.node);
  
  toString() => "$node";
}

class Edge {
  Node from;
  Node to;
  int weight;
  Edge(this.from, this.to, this.weight);
  
  toString() => "$from-($weight)->$to";
}

class Graph {
  var nodes = new List<Node>();
  var edges = new List<Edge>();
  var intToNode = {};

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

void main() {
  var f = new File("dijkstraData.txt");
  var lines = f.readAsLinesSync();
  var edges = [];
  var graph = new Graph();
  for (var line in lines) {
    var l = line.split("\t");
    var from = int.parse(l[0]);
    for (var to_weight in l.skip(1).where((s) => s.isNotEmpty)) {
      var s = to_weight.split(",").map((s) => int.parse(s)).toList();
      edges.add(new Edge(
          graph.getOrAddNode(from), 
          graph.getOrAddNode(s[0]),
          s[1]));
    }
  }
  print(edges);
  
  
  var S = List<Node>(); // nodes we found minimum path to
  var T = List<Node>(); // nodes not processed yet
  
  Node minNode = frontier.extractMin();
  S.add(minNode);
  
  // recalculate frontier
  frontier.removeAllLeadingTo(minNode);
  frontier.recalculateAllOutgoingFrom(minNode);
}
