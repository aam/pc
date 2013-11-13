import 'dart:collection';
import 'package:unittest/unittest.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
  
  bool operator==(Point p) => p != null && p.x == x && p.y == y;
  int get hashCode => (x + y) % 31;
  toString() => "($x, $y)";
}

class PointLine {
  Point p;
  Line l;
  PointLine(this.p, this.l);
  toString() => "$p on $l";
}

class Line {
  Point p1;
  Point p2;
  List<PointLine> adjacentLines;
  
  Line.fromPoints(this.p1, this.p2) {
    adjacentLines = [];
  }
  Line(int x1, int y1, int x2, int y2) {
    p1 = new Point(x1, y1);
    p2 = new Point(x2, y2);
    adjacentLines = [];
  }

  addAdjacent(PointLine pl) {
    adjacentLines.add(pl);
  }

  bool get isVertical => p1.x == p2.x;
  bool get isHorizontal => p1.y == p2.y;

  bool operator==(Line l) => 
      l != null && 
      (
          (l.p1 == p1 && l.p2 == p2) ||
          (l.p1 == p2 && l.p2 == p1)
      );
  int get hashCode => (p1.hashCode + p2.hashCode) % 31;
  
  toString() => "$p1-$p2";
}

class GraphEdge {
  GraphNode n1;
  GraphNode n2;
  GraphEdge(this.n1, this.n2);
  
  bool operator==(GraphEdge ge) =>
      ge != null && 
      (
          (n1 == ge.n1 && n2 == ge.n2) ||
          (n1 == ge.n2 && n2 == ge.n1)
      );
  int get hashCode => (n1.hashCode + n2.hashCode) % 31;
  toString() => "$n1<==>$n2";
}

class GraphNode {
  Point point;
  HashSet<GraphEdge> edges;
  int get degree => edges.length; 
  
  GraphNode(this.point) {
    edges = new HashSet<GraphEdge>();
  }
  
  bool operator==(GraphNode gn) => gn != null && gn.point == point;
  int get hashCode => point.hashCode;

  toString() => "{$point:$degree}";
  detailedToString() => toString() + edges.fold("", (s, edge) => "$s\n\t$edge");
}

class Graph {
  Set<GraphNode> nodes;
  Graph() {
    nodes = new HashSet<GraphNode>();
  }
  
  toString() => nodes.fold("", (s, node) => "$s $node");
}

DFS(GraphNode node, Graph graph) {
  graph.nodes.add(node);
  for (GraphEdge e in node.edges) {
    var otherNode = node == e.n1? e.n2: e.n1;
    if (!graph.nodes.contains(otherNode)) {
      DFS(otherNode, graph);
    }
  }
}

parse(var strings) {
  List<Line> lines = [];
  for(String s in strings) {
    var splitted = s.split(" ");
    var x1 = int.parse(splitted[0]);
    var y1 = int.parse(splitted[1]);
    var x2 = int.parse(splitted[2]);
    var y2 = int.parse(splitted[3]);
    
    if (x1 < x2 || (x1 == x2 && y1 < y2)) {
      lines.add(new Line(x1, y1, x2, y2));
    } else {
      lines.add(new Line(x2, y2, x1, y1));
    }
  }
  return lines;
}

void addEdge(GraphNode n1, GraphNode n2, HashSet<GraphEdge> edges) {
  if (n1 != n2) {
    GraphEdge ge = new GraphEdge(n1, n2);
    if (!n1.edges.contains(ge)) {
      n1.edges.add(ge);
      n2.edges.add(ge);
      edges.add(ge);
    }
  }
}

void removeEdge(GraphNode n1, GraphNode n2, HashSet<GraphEdge> edges) {
  GraphEdge ge = new GraphEdge(n1, n2);
  n1.edges.remove(ge);
  n2.edges.remove(ge);
  edges.remove(ge);
}

