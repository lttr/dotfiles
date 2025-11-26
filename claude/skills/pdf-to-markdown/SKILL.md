---
name: pdf-to-markdown
description: Extract text from scanned PDF documents and convert to clean markdown. Use when user asks to transcribe, extract text, OCR, or convert a PDF (especially scanned documents, historical documents, or image-based PDFs) to markdown format. Outputs markdown file saved next to the original PDF.
---

# PDF to Markdown Extraction

Extract text content from PDF documents and save as clean markdown.

## Workflow

1. **Analyze the PDF** - View each page of the PDF to read its content
2. **Extract text** - Transcribe all visible text, preserving document structure
3. **Format as markdown** - Apply appropriate heading levels, lists, and formatting
4. **Review for errors** - Check the grammar/spelling of the document in its language, fix obvious OCR-style typos
5. **Save output** - Write markdown file next to original PDF with same base name

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
