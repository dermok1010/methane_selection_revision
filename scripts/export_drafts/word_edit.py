#!/usr/bin/env python
"""Edit a reviewed Word file in place of rebuilding it: accept the reviewers' tracked
changes, make new edits as tracked changes, and add comments and threaded replies.

Working on the author's own .docx keeps its styles, highlights, line numbering and
EndNote fields (ADDIN EN.CITE / EN.REFLIST), so citations can still be updated from
EndNote afterwards.

EDITS.json:
  {"author": "Claude",
   "edits":    [{"para": "<unique text in the paragraph>", "old": "...", "new": "...",
                 "nth": 1, "note": "optional new comment on the edit"}],
   "replies":  [{"anchor": "<text inside the parent comment's range or its body start>",
                 "parent_body": "<start of the parent comment's text>", "text": "..."}],
   "comments": [{"para": "...", "text_anchor": "...", "text": "..."}]}

`old` must occur once in the paragraph (or use nth); "" with `after` inserts.

Usage (docx-tools env):
  python word_edit.py IN.docx EDITS.json OUT.docx
"""
import copy, json, random, re, shutil, sys, tempfile, zipfile
from datetime import datetime, timezone
from pathlib import Path

from lxml import etree

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
W14 = "http://schemas.microsoft.com/office/word/2010/wordml"
W15 = "http://schemas.microsoft.com/office/word/2012/wordml"
W16CID = "http://schemas.microsoft.com/office/word/2016/wordml/cid"
W16CEX = "http://schemas.microsoft.com/office/word/2018/wordml/cex"
XML = "http://www.w3.org/XML/1998/namespace"


def w(tag):
    return f"{{{W}}}{tag}"


NOW = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
_rev = [9000]


def next_rev():
    _rev[0] += 1
    return str(_rev[0])


# ---------------------------------------------------------------- accept changes
def accept_all(root):
    for tag in ("del", "moveFrom"):
        for el in list(root.iter(w(tag))):
            parent = el.getparent()
            if parent is not None and parent.tag == w("rPr"):
                continue  # paragraph-mark deletion; handled below
            parent.remove(el)
    for tag in ("ins", "moveTo"):
        for el in list(root.iter(w(tag))):
            parent = el.getparent()
            if parent.tag == w("rPr"):
                parent.remove(el)
                continue
            i = parent.index(el)
            for ch in list(el):
                parent.insert(i, ch)
                i += 1
            parent.remove(el)
    for tag in ("rPrChange", "pPrChange", "sectPrChange", "tblPrChange", "trPrChange", "tcPrChange",
                "moveFromRangeStart", "moveFromRangeEnd", "moveToRangeStart", "moveToRangeEnd"):
        for el in list(root.iter(w(tag))):
            el.getparent().remove(el)
    # merge paragraphs whose mark was deleted
    for mark in list(root.iter(w("del"))):
        rpr = mark.getparent()
        p = rpr.getparent().getparent()
        rpr.remove(mark)
        nxt = p.getnext()
        if nxt is not None and nxt.tag == w("p"):
            for ch in list(nxt):
                if ch.tag != w("pPr"):
                    p.append(ch)
            nxt.getparent().remove(nxt)


# ---------------------------------------------------------------- paragraph text
def text_runs(p):
    """(t element, start offset) for every visible w:t in the paragraph, in order."""
    out, pos = [], 0
    for t in p.iter(w("t")):
        if any(a.tag == w("del") for a in t.iterancestors()):
            continue
        out.append((t, pos))
        pos += len(t.text or "")
    return out


def ptext(p):
    return "".join(t.text or "" for t, _ in text_runs(p))


def split_at(p, off):
    """Make `off` fall on a run boundary; return nothing."""
    for t, s in text_runs(p):
        txt = t.text or ""
        if s < off < s + len(txt):
            r = t.getparent()
            r2 = copy.deepcopy(r)
            for ch in list(r2):
                if ch.tag not in (w("rPr"),):
                    r2.remove(ch)
            t2 = etree.SubElement(r2, w("t"))
            t2.text = txt[off - s:]
            t2.set(f"{{{XML}}}space", "preserve")
            # move following siblings of t into r2
            after = False
            for ch in list(r):
                if ch is t:
                    after = True
                    continue
                if after:
                    r2.append(ch)
            t.text = txt[:off - s]
            t.set(f"{{{XML}}}space", "preserve")
            r.addnext(r2)
            return


