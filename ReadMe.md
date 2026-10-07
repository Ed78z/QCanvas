QCanvas.pas - The High-Fidelity Vector Canvas

DESCRIPTION:
TQCanvas is a 100% GDI-FREE, hardware-independent 2D vector rendering context.
It acts as a seamless drop-in replacement for standard LCL TCanvas methods
(Draw, StretchDraw, CopyRect, Pie, Chord, and classical GDI bounding-box Arc),
while exposing the complete modern AggPasMod (Agg2D) vector pipeline: multi-stop
linear and radial gradients with profile falloff, full affine transforms (TAggTransAffine),
Porter-Duff alpha compositing, FreeType-backed outline typography, subpath accumulation,
and explicit vector paths.

The architecture decouples CROSS-PLATFORM typography through QFONT.PAS and
QLANGUAGES.PAS, providing script-aware font matching, TrueType Collection (TTC)
mapping for CJK, UTF-8 codepoint decomposition, full Unicode RTL script coverage,
and an internal contextual shaper for cursive Arabic and Persian scripts.

BUFFER ATTACHMENT & LIFECYCLE MANAGEMENT:
TQCanvas does not wrap native OS display handles (HDC/GDI). Instead, it renders
directly into 32-bit linear memory buffers (pfBGRA).

Using BeginPaint and EndPaint on a control that already possesses a native
TBitmap degrades performance by forcing the engine to allocate an auxiliary
TRawImage buffer and execute a CPU-bound blit during EndPaint.

By contrast, AttachToBitmap is a zero-copy operation: the engine binds directly
to the bitmap's raw scanline pointer, rasterizing directly into target memory
with zero intermediate allocations.

Volatile UI controls lack persistent pixel storage and are wiped during OS
invalidation cycles; for those, BeginPaint and EndPaint provide the required
managed off-screen staging buffer.

A) Persistent Targets (Use AttachToBitmap / Zero-Copy):
* TImage (via Picture.Bitmap)
* TBitmap standalone instances
* TBitBtn / TSpeedButton (via Glyph)
* Custom off-screen framebuffers and texture caches

B) Volatile Controls (Use BeginPaint / EndPaint):
* TForm (in OnPaint)
* TPanel (in OnPaint)
* TPaintBox (in OnPaint)
* Custom TGraphicControl / TCustomControl descendants

---

TYPICAL WORKFLOWS:

1. Zero-Copy Persistent Bitmap Workflow:
var
  Bmp: TBitmap;
  Q: TQCanvas;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(800, 600);
    Bmp.PixelFormat := pf32bit; // Essential for 32-bit BGRA layout

    Bmp.BeginUpdate(False);
    Q := TQCanvas.Create;
    try
      Q.AttachToBitmap(Bmp); // Direct scanline pointer binding
      Q.ClearAll(clWhite, 255);

      Q.Pen.Width := 4.0;
      Q.Pen.Color := clNavy;
      Q.Line(20.0, 20.0, 780.0, 580.0);
    finally
      Q.Free;
      Bmp.EndUpdate(False);
    end;

    Image1.Picture.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

2. Volatile Control Interception Workflow (Managed Form Fields):
// Avoid creating TQCanvas inside OnPaint repeatedly; maintain a persistent instance
procedure TForm1.Panel1Paint(Sender: TObject);
begin
  FQCanvasPanel.BeginPaint(Panel1.Canvas, Panel1.ClientWidth, Panel1.ClientHeight);
  try
    FQCanvasPanel.ClearAll(clWhite, 255);
    FQCanvasPanel.SetFontForScript(scrPersian);
    FQCanvasPanel.Font.Size := 11.0;
    FQCanvasPanel.Font.Color := clNavy;
    FQCanvasPanel.Font.Alpha := 220;
    FQCanvasPanel.TextOutR(20.0, 50.0, -22.5, 'Persian: درود جهان');
  finally
    FQCanvasPanel.EndPaint;
  end;
end;

---

TYPOGRAPHY & MULTILINGUAL PIPELINE:

1. Cross-Platform Font Resolution (QFont.pas):
   QFont.ResolveFontFile maps logical typeface names to physical disk paths
   across system and per-user directories:
   - Windows: C:\Windows\Fonts, C:\ProgramData\Microsoft\Windows\Fonts,
     and %LOCALAPPDATA%\Microsoft\Windows\Fonts (via ExpandFontUserHome).
   - Linux: /usr/share/fonts/..., /usr/local/share/fonts/, and ~/.fonts/ / ~/.local/share/fonts/.
   - macOS: /System/Library/Fonts/, /Library/Fonts/, and ~/Library/Fonts/.
   It maps generic aliases (Sans, Serif, Monospace), handles style naming conventions
   (arialbd.ttf, segoeuib.ttf), and resolves TrueType Collections for CJK families
   (msyh.ttc, simsun.ttc, msjh.ttc, YuGothM.ttc, malgun.ttf).

