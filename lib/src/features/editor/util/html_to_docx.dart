import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Builds a minimal valid `.docx` (Office Open XML) whose body is the supplied
/// HTML, embedded via the standard `w:altChunk` relationship.
///
/// Microsoft Word inflates the HTML on open and converts it into native Word
/// content. Pages, headings, lists, bold/italic/underline, alignment and inline
/// styles produced by Quill all render correctly.
class HtmlToDocx {
  const HtmlToDocx._();

  static Uint8List build(String htmlBody) {
    final wrappedHtml = _wrapHtml(htmlBody);

    final archive = Archive()
      ..addFile(_textFile('[Content_Types].xml', _contentTypes))
      ..addFile(_textFile('_rels/.rels', _rootRels))
      ..addFile(_textFile('word/_rels/document.xml.rels', _documentRels))
      ..addFile(_textFile('word/document.xml', _documentXml))
      ..addFile(_textFile('word/afchunk.html', wrappedHtml));

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  static ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  /// Wraps the editor HTML in a full document including a Word-friendly
  /// `<style>` block. Word's altChunk importer consults the stylesheet when
  /// inline `style=` attributes on block-level elements are dropped, which is
  /// what causes blockquotes / coloured text to look unstyled in `.docx`.
  static String _wrapHtml(String htmlBody) =>
      '''
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word">
<head>
<meta charset="UTF-8"/>
<style type="text/css">
body { font-family: Calibri, Arial, sans-serif; font-size: 11pt; color: #000000; line-height: 1.4; }
p { margin: 0 0 8pt 0; }
blockquote {
  margin: 8pt 0 8pt 0;
  padding: 6pt 0 6pt 14pt;
  border-left: 4px solid #cccccc;
  color: #555555;
  font-style: italic;
  background: #f7f7f7;
}
pre { font-family: Consolas, "Courier New", monospace; font-size: 10pt; background: #f4f4f4; padding: 6pt; }
code { font-family: Consolas, "Courier New", monospace; background: #f4f4f4; }
ul, ol { margin: 0 0 8pt 0.25in; padding-left: 0.25in; }
h1 { font-size: 22pt; margin: 12pt 0 6pt 0; }
h2 { font-size: 18pt; margin: 10pt 0 6pt 0; }
h3 { font-size: 14pt; margin: 8pt 0 4pt 0; }
a { color: #1155cc; }
/* Make sure Quill's inline color/background spans win over body color */
span[style*="color"] { color: inherit; }
</style>
</head>
<body>$htmlBody</body>
</html>''';

  static const String _contentTypes = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/afchunk.html" ContentType="text/html"/></Types>''';

  static const String _rootRels = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>''';

  static const String _documentRels = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="htmlChunk" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/aFChunk" Target="afchunk.html"/></Relationships>''';

  /// A4 page size: 11906 × 16838 twentieths-of-a-point. Margins ~1 inch (1440).
  static const String _documentXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:altChunk r:id="htmlChunk"/><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/></w:sectPr></w:body></w:document>''';
}