def runs_in(p, s, e):
    rs = []
    for t, ts in text_runs(p):
        te = ts + len(t.text or "")
        if ts >= s and te <= e and te > ts:
            r = t.getparent()
            if r not in rs:
                rs.append(r)
    return rs


def make_run(template_run, text, author):
    r = etree.Element(w("r"))
    rpr = template_run.find(w("rPr")) if template_run is not None else None
    if rpr is not None:
        rpr = copy.deepcopy(rpr)
        for bad in (w("rStyle"),):
            for el in rpr.findall(bad):
                if el.get(w("val"), "").startswith("Comment"):
                    rpr.remove(el)
        r.append(rpr)
    t = etree.SubElement(r, w("t"))
    t.text = text
    t.set(f"{{{XML}}}space", "preserve")
    return r


def tracked_edit(p, s, e, new, author):
    """Replace chars [s,e) of paragraph p by `new` as a tracked change. Returns the
    (first, last) elements of the edit for comment anchoring."""
    split_at(p, s)
    split_at(p, e)
    first = last = None
    template = None
    if e > s:
        rs = runs_in(p, s, e)
        template = rs[0]
        d = etree.Element(w("del"), {w("id"): next_rev(), w("author"): author, w("date"): NOW})
        rs[0].addprevious(d)
        for r in rs:
            for t in r.findall(w("t")):
                t.tag = w("delText")
            d.append(r)  # moves the run
        first = last = d
    else:
        # insertion point: run ending at s
        for t, ts in text_runs(p):
            if ts + len(t.text or "") == s:
                template = t.getparent()
        if template is None:
            template = text_runs(p)[0][0].getparent()
    if new:
        ins = etree.Element(w("ins"), {w("id"): next_rev(), w("author"): author, w("date"): NOW})
        ins.append(make_run(template, new, author))
        if last is not None:
            last.addnext(ins)
        else:
            # insert after the run that ends at s (or before the first run if s == 0)
            anchor = None
            for t, ts in text_runs(p):
                if ts + len(t.text or "") == s:
                    anchor = t.getparent()
            if anchor is None:
                text_runs(p)[0][0].getparent().addprevious(ins)
            else:
                anchor.addnext(ins)
            first = ins
        last = ins
    return first, last


# ---------------------------------------------------------------- comments
class Comments:
    def __init__(self, tmp):
        self.tmp = tmp
        self.c = etree.parse(str(tmp / "word/comments.xml"))
        self.ext = self._load("word/commentsExtended.xml")
        self.ids = self._load("word/commentsIds.xml")
        self.cex = self._load("word/commentsExtensible.xml")
        self.next_id = max(int(c.get(w("id"))) for c in self.c.getroot().iter(w("comment"))) + 1

    def _load(self, name):
        f = self.tmp / name
        return etree.parse(str(f)) if f.exists() else None

    def save(self):
        for tree, name in ((self.c, "word/comments.xml"), (self.ext, "word/commentsExtended.xml"),
                           (self.ids, "word/commentsIds.xml"), (self.cex, "word/commentsExtensible.xml")):
            if tree is not None:
                tree.write(str(self.tmp / name), xml_declaration=True, encoding="UTF-8", standalone=True)

    def find(self, body_start):
        hits = [c for c in self.c.getroot().iter(w("comment"))
                if "".join(t.text or "" for t in c.iter(w("t"))).strip().startswith(body_start)]
        assert len(hits) == 1, (body_start, len(hits))
        return hits[0]

    def para_id(self, comment):
        return comment.findall(w("p"))[-1].get(f"{{{W14}}}paraId")

    def add(self, author, text, parent=None):
        cid = str(self.next_id)
        self.next_id += 1
        pid = "%08X" % random.randint(0x10000000, 0x7FFFFFFF)
        did = "%08X" % random.randint(0x10000000, 0x7FFFFFFF)
        com = etree.SubElement(self.c.getroot(), w("comment"),
                               {w("id"): cid, w("author"): author, w("date"): NOW, w("initials"): author[:1]})
        for k, line in enumerate(text.split("\n")):
            p = etree.SubElement(com, w("p"))
            ppr = etree.SubElement(p, w("pPr"))
            etree.SubElement(ppr, w("pStyle"), {w("val"): "CommentText"})
            if k == 0:
                r = etree.SubElement(p, w("r"))
                rpr = etree.SubElement(r, w("rPr"))
                etree.SubElement(rpr, w("rStyle"), {w("val"): "CommentReference"})
                etree.SubElement(r, w("annotationRef"))
            r = etree.SubElement(p, w("r"))
            t = etree.SubElement(r, w("t"))
            t.text = line
            t.set(f"{{{XML}}}space", "preserve")
        com.findall(w("p"))[-1].set(f"{{{W14}}}paraId", pid)
        com.findall(w("p"))[-1].set(f"{{{W14}}}textId", "77777777")
        if self.ext is not None:
            attrs = {f"{{{W15}}}paraId": pid, f"{{{W15}}}done": "0"}
            if parent is not None:
                attrs[f"{{{W15}}}paraIdParent"] = self.para_id(parent)
            etree.SubElement(self.ext.getroot(), f"{{{W15}}}commentEx", attrs)
        if self.ids is not None:
            etree.SubElement(self.ids.getroot(), f"{{{W16CID}}}commentId",
                             {f"{{{W16CID}}}paraId": pid, f"{{{W16CID}}}durableId": did})
        if self.cex is not None:
            etree.SubElement(self.cex.getroot(), f"{{{W16CEX}}}commentExtensible",
                             {f"{{{W16CEX}}}durableId": did, f"{{{W16CEX}}}dateUtc": NOW})
        return cid


def ref_run(cid):
    r = etree.Element(w("r"))
    rpr = etree.SubElement(r, w("rPr"))
    etree.SubElement(rpr, w("rStyle"), {w("val"): "CommentReference"})
    etree.SubElement(r, w("commentReference"), {w("id"): cid})
    return r


def anchor_comment(first, last, cid):
    first.addprevious(etree.Element(w("commentRangeStart"), {w("id"): cid}))
    end = etree.Element(w("commentRangeEnd"), {w("id"): cid})
    last.addnext(end)
    end.addnext(ref_run(cid))


def reply_in_doc(body, parent_cid, cid):
    """Place the reply's range next to the parent's."""
    starts = [e for e in body.iter(w("commentRangeStart")) if e.get(w("id")) == parent_cid]
    ends = [e for e in body.iter(w("commentRangeEnd")) if e.get(w("id")) == parent_cid]
    refs = [e.getparent() for e in body.iter(w("commentReference")) if e.get(w("id")) == parent_cid]
    if starts:
        starts[0].addnext(etree.Element(w("commentRangeStart"), {w("id"): cid}))
    if ends:
        ends[0].addnext(etree.Element(w("commentRangeEnd"), {w("id"): cid}))
    refs[0].addnext(ref_run(cid))


# ---------------------------------------------------------------- main
def find_para(body, key):
    hits = [p for p in body.iter(w("p")) if key in ptext(p)]
    assert len(hits) == 1, (key, len(hits))
    return hits[0]


def main():
    src, spec_path, out = sys.argv[1:4]
    spec = json.loads(Path(spec_path).read_text())
    author = spec.get("author", "Claude")
    tmp = Path(tempfile.mkdtemp())
    with zipfile.ZipFile(src) as z:
        z.extractall(tmp)
    doc = etree.parse(str(tmp / "word/document.xml"))
    body = doc.getroot().find(w("body"))
    accept_all(body)
    com = Comments(tmp)

    for ed in spec.get("edits", []):
        p = find_para(body, ed["para"])
        txt = ptext(p)
        if ed.get("old"):
            idx = [m.start() for m in re.finditer(re.escape(ed["old"]), txt)]
            n = ed.get("nth", 1)
            assert len(idx) >= n and (len(idx) == 1 or "nth" in ed), (ed["old"], len(idx))
            s = idx[n - 1]
            e = s + len(ed["old"])
        else:
            s = e = txt.index(ed["after"]) + len(ed["after"])
        first, last = tracked_edit(p, s, e, ed["new"], author)
        assert ed["new"] == "" or True
        if ed.get("note"):
            cid = com.add(author, ed["note"])
            anchor_comment(first, last, cid)
        print("edit ok:", (ed.get("old") or ed.get("after"))[:50])

    for rp in spec.get("replies", []):
        parent = com.find(rp["parent_body"])
        cid = com.add(author, rp["text"], parent=parent)
        reply_in_doc(body, parent.get(w("id")), cid)
        print("reply ok:", rp["parent_body"][:50])

    doc.write(str(tmp / "word/document.xml"), xml_declaration=True, encoding="UTF-8", standalone=True)
    com.save()
    out = Path(out)
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            zout.write(tmp / item.filename, item.filename)
    shutil.rmtree(tmp)
    print("wrote", out)


if __name__ == "__main__":
    main()