2. Script & Locale Directives:
   SetFontForScript and SetFontForLangID automatically select the optimal
   installed font family using candidate ranking from QFont.pas
   (supporting Latin, Greek, Cyrillic, Arabic, Persian, Hebrew, Devanagari,
   Bengali, Thai, CJK, and regional historic scripts).

3. Unicode & Universal RTL BiDi Processing:
   * String metrics and text drawing decode multi-byte UTF-8 sequences directly
     into 32-bit Unicode scalar values for FreeType glyph indexing.
   * VisualOrderUTF8 processes strings run-by-run:
   * Universal RTL Script Detection covers all standard Unicode RTL ranges:
   * Contextual Cursive Shaping & Ligatures

4. Caching Strategies:
   * fcRaster: Fast 8-bit anti-aliased glyph bitmaps. Best for horizontal UI
     body text (8pt to 14pt) snapping to physical pixel grids.
   * fcVector: Mathematical outline vectors decomposed into AGG paths. Rendered
     via dpfFillOnly to eliminate stroke bloating. Ideal for arbitrary subpixel
     rotation (TextOutR), smooth animation, and large display headings.

---

TQCANVAS API REFERENCE:

[Buffer Attachments & Target Presenters]
AttachToBitmap, AttachToRawBuffer, AttachToRawImage, BeginPaint, EndPaint

[State Properties & Classes]
Pen, Brush, Font, PenPos, Pixels, Row, Width, Height, ClipRect, Engine

[Script & Locale Font Selection]
SetFontForScript, SetFontForLangID

[Pipeline & Blend Modes]
BlendMode, ImageBlendMode, ImageBlendColor, MasterAlpha, AntiAliasGamma,
FillEvenOdd, TextHints, FlipText, ImageFilter, ImageResample

[Coordinates & Clipping]
WorldToScreen, ScreenToWorld, AlignPoint, InBox, GetClipBox, SetClipBox,
ResetClipping, ClearAll, ClearClipBox

[Affine Transforms & Viewports]
ResetTransformations, GetTransformations, SetTransformations, SetAffineTransform,
Affine, Rotate, Scale, Skew, Translate, Parallelogram, Viewport

[Pen Stroke Styling & Dashes]
AddDash, RemoveAllDashes

[Color Shaders & Gradients]
FillLinearGradient, LineLinearGradient, FillRadialGradient, LineRadialGradient

[Native TCanvas Geometry]
MoveTo, LineTo, Line, Rectangle, Triangle, FillRect, FrameRect, Ellipse

[Rounded Rectangles]
RoundRect, RoundedRect

[Classical GDI Radial Math]
Arc, Chord, Pie

[Agg2D Analytical Shapes]
Circle, EllipseCenter, Arc, Pie, Star

[Polygons & Splines]
Polygon, Polyline, PolyBezier, PolyBezierTo

[Vector Path Construction & Execution]
ResetPath, ClosePolygon, DrawPath, DrawPathNoTransform, AddLine, AddEllipse

[Relative & SVG Vector Commands]
MoveRel, LineRel, HorizontalLineTo, HorizontalLineRel, VerticalLineTo,
VerticalLineRel, ArcTo, ArcRel, QuadricCurveTo, QuadricCurveRel,
CubicCurveTo, CubicCurveRel

[Typography & Metrics]
TextOut, TextOutR, TextRect, TextWidth, TextHeight, TextExtent,
FontHeight, FontAscent, FontDescent

[Native TCanvas Image Rendering & Transfers]
Draw, StretchDraw, CopyRect

[Low-Level Image Transformations & Blending]
BlendImage, CopyImage, TransformImage, TransformImagePath

---

COMPILER & RUNTIME REQUIREMENTS:
Dynamic Linker Target Names (place next to binary or in system search paths):
   - Windows (x86_64, i386, AArch64): freetype.dll
   - Linux / BSD (x86_64, aarch64, armhf, riscv64): libfreetype.so.6
   - macOS (Apple Silicon arm64, Intel x86_64): libfreetype.dylib
   - Generic Unix / Solaris / Other: libfreetype.so