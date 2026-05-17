from copy import deepcopy
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

from lxml import etree


DOCX = Path(r"D:\git\sifovm\LABS\student_labs_5_8\lab7_bus_arbiter\report\LR7_BUS_ARBITER_variant.docx")
W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
WP_NS = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"
NS = {"w": W_NS, "wp": WP_NS, "a": A_NS}


def qn(prefix, tag):
    return f"{{{NS[prefix]}}}{tag}"


def para_text(p):
    return "".join(p.xpath(".//w:t/text()", namespaces=NS)).strip()


def set_child_attr(parent, tag, attrs):
    node = parent.find(qn("w", tag))
    if node is None:
        node = etree.SubElement(parent, qn("w", tag))
    for key, value in attrs.items():
        node.set(qn("w", key), str(value))
    return node


def make_section(base, landscape=False, next_page=True):
    sect = deepcopy(base)
    for node in sect.xpath("./w:type", namespaces=NS):
        sect.remove(node)
    type_node = etree.Element(qn("w", "type"))
    type_node.set(qn("w", "val"), "nextPage" if next_page else "continuous")
    sect.insert(0, type_node)

    for node in sect.xpath("./w:pgSz", namespaces=NS):
        sect.remove(node)
    for node in sect.xpath("./w:pgMar", namespaces=NS):
        sect.remove(node)

    if landscape:
        set_child_attr(
            sect,
            "pgSz",
            {"w": 16838, "h": 11906, "orient": "landscape"},
        )
        set_child_attr(
            sect,
            "pgMar",
            {"top": 850, "right": 850, "bottom": 850, "left": 850, "header": 708, "footer": 708, "gutter": 0},
        )
    else:
        set_child_attr(sect, "pgSz", {"w": 11906, "h": 16838})
        set_child_attr(
            sect,
            "pgMar",
            {"top": 1134, "right": 850, "bottom": 1134, "left": 1701, "header": 708, "footer": 708, "gutter": 0},
        )
    return sect


def set_para_section(p, sect):
    ppr = p.find(qn("w", "pPr"))
    if ppr is None:
        ppr = etree.Element(qn("w", "pPr"))
        p.insert(0, ppr)
    for old in ppr.xpath("./w:sectPr", namespaces=NS):
        ppr.remove(old)
    ppr.append(sect)


def ensure_page_break(p):
    # Keep the paragraph blank but make it a forced page break.
    for child in list(p):
        if child.tag != qn("w", "pPr"):
            p.remove(child)
    run = etree.SubElement(p, qn("w", "r"))
    br = etree.SubElement(run, qn("w", "br"))
    br.set(qn("w", "type"), "page")


def clear_non_properties(p):
    for child in list(p):
        if child.tag != qn("w", "pPr"):
            p.remove(child)


def resize_picture_paragraph(p, width_cm):
    cx = int(width_cm / 2.54 * 914400)
    for extent in p.xpath(".//wp:extent", namespaces=NS):
        old_cx = int(extent.get("cx"))
        old_cy = int(extent.get("cy"))
        cy = int(old_cy * cx / old_cx)
        extent.set("cx", str(cx))
        extent.set("cy", str(cy))
    for ext in p.xpath(".//a:xfrm/a:ext", namespaces=NS):
        old_cx = int(ext.get("cx"))
        old_cy = int(ext.get("cy"))
        cy = int(old_cy * cx / old_cx)
        ext.set("cx", str(cx))
        ext.set("cy", str(cy))