fixOverlapped(lines, newlines, int aggregationAxis(Point), int orderingAxis(Point)) {
  var rows = lines.fold(
      {},
      (Map<int, List<Line>> rs, line) {
        rs.putIfAbsent(aggregationAxis(line.p1), () => []);
        rs[aggregationAxis(line.p1)].add(line);
        return rs;
      });
//  print(rows);
  
  for (int rowNum in rows.keys) {
    List<PointLine> points = rows[rowNum].fold(
        [],
        (List<PointLine> list, Line l) =>
            list..add(new PointLine(l.p1, l))
                ..add(new PointLine(l.p2, l)));
    points.sort((pl1, pl2) => orderingAxis(pl1.p) - orderingAxis(pl2.p));
    
    Point farthest = null;
    for (PointLine pl in points) {
      if (orderingAxis(pl.p) == orderingAxis(pl.l.p2)) { // end of line
        if (farthest != null && orderingAxis(farthest) == orderingAxis(pl.p)) { // and farthest line so far
          farthest = null;
        } else { // start new line from here onwards
          newlines.last.p2 = pl.p;
          if (newlines.last.p2 == newlines.last.p1) {
            newlines.removeLast();
          }
          if (farthest != null) {
            newlines.add(new Line(pl.p.x, pl.p.y, farthest.x, farthest.y));
          }
        }
      } else { // beginning of line
        if (farthest != null) { // stop current line
          newlines.last.p2 = pl.p;
          if (newlines.last.p2 == newlines.last.p1) {
            newlines.removeLast();
          }
        }
        if (farthest == null || orderingAxis(pl.l.p2) > orderingAxis(farthest)) {
          farthest = pl.l.p2; // set farthest to the end of this line
        }
        newlines.add(new Line(pl.p.x, pl.p.y, farthest.x, farthest.y));
      }
    }
  }
  var nl = [];
  var processed = new HashSet<Line>();
  for (Line l in newlines) {
    if (!processed.contains(l)) {
      nl.add(l);
      processed.add(l);
    }
  }
  return nl;
}

penlifts(linesString, k) {
  var initiallines = parse(linesString);
  var lines = [];
  
  fixOverlapped(
      initiallines.where((line) => line.isHorizontal),
      lines,
      (Point p) => p.y,
      (Point p) => p.x
  );

  fixOverlapped(
      initiallines.where((line) => line.isVertical),
      lines,
      (Point p) => p.x,
      (Point p) => p.y
  );
  
  var points = [];
  for (Line line in lines) {
    points.add(new PointLine(line.p1, line));
    points.add(new PointLine(line.p2, line));
  }
  
  var horizontalLines = lines.where((line) => line.isHorizontal);
  var verticalLines = lines.where((line) => line.isVertical);
  
  for (Line hLine in horizontalLines) {
    for (Line vLine in verticalLines) {
      if (hLine.p1.x < vLine.p1.x && vLine.p1.x < hLine.p2.x) {
        if (hLine.p1.y == vLine.p1.y) {
          hLine.addAdjacent(new PointLine(vLine.p1, vLine));
        } else if (hLine.p1.y == vLine.p2.y) {
          hLine.addAdjacent(new PointLine(vLine.p2, vLine));
        }
      } else if (vLine.p1.y < hLine.p1.y && hLine.p1.y < vLine.p2.y) {
        if (vLine.p1.x == hLine.p1.x) {
          vLine.addAdjacent(new PointLine(hLine.p1, hLine));
        } else if (vLine.p1.x == hLine.p2.x) {
          vLine.addAdjacent(new PointLine(hLine.p2, hLine));
        }
      }
    }
  }
  
  var edges = new HashSet<GraphEdge>();
  var mapPointToGraphNode = new HashMap<Point, GraphNode>();
  for (Line l in lines) {
    mapPointToGraphNode.putIfAbsent(l.p1, () => new GraphNode(l.p1));
    mapPointToGraphNode.putIfAbsent(l.p2, () => new GraphNode(l.p2));
    GraphNode n1 = mapPointToGraphNode[l.p1];
    GraphNode n2 = mapPointToGraphNode[l.p2];
    addEdge(n1, n2, edges);
  }

  for (Line l in lines) {
    if (l.adjacentLines.isNotEmpty) {
      removeEdge(mapPointToGraphNode[l.p1], mapPointToGraphNode[l.p2], edges);
      Point previousPoint = l.p1;
      for (PointLine adjacent in l.adjacentLines) {
        addEdge(mapPointToGraphNode[previousPoint], mapPointToGraphNode[adjacent.p], edges);
        previousPoint = adjacent.p;
      }
      addEdge(mapPointToGraphNode[previousPoint], mapPointToGraphNode[l.p2], edges);
    }
  }
  
  var nodes = mapPointToGraphNode.values.toSet();
  var graphs = [];
  while (nodes.isNotEmpty) {
    var graph = new Graph();
    DFS(nodes.first, graph);
    nodes.removeAll(graph.nodes);
    graphs.add(graph);
  }
  var nLifts = graphs.length - 1;

  for (Graph graph in graphs) {
    var nodes = graph.nodes;
    var cntOddDegree = nodes.fold(0, (cntOddDegree, node) => cntOddDegree + ((node.degree*k).isOdd?1:0)); 
    var cntEvenDegree = nodes.fold(0, (cntEvenDegree, node) => cntEvenDegree + ((node.degree*k).isEven?1:0));
  
    if (cntOddDegree > 2) {
      nLifts += ((cntOddDegree - 2) / 2).ceil();
    }
  }
  return nLifts;
}

