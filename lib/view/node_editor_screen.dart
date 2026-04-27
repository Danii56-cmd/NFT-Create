// lib/view/node_editor_screen.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

const kOrange = Color(0xFFF5A623);
const kDark = Color(0xFF2A2A2A);
const kPanel = Color(0xFF1E1E1E);
const kWhite10 = Color(0x1AFFFFFF);
const kWhite20 = Color(0x33FFFFFF);
const kBlack50 = Color(0x80000000);

// ══════════════════════════════════════════════════════════════════════════════
// NODE TYPES
// ══════════════════════════════════════════════════════════════════════════════
enum NodeType {
  slider, // outputs a number
  colorPicker, // outputs a color
  gridPoints, // outputs a 2D grid of points
  waveDeform, // deforms points with sine wave
  radialDeform, // deforms points radially
  twistDeform, // rotates points by distance from centre
  noiseDeform, // random noise displacement
  connectLines, // connects adjacent points with lines
  meshFill, // fills triangles between points
  extrude, // adds 3D depth illusion
  colorMap, // maps height/position to color gradient
  output, // renders to canvas
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════
class NodePort {
  final String name;
  final bool isInput; // true = input, false = output
  Offset worldPos = Offset.zero; // updated during layout
  NodePort({required this.name, required this.isInput});
}

class NodeConnection {
  final String fromNodeId;
  final String fromPort;
  final String toNodeId;
  final String toPort;
  NodeConnection({
    required this.fromNodeId,
    required this.fromPort,
    required this.toNodeId,
    required this.toPort,
  });
}

class NodeData {
  final String id;
  final NodeType type;
  Offset position;
  Map<String, double> params; // slider values etc.
  Color color;
  bool selected;

  NodeData({
    required this.id,
    required this.type,
    required this.position,
    Map<String, double>? params,
    Color? color,
    this.selected = false,
  }) : params = params ?? {},
       color = color ?? Colors.tealAccent;

  String get title => switch (type) {
    NodeType.slider => 'Slider',
    NodeType.colorPicker => 'Color',
    NodeType.gridPoints => 'Grid',
    NodeType.waveDeform => 'Wave',
    NodeType.radialDeform => 'Radial',
    NodeType.twistDeform => 'Twist',
    NodeType.noiseDeform => 'Noise',
    NodeType.connectLines => 'Lines',
    NodeType.meshFill => 'Mesh Fill',
    NodeType.extrude => 'Extrude',
    NodeType.colorMap => 'Color Map',
    NodeType.output => 'Output',
  };

  Color get headerColor => switch (type) {
    NodeType.slider => const Color(0xFF4CAF50),
    NodeType.colorPicker => const Color(0xFFE91E63),
    NodeType.gridPoints => const Color(0xFF2196F3),
    NodeType.waveDeform => const Color(0xFF9C27B0),
    NodeType.radialDeform => const Color(0xFF9C27B0),
    NodeType.twistDeform => const Color(0xFF9C27B0),
    NodeType.noiseDeform => const Color(0xFF9C27B0),
    NodeType.connectLines => const Color(0xFFFF9800),
    NodeType.meshFill => const Color(0xFFFF9800),
    NodeType.extrude => const Color(0xFFFF9800),
    NodeType.colorMap => const Color(0xFFE91E63),
    NodeType.output => kOrange,
  };

