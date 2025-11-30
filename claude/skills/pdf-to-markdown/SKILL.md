---
name: pdf-to-markdown
description: Extract text from scanned PDF documents and convert to clean markdown. Use when user asks to transcribe, extract text, OCR, or convert a PDF (especially scanned documents, historical documents, or image-based PDFs) to markdown format. Outputs markdown file saved next to the original PDF.
---

# PDF to Markdown Extraction

Extract text content from PDF documents and save as clean markdown.

## Workflow

1. **Check PDF size** - Count pages using `pdfinfo <file>.pdf | grep Pages`
2. **Split if large (10+ pages)** - Use qpdf to split into 4-page chunks
3. **Extract text** - For small PDFs: read directly. For large PDFs: process chunks in parallel using Task agents
4. **Merge results** - Combine extracted text in page order
5. **Format as markdown** - Apply appropriate heading levels, lists, and formatting
6. **Review for errors** - Check grammar/spelling, fix obvious OCR-style typos
7. **Save output** - Write markdown file next to original PDF with same base name
8. **Cleanup** - Remove temporary chunk files

## Handling Large PDFs (10+ pages)

For PDFs with 10 or more pages, split into chunks for parallel processing.

### Prerequisites

Ensure `qpdf` is installed:

```bash
# Check if installed
command -v qpdf

# Install if missing (Debian/Ubuntu)
sudo apt install qpdf
```

### Splitting Process

```bash
# Create unique temp directory
TMPDIR=$(mktemp -d)

# Split into 4-page chunks
qpdf --split-pages=4 input.pdf "$TMPDIR/chunk-%d.pdf"
```

This creates files like `chunk-1.pdf`, `chunk-2.pdf`, etc.

### Parallel Extraction

Launch multiple Task agents concurrently (one per chunk) to extract text. Each agent reads its assigned chunk and returns the extracted text. Collect and merge results in page order.

### Cleanup

After merging, remove the temporary directory:

```bash
rm -rf "$TMPDIR"
```

## Output Location

Save the `.md` file in the same directory as the source PDF:

- Input: `/path/to/document.pdf`
- Output: `/path/to/document.md`

## Language-Specific Notes

- Preserve diacritics accurately (háčky, čárky)
- Keep abbreviations as in original (e.g., `čs.`, `použ.`)

## Handling Annotations

If the document contains handwritten annotations:

- Use `~~strikethrough~~` for crossed-out text
- Use `*italics*` for handwritten additions
- Note unclear annotations in the output, use `(` and `)` to highlight

## Quality Checklist

Before saving, verify:

- All pages transcribed
- Heading hierarchy makes sense
- Lists formatted consistently
- No obvious typos or garbled text
- Special characters rendered correctly
