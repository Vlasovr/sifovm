#!/usr/bin/env python3
"""Export simple draw.io coursework diagrams to separate A3 PDF sheets.

The draw.io files generated for this project intentionally use a small subset of
diagrams.net XML: rectangular vertices and direct source-target edges. This
script keeps the export reproducible on macOS without requiring the draw.io
desktop CLI.
"""

from __future__ import annotations

import argparse
import math
import re
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from html import escape, unescape
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A3, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph


PROJECT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_DIR = PROJECT_DIR / "schemes"
DEFAULT_OUTPUT_DIR = DEFAULT_SOURCE_DIR / "pdf"

FONT_REGULAR = "CourseworkArial"
FONT_BOLD = "CourseworkArialBold"
FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial.ttf")
BOLD_FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")


@dataclass(frozen=True)
class Geometry:
    x: float
    y: float
    width: float
    height: float

    @property
    def center(self) -> tuple[float, float]:
        return self.x + self.width / 2, self.y + self.height / 2


@dataclass(frozen=True)
class Vertex:
    cell_id: str
    value: str
    style: dict[str, str]
    geometry: Geometry


@dataclass(frozen=True)
class Edge:
    cell_id: str
    value: str
    style: dict[str, str]
    source: str
    target: str


@dataclass(frozen=True)
class Diagram:
    page_width: float
    page_height: float
    vertices: list[Vertex]
    edges: list[Edge]


class PageTransform:
    def __init__(self, source_width: float, source_height: float) -> None:
        self.paper_width, self.paper_height = landscape(A3)
        margin = 24.0
        self.scale = min(
            (self.paper_width - 2 * margin) / source_width,
            (self.paper_height - 2 * margin) / source_height,
        )
        self.origin_x = (self.paper_width - source_width * self.scale) / 2
        self.origin_y = (self.paper_height - source_height * self.scale) / 2
        self.source_height = source_height

    def point(self, x: float, y: float) -> tuple[float, float]:
        return (
            self.origin_x + x * self.scale,
            self.origin_y + (self.source_height - y) * self.scale,
        )

    def rect(self, geom: Geometry) -> tuple[float, float, float, float]:
        left, bottom = self.point(geom.x, geom.y + geom.height)
        return left, bottom, geom.width * self.scale, geom.height * self.scale

    def length(self, value: float) -> float:
        return value * self.scale


def parse_style(style: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for part in style.split(";"):
        if not part:
            continue
        if "=" in part:
            key, value = part.split("=", 1)
            result[key] = value
        else:
            result[part] = "1"
    return result


def parse_drawio(path: Path) -> Diagram:
    root = ET.parse(path).getroot()
    graph = root.find(".//mxGraphModel")
    if graph is None:
        raise ValueError(f"No mxGraphModel in {path}")

    page_width = float(graph.attrib.get("pageWidth", "1600"))
    page_height = float(graph.attrib.get("pageHeight", "1100"))
    vertices: list[Vertex] = []
    edges: list[Edge] = []

    for cell in graph.findall(".//mxCell"):
        geom = cell.find("mxGeometry")
        if geom is None:
            continue

        style = parse_style(cell.attrib.get("style", ""))
        value = cell.attrib.get("value", "")
        if cell.attrib.get("vertex") == "1":
            vertices.append(
                Vertex(
                    cell_id=cell.attrib["id"],
                    value=value,
                    style=style,
                    geometry=Geometry(
                        x=float(geom.attrib.get("x", "0")),
                        y=float(geom.attrib.get("y", "0")),
                        width=float(geom.attrib.get("width", "0")),
                        height=float(geom.attrib.get("height", "0")),
                    ),
                )
            )
        elif cell.attrib.get("edge") == "1":
            edges.append(
                Edge(
                    cell_id=cell.attrib["id"],
                    value=value,
                    style=style,
                    source=cell.attrib["source"],
                    target=cell.attrib["target"],
                )
            )

    return Diagram(
        page_width=page_width,
        page_height=page_height,
        vertices=vertices,
        edges=edges,
    )


def register_fonts() -> None:
    if FONT_REGULAR not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_REGULAR, str(FONT_PATH)))
    if FONT_BOLD not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_BOLD, str(BOLD_FONT_PATH)))


def color_from_style(value: str | None, fallback: colors.Color) -> colors.Color:
    if not value or value == "none":
        return fallback
    return colors.HexColor(value)


def clean_label(value: str) -> str:
    text = unescape(value)
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>", "", text)
    return text.strip()


def draw_paragraph(
    c: canvas.Canvas,
    text: str,
    left: float,
    bottom: float,
    width: float,
    height: float,
    font_size: float,
    align: int,
    bold: bool = False,
) -> None:
    if not text:
        return

    escaped = "<br/>".join(escape(line) for line in text.splitlines())
    font_name = FONT_BOLD if bold else FONT_REGULAR
    padding = max(3.0, min(width, height) * 0.06)
    usable_width = max(4.0, width - 2 * padding)
    usable_height = max(4.0, height - 2 * padding)

    size = font_size
    while size >= 5.0:
        style = ParagraphStyle(
            name="diagram-label",
            fontName=font_name,
            fontSize=size,
            leading=size * 1.18,
            alignment=align,
            textColor=colors.HexColor("#222222"),
            splitLongWords=True,
            wordWrap="CJK",
        )
        paragraph = Paragraph(escaped, style)
        _, paragraph_height = paragraph.wrap(usable_width, usable_height)
        if paragraph_height <= usable_height or size <= 5.2:
            y = bottom + padding + max(0.0, (usable_height - paragraph_height) / 2)
            paragraph.drawOn(c, left + padding, y)
            return
        size -= 0.5


def draw_vertex(c: canvas.Canvas, vertex: Vertex, transform: PageTransform) -> None:
    left, bottom, width, height = transform.rect(vertex.geometry)
    fill_color = color_from_style(vertex.style.get("fillColor"), colors.white)
    stroke_color = color_from_style(vertex.style.get("strokeColor"), colors.black)
    stroke_width = float(vertex.style.get("strokeWidth", "1")) * transform.scale
    rounded = vertex.style.get("rounded") == "1"
    radius = min(width, height) * 0.08 if rounded else 0

    c.saveState()
    c.setStrokeColor(stroke_color)
    c.setLineWidth(max(0.75, stroke_width))
    if vertex.style.get("fillColor") == "none":
        c.setFillColor(colors.Color(1, 1, 1, alpha=0))
    else:
        c.setFillColor(fill_color)

    if rounded:
        c.roundRect(left, bottom, width, height, radius, stroke=1, fill=vertex.style.get("fillColor") != "none")
    else:
        c.rect(left, bottom, width, height, stroke=1, fill=vertex.style.get("fillColor") != "none")
    c.restoreState()

    align = TA_LEFT if vertex.style.get("align") == "left" else TA_CENTER
    font_size = float(vertex.style.get("fontSize", "14")) * transform.scale
    draw_paragraph(
        c,
        clean_label(vertex.value),
        left,
        bottom,
        width,
        height,
        font_size=max(7.0, font_size),
        align=align,
        bold=False,
    )


def edge_endpoint(source: Geometry, target: Geometry) -> tuple[float, float]:
    sx, sy = source.center
    tx, ty = target.center
    dx = tx - sx
    dy = ty - sy
    if dx == 0 and dy == 0:
        return sx, sy

    scale_x = (source.width / 2) / abs(dx) if dx else math.inf
    scale_y = (source.height / 2) / abs(dy) if dy else math.inf
    scale = min(scale_x, scale_y)
    return sx + dx * scale, sy + dy * scale


def edge_offsets(edges: list[Edge]) -> dict[str, float]:
    groups: dict[tuple[str, str], list[Edge]] = {}
    for edge in edges:
        key = tuple(sorted((edge.source, edge.target)))
        groups.setdefault(key, []).append(edge)

    offsets: dict[str, float] = {}
    for grouped_edges in groups.values():
        count = len(grouped_edges)
        if count == 1:
            offsets[grouped_edges[0].cell_id] = 0.0
            continue
        step = 18.0
        start = -step * (count - 1) / 2
        for index, edge in enumerate(grouped_edges):
            offsets[edge.cell_id] = start + index * step
    return offsets


def offset_points(
    start: tuple[float, float],
    end: tuple[float, float],
    offset: float,
) -> tuple[tuple[float, float], tuple[float, float]]:
    if offset == 0:
        return start, end
    sx, sy = start
    ex, ey = end
    dx = ex - sx
    dy = ey - sy
    length = math.hypot(dx, dy)
    if length == 0:
        return start, end
    nx = -dy / length
    ny = dx / length
    return (sx + nx * offset, sy + ny * offset), (ex + nx * offset, ey + ny * offset)


def draw_arrow(
    c: canvas.Canvas,
    start: tuple[float, float],
    end: tuple[float, float],
    color: colors.Color,
    width: float,
    dashed: bool,
) -> None:
    c.saveState()
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(width)
    if dashed:
        c.setDash(6, 4)

    c.line(start[0], start[1], end[0], end[1])
    c.setDash()

    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    arrow_len = max(8.0, 11.0 * width)
    arrow_width = arrow_len * 0.55
    p1 = end
    p2 = (
        end[0] - arrow_len * math.cos(angle) + arrow_width * math.sin(angle),
        end[1] - arrow_len * math.sin(angle) - arrow_width * math.cos(angle),
    )
    p3 = (
        end[0] - arrow_len * math.cos(angle) - arrow_width * math.sin(angle),
        end[1] - arrow_len * math.sin(angle) + arrow_width * math.cos(angle),
    )
    path = c.beginPath()
    path.moveTo(*p1)
    path.lineTo(*p2)
    path.lineTo(*p3)
    path.close()
    c.drawPath(path, stroke=0, fill=1)
    c.restoreState()


def draw_edge_label(
    c: canvas.Canvas,
    text: str,
    point: tuple[float, float],
    font_size: float,
) -> None:
    if not text:
        return

    label = clean_label(text)
    if not label:
        return

    max_width = 115.0
    style = ParagraphStyle(
        name="edge-label",
        fontName=FONT_REGULAR,
        fontSize=max(6.8, font_size),
        leading=max(7.8, font_size * 1.12),
        alignment=TA_CENTER,
        textColor=colors.HexColor("#222222"),
        splitLongWords=True,
        wordWrap="CJK",
    )
    paragraph = Paragraph(escape(label), style)
    width, height = paragraph.wrap(max_width, 36)
    box_width = width + 8
    box_height = height + 4
    left = point[0] - box_width / 2
    bottom = point[1] - box_height / 2

    c.saveState()
    c.setFillColor(colors.white)
    c.setStrokeColor(colors.HexColor("#e0e0e0"))
    c.setLineWidth(0.4)
    c.roundRect(left, bottom, box_width, box_height, 2.0, stroke=1, fill=1)
    c.restoreState()
    paragraph.drawOn(c, left + 4, bottom + 2)


def point_hits_label_zone(
    point: tuple[float, float],
    vertices: list[Vertex],
    label: str,
) -> bool:
    x, y = point
    half_width = min(120.0, max(44.0, len(label) * 3.8))
    half_height = 18.0 if len(label) <= 18 else 26.0

    for vertex in vertices:
        geom = vertex.geometry
        if vertex.style.get("fillColor") == "none":
            continue
        if not clean_label(vertex.value):
            continue

        if (
            x + half_width >= geom.x
            and x - half_width <= geom.x + geom.width
            and y + half_height >= geom.y
            and y - half_height <= geom.y + geom.height
        ):
            return True
    return False


def choose_label_point(
    start: tuple[float, float],
    end: tuple[float, float],
    vertices: list[Vertex],
    label: str,
) -> tuple[float, float] | None:
    if not clean_label(label):
        return None

    sx, sy = start
    ex, ey = end
    dx = ex - sx
    dy = ey - sy
    length = math.hypot(dx, dy)
    if length == 0:
        return None

    nx = -dy / length
    ny = dx / length
    candidates = [
        (0.50, 0.0),
        (0.35, 0.0),
        (0.65, 0.0),
        (0.50, 28.0),
        (0.50, -28.0),
        (0.30, 28.0),
        (0.70, -28.0),
        (0.25, 0.0),
        (0.75, 0.0),
    ]

    for t, normal_shift in candidates:
        point = (
            sx + dx * t + nx * normal_shift,
            sy + dy * t + ny * normal_shift,
        )
        if not point_hits_label_zone(point, vertices, label):
            return point
    return None


def draw_edge(
    c: canvas.Canvas,
    edge: Edge,
    vertices_by_id: dict[str, Vertex],
    vertices: list[Vertex],
    transform: PageTransform,
    offset: float,
) -> tuple[str, tuple[float, float] | None, float]:
    source = vertices_by_id[edge.source].geometry
    target = vertices_by_id[edge.target].geometry
    start = edge_endpoint(source, target)
    end = edge_endpoint(target, source)
    start, end = offset_points(start, end, offset)

    start_page = transform.point(*start)
    end_page = transform.point(*end)
    color = color_from_style(edge.style.get("strokeColor"), colors.HexColor("#43556b"))
    width = max(0.85, float(edge.style.get("strokeWidth", "2")) * transform.scale)
    dashed = edge.style.get("dashed") == "1"
    draw_arrow(c, start_page, end_page, color, width, dashed)

    label_point = choose_label_point(start, end, vertices, edge.value)
    page_label_point = transform.point(*label_point) if label_point is not None else None
    return edge.value, page_label_point, float(edge.style.get("fontSize", "12")) * transform.scale


def export_pdf(source: Path, target: Path) -> None:
    diagram = parse_drawio(source)
    register_fonts()
    transform = PageTransform(diagram.page_width, diagram.page_height)
    target.parent.mkdir(parents=True, exist_ok=True)

    pdf = canvas.Canvas(str(target), pagesize=landscape(A3))
    pdf.setTitle(source.stem)
    pdf.setAuthor("Codex")
    pdf.setSubject("SIFO VM coursework variant 4 diagram")

    vertices_by_id = {vertex.cell_id: vertex for vertex in diagram.vertices}
    offsets = edge_offsets(diagram.edges)

    frame_vertices = [
        vertex
        for vertex in diagram.vertices
        if vertex.style.get("fillColor") == "none" or not clean_label(vertex.value)
    ]
    content_vertices = [vertex for vertex in diagram.vertices if vertex not in frame_vertices]

    for vertex in frame_vertices:
        draw_vertex(pdf, vertex, transform)

    labels: list[tuple[str, tuple[float, float] | None, float]] = []
    for edge in diagram.edges:
        labels.append(draw_edge(pdf, edge, vertices_by_id, diagram.vertices, transform, offsets.get(edge.cell_id, 0.0)))

    for vertex in content_vertices:
        draw_vertex(pdf, vertex, transform)

    for text, point, font_size in labels:
        if point is not None:
            draw_edge_label(pdf, text, point, font_size)

    pdf.showPage()
    pdf.save()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source-dir",
        type=Path,
        default=DEFAULT_SOURCE_DIR,
        help="Directory with .drawio files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help="Directory for generated PDF files.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    drawio_files = sorted(args.source_dir.glob("A*.drawio"))
    if not drawio_files:
        raise SystemExit(f"No A*.drawio files found in {args.source_dir}")

    for source in drawio_files:
        target = args.output_dir / f"{source.stem}.pdf"
        export_pdf(source, target)
        print(target)


if __name__ == "__main__":
    main()