  List<NodePort> get inputs => switch (type) {
    NodeType.slider => [],
    NodeType.colorPicker => [],
    NodeType.gridPoints => [
      NodePort(name: 'cols', isInput: true),
      NodePort(name: 'rows', isInput: true),
    ],
    NodeType.waveDeform => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'amp', isInput: true),
      NodePort(name: 'freq', isInput: true),
    ],
    NodeType.radialDeform => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'strength', isInput: true),
    ],
    NodeType.twistDeform => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'angle', isInput: true),
    ],
    NodeType.noiseDeform => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'scale', isInput: true),
    ],
    NodeType.connectLines => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'color', isInput: true),
    ],
    NodeType.meshFill => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'color', isInput: true),
    ],
    NodeType.extrude => [
      NodePort(name: 'points', isInput: true),
      NodePort(name: 'depth', isInput: true),
      NodePort(name: 'color', isInput: true),
    ],
    NodeType.colorMap => [NodePort(name: 'points', isInput: true)],
    NodeType.output => [NodePort(name: 'geometry', isInput: true)],
  };

  List<NodePort> get outputs => switch (type) {
    NodeType.slider => [NodePort(name: 'value', isInput: false)],
    NodeType.colorPicker => [NodePort(name: 'color', isInput: false)],
    NodeType.gridPoints => [NodePort(name: 'points', isInput: false)],
    NodeType.waveDeform => [NodePort(name: 'points', isInput: false)],
    NodeType.radialDeform => [NodePort(name: 'points', isInput: false)],
    NodeType.twistDeform => [NodePort(name: 'points', isInput: false)],
    NodeType.noiseDeform => [NodePort(name: 'points', isInput: false)],
    NodeType.connectLines => [NodePort(name: 'geometry', isInput: false)],
    NodeType.meshFill => [NodePort(name: 'geometry', isInput: false)],
    NodeType.extrude => [NodePort(name: 'geometry', isInput: false)],
    NodeType.colorMap => [NodePort(name: 'geometry', isInput: false)],
    NodeType.output => [],
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// GEOMETRY EVALUATOR
// ══════════════════════════════════════════════════════════════════════════════
class _EvalResult {
  final List<Offset> points;
  final int cols;
  final int rows;
  const _EvalResult(this.points, this.cols, this.rows);
}

class GraphEvaluator {
  final List<NodeData> nodes;
  final List<NodeConnection> connections;

  GraphEvaluator(this.nodes, this.connections);

  NodeData? _nodeById(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // Returns the value connected to an input port, or null
  dynamic _resolveInput(String nodeId, String portName) {
    final conn = connections
        .where((c) => c.toNodeId == nodeId && c.toPort == portName)
        .toList();
    if (conn.isEmpty) return null;
    final c = conn.first;
    final from = _nodeById(c.fromNodeId);
    if (from == null) return null;
    return _evalNode(from, c.fromPort);
  }

  dynamic _evalNode(NodeData n, String outputPort) {
    switch (n.type) {
      case NodeType.slider:
        return n.params['value'] ?? 5.0;

      case NodeType.colorPicker:
        return n.color;

      case NodeType.gridPoints:
        final cols =
            ((_resolveInput(n.id, 'cols') ?? n.params['cols'] ?? 8.0) as double)
                .round()
                .clamp(2, 30);
        final rows =
            ((_resolveInput(n.id, 'rows') ?? n.params['rows'] ?? 8.0) as double)
                .round()
                .clamp(2, 30);
        final pts = <Offset>[];
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            pts.add(Offset(c / (cols - 1), r / (rows - 1)));
          }
        }
        return _EvalResult(pts, cols, rows);

      case NodeType.waveDeform:
        final src = _resolveInput(n.id, 'points');
        if (src == null) return _EvalResult([], 0, 0);
        final er = src as _EvalResult;
        final amp =
            (_resolveInput(n.id, 'amp') ?? n.params['amp'] ?? 0.1) as double;
        final freq =
            (_resolveInput(n.id, 'freq') ?? n.params['freq'] ?? 3.0) as double;
        final pts = er.points
            .map(
              (p) => Offset(
                p.dx,
                p.dy + amp * math.sin(p.dx * freq * math.pi * 2),
              ),
            )
            .toList();
        return _EvalResult(pts, er.cols, er.rows);

      case NodeType.radialDeform:
        final src = _resolveInput(n.id, 'points');
        if (src == null) return _EvalResult([], 0, 0);
        final er = src as _EvalResult;
        final strength =
            (_resolveInput(n.id, 'strength') ?? n.params['strength'] ?? 0.2)
                as double;
        final pts = er.points.map((p) {
          final dx = p.dx - 0.5;
          final dy = p.dy - 0.5;
          final dist = math.sqrt(dx * dx + dy * dy);
          final push = strength * math.sin(dist * math.pi * 4);
          final ang = math.atan2(dy, dx);
          return Offset(
            p.dx + push * math.cos(ang),
            p.dy + push * math.sin(ang),
          );
        }).toList();
        return _EvalResult(pts, er.cols, er.rows);

      case NodeType.twistDeform:
        final src = _resolveInput(n.id, 'points');
        if (src == null) return _EvalResult([], 0, 0);
        final er = src as _EvalResult;
        final angle =
            (_resolveInput(n.id, 'angle') ?? n.params['angle'] ?? 1.0)
                as double;
        final pts = er.points.map((p) {
          final dx = p.dx - 0.5;
          final dy = p.dy - 0.5;
          final dist = math.sqrt(dx * dx + dy * dy);
          final rot = angle * dist;
          final cos = math.cos(rot);
          final sin = math.sin(rot);
          return Offset(0.5 + dx * cos - dy * sin, 0.5 + dx * sin + dy * cos);
        }).toList();
        return _EvalResult(pts, er.cols, er.rows);

      case NodeType.noiseDeform:
        final src = _resolveInput(n.id, 'points');
        if (src == null) return _EvalResult([], 0, 0);
        final er = src as _EvalResult;
        final scale =
            (_resolveInput(n.id, 'scale') ?? n.params['scale'] ?? 0.08)
                as double;
        final rng = math.Random(42);
        final pts = er.points
            .map(
              (p) => Offset(
                p.dx + (rng.nextDouble() - 0.5) * scale,
                p.dy + (rng.nextDouble() - 0.5) * scale,
              ),
            )
            .toList();
        return _EvalResult(pts, er.cols, er.rows);

      case NodeType.connectLines:
      case NodeType.meshFill:
      case NodeType.extrude:
      case NodeType.colorMap:
      case NodeType.output:
        // These are render nodes — return the evaluator + config
        return {'node': n, 'eval': this};
    }
  }

  // Final render — called by the Output node painter
  void render(Canvas canvas, Size size, NodeData outputNode) {
    final geomConn = connections
        .where((c) => c.toNodeId == outputNode.id && c.toPort == 'geometry')
        .toList();
    if (geomConn.isEmpty) return;

    final geomNode = _nodeById(geomConn.first.fromNodeId);
    if (geomNode == null) return;

    _renderNode(canvas, size, geomNode);
  }

  void _renderNode(Canvas canvas, Size size, NodeData n) {
    switch (n.type) {
      case NodeType.connectLines:
        _renderLines(canvas, size, n);
      case NodeType.meshFill:
        _renderMesh(canvas, size, n);
      case NodeType.extrude:
        _renderExtrude(canvas, size, n);
      case NodeType.colorMap:
        _renderColorMap(canvas, size, n);
      default:
        // Try rendering as lines if it's a deform node connected directly
        _renderLines(canvas, size, n);
    }
  }

  _EvalResult? _getPoints(String nodeId, String portName) {
    final v = _resolveInput(nodeId, portName);
    if (v is _EvalResult) return v;
    return null;
  }

  Color _getColor(String nodeId, String portName, Color fallback) {
    final v = _resolveInput(nodeId, portName);
    if (v is Color) return v;
    return fallback;
  }

  void _renderLines(Canvas canvas, Size size, NodeData n) {
    final er = _getPoints(n.id, 'points');
    if (er == null || er.cols == 0) return;
    final color = _getColor(n.id, 'color', Colors.cyanAccent);
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final pts = _toScreen(er.points, size);

    // Horizontal lines
    for (int r = 0; r < er.rows; r++) {
      for (int c = 0; c < er.cols - 1; c++) {
        final i = r * er.cols + c;
        if (i + 1 < pts.length) {
          canvas.drawLine(pts[i], pts[i + 1], paint);
        }
      }
    }
    // Vertical lines
    for (int r = 0; r < er.rows - 1; r++) {
      for (int c = 0; c < er.cols; c++) {
        final i = r * er.cols + c;
        if (i + er.cols < pts.length) {
          canvas.drawLine(pts[i], pts[i + er.cols], paint);
        }
      }
    }
  }

  void _renderMesh(Canvas canvas, Size size, NodeData n) {
    final er = _getPoints(n.id, 'points');
    if (er == null || er.cols == 0) return;
    final color = _getColor(n.id, 'color', Colors.deepPurpleAccent);
    final pts = _toScreen(er.points, size);

    for (int r = 0; r < er.rows - 1; r++) {
      for (int c = 0; c < er.cols - 1; c++) {
        final tl = r * er.cols + c;
        final tr = tl + 1;
        final bl = tl + er.cols;
        final br = bl + 1;
        if (br >= pts.length) continue;

        // Shade by row for 3D feel
        final shade = (r / er.rows);
        final fillColor = Color.lerp(
          color.withOpacity(0.3),
          color.withOpacity(0.7),
          shade,
        )!;

        final path = Path()
          ..moveTo(pts[tl].dx, pts[tl].dy)
          ..lineTo(pts[tr].dx, pts[tr].dy)
          ..lineTo(pts[br].dx, pts[br].dy)
          ..lineTo(pts[bl].dx, pts[bl].dy)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
    }
  }

  void _renderExtrude(Canvas canvas, Size size, NodeData n) {
    final er = _getPoints(n.id, 'points');
    if (er == null || er.cols == 0) return;
    final depth =
        (_resolveInput(n.id, 'depth') ?? n.params['depth'] ?? 0.05) as double;
    final color = _getColor(n.id, 'color', Colors.orangeAccent);
    final pts = _toScreen(er.points, size);

    final depthPx = depth * size.width;
    final off = Offset(depthPx * 0.6, -depthPx * 0.8);

    // Draw back layer
    final backPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int r = 0; r < er.rows; r++) {
      for (int c = 0; c < er.cols - 1; c++) {
        final i = r * er.cols + c;
        if (i + 1 < pts.length) {
          canvas.drawLine(pts[i] + off, pts[i + 1] + off, backPaint);
        }
      }
    }
    for (int r = 0; r < er.rows - 1; r++) {
      for (int c = 0; c < er.cols; c++) {
        final i = r * er.cols + c;
        if (i + er.cols < pts.length) {
          canvas.drawLine(pts[i] + off, pts[i + er.cols] + off, backPaint);
        }
      }
    }

    // Draw extrusion edges
    final edgePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (int r = 0; r < er.rows; r += (er.rows ~/ 5).clamp(1, 99)) {
      for (int c = 0; c < er.cols; c += (er.cols ~/ 5).clamp(1, 99)) {
        final i = r * er.cols + c;
        if (i < pts.length) {
          canvas.drawLine(pts[i], pts[i] + off, edgePaint);
        }
      }
    }

    // Draw front layer
    final frontPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int r = 0; r < er.rows; r++) {
      for (int c = 0; c < er.cols - 1; c++) {
        final i = r * er.cols + c;
        if (i + 1 < pts.length) canvas.drawLine(pts[i], pts[i + 1], frontPaint);
      }
    }
    for (int r = 0; r < er.rows - 1; r++) {
      for (int c = 0; c < er.cols; c++) {
        final i = r * er.cols + c;
        if (i + er.cols < pts.length) {
          canvas.drawLine(pts[i], pts[i + er.cols], frontPaint);
        }
      }
    }
  }

  void _renderColorMap(Canvas canvas, Size size, NodeData n) {
    final er = _getPoints(n.id, 'points');
    if (er == null || er.cols == 0) return;
    final pts = _toScreen(er.points, size);

    const colors = [
      Color(0xFF0D47A1),
      Color(0xFF00BCD4),
      Color(0xFF4CAF50),
      Color(0xFFFFEB3B),
      Color(0xFFFF5722),
    ];

    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int r = 0; r < er.rows - 1; r++) {
      for (int c = 0; c < er.cols - 1; c++) {
        final tl = r * er.cols + c;
        final tr = tl + 1;
        final bl = tl + er.cols;
        final br = bl + 1;
        if (br >= pts.length) continue;

        final t = r / (er.rows - 1);
        final colorIdx = (t * (colors.length - 1)).floor().clamp(
          0,
          colors.length - 2,
        );
        final lerp = t * (colors.length - 1) - colorIdx;
        final color = Color.lerp(colors[colorIdx], colors[colorIdx + 1], lerp)!;

        final path = Path()
          ..moveTo(pts[tl].dx, pts[tl].dy)
          ..lineTo(pts[tr].dx, pts[tr].dy)
          ..lineTo(pts[br].dx, pts[br].dy)
          ..lineTo(pts[bl].dx, pts[bl].dy)
          ..close();

        canvas.drawPath(
          path,
          Paint()
            ..color = color.withOpacity(0.6)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      }
    }

    // Dots at vertices
    for (int i = 0; i < pts.length; i++) {
      final t = i / pts.length;
      final ci = (t * (colors.length - 1)).floor().clamp(0, colors.length - 2);
      final l = t * (colors.length - 1) - ci;
      dotPaint.color = Color.lerp(colors[ci], colors[ci + 1], l)!;
      canvas.drawCircle(pts[i], 2, dotPaint);
    }
  }

  List<Offset> _toScreen(List<Offset> norm, Size size) {
    const pad = 40.0;
    return norm
        .map(
          (p) => Offset(
            pad + p.dx * (size.width - pad * 2),
            pad + p.dy * (size.height - pad * 2),
          ),
        )
        .toList();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAINTER
// ══════════════════════════════════════════════════════════════════════════════
class _PreviewPainter extends CustomPainter {
  final List<NodeData> nodes;
  final List<NodeConnection> connections;

  _PreviewPainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0A0A0A),
    );

    final outputNodes = nodes.where((n) => n.type == NodeType.output).toList();
    if (outputNodes.isEmpty) return;

    final eval = GraphEvaluator(nodes, connections);
    eval.render(canvas, size, outputNodes.first);
  }

  @override
  bool shouldRepaint(_PreviewPainter o) => true;
}