def update_toc(doc_root, pages):
    mapping = {
        "1 Цель работы": f"1 Цель работы\t{pages['goal']}",
        "2 Исходные данные к работе": f"2 Исходные данные к работе\t{pages['input']}",
        "3 Теоретические сведения": f"3 Теоретические сведения\t{pages['theory']}",
        "4 Выполнение работы": f"4 Выполнение работы\t{pages['work']}",
        "5 Вывод": f"5 Вывод\t{pages['conclusion']}",
    }
    for p in doc_root.xpath(".//w:p", namespaces=NS):
        text = para_text(p)
        if "\t" not in text:
            continue
        for prefix, replacement in mapping.items():
            if text.startswith(prefix):
                runs = p.xpath("./w:r", namespaces=NS)
                if not runs:
                    runs = [etree.SubElement(p, qn("w", "r"))]
                texts = runs[0].xpath(".//w:t", namespaces=NS)
                if not texts:
                    texts = [etree.SubElement(runs[0], qn("w", "t"))]
                texts[0].text = replacement
                for r in runs[1:]:
                    for t in r.xpath(".//w:t", namespaces=NS):
                        t.text = ""
                break


def main():
    tmp = DOCX.with_suffix(".landscape_tmp.docx")
    with ZipFile(DOCX, "r") as zin:
        xml = zin.read("word/document.xml")
        files = {name: zin.read(name) for name in zin.namelist() if name != "word/document.xml"}

    root = etree.fromstring(xml)
    body = root.find(qn("w", "body"))
    paras = body.xpath("./w:p", namespaces=NS)
    final_sect = body.find(qn("w", "sectPr"))
    if final_sect is None:
        raise RuntimeError("No final section properties found")

    cap47 = next(i for i, p in enumerate(paras) if para_text(p).startswith("Рисунок 4.7"))
    cap48 = next(i for i, p in enumerate(paras) if para_text(p).startswith("Рисунок 4.8"))
    img47 = max(i for i in range(0, cap47) if paras[i].xpath(".//w:drawing", namespaces=NS))
    img48 = max(i for i in range(cap47 + 1, cap48) if paras[i].xpath(".//w:drawing", namespaces=NS))

    # Remove old section breaks from a previous run before placing the final ones.
    for p in paras:
        ppr = p.find(qn("w", "pPr"))
        if ppr is not None:
            for old in ppr.xpath("./w:sectPr", namespaces=NS):
                ppr.remove(old)

    # End the portrait section immediately before the first waveform picture.
    set_para_section(paras[img47 - 1], make_section(final_sect, landscape=False, next_page=True))
    # End the first landscape section after the first waveform caption.
    set_para_section(paras[cap47], make_section(final_sect, landscape=True, next_page=True))
    # The explanatory text between figures remains portrait; then the second waveform starts another landscape section.
    if img48 - 1 >= 0 and not para_text(paras[img48 - 1]):
        clear_non_properties(paras[img48 - 1])
        set_para_section(paras[img48 - 1], make_section(final_sect, landscape=False, next_page=True))
    else:
        raise RuntimeError("Expected a blank paragraph before the second waveform")
    # End the second landscape section after the second waveform caption and return to portrait.
    set_para_section(paras[cap48], make_section(final_sect, landscape=True, next_page=True))

    # Make each waveform large and readable on landscape pages.
    resize_picture_paragraph(paras[img47], 25.8)
    resize_picture_paragraph(paras[img48], 25.8)

    # Keep the document's final section portrait A4.
    portrait_final = make_section(final_sect, landscape=False, next_page=False)
    for old in body.xpath("./w:sectPr", namespaces=NS):
        body.remove(old)
    for type_node in portrait_final.xpath("./w:type", namespaces=NS):
        portrait_final.remove(type_node)
    body.append(portrait_final)

    with ZipFile(tmp, "w", ZIP_DEFLATED) as zout:
        for name, data in files.items():
            zout.writestr(name, data)
        zout.writestr("word/document.xml", etree.tostring(root, xml_declaration=True, encoding="UTF-8", standalone="yes"))
    tmp.replace(DOCX)
    print(f"patched {DOCX}")
    print(f"wave paragraphs: image47={img47}, caption47={cap47}, image48={img48}, caption48={cap48}")


if __name__ == "__main__":
    main()