void main() {
  test('0', () =>
      expect(penlifts(["0 -10 0 5","0 -5 0 10"], 1), 0));

  test('0a', () =>
      expect(penlifts(["-10 0 5 0","-5 0 10 0"], 1), 0));

  test('0b', () =>
      expect(penlifts(["-5 0 5 0","-10 0 10 0"], 1), 0));
  
  test('1', () =>
      expect(penlifts(["-10 0 10 0","0 -10 0 10"], 1), 1));

  test('2', () =>
      expect(penlifts(["-10 0 0 0","0 0 10 0","0 -10 0 0","0 0 0 10"], 1), 1));

  test('3', () =>
      expect(penlifts(["-10 0 0 0","0 0 10 0","0 -10 0 0","0 0 0 10"], 4), 0));

  test('4', () =>
      expect(penlifts(["0 0 1 0",   "2 0 4 0",   "5 0 8 0",   "9 0 13 0",
                       "0 1 1 1",   "2 1 4 1",   "5 1 8 1",   "9 1 13 1",
                       "0 0 0 1",   "1 0 1 1",   "2 0 2 1",   "3 0 3 1",
                       "4 0 4 1",   "5 0 5 1",   "6 0 6 1",   "7 0 7 1",
                       "8 0 8 1",   "9 0 9 1",   "10 0 10 1", "11 0 11 1",
                       "12 0 12 1", "13 0 13 1"], 1), 6));
  test('5', () => 
      expect(penlifts([
        "-2 6 -2 1", /*a*/ "2 6 2 1" /*b*/,  "6 -2 1 -2" /*c*/,  "6 2 1 2" /*d*/,
        "-2 5 -2 -1",/*e*/ "2 5 2 -1"/*f*/, "5 -2 -1 -2"/*g*/, "5 2 -1 2" /*h*/,
        "-2 1 -2 -5",/*i*/ "2 1 2 -5"/*j*/, "1 -2 -5 -2"/*k*/, "1 2 -5 2" /*l*/,
        "-2 -1 -2 -6",/*m*/ "2 -1 2 -6"/*n*/,"-1 -2 -6 -2"/*o*/,"-1 2 -6 2"/*p*/], 5), 3));
  
  test('6', () =>
      expect(penlifts([
        "-252927 -1000000 -252927 549481","628981 580961 -971965 580961",
        "159038 -171934 159038 -420875","159038 923907 159038 418077",
        "1000000 1000000 -909294 1000000","1000000 -420875 1000000 66849",
        "1000000 -171934 628981 -171934","411096 66849 411096 -420875",
        "-1000000 -420875 -396104 -420875","1000000 1000000 159038 1000000",
        "411096 66849 411096 521448","-971965 580961 -909294 580961",
        "159038 66849 159038 -1000000","-971965 1000000 725240 1000000",
        "-396104 -420875 -396104 -171934","-909294 521448 628981 521448",
        "-909294 1000000 -909294 -1000000","628981 1000000 -909294 1000000",
        "628981 418077 -396104 418077","-971965 -420875 159038 -420875",
        "1000000 -1000000 -396104 -1000000","-971965 66849 159038 66849",
        "-909294 418077 1000000 418077","-909294 418077 411096 418077",
        "725240 521448 725240 418077","-252927 -1000000 -1000000 -1000000",
        "411096 549481 -1000000 549481","628981 -171934 628981 923907",
        "-1000000 66849 -1000000 521448","-396104 66849 -396104 1000000",
        "628981 -1000000 628981 521448","-971965 521448 -396104 521448",
        "-1000000 418077 1000000 418077","-1000000 521448 -252927 521448",
        "725240 -420875 725240 -1000000","-1000000 549481 -1000000 -420875",
        "159038 521448 -396104 521448","-1000000 521448 -252927 521448",
        "628981 580961 628981 549481","628981 -1000000 628981 521448",
        "1000000 66849 1000000 -171934","-396104 66849 159038 66849",
        "1000000 66849 -396104 66849","628981 1000000 628981 521448",
        "-252927 923907 -252927 580961","1000000 549481 -971965 549481",
        "-909294 66849 628981 66849","-252927 418077 628981 418077",
        "159038 -171934 -909294 -171934","-252927 549481 159038 549481"], 824759), 19));                       
}