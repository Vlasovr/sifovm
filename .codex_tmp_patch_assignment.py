import os
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"

NAMESPACES = [
    ("wpc", "http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"),
    ("cx", "http://schemas.microsoft.com/office/drawing/2014/chartex"),
    ("cx1", "http://schemas.microsoft.com/office/drawing/2015/9/8/chartex"),
    ("cx2", "http://schemas.microsoft.com/office/drawing/2015/10/21/chartex"),
    ("cx3", "http://schemas.microsoft.com/office/drawing/2016/5/9/chartex"),
    ("cx4", "http://schemas.microsoft.com/office/drawing/2016/5/10/chartex"),
    ("cx5", "http://schemas.microsoft.com/office/drawing/2016/5/11/chartex"),
    ("cx6", "http://schemas.microsoft.com/office/drawing/2016/5/12/chartex"),
    ("cx7", "http://schemas.microsoft.com/office/drawing/2016/5/13/chartex"),
    ("cx8", "http://schemas.microsoft.com/office/drawing/2016/5/14/chartex"),
    ("mc", "http://schemas.openxmlformats.org/markup-compatibility/2006"),
    ("aink", "http://schemas.microsoft.com/office/drawing/2016/ink"),
    ("am3d", "http://schemas.microsoft.com/office/drawing/2017/model3d"),
    ("o", "urn:schemas-microsoft-com:office:office"),
    ("r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships"),
    ("m", "http://schemas.openxmlformats.org/officeDocument/2006/math"),
    ("v", "urn:schemas-microsoft-com:vml"),
    ("wp14", "http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"),
    ("wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"),
    ("w10", "urn:schemas-microsoft-com:office:word"),
    ("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
    ("w14", "http://schemas.microsoft.com/office/word/2010/wordml"),
    ("w15", "http://schemas.microsoft.com/office/word/2012/wordml"),
    ("w16cex", "http://schemas.microsoft.com/office/word/2018/wordml/cex"),
    ("w16cid", "http://schemas.microsoft.com/office/word/2016/wordml/cid"),
    ("w16", "http://schemas.microsoft.com/office/word/2018/wordml"),
    ("w16sdtdh", "http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash"),
    ("w16se", "http://schemas.microsoft.com/office/word/2015/wordml/symex"),
    ("wpg", "http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"),
    ("wpi", "http://schemas.microsoft.com/office/word/2010/wordprocessingInk"),
    ("wne", "http://schemas.microsoft.com/office/word/2006/wordml"),
    ("wps", "http://schemas.microsoft.com/office/word/2010/wordprocessingShape"),
]

for prefix, uri in NAMESPACES:
    try:
        ET.register_namespace(prefix, uri)
    except ValueError:
        pass


def text_nodes(paragraph):
    return list(paragraph.iter(W + "t"))


def visible_text(paragraph):
    parts = []
    for node in paragraph.iter():
        if node.tag == W + "t":
            parts.append(node.text or "")
        elif node.tag == W + "tab":
            parts.append("\t")
        elif node.tag == W + "br":
            parts.append("\n")
    return "".join(parts).strip()


def set_if(nodes, index, value):
    nodes[index].text = value


def main():
    src = Path(os.environ["INPUT_DOCX"])
    out_dir = Path.home() / "Documents"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "assignment_variant4_Migulin_DN.docx"

    with zipfile.ZipFile(src, "r") as zin:
        root = ET.fromstring(zin.read("word/document.xml"))
        paragraphs = list(root.iter(W + "p"))

        # 1-based paragraph numbers are from the original document text audit.
        set_if(text_nodes(paragraphs[15]), 4, "\u0414.\u041d.")

        nodes = text_nodes(paragraphs[21])
        nodes[1].text = nodes[1].text.replace("12", "16", 1)

        set_if(
            text_nodes(paragraphs[22]),
            1,
            " \u041f\u0430\u043c\u044f\u0442\u044c: \u041f\u0417\u0423 \u2013 "
            "\u0441\u0438\u043d\u0445\u0440\u043e\u043d\u043d\u043e\u0435, "
            "\u041e\u0417\u0423 \u2013 "
            "\u0441\u0438\u043d\u0445\u0440\u043e\u043d\u043d\u043e\u0435, "
            "\u0442\u0438\u043f \u0430\u0434\u0440\u0435\u0441\u0430\u0446\u0438\u0438 "
            "\u2013 \u043f\u0440\u044f\u043c\u043e-\u0440\u0435\u0433\u0438\u0441\u0442"
            "\u0440\u043e\u0432\u0430\u044f \u0438 \u043f\u0440\u044f\u043c\u0430\u044f; ",
        )

        nodes = text_nodes(paragraphs[23])
        nodes[1].text = nodes[1].text.replace("8", "12", 1)

        set_if(
            text_nodes(paragraphs[24]),
            5,
            "\u043f\u043e \u043d\u0430\u0438\u0431\u043e\u043b\u044c\u0448\u0435\u0439 "
            "\u0434\u0430\u0432\u043d\u043e\u0441\u0442\u0438 \u0445\u0440\u0430\u043d"
            "\u0435\u043d\u0438\u044f",
        )

        nodes = text_nodes(paragraphs[25])
        for node in nodes:
            if node.text == "NOT":
                node.text = "OR"
            elif node.text == "AND":
                node.text = "NOR"
            elif node.text == "SRL":
                node.text = "SRA"

        nodes = text_nodes(paragraphs[26])
        nodes[1].text = nodes[1].text.replace(
            "\u0446\u0435\u043d\u0442\u0440\u0430\u043b\u044c\u043d\u044b\u0439",
            "\u0446\u0435\u043d\u0442\u0440\u0430\u043b\u0438\u0437\u043e\u0432\u0430\u043d\u043d\u044b\u0439",
        )

        nodes = text_nodes(paragraphs[27])
        nodes[0].text = (
            "8. \u0421\u0445\u0435\u043c\u0430 \u043f\u0440\u0435\u0434\u0441\u043a"
            "\u0430\u0437\u0430\u043d\u0438\u044f \u043f\u0435\u0440\u0435\u0445\u043e"
            "\u0434\u043e\u0432: A4, \u0438\u043d\u0434\u0435\u043a\u0441 "
        )
        nodes[1].text = "PC(2) || GHR(2)"
        for node in nodes[2:4]:
            node.text = ""

        nodes = text_nodes(paragraphs[28])
        nodes[2].text = nodes[2].text.replace("5", "7", 1)

        nodes = text_nodes(paragraphs[29])
        nodes[0].text = nodes[0].text.replace("6", "10", 1).replace("8", "6", 1)

        updated_xml = ET.tostring(root, encoding="utf-8", xml_declaration=True)
        with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = updated_xml if item.filename == "word/document.xml" else zin.read(item.filename)
                zi = zipfile.ZipInfo(item.filename, date_time=item.date_time)
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = item.external_attr
                zout.writestr(zi, data)

    print(out)
    with zipfile.ZipFile(out, "r") as z:
        root = ET.fromstring(z.read("word/document.xml"))
    for p in root.iter(W + "p"):
        text = visible_text(p)
        if text.startswith(
            (
                "\u0421\u0442\u0443\u0434\u0435\u043d\u0442\u0443",
                "2. ",
                "3. ",
                "4. ",
                "5. ",
                "6. ",
                "7. ",
                "8. ",
                "9. ",
                "10. ",
            )
        ):
            print(text)


if __name__ == "__main__":
    main()