// ══════════════════════════════════════════════════════════════════════════════
// NODE EDITOR SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class NodeEditorScreen extends StatefulWidget {
  const NodeEditorScreen({super.key});
  @override
  State<NodeEditorScreen> createState() => _NodeEditorScreenState();
}

class _NodeEditorScreenState extends State<NodeEditorScreen> {
  final GlobalKey _previewKey = GlobalKey();

  final List<NodeData> _nodes = [];
  final List<NodeConnection> _connections = [];

  String? _connectingFromNode;
  String? _connectingFromPort;
  bool _connectingIsOutput = false;
  Offset _connectingPos = Offset.zero;
  Offset _cursorPos = Offset.zero;

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _buildDefaultGraph();
  }

  void _buildDefaultGraph() {
    // A default graph: Grid → Wave → Extrude → Output
    final grid = NodeData(
      id: 'grid1',
      type: NodeType.gridPoints,
      position: const Offset(40, 120),
      params: {'cols': 12.0, 'rows': 12.0},
    );
    final colsSlider = NodeData(
      id: 'slider_cols',
      type: NodeType.slider,
      position: const Offset(40, 40),
      params: {'value': 12.0},
    );
    final wave = NodeData(
      id: 'wave1',
      type: NodeType.waveDeform,
      position: const Offset(260, 100),
      params: {'amp': 0.12, 'freq': 3.0},
    );
    final ampSlider = NodeData(
      id: 'slider_amp',
      type: NodeType.slider,
      position: const Offset(260, 40),
      params: {'value': 0.12},
    );
    final color = NodeData(
      id: 'color1',
      type: NodeType.colorPicker,
      position: const Offset(480, 40),
      color: Colors.cyanAccent,
    );
    final extrude = NodeData(
      id: 'extrude1',
      type: NodeType.extrude,
      position: const Offset(480, 120),
      params: {'depth': 0.06},
    );
    final output = NodeData(
      id: 'output1',
      type: NodeType.output,
      position: const Offset(700, 160),
    );

    _nodes.addAll([colsSlider, grid, ampSlider, wave, color, extrude, output]);
    _connections.addAll([
      NodeConnection(
        fromNodeId: 'slider_cols',
        fromPort: 'value',
        toNodeId: 'grid1',
        toPort: 'cols',
      ),
      NodeConnection(
        fromNodeId: 'grid1',
        fromPort: 'points',
        toNodeId: 'wave1',
        toPort: 'points',
      ),
      NodeConnection(
        fromNodeId: 'slider_amp',
        fromPort: 'value',
        toNodeId: 'wave1',
        toPort: 'amp',
      ),
      NodeConnection(
        fromNodeId: 'wave1',
        fromPort: 'points',
        toNodeId: 'extrude1',
        toPort: 'points',
      ),
      NodeConnection(
        fromNodeId: 'color1',
        fromPort: 'color',
        toNodeId: 'extrude1',
        toPort: 'color',
      ),
      NodeConnection(
        fromNodeId: 'extrude1',
        fromPort: 'geometry',
        toNodeId: 'output1',
        toPort: 'geometry',
      ),
    ]);
  }

  // ── Add node menu ─────────────────────────────────────────────────────────
  void _showAddNodeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Node',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NodeType.values.map((t) {
                final dummy = NodeData(id: '', type: t, position: Offset.zero);
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _nodes.add(
                        NodeData(
                          id: '${t.name}_${DateTime.now().millisecondsSinceEpoch}',
                          type: t,
                          position: Offset(
                            100 + _nodes.length * 20.0,
                            100 + _nodes.length * 20.0,
                          ),
                          params: _defaultParams(t),
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: dummy.headerColor.withOpacity(0.2),
                      border: Border.all(color: dummy.headerColor, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dummy.title,
                      style: TextStyle(color: dummy.headerColor, fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _defaultParams(NodeType t) => switch (t) {
    NodeType.slider => {'value': 5.0},
    NodeType.gridPoints => {'cols': 10.0, 'rows': 10.0},
    NodeType.waveDeform => {'amp': 0.1, 'freq': 3.0},
    NodeType.radialDeform => {'strength': 0.2},
    NodeType.twistDeform => {'angle': 1.0},
    NodeType.noiseDeform => {'scale': 0.08},
    NodeType.extrude => {'depth': 0.06},
    _ => {},
  };

  // ── Save preview to gallery ───────────────────────────────────────────────
  Future<void> _saveToGallery() async {
    try {
      final boundary =
          _previewKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      await Gal.putImageBytes(
        bytes,
        name: 'node_nft_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kOrange,
            content: Text(
              'Saved to gallery!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      appBar: AppBar(
        backgroundColor: kPanel,
        title: const Text(
          'Node Editor',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showPreview ? Icons.edit : Icons.visibility,
              color: kOrange,
            ),
            tooltip: _showPreview ? 'Edit Graph' : 'Preview',
            onPressed: () => setState(() => _showPreview = !_showPreview),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: 'Save to Gallery',
            onPressed: _saveToGallery,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Node',
            onPressed: _showAddNodeMenu,
          ),
        ],
      ),
      body: _showPreview ? _buildPreview() : _buildEditor(),
    );
  }

  // ── PREVIEW ───────────────────────────────────────────────────────────────
  Widget _buildPreview() {
    return Center(
      child: RepaintBoundary(
        key: _previewKey,
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _PreviewPainter(nodes: _nodes, connections: _connections),
          ),
        ),
      ),
    );
  }

  // ── EDITOR ────────────────────────────────────────────────────────────────
  Widget _buildEditor() {
    return Stack(
      children: [
        // Grid background
        CustomPaint(painter: _GridBgPainter(), size: Size.infinite),

        // Connection wires being dragged
        if (_connectingFromNode != null)
          Listener(
            onPointerMove: (e) => setState(() => _cursorPos = e.localPosition),
            child: CustomPaint(
              painter: _WipePainter(from: _connectingPos, to: _cursorPos),
              size: Size.infinite,
            ),
          ),

        // Permanent connections
        CustomPaint(
          painter: _ConnectionsPainter(
            nodes: _nodes,
            connections: _connections,
          ),
          size: Size.infinite,
        ),

        // Nodes
        ..._nodes.map(
          (n) => _NodeWidget(
            node: n,
            onMove: (delta) => setState(() => n.position += delta),
            onDelete: () => setState(() {
              _nodes.remove(n);
              _connections.removeWhere(
                (c) => c.fromNodeId == n.id || c.toNodeId == n.id,
              );
            }),
            onParamChanged: (k, v) => setState(() => n.params[k] = v),
            onColorChanged: (c) => setState(() => n.color = c),
            onPortTap: (portName, isOutput, worldPos) {
              setState(() {
                if (_connectingFromNode == null) {
                  // Start connection
                  _connectingFromNode = n.id;
                  _connectingFromPort = portName;
                  _connectingIsOutput = isOutput;
                  _connectingPos = worldPos;
                  _cursorPos = worldPos;
                } else {
                  // Complete connection
                  if (_connectingIsOutput && !isOutput) {
                    _connections.removeWhere(
                      (c) => c.toNodeId == n.id && c.toPort == portName,
                    );
                    _connections.add(
                      NodeConnection(
                        fromNodeId: _connectingFromNode!,
                        fromPort: _connectingFromPort!,
                        toNodeId: n.id,
                        toPort: portName,
                      ),
                    );
                  } else if (!_connectingIsOutput && isOutput) {
                    _connections.removeWhere(
                      (c) =>
                          c.toNodeId == _connectingFromNode! &&
                          c.toPort == _connectingFromPort!,
                    );
                    _connections.add(
                      NodeConnection(
                        fromNodeId: n.id,
                        fromPort: portName,
                        toNodeId: _connectingFromNode!,
                        toPort: _connectingFromPort!,
                      ),
                    );
                  }
                  _connectingFromNode = null;
                  _connectingFromPort = null;
                }
              });
            },
          ),
        ),

        // Cancel connection on tap outside
        if (_connectingFromNode != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _connectingFromNode = null),
            ),
          ),

        // Mini preview bottom-right
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => setState(() => _showPreview = true),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: kOrange, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CustomPaint(
                  painter: _PreviewPainter(
                    nodes: _nodes,
                    connections: _connections,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NODE WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class _NodeWidget extends StatelessWidget {
  final NodeData node;
  final void Function(Offset delta) onMove;
  final VoidCallback onDelete;
  final void Function(String key, double val) onParamChanged;
  final void Function(Color) onColorChanged;
  final void Function(String portName, bool isOutput, Offset worldPos)
  onPortTap;

  const _NodeWidget({
    required this.node,
    required this.onMove,
    required this.onDelete,
    required this.onParamChanged,
    required this.onColorChanged,
    required this.onPortTap,
  });

  static const double _nodeWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => onMove(d.delta),
        child: Container(
          width: _nodeWidth,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border.all(
              color: node.selected ? kOrange : Colors.white24,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x88000000), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: node.headerColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(9),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        node.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Ports + params
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    // Inputs
                    ...node.inputs.map(
                      (port) => _PortRow(
                        port: port,
                        nodePos: node.position,
                        nodeWidth: _nodeWidth,
                        onTap: onPortTap,
                      ),
                    ),

                    // Params
                    ..._buildParams(),

                    // Outputs
                    ...node.outputs.map(
                      (port) => _PortRow(
                        port: port,
                        nodePos: node.position,
                        nodeWidth: _nodeWidth,
                        onTap: onPortTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParams() {
    final widgets = <Widget>[];

    if (node.type == NodeType.slider) {
      final v = node.params['value'] ?? 5.0;
      widgets.add(
        _ParamSlider(
          label: 'Value',
          value: v,
          min: 0,
          max: 30,
          onChanged: (nv) => onParamChanged('value', nv),
        ),
      );
    }

    if (node.type == NodeType.gridPoints) {
      widgets.add(
        _ParamSlider(
          label: 'Cols',
          value: node.params['cols'] ?? 8,
          min: 2,
          max: 25,
          onChanged: (v) => onParamChanged('cols', v),
        ),
      );
      widgets.add(
        _ParamSlider(
          label: 'Rows',
          value: node.params['rows'] ?? 8,
          min: 2,
          max: 25,
          onChanged: (v) => onParamChanged('rows', v),
        ),
      );
    }

    if (node.type == NodeType.waveDeform) {
      widgets.add(
        _ParamSlider(
          label: 'Amplitude',
          value: node.params['amp'] ?? 0.1,
          min: 0,
          max: 0.5,
          onChanged: (v) => onParamChanged('amp', v),
        ),
      );
      widgets.add(
        _ParamSlider(
          label: 'Frequency',
          value: node.params['freq'] ?? 3.0,
          min: 0.5,
          max: 10,
          onChanged: (v) => onParamChanged('freq', v),
        ),
      );
    }

    if (node.type == NodeType.radialDeform) {
      widgets.add(
        _ParamSlider(
          label: 'Strength',
          value: node.params['strength'] ?? 0.2,
          min: 0,
          max: 0.5,
          onChanged: (v) => onParamChanged('strength', v),
        ),
      );
    }

    if (node.type == NodeType.twistDeform) {
      widgets.add(
        _ParamSlider(
          label: 'Angle',
          value: node.params['angle'] ?? 1.0,
          min: 0,
          max: math.pi * 2,
          onChanged: (v) => onParamChanged('angle', v),
        ),
      );
    }

    if (node.type == NodeType.noiseDeform) {
      widgets.add(
        _ParamSlider(
          label: 'Scale',
          value: node.params['scale'] ?? 0.08,
          min: 0,
          max: 0.3,
          onChanged: (v) => onParamChanged('scale', v),
        ),
      );
    }

    if (node.type == NodeType.extrude) {
      widgets.add(
        _ParamSlider(
          label: 'Depth',
          value: node.params['depth'] ?? 0.06,
          min: 0,
          max: 0.2,
          onChanged: (v) => onParamChanged('depth', v),
        ),
      );
    }

    if (node.type == NodeType.colorPicker) {
      const presets = [
        Colors.cyanAccent,
        Colors.deepPurpleAccent,
        Colors.orangeAccent,
        Colors.pinkAccent,
        Colors.greenAccent,
        Colors.yellowAccent,
        Colors.redAccent,
        Colors.white,
      ];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: presets
                .map(
                  (c) => GestureDetector(
                    onTap: () => onColorChanged(c),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c == node.color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    return widgets;
  }
}

// ── Port row ──────────────────────────────────────────────────────────────────
class _PortRow extends StatelessWidget {
  final NodePort port;
  final Offset nodePos;
  final double nodeWidth;
  final void Function(String portName, bool isOutput, Offset worldPos) onTap;

  const _PortRow({
    required this.port,
    required this.nodePos,
    required this.nodeWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutput = !port.isInput;
    final dot = GestureDetector(
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox?;
        final world = box?.localToGlobal(d.localPosition) ?? Offset.zero;
        onTap(port.name, isOutput, world);
      },
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isOutput ? kOrange : Colors.cyanAccent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        children: isOutput
            ? [
                Expanded(
                  child: Text(
                    port.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 4),
                dot,
              ]
            : [
                dot,
                const SizedBox(width: 4),
                Text(
                  port.name,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
      ),
    );
  }
}

// ── Param slider ──────────────────────────────────────────────────────────────
class _ParamSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 2,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                activeColor: kOrange,
                inactiveColor: kWhite20,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ══════════════════════════════════════════════════════════════════════════════
class _GridBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F0F0F),
    );
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_GridBgPainter o) => false;
}

class _ConnectionsPainter extends CustomPainter {
  final List<NodeData> nodes;
  final List<NodeConnection> connections;
  _ConnectionsPainter({required this.nodes, required this.connections});

  NodeData? _node(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Offset _outputPortPos(NodeData n, String portName) {
    final idx = n.outputs.indexWhere((p) => p.name == portName);
    // Approximate position — header(~28) + inputs*(~22) + params*(~32) + output rows
    final inputCount = n.inputs.length;
    final paramHeight = _estimateParamHeight(n);
    final top =
        n.position.dy + 28 + inputCount * 22 + paramHeight + idx * 22 + 11;
    return Offset(n.position.dx + 200, top);
  }

  Offset _inputPortPos(NodeData n, String portName) {
    final idx = n.inputs.indexWhere((p) => p.name == portName);
    final top = n.position.dy + 28 + idx * 22 + 11;
    return Offset(n.position.dx, top);
  }

  double _estimateParamHeight(NodeData n) {
    switch (n.type) {
      case NodeType.gridPoints:
        return 64;
      case NodeType.waveDeform:
        return 64;
      case NodeType.colorPicker:
        return 52;
      case NodeType.slider:
        return 32;
      case NodeType.radialDeform:
      case NodeType.twistDeform:
      case NodeType.noiseDeform:
      case NodeType.extrude:
        return 32;
      default:
        return 0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final c in connections) {
      final from = _node(c.fromNodeId);
      final to = _node(c.toNodeId);
      if (from == null || to == null) continue;

      final start = _outputPortPos(from, c.fromPort);
      final end = _inputPortPos(to, c.toPort);
      final cp1 = Offset(start.dx + 60, start.dy);
      final cp2 = Offset(end.dx - 60, end.dy);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      paint.color = kOrange.withOpacity(0.7);
      canvas.drawPath(path, paint);

      // Dot at ends
      canvas.drawCircle(start, 4, Paint()..color = kOrange);
      canvas.drawCircle(end, 4, Paint()..color = Colors.cyanAccent);
    }
  }

  @override
  bool shouldRepaint(_ConnectionsPainter o) => true;
}

class _WipePainter extends CustomPainter {
  final Offset from, to;
  const _WipePainter({required this.from, required this.to});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOrange.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx + 60, from.dy, to.dx - 60, to.dy, to.dx, to.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WipePainter o) => o.from != from || o.to != to;
}
