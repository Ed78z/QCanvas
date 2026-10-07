unit QCanvas;

{ ============================================================================ }
{ QCANVAS                                                                      }
{ Copyright (C) 2026 Ed White (ew78ee@gmail.com)                               }
{                                                                              }
{ Portions of this software are based on AggPasMod:                            }
{ Copyright (c) 2012-2015 Christian-W. Budde                                  }
{ Copyright (c) 2005-2006 Milan Marusinec                                      }
{ Copyright (c) 2002-2006 Maxim Shemanarev                                     }
{                                                                              }
{ Permission to copy, use, modify, sell, and distribute this software for any  }
{ purpose is hereby granted, subject to the following conditions:              }
{                                                                              }
{ 1. The above copyright notices, including authorship attribution to Ed White }
{    and the original AGG/AggPasMod contributors, must appear in all copies,   }
{    substantial portions, or derivatives of this software.                    }
{                                                                              }
{ 2. In binary or executable distributions, the above copyright notices and    }
{    attributions must be reproduced in the accompanying documentation,        }
{    license file, or application credits/about dialog.                        }
{                                                                              }
{ This software is provided "as is", without express or implied warranty, and  }
{ with no claim as to its suitability for any purpose.                         }
{ ============================================================================ }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Graphics, GraphType, FPImage, Types,
  QLanguages, QFont,
  AggBasics, AggColor, AggPixelFormat, AggTransAffine, Agg2D;

type
  { Re-exported Basic & Color Types }
  TAggColorRgba8                 = AggColor.TAggRgba8;
  PAggColorRgba8                 = Agg2D.PAggColorRgba8;
  TAggPixelFormat                = Agg2D.TAggPixelFormat;

  { Caps, Joins & Directions }
  TAggLineCap                    = AggBasics.TAggLineCap;
  TAggLineJoin                   = AggBasics.TAggLineJoin;
  TAggDirection                  = Agg2D.TAggDirection;

  { Blending Modes }
  TAggBlendMode                  = AggPixelFormat.TAggBlendMode;

  { Geometry, Paths & Viewports }
  TAggDrawPathFlag               = Agg2D.TAggDrawPathFlag;
  TAggViewportOption             = Agg2D.TAggViewportOption;
  TAggTransformations            = Agg2D.TAggTransformations;
  PAggTransformations            = Agg2D.PAggTransformations;
  TAggTransAffine                = AggTransAffine.TAggTransAffine;

  { Gradients }
  TAggGradient                   = Agg2D.TAggGradient;

  { Image Filtering & Resampling }
  TAggImageFilterType            = Agg2D.TAggImageFilterType;
  TAggImageResample              = Agg2D.TAggImageResample;

  { Typography & Text Alignments }
  TAggFontCache                  = Agg2D.TAggFontCache;
  TAggTextAlignmentHorizontal    = Agg2D.TAggTextAlignmentHorizontal;
  TAggTextAlignmentVertical      = Agg2D.TAggTextAlignmentVertical;

  { Underlying Agg2D Classes }
  TAgg2DImage                    = Agg2D.TAgg2DImage;
  TAgg2D                         = Agg2D.TAgg2D;

const
  pfRGBA                         = Agg2D.pfRGBA;
  pfBGRA                         = Agg2D.pfBGRA;

  dirCW                          = Agg2D.dirCW;
  dirCCW                         = Agg2D.dirCCW;

  grdSolid                       = Agg2D.grdSolid;
  grdLinear                      = Agg2D.grdLinear;
  grdRadial                      = Agg2D.grdRadial;

  lcButt                         = AggBasics.lcButt;
  lcSquare                       = AggBasics.lcSquare;
  lcRound                        = AggBasics.lcRound;

  ljMiter                        = AggBasics.ljMiter;
  ljMiterRevert                  = AggBasics.ljMiterRevert;
  ljRound                        = AggBasics.ljRound;
  ljBevel                        = AggBasics.ljBevel;

  dpfFillOnly                    = Agg2D.dpfFillOnly;
  dpfStrokeOnly                  = Agg2D.dpfStrokeOnly;
  dpfFillAndStroke               = Agg2D.dpfFillAndStroke;
  dpfFillWithHorizontalLineColor = Agg2D.dpfFillWithHorizontalLineColor;

  voAnisotropic                  = Agg2D.voAnisotropic;
  voXMinYMin                     = Agg2D.voXMinYMin;
  voXMidYMin                     = Agg2D.voXMidYMin;
  voXMaxYMin                     = Agg2D.voXMaxYMin;
  voXMinYMid                     = Agg2D.voXMinYMid;
  voXMidYMid                     = Agg2D.voXMidYMid;
  voXMaxYMid                     = Agg2D.voXMaxYMid;
  voXMinYMax                     = Agg2D.voXMinYMax;
  voXMidYMax                     = Agg2D.voXMidYMax;
  voXMaxYMax                     = Agg2D.voXMaxYMax;

  fcRaster                       = Agg2D.fcRaster;
  fcVector                       = Agg2D.fcVector;

  tahLeft                        = Agg2D.tahLeft;
  tahRight                       = Agg2D.tahRight;
  tahCenter                      = Agg2D.tahCenter;

  tavTop                         = Agg2D.tavTop;
  tavBottom                      = Agg2D.tavBottom;
  tavCenter                      = Agg2D.tavCenter;

  ifNoFilter                     = Agg2D.ifNoFilter;
  ifBilinear                     = Agg2D.ifBilinear;
  ifHanning                      = Agg2D.ifHanning;
  ifHermite                      = Agg2D.ifHermite;
  ifQuadric                      = Agg2D.ifQuadric;
  ifBicubic                      = Agg2D.ifBicubic;
  ifCatrom                       = Agg2D.ifCatrom;
  ifSpline16                     = Agg2D.ifSpline16;
  ifSpline36                     = Agg2D.ifSpline36;
  ifBlackman144                  = Agg2D.ifBlackman144;

  irNever                        = Agg2D.irNever;
  irAlways                       = Agg2D.irAlways;
  irOnZoomOut                    = Agg2D.irOnZoomOut;

  bmClear                        = AggPixelFormat.bmClear;
  bmSrc                          = AggPixelFormat.bmSource;
  bmDst                          = AggPixelFormat.bmDestination;
  bmSrcOver                      = AggPixelFormat.bmSourceOver;
  bmDstOver                      = AggPixelFormat.bmDestinationOver;
  bmSrcIn                        = AggPixelFormat.bmSourceIn;
  bmDstIn                        = AggPixelFormat.bmDestinationIn;
  bmSrcOut                       = AggPixelFormat.bmSourceOut;
  bmDstOut                       = AggPixelFormat.bmDestinationOut;
  bmSrcAtop                      = AggPixelFormat.bmSourceATop;
  bmDstAtop                      = AggPixelFormat.bmDestinationATop;
  bmXor                          = AggPixelFormat.bmXor;
  bmPlus                         = AggPixelFormat.bmPlus;
  bmMinus                        = AggPixelFormat.bmMinus;
  bmMultiply                     = AggPixelFormat.bmMultiply;
  bmScreen                       = AggPixelFormat.bmScreen;
  bmOverlay                      = AggPixelFormat.bmOverlay;
  bmDarken                       = AggPixelFormat.bmDarken;
  bmLighten                      = AggPixelFormat.bmLighten;
  bmColorDodge                   = AggPixelFormat.bmColorDodge;
  bmColorBurn                    = AggPixelFormat.bmColorBurn;
  bmHardLight                    = AggPixelFormat.bmHardLight;
  bmSoftLight                    = AggPixelFormat.bmSoftLight;
  bmDifference                   = AggPixelFormat.bmDifference;
  bmExclusion                    = AggPixelFormat.bmExclusion;
  bmContrast                     = AggPixelFormat.bmContrast;
  bmInvert                       = AggPixelFormat.bmInvert;
  bmInvertRgb                    = AggPixelFormat.bmInvertRgb;
  bmAlpha                        = AggPixelFormat.bmAlpha;

type
  TPointDoubleArray = array of TPointDouble;
  TQCanvas = class;

  { TQPen }
  TQPen = class
  private
    FCanvas: TQCanvas;
    FColor: TColor;
    FAlpha: Byte;
    FWidth: Double;
    FStyle: TPenStyle;
    FCap: TAggLineCap;
    FJoin: TAggLineJoin;
    procedure SetColor(AValue: TColor);
    procedure SetAlpha(AValue: Byte);
    procedure SetWidth(AValue: Double);
    procedure SetStyle(AValue: TPenStyle);
    procedure SetCap(AValue: TAggLineCap);
    procedure SetJoin(AValue: TAggLineJoin);
  public
    constructor Create(ACanvas: TQCanvas);
    procedure ApplyDashes;
    property Color: TColor read FColor write SetColor;
    property Alpha: Byte read FAlpha write SetAlpha;
    property Width: Double read FWidth write SetWidth;
    property Style: TPenStyle read FStyle write SetStyle;
    property Cap: TAggLineCap read FCap write SetCap;
    property Join: TAggLineJoin read FJoin write SetJoin;
  end;

  { TQBrush }
  TQBrush = class
  private
    FCanvas: TQCanvas;
    FColor: TColor;
    FAlpha: Byte;
    FStyle: TBrushStyle;
    procedure SetColor(AValue: TColor);
    procedure SetAlpha(AValue: Byte);
    procedure SetStyle(AValue: TBrushStyle);
  public
    constructor Create(ACanvas: TQCanvas);
    procedure NoFill;
    property Color: TColor read FColor write SetColor;
    property Alpha: Byte read FAlpha write SetAlpha;
    property Style: TBrushStyle read FStyle write SetStyle;
  end;

  { TQFont }
  TQFont = class
  private
    FCanvas: TQCanvas;
    FColor: TColor;
    FAlpha: Byte;
    FAlignHorz: TAggTextAlignmentHorizontal;
    FAlignVert: TAggTextAlignmentVertical;

    FName: String;
    FSize: Double;
    FStyle: TFontStyles;
    FCache: TAggFontCache;
    FAngle: Double;

    FLastFile: String;
    FLastSize: Double;
    FLastBold: Boolean;
    FLastItalic: Boolean;
    FLastCache: TAggFontCache;
    FLastAngle: Double;

    procedure ApplyFont(AngleDeg: Double = 0.0);
  public
    constructor Create(ACanvas: TQCanvas);
    procedure SetForScript(Script: TScriptType);
    procedure SetForLangID(ALangID: Integer);
    property Color: TColor read FColor write FColor;
    property Alpha: Byte read FAlpha write FAlpha;
    property Name: String read FName write FName;
    property Size: Double read FSize write FSize;
    property Style: TFontStyles read FStyle write FStyle;
    property Cache: TAggFontCache read FCache write FCache;
    property AlignHorz: TAggTextAlignmentHorizontal read FAlignHorz write FAlignHorz;
    property AlignVert: TAggTextAlignmentVertical read FAlignVert write FAlignVert;
    property Angle: Double read FAngle write FAngle;
  end;

  { TQCanvas }
  TQCanvas = class
  private
    { Core Engine & Canvas Contexts }
    FAgg: TAgg2D;
    FPixelFormat: TAggPixelFormat;
    FOffsetR: Integer;
    FOffsetG: Integer;
    FOffsetB: Integer;
    FOffsetA: Integer;
    FTargetCanvas: TCanvas;
    FRawImage: TRawImage;
    FBufferAllocated: Boolean;
    FWidth: Integer;
    FHeight: Integer;

    { Sub-System Controllers & State }
    FPen: TQPen;
    FBrush: TQBrush;
    FFont: TQFont;
    FPenPos: TPointDouble;
    FHasFillGradient: Boolean;
    FHasLineGradient: Boolean;

    { Internal State Synchronization & Color Conversions }
    procedure ApplyState;
    function GetAggColor(C: TColor; A: Byte = 255): TAggColorRgba8;
    procedure CalcArcAngles(Cx, Cy, X3, Y3, X4, Y4: Double; out StartAngle, SweepAngle: Double);
    function CreateAggImage(AGraphic: TGraphic; out OutBmpToFree: TBitmap; out OutConvertedBuffer: PByte): TAgg2DImage;

    { Property Getters & Setters: Surface & Geometry }
    function GetPixels(X, Y: Integer): TColor;
    procedure SetPixels(X, Y: Integer; AValue: TColor); overload;
    procedure SetPixels(X, Y: Integer; AValue: TColor; AAlpha: Byte); overload;
    function GetRow(Y: Cardinal): PByte;
    function GetClipRect: TRect;

    { Property Getters & Setters: Rasterizer & Pipeline }
    function GetBlendMode: TAggBlendMode;
    procedure SetBlendMode(AValue: TAggBlendMode);
    function GetImageBlendMode: TAggBlendMode;
    procedure SetImageBlendMode(AValue: TAggBlendMode);
    function GetImageBlendColor: TColor;
    procedure SetImageBlendColor(AValue: TColor);
    function GetMasterAlpha: Double;
    procedure SetMasterAlpha(AValue: Double);
    function GetAntiAliasGamma: Double;
    procedure SetAntiAliasGamma(AValue: Double);
    function GetImageFilter: TAggImageFilterType;
    procedure SetImageFilter(AValue: TAggImageFilterType);
    function GetImageResample: TAggImageResample;
    procedure SetImageResample(AValue: TAggImageResample);
    function GetFillEvenOdd: Boolean;
    procedure SetFillEvenOdd(AValue: Boolean);

    { Property Getters & Setters: Typography }
    function GetTextHints: Boolean;
    procedure SetTextHints(AValue: Boolean);
    function GetFlipText: Boolean;
    procedure SetFlipText(AValue: Boolean);
    function GetFontHeight: Double;
    function GetFontAscent: Double;
    function GetFontDescent: Double;

  public
    { Lifecycle Management }
    constructor Create(APixelFormat: TAggPixelFormat = pfBGRA);
    property PixelFormat: TAggPixelFormat read FPixelFormat;
    destructor Destroy; override;

    { Buffer Attachments & Target Presenters }
    procedure AttachToBitmap(ABitmap: TBitmap);
    procedure AttachToRawBuffer(Buffer: PByte; AWidth, AHeight, AStride: Integer);
    procedure AttachToRawImage(var ARawImage: TRawImage);
    procedure BeginPaint(ACanvas: TCanvas; AWidth, AHeight: Integer);
    procedure EndPaint;

    { Surface Dimensions, Direct Pixel & Memory Access }
    property Engine: TAgg2D read FAgg;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Pixels[X, Y: Integer]: TColor read GetPixels write SetPixels;
    property Row[Y: Cardinal]: PByte read GetRow;

    { Core Canvas Drawing Objects }
    property Pen: TQPen read FPen;
    property Brush: TQBrush read FBrush;
    property Font: TQFont read FFont;
    property PenPos: TPointDouble read FPenPos write FPenPos;

    { Clipping & Canvas Clearing }
    property ClipRect: TRect read GetClipRect;
    function GetClipBox: TRectDouble;
    procedure SetClipBox(X1, Y1, X2, Y2: Double); overload;
    procedure SetClipBox(const ARect: TRectDouble); overload;
    procedure ResetClipping;
    procedure ClearAll(Color: TColor; Alpha: Byte = 255);
    procedure ClearClipBox(Color: TColor; Alpha: Byte = 255);

    { Coordinate Mapping, Testing & Grid Snapping }
    procedure WorldToScreen(X, Y: PDouble); overload;
    procedure WorldToScreen(var X, Y: Double); overload;
    function WorldToScreen(Scalar: Double): Double; overload;
    procedure ScreenToWorld(X, Y: PDouble); overload;
    procedure ScreenToWorld(var X, Y: Double); overload;
    function ScreenToWorld(Scalar: Double): Double; overload;
    procedure AlignPoint(X, Y: PDouble); overload;
    procedure AlignPoint(var X, Y: Double); overload;
    function InBox(WorldX, WorldY: Double): Boolean; overload;
    function InBox(const World: TPointDouble): Boolean; overload;

    { Affine Transformations & Viewports }
    procedure ResetTransformations;
    function GetTransformations: TAggTransformations;
    procedure SetTransformations(var Tr: TAggTransformations); overload;
    procedure SetTransformations(V0, V1, V2, V3, V4, V5: Double); overload;
    procedure SetAffineTransform(const Trans: TAggTransAffine);
    procedure Affine(const Trans: TAggTransAffine); overload;
    procedure Affine(var Tr: TAggTransformations); overload;
    procedure Rotate(AngleRad: Double);
    procedure Scale(Sx, Sy: Double);
    procedure Skew(Sx, Sy: Double);
    procedure Translate(X, Y: Double);
    procedure Parallelogram(X1, Y1, X2, Y2: Double; Para: PDouble);
    procedure Viewport(WorldX1, WorldY1, WorldX2, WorldY2, ScreenX1, ScreenY1, ScreenX2, ScreenY2: Double; Opt: TAggViewportOption = voXMidYMid); overload;
    procedure Viewport(World, Screen: TRectDouble; Opt: TAggViewportOption = voXMidYMid); overload;

    { Rasterizer, Compositing & Image Pipelines }
    property BlendMode: TAggBlendMode read GetBlendMode write SetBlendMode;
    property ImageBlendMode: TAggBlendMode read GetImageBlendMode write SetImageBlendMode;
    property ImageBlendColor: TColor read GetImageBlendColor write SetImageBlendColor;
    property ImageFilter: TAggImageFilterType read GetImageFilter write SetImageFilter;
    property ImageResample: TAggImageResample read GetImageResample write SetImageResample;
    property MasterAlpha: Double read GetMasterAlpha write SetMasterAlpha;
    property AntiAliasGamma: Double read GetAntiAliasGamma write SetAntiAliasGamma;
    property FillEvenOdd: Boolean read GetFillEvenOdd write SetFillEvenOdd;

    { Pen Stroke Styling & Dashes }
    procedure AddDash(DashLen, GapLen: Double);
    procedure RemoveAllDashes;

    { Color Shaders & Gradients }
    procedure FillLinearGradient(X1, Y1, X2, Y2: Double; Color1, Color2: TColor; Alpha1: Byte = 255; Alpha2: Byte = 255; Profile: Double = 1.0);
    procedure LineLinearGradient(X1, Y1, X2, Y2: Double; Color1, Color2: TColor; Alpha1: Byte = 255; Alpha2: Byte = 255; Profile: Double = 1.0);
    procedure FillRadialGradient(X, Y, Radius: Double; Color1, Color2: TColor; Alpha1: Byte = 255; Alpha2: Byte = 255); overload;
    procedure FillRadialGradient(X, Y, Radius: Double; Color1, Color2, Color3: TColor; A1: Byte = 255; A2: Byte = 255; A3: Byte = 255); overload;
    procedure FillRadialGradient(X, Y, Radius: Double); overload;
    procedure LineRadialGradient(X, Y, Radius: Double; Color1, Color2: TColor; Alpha1: Byte = 255; Alpha2: Byte = 255); overload;
    procedure LineRadialGradient(X, Y, Radius: Double; Color1, Color2, Color3: TColor; A1: Byte = 255; A2: Byte = 255; A3: Byte = 255); overload;
    procedure LineRadialGradient(X, Y, Radius: Double); overload;

    { Geometric Primitives: Lines & Polygons }
    procedure MoveTo(X, Y: Double); overload;
    procedure MoveTo(const P: TPoint); overload;
    procedure LineTo(X, Y: Double); overload;
    procedure LineTo(const P: TPoint); overload;
    procedure Line(X1, Y1, X2, Y2: Double); overload;
    procedure Line(const P1, P2: TPoint); overload;
    procedure Line(const ARect: TRect); overload;
    procedure Triangle(X1, Y1, X2, Y2, X3, Y3: Double);
    procedure Polygon(Xy: PPointDouble; NumPoints: Integer; Flag: TAggDrawPathFlag = dpfFillAndStroke); overload;
    procedure Polygon(const Points: TPointDoubleArray); overload;
    procedure Polygon(const Points: array of TPoint); overload;
    procedure Polyline(Xy: PPointDouble; NumPoints: Integer); overload;
    procedure Polyline(const Points: TPointDoubleArray); overload;
    procedure Polyline(const Points: array of TPoint); overload;

    { Geometric Primitives: Rectangles & Curves }
    procedure Rectangle(X1, Y1, X2, Y2: Double); overload;
    procedure Rectangle(const ARect: TRect); overload;
    procedure Rectangle(const ARect: TRectDouble); overload;
    procedure FillRect(X1, Y1, X2, Y2: Double); overload;
    procedure FillRect(const ARect: TRect); overload;
    procedure FillRect(const ARect: TRectDouble); overload;
    procedure FrameRect(const ARect: TRect); overload;
    procedure FrameRect(const ARect: TRectDouble); overload;
    procedure RoundRect(X1, Y1, X2, Y2: Double; R: Double); overload;
    procedure RoundRect(X1, Y1, X2, Y2: Double; Rx, Ry: Double); overload;
    procedure RoundRect(X1, Y1, X2, Y2: Double; RxBottom, RyBottom, RxTop, RyTop: Double); overload;
    procedure RoundRect(const ARect: TRect; Rx, Ry: Double); overload;
    procedure RoundRect(const ARect: TRectDouble; R: Double); overload;
    procedure RoundRect(const ARect: TRectDouble; Rx, Ry: Double); overload;
    procedure RoundedRect(X1, Y1, X2, Y2: Double; R: Double); overload;
    procedure RoundedRect(X1, Y1, X2, Y2: Double; Rx, Ry: Double); overload;
    procedure RoundedRect(X1, Y1, X2, Y2: Double; RxBottom, RyBottom, RxTop, RyTop: Double); overload;
    procedure RoundedRect(const ARect: TRect; Rx, Ry: Double); overload;
    procedure RoundedRect(const ARect: TRectDouble; R: Double); overload;
    procedure RoundedRect(const ARect: TRectDouble; Rx, Ry: Double); overload;

    { Geometric Primitives: Radials, Arcs & Stars }
    procedure Circle(Cx, Cy, Radius: Double);
    procedure Ellipse(X1, Y1, X2, Y2: Double); overload;
    procedure Ellipse(const ARect: TRect); overload;
    procedure Ellipse(const ARect: TRectDouble); overload;
    procedure EllipseCenter(Cx, Cy, Rx, Ry: Double);
    procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double); overload;
    procedure Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double); overload;
    procedure Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double);
    procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double); overload;
    procedure Pie(Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double); overload;
    procedure Star(Cx, Cy, R1, R2, StartAngle: Double; NumRays: Integer);

    { Splines & Continuous Curves }
    procedure Curve(X1, Y1, X2, Y2, X3, Y3: Double); overload;
    procedure Curve(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double); overload;
    procedure PolyBezier(const Points: TPointDoubleArray); overload;
    procedure PolyBezier(const Points: array of TPoint); overload;
    procedure PolyBezierTo(const Points: TPointDoubleArray); overload;
    procedure PolyBezierTo(const Points: array of TPoint); overload;

    { Vector Path Construction & Execution }
    procedure ResetPath;
    procedure ClosePolygon;
    procedure DrawPath(Flag: TAggDrawPathFlag = dpfFillAndStroke);
    procedure DrawPathNoTransform(Flag: TAggDrawPathFlag = dpfFillAndStroke);
    procedure AddLine(X1, Y1, X2, Y2: Double);
    procedure AddEllipse(Cx, Cy, Rx, Ry: Double; Dir: TAggDirection = dirCW); overload;
    procedure AddEllipse(Center, Radius: TPointDouble; Dir: TAggDirection = dirCW); overload;

    { Relative & SVG Vector Path Commands }
    procedure MoveRel(Dx, Dy: Double);
    procedure LineRel(Dx, Dy: Double);
    procedure HorizontalLineTo(X: Double);
    procedure HorizontalLineRel(Dx: Double);
    procedure VerticalLineTo(Y: Double);
    procedure VerticalLineRel(Dy: Double);
    procedure ArcTo(Rx, Ry, Angle: Double; LargeArcFlag, SweepFlag: Boolean; X, Y: Double);
    procedure ArcRel(Rx, Ry, Angle: Double; LargeArcFlag, SweepFlag: Boolean; Dx, Dy: Double);
    procedure QuadricCurveTo(XCtrl, YCtrl, XTo, YTo: Double); overload;
    procedure QuadricCurveTo(XTo, YTo: Double); overload;
    procedure QuadricCurveRel(DxCtrl, DyCtrl, DxTo, DyTo: Double); overload;
    procedure QuadricCurveRel(DxTo, DyTo: Double); overload;
    procedure CubicCurveTo(XCtrl1, YCtrl1, XCtrl2, YCtrl2, XTo, YTo: Double); overload;
    procedure CubicCurveTo(XCtrl2, YCtrl2, XTo, YTo: Double); overload;
    procedure CubicCurveRel(DxCtrl1, DyCtrl1, DxCtrl2, DyCtrl2, DxTo, DyTo: Double); overload;
    procedure CubicCurveRel(DxCtrl2, DyCtrl2, DxTo, DyTo: Double); overload;

    { Typography, Script Selectors & Metrics }
    property TextHints: Boolean read GetTextHints write SetTextHints;
    property FlipText: Boolean read GetFlipText write SetFlipText;
    property FontHeight: Double read GetFontHeight;
    property FontAscent: Double read GetFontAscent;
    property FontDescent: Double read GetFontDescent;
    procedure SetFontForScript(Script: TScriptType);
    procedure SetFontForLangID(ALangID: Integer);
    procedure TextOut(X, Y: Double; const Text: String);
    procedure TextOutR(X, Y, RotDeg: Double; const Text: String);
    procedure TextRect(const ARect: TRect; X, Y: Double; const Text: String); overload;
    procedure TextRect(const ARect: TRectDouble; X, Y: Double; const Text: String); overload;
    function TextWidth(const Text: String): Double;
    function TextHeight(const {%H-}Text: String): Double;
    function TextExtent(const Text: String): TSize;

    { Native TCanvas Image Rendering & Blitting }
    procedure Draw(X, Y: Double; AGraphic: TGraphic);
    procedure StretchDraw(X1, Y1, X2, Y2: Double; AGraphic: TGraphic); overload;
    procedure StretchDraw(const ARect: TRect; AGraphic: TGraphic); overload;
    procedure StretchDraw(const ARect: TRectDouble; AGraphic: TGraphic); overload;
    procedure CopyRect(const DestRect: TRect; SourceCanvas: TQCanvas; const SourceRect: TRect); overload;
    procedure CopyRect(const DestRect: TRectDouble; SourceCanvas: TQCanvas; const SourceRect: TRectDouble); overload;

    { Low-Level Image Transformations, Blending & Copying }
    procedure BlendImage(Img: TAgg2DImage; DstX, DstY: Double; Alpha: Cardinal = 255); overload;
    procedure BlendImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX, DstY: Double; Alpha: Cardinal = 255); overload;
    procedure CopyImage(Img: TAgg2DImage; DstX, DstY: Double); overload;
    procedure CopyImage(Img: TAgg2DImage; const Destination: TPointDouble); overload;
    procedure CopyImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX, DstY: Double); overload;
    procedure CopyImage(Img: TAgg2DImage; ImgRect: TRectInteger; const Destination: TPointDouble); overload;
    procedure TransformImage(Img: TAgg2DImage; DstX1, DstY1, DstX2, DstY2: Double); overload;
    procedure TransformImage(Img: TAgg2DImage; const Destination: TRectDouble); overload;
    procedure TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; const Destination: TRectDouble); overload;
    procedure TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; DstX1, DstY1, DstX2, DstY2: Double); overload;
    procedure TransformImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX1, DstY1, DstX2, DstY2: Double); overload;
    procedure TransformImage(Img: TAgg2DImage; AParallelogram: PDouble); overload;
    procedure TransformImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; AParallelogram: PDouble); overload;
    procedure TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; AParallelogram: PDouble); overload;
    procedure TransformImagePath(Img: TAgg2DImage; DstX1, DstY1, DstX2, DstY2: Double); overload;
    procedure TransformImagePath(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX1, DstY1, DstX2, DstY2: Double); overload;
    procedure TransformImagePath(Img: TAgg2DImage; AParallelogram: PDouble); overload;
    procedure TransformImagePath(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; AParallelogram: PDouble); overload;
  end;

implementation

{ TQPen }

constructor TQPen.Create(ACanvas: TQCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FColor := clBlack;
  FAlpha := 255;
  FWidth := 1.0;
  FStyle := psSolid;
  FCap := lcRound;
  FJoin := ljRound;
end;

procedure TQPen.SetColor(AValue: TColor);
var
  RGBVal: LongInt;
begin
  FColor := AValue;
  FCanvas.FHasLineGradient := False;
  RGBVal := ColorToRGB(AValue);
  FCanvas.FAgg.SetLineColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FAlpha);
  if FStyle = psClear then FStyle := psSolid;
end;

procedure TQPen.SetAlpha(AValue: Byte);
var
  RGBVal: LongInt;
begin
  FAlpha := AValue;
  FCanvas.FHasLineGradient := False;
  RGBVal := ColorToRGB(FColor);
  FCanvas.FAgg.SetLineColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FAlpha);
  if FStyle = psClear then FStyle := psSolid;
end;

procedure TQPen.SetWidth(AValue: Double);
begin
  FWidth := AValue;
  FCanvas.FAgg.LineWidth := FWidth;
  if FStyle = psClear then FStyle := psSolid;
end;

procedure TQPen.SetCap(AValue: TAggLineCap);
begin
  FCap := AValue;
  FCanvas.FAgg.LineCap := FCap;
end;

procedure TQPen.SetJoin(AValue: TAggLineJoin);
begin
  FJoin := AValue;
  FCanvas.FAgg.LineJoin := FJoin;
end;

procedure TQPen.SetStyle(AValue: TPenStyle);
begin
  FStyle := AValue;
  ApplyDashes;
end;

procedure TQPen.ApplyDashes;
begin
  FCanvas.FAgg.RemoveAllDashes;
  case FStyle of
    psDash:
      FCanvas.FAgg.AddDash(FWidth * 4.0, FWidth * 3.0);
    psDot:
      FCanvas.FAgg.AddDash(FWidth * 1.0, FWidth * 2.0);
    psDashDot:
      begin
        FCanvas.FAgg.AddDash(FWidth * 4.0, FWidth * 2.0);
        FCanvas.FAgg.AddDash(FWidth * 1.0, FWidth * 2.0);
      end;
    psDashDotDot:
      begin
        FCanvas.FAgg.AddDash(FWidth * 4.0, FWidth * 2.0);
        FCanvas.FAgg.AddDash(FWidth * 1.0, FWidth * 2.0);
        FCanvas.FAgg.AddDash(FWidth * 1.0, FWidth * 2.0);
      end;
  end;
end;

{ TQBrush }

constructor TQBrush.Create(ACanvas: TQCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FColor := clWhite;
  FAlpha := 255;
  FStyle := bsSolid;
end;

procedure TQBrush.SetColor(AValue: TColor);
var
  RGBVal: LongInt;
begin
  FColor := AValue;
  FCanvas.FHasFillGradient := False;
  RGBVal := ColorToRGB(AValue);
  FCanvas.FAgg.SetFillColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FAlpha);
  if FStyle = bsClear then FStyle := bsSolid;
end;

procedure TQBrush.SetAlpha(AValue: Byte);
var
  RGBVal: LongInt;
begin
  FAlpha := AValue;
  FCanvas.FHasFillGradient := False;
  RGBVal := ColorToRGB(FColor);
  FCanvas.FAgg.SetFillColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FAlpha);
  if FStyle = bsClear then FStyle := bsSolid;
end;

procedure TQBrush.SetStyle(AValue: TBrushStyle);
begin
  FStyle := AValue;
end;

procedure TQBrush.NoFill;
begin
  FStyle := bsClear;
  FCanvas.FHasFillGradient := False;
end;

{ TQFont }

constructor TQFont.Create(ACanvas: TQCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FColor := clBlack;
  FAlpha := 255;
  FName := 'Arial';
  FSize := 10.0;
  FStyle := [];
  FCache := fcVector;
  FAlignHorz := tahLeft;
  FAlignVert := tavTop;
  FAngle := 0.0;
  FLastFile := '';
  FLastSize := -1.0;
  FLastBold := False;
  FLastItalic := False;
  FLastCache := fcRaster;
  FLastAngle := -999.0;
end;

procedure TQFont.ApplyFont(AngleDeg: Double);
var
  RGBVal: LongInt;
  ActualPixSize: Double;
  FontFile: String;
  CurBold, CurItalic: Boolean;
begin
  ActualPixSize := Abs(FSize) * (96.0 / 72.0);
  FontFile := QFont.ResolveFontFile(FName, FStyle);

  if not FileExists(FontFile) then
    FontFile := QFont.GetPlatformFontFallback;

  CurBold := fsBold in FStyle;
  CurItalic := fsItalic in FStyle;

  if (FontFile <> FLastFile) or (ActualPixSize <> FLastSize) or
     (CurBold <> FLastBold) or (CurItalic <> FLastItalic) or
     (FCache <> FLastCache) or (AngleDeg <> FLastAngle) then
  begin
    FCanvas.FAgg.Font(PAnsiChar(AnsiString(FontFile)), ActualPixSize,
                      CurBold, CurItalic, FCache, -DegToRad(AngleDeg));
    FLastFile   := FontFile;
    FLastSize   := ActualPixSize;
    FLastBold   := CurBold;
    FLastItalic := CurItalic;
    FLastCache  := FCache;
    FLastAngle  := AngleDeg;
  end;

  FCanvas.FAgg.FlipText := True;
  FCanvas.FAgg.TextAlignment(FAlignHorz, FAlignVert);

  RGBVal := ColorToRGB(FColor);
  FCanvas.FAgg.SetFillColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FAlpha);
end;

procedure TQFont.SetForScript(Script: TScriptType);
begin
  Name := GetOSFontForScript(Script);
end;

procedure TQFont.SetForLangID(ALangID: Integer);
begin
  Name := GetOSFontForLangID(ALangID);
end;

{ TQCanvas }

constructor TQCanvas.Create(APixelFormat: TAggPixelFormat = pfBGRA);
begin
  inherited Create;
  FPixelFormat := APixelFormat;
  FAgg := TAgg2D.Create(FPixelFormat);

  case FPixelFormat of
    pfRGBA:
      begin
        FOffsetR := 0; FOffsetG := 1; FOffsetB := 2; FOffsetA := 3;
      end;
    pfBGRA:
      begin
        FOffsetB := 0; FOffsetG := 1; FOffsetR := 2; FOffsetA := 3;
      end;
  else
    FOffsetB := 0; FOffsetG := 1; FOffsetR := 2; FOffsetA := 3;
  end;

  FPen := TQPen.Create(Self);
  FBrush := TQBrush.Create(Self);
  FFont := TQFont.Create(Self);
  FPenPos := PointDouble(0, 0);
  FRawImage := Default(TRawImage);
  FBufferAllocated := False;
  FTargetCanvas := nil;
  FWidth := 0;
  FHeight := 0;
  FHasFillGradient := False;
  FHasLineGradient := False;
end;

destructor TQCanvas.Destroy;
begin
  if FBufferAllocated then
  begin
    FRawImage.FreeData;
    FBufferAllocated := False;
  end;
  FPen.Free;
  FBrush.Free;
  FFont.Free;
  FAgg.Free;
  inherited Destroy;
end;

function TQCanvas.GetAggColor(C: TColor; A: Byte): TAggColorRgba8;
var
  RGBVal: LongInt;
begin
  RGBVal := ColorToRGB(C);
  Result.R := Red(RGBVal);
  Result.G := Green(RGBVal);
  Result.B := Blue(RGBVal);
  Result.A := A;
end;

procedure TQCanvas.ApplyState;
var
  RGBVal: LongInt;
begin
  if not FHasLineGradient then
  begin
    if FPen.Style = psClear then
      FAgg.NoLine
    else
    begin
      RGBVal := ColorToRGB(FPen.Color);
      FAgg.SetLineColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FPen.Alpha);
    end;
  end;
  FAgg.LineWidth := FPen.Width;
  FAgg.LineCap := FPen.Cap;
  FAgg.LineJoin := FPen.Join;

  if not FHasFillGradient then
  begin
    if FBrush.Style = bsClear then
      FAgg.NoFill
    else
    begin
      RGBVal := ColorToRGB(FBrush.Color);
      FAgg.SetFillColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FBrush.Alpha);
    end;
  end;
end;

function TQCanvas.GetBlendMode: TAggBlendMode; begin Result := FAgg.BlendMode; end;
procedure TQCanvas.SetBlendMode(AValue: TAggBlendMode); begin FAgg.BlendMode := AValue; end;
function TQCanvas.GetImageBlendMode: TAggBlendMode; begin Result := FAgg.ImageBlendMode; end;
procedure TQCanvas.SetImageBlendMode(AValue: TAggBlendMode); begin FAgg.ImageBlendMode := AValue; end;

function TQCanvas.GetImageBlendColor: TColor;
begin
  Result := RGBToColor(FAgg.ImageBlendColor.R, FAgg.ImageBlendColor.G, FAgg.ImageBlendColor.B);
end;

procedure TQCanvas.SetImageBlendColor(AValue: TColor);
var
  RGBVal: LongInt;
begin
  RGBVal := ColorToRGB(AValue);
  FAgg.SetImageBlendColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), 255);
end;

function TQCanvas.GetMasterAlpha: Double; begin Result := FAgg.MasterAlpha; end;
procedure TQCanvas.SetMasterAlpha(AValue: Double); begin FAgg.MasterAlpha := AValue; end;
function TQCanvas.GetAntiAliasGamma: Double; begin Result := FAgg.AntiAliasGamma; end;
procedure TQCanvas.SetAntiAliasGamma(AValue: Double); begin FAgg.AntiAliasGamma := AValue; end;
function TQCanvas.GetImageFilter: TAggImageFilterType; begin Result := FAgg.ImageFilter; end;
procedure TQCanvas.SetImageFilter(AValue: TAggImageFilterType); begin FAgg.ImageFilter := AValue; end;
function TQCanvas.GetImageResample: TAggImageResample; begin Result := FAgg.ImageResample; end;
procedure TQCanvas.SetImageResample(AValue: TAggImageResample); begin FAgg.ImageResample := AValue; end;
function TQCanvas.GetFillEvenOdd: Boolean; begin Result := FAgg.FillEvenOdd; end;
procedure TQCanvas.SetFillEvenOdd(AValue: Boolean); begin FAgg.FillEvenOdd := AValue; end;
function TQCanvas.GetTextHints: Boolean; begin Result := FAgg.TextHints; end;
procedure TQCanvas.SetTextHints(AValue: Boolean); begin FAgg.TextHints := AValue; end;
function TQCanvas.GetFlipText: Boolean; begin Result := FAgg.FlipText; end;
procedure TQCanvas.SetFlipText(AValue: Boolean); begin FAgg.FlipText := AValue; end;
function TQCanvas.GetFontHeight: Double; begin Result := FAgg.FontHeight; end;

function TQCanvas.GetClipRect: TRect;
var
  Box: TRectDouble;
begin
  Box := FAgg.ClipBox;
  Result := Rect(Trunc(Box.X1), Trunc(Box.Y1), Ceil(Box.X2), Ceil(Box.Y2));
end;

function TQCanvas.GetFontAscent: Double;
begin
  Result := FFont.Size * (96.0 / 72.0) * 0.8; // Or wire directly to FFontEngine.Ascender
end;

function TQCanvas.GetFontDescent: Double;
begin
  Result := FFont.Size * (96.0 / 72.0) * 0.2; // Or wire directly to FFontEngine.Descender
end;

procedure TQCanvas.AttachToBitmap(ABitmap: TBitmap);
var
  DataPtr: PByte;
  Stride: Integer;
begin
  FWidth := ABitmap.Width;
  FHeight := ABitmap.Height;
  DataPtr := PByte(ABitmap.RawImage.Data);
  Stride := ABitmap.RawImage.Description.BytesPerLine;

  if ABitmap.RawImage.Description.LineOrder = riloBottomToTop then
  begin
    Inc(DataPtr, (FHeight - 1) * Stride);
    Stride := -Stride;
  end;

  FAgg.Attach(DataPtr, FWidth, FHeight, Stride);
  FAgg.ResetTransformations;
  FAgg.ClipBox(0, 0, FWidth, FHeight);
end;

procedure TQCanvas.AttachToRawBuffer(Buffer: PByte; AWidth, AHeight, AStride: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  FAgg.Attach(Buffer, AWidth, AHeight, AStride);
  FAgg.ResetTransformations;
  FAgg.ClipBox(0, 0, AWidth, AHeight);
end;

procedure TQCanvas.AttachToRawImage(var ARawImage: TRawImage);
var
  DataPtr: PByte;
  Stride: Integer;
begin
  FWidth := ARawImage.Description.Width;
  FHeight := ARawImage.Description.Height;
  DataPtr := PByte(ARawImage.Data);
  Stride := ARawImage.Description.BytesPerLine;

  if ARawImage.Description.LineOrder = riloBottomToTop then
  begin
    Inc(DataPtr, (FHeight - 1) * Stride);
    Stride := -Stride;
  end;

  FAgg.Attach(DataPtr, FWidth, FHeight, Stride);
  FAgg.ResetTransformations;
  FAgg.ClipBox(0, 0, FWidth, FHeight);
end;

procedure TQCanvas.BeginPaint(ACanvas: TCanvas; AWidth, AHeight: Integer);
var
  Reallocate: Boolean;
begin
  FTargetCanvas := ACanvas;
  Reallocate := not FBufferAllocated or (FWidth <> AWidth) or (FHeight <> AHeight);

  FWidth := AWidth;
  FHeight := AHeight;

  if Reallocate then
  begin
    if FBufferAllocated then FRawImage.FreeData;

    FRawImage := Default(TRawImage);
    FRawImage.Init;

    if FPixelFormat = pfRGBA then
      FRawImage.Description.Init_BPP32_R8G8B8A8_BIO_TTB(FWidth, FHeight)
    else
      FRawImage.Description.Init_BPP32_B8G8R8A8_BIO_TTB(FWidth, FHeight);

    FRawImage.CreateData(True);
    FBufferAllocated := True;
  end;

  FAgg.Attach(PByte(FRawImage.Data), FWidth, FHeight, FRawImage.Description.BytesPerLine);
  FAgg.ResetTransformations;
  FAgg.ClipBox(0, 0, FWidth, FHeight);
end;

procedure TQCanvas.EndPaint;
var
  TempBmp: TBitmap;
begin
  if not Assigned(FTargetCanvas) or not FBufferAllocated then
    Exit;

  TempBmp := TBitmap.Create;
  try
    TempBmp.LoadFromRawImage(FRawImage, False);
    FTargetCanvas.Draw(0, 0, TempBmp);
  finally
    TempBmp.Free;
    FTargetCanvas := nil;
  end;
end;

function TQCanvas.GetPixels(X, Y: Integer): TColor;
var
  RowPtr, Pix: PByte;
begin
  if (X < 0) or (Y < 0) or (X >= FWidth) or (Y >= FHeight) or (FAgg = nil) then
    Exit(clNone);

  // FAgg.Row handles stride direction and returns nil if detached
  RowPtr := PByte(FAgg.Row[Cardinal(Y)]);
  if RowPtr = nil then
    Exit(clNone);

  Pix := RowPtr + (X shl 2);
  Result := RGBToColor(Pix[FOffsetR], Pix[FOffsetG], Pix[FOffsetB]);
end;

procedure TQCanvas.SetPixels(X, Y: Integer; AValue: TColor; AAlpha: Byte);
var
  RowPtr, Pix: PByte;
  RGBVal: Cardinal;
begin
  if (X < 0) or (Y < 0) or (X >= FWidth) or (Y >= FHeight) or (FAgg = nil) then
    Exit;

  // FAgg.Row handles stride direction and returns nil if detached
  RowPtr := PByte(FAgg.Row[Cardinal(Y)]);
  if RowPtr = nil then
    Exit;

  RGBVal := Cardinal(ColorToRGB(AValue));
  Pix := RowPtr + (X shl 2);
  Pix[FOffsetR] := Red(RGBVal);
  Pix[FOffsetG] := Green(RGBVal);
  Pix[FOffsetB] := Blue(RGBVal);
  Pix[FOffsetA] := AAlpha;
end;

procedure TQCanvas.SetPixels(X, Y: Integer; AValue: TColor);
begin
  SetPixels(X, Y, AValue, 255);
end;

{ Geometry Overloads }

procedure TQCanvas.MoveTo(X, Y: Double);
begin
  FPenPos := PointDouble(X, Y);
  FAgg.MoveTo(X, Y);
end;

procedure TQCanvas.MoveTo(const P: TPoint);
begin
  MoveTo(P.X, P.Y);
end;

procedure TQCanvas.LineTo(X, Y: Double);
begin
  ApplyState;
  //FAgg.NoFill;
  FAgg.Line(FPenPos.X, FPenPos.Y, X, Y);
  FPenPos := PointDouble(X, Y);
end;

procedure TQCanvas.LineTo(const P: TPoint);
begin
  LineTo(P.X, P.Y);
end;

procedure TQCanvas.Line(X1, Y1, X2, Y2: Double);
begin
  ApplyState;
  //FAgg.NoFill;
  FAgg.Line(X1, Y1, X2, Y2);
  FPenPos := PointDouble(X2, Y2);
end;

procedure TQCanvas.Line(const P1, P2: TPoint);
begin
  Line(P1.X, P1.Y, P2.X, P2.Y);
end;

procedure TQCanvas.Line(const ARect: TRect);
begin
  Line(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TQCanvas.Rectangle(X1, Y1, X2, Y2: Double);
begin
  ApplyState;
  FAgg.Rectangle(X1, Y1, X2, Y2);
end;

procedure TQCanvas.Rectangle(const ARect: TRect);
begin
  Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TQCanvas.Rectangle(const ARect: TRectDouble);
begin
  Rectangle(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2);
end;

procedure TQCanvas.Triangle(X1, Y1, X2, Y2, X3, Y3: Double);
begin
  ApplyState;
  FAgg.Triangle(X1, Y1, X2, Y2, X3, Y3);
end;

procedure TQCanvas.FillRect(X1, Y1, X2, Y2: Double);
begin
  ApplyState;
  FAgg.NoLine;
  FAgg.Rectangle(X1, Y1, X2, Y2);
end;

procedure TQCanvas.FillRect(const ARect: TRect);
begin
  FillRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TQCanvas.FillRect(const ARect: TRectDouble);
begin
  FillRect(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2);
end;

procedure TQCanvas.FrameRect(const ARect: TRectDouble);
var
  RGBVal: LongInt;
begin
  FAgg.NoFill;
  RGBVal := ColorToRGB(FBrush.Color);
  FAgg.SetLineColor(Red(RGBVal), Green(RGBVal), Blue(RGBVal), FBrush.Alpha);
  FAgg.LineWidth := 1.0;
  FAgg.Rectangle(ARect.X1 + 0.5, ARect.Y1 + 0.5, ARect.X2 - 0.5, ARect.Y2 - 0.5);
  // Restore state for subsequent pen operations
  ApplyState;
end;

procedure TQCanvas.FrameRect(const ARect: TRect);
begin
  FrameRect(RectDouble(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom));
end;

procedure TQCanvas.Ellipse(X1, Y1, X2, Y2: Double);
var
  Cx, Cy, Rx, Ry: Double;
begin
  Cx := (X1 + X2) / 2.0;
  Cy := (Y1 + Y2) / 2.0;
  Rx := Abs(X2 - X1) / 2.0;
  Ry := Abs(Y2 - Y1) / 2.0;
  ApplyState;
  FAgg.Ellipse(Cx, Cy, Rx, Ry);
end;

procedure TQCanvas.Ellipse(const ARect: TRect);
begin
  Ellipse(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TQCanvas.Ellipse(const ARect: TRectDouble);
begin
  Ellipse(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2);
end;

procedure TQCanvas.RoundRect(X1, Y1, X2, Y2: Double; Rx, Ry: Double);
begin
  ApplyState;
  FAgg.RoundedRect(X1, Y1, X2, Y2, Rx, Ry);
end;

procedure TQCanvas.RoundRect(const ARect: TRect; Rx, Ry: Double);
begin
  RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, Rx, Ry);
end;

procedure TQCanvas.RoundRect(X1, Y1, X2, Y2: Double; R: Double);
begin
  ApplyState;
  FAgg.RoundedRect(X1, Y1, X2, Y2, R);
end;

procedure TQCanvas.RoundRect(const ARect: TRectDouble; R: Double);
begin
  ApplyState;
  FAgg.RoundedRect(ARect, R);
end;

procedure TQCanvas.RoundRect(const ARect: TRectDouble; Rx, Ry: Double);
begin
  ApplyState;
  FAgg.RoundedRect(ARect, Rx, Ry);
end;

procedure TQCanvas.RoundRect(X1, Y1, X2, Y2: Double; RxBottom, RyBottom, RxTop, RyTop: Double);
begin
  ApplyState;
  FAgg.RoundedRect(X1, Y1, X2, Y2, RxBottom, RyBottom, RxTop, RyTop);
end;

procedure TQCanvas.RoundedRect(X1, Y1, X2, Y2: Double; Rx, Ry: Double);
begin
  RoundRect(X1, Y1, X2, Y2, Rx, Ry);
end;

procedure TQCanvas.RoundedRect(const ARect: TRect; Rx, Ry: Double);
begin
  RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, Rx, Ry);
end;

procedure TQCanvas.RoundedRect(X1, Y1, X2, Y2: Double; R: Double);
begin
  RoundRect(X1, Y1, X2, Y2, R);
end;

procedure TQCanvas.RoundedRect(const ARect: TRectDouble; R: Double);
begin
  RoundRect(ARect, R);
end;

procedure TQCanvas.RoundedRect(const ARect: TRectDouble; Rx, Ry: Double);
begin
  RoundRect(ARect, Rx, Ry);
end;

procedure TQCanvas.RoundedRect(X1, Y1, X2, Y2: Double; RxBottom, RyBottom, RxTop, RyTop: Double);
begin
  RoundRect(X1, Y1, X2, Y2, RxBottom, RyBottom, RxTop, RyTop);
end;

procedure TQCanvas.CalcArcAngles(Cx, Cy, X3, Y3, X4, Y4: Double; out StartAngle, SweepAngle: Double);
var
  EndAngle: Double;
begin
  StartAngle := ArcTan2(Y3 - Cy, X3 - Cx);
  EndAngle := ArcTan2(Y4 - Cy, X4 - Cx);
  SweepAngle := EndAngle - StartAngle;
  if SweepAngle < 0 then
    SweepAngle := SweepAngle + (2 * Pi);
end;

function TQCanvas.CreateAggImage(AGraphic: TGraphic; out OutBmpToFree: TBitmap; out OutConvertedBuffer: PByte): TAgg2DImage;
var
  LocalBmp: TBitmap;
  DataPtr: PByte;
  Stride, AbsStride, Y, X: Integer;
  SrcRow, DstRow: PByte;
begin
  Result := nil;
  OutBmpToFree := nil;
  OutConvertedBuffer := nil;
  if not Assigned(AGraphic) then Exit;

  if AGraphic is TBitmap then
    LocalBmp := TBitmap(AGraphic)
  else
  begin
    LocalBmp := TBitmap.Create;
    LocalBmp.Assign(AGraphic);
    LocalBmp.PixelFormat := pf32bit;
    OutBmpToFree := LocalBmp;
  end;

  DataPtr := PByte(LocalBmp.RawImage.Data);
  Stride := LocalBmp.RawImage.Description.BytesPerLine;

  if LocalBmp.RawImage.Description.LineOrder = riloBottomToTop then
  begin
    Inc(DataPtr, (LocalBmp.Height - 1) * Stride);
    Stride := -Stride;
  end;

  // If the canvas is native BGRA, no conversion is necessary; wrap directly.
  if FPixelFormat = pfBGRA then
  begin
    Result := TAgg2DImage.Create(DataPtr, LocalBmp.Width, LocalBmp.Height, Stride);
    Exit;
  end;

  // Cache AbsStride to avoid recalculation inside the row loop
  AbsStride := Abs(Stride);
  GetMem(OutConvertedBuffer, AbsStride * LocalBmp.Height);
  for Y := 0 to LocalBmp.Height - 1 do
  begin
    SrcRow := DataPtr + (Y * Stride);
    DstRow := OutConvertedBuffer + (Y * AbsStride);
    for X := 0 to LocalBmp.Width - 1 do
    begin
      // SrcRow is BGRA: [0]=B, [1]=G, [2]=R, [3]=A
      DstRow[X * 4 + FOffsetR] := SrcRow[X * 4 + 2]; // R
      DstRow[X * 4 + FOffsetG] := SrcRow[X * 4 + 1]; // G
      DstRow[X * 4 + FOffsetB] := SrcRow[X * 4 + 0]; // B
      DstRow[X * 4 + FOffsetA] := SrcRow[X * 4 + 3]; // A
    end;
  end;

  Result := TAgg2DImage.Create(OutConvertedBuffer, LocalBmp.Width, LocalBmp.Height, AbsStride);
end;

procedure TQCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double);
var
  Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double;
begin
  Cx := (X1 + X2) / 2.0;
  Cy := (Y1 + Y2) / 2.0;
  Rx := Abs(X2 - X1) / 2.0;
  Ry := Abs(Y2 - Y1) / 2.0;
  CalcArcAngles(Cx, Cy, X3, Y3, X4, Y4, StartAngle, SweepAngle);
  ApplyState;
  FAgg.NoFill;
  FAgg.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle);
end;

procedure TQCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double);
var
  Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double;
begin
  Cx := (X1 + X2) / 2.0;
  Cy := (Y1 + Y2) / 2.0;
  Rx := Abs(X2 - X1) / 2.0;
  Ry := Abs(Y2 - Y1) / 2.0;
  CalcArcAngles(Cx, Cy, X3, Y3, X4, Y4, StartAngle, SweepAngle);
  ApplyState;
  FAgg.ResetPath;
  FAgg.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle);
  FAgg.ClosePolygon;
  FAgg.DrawPath(dpfFillAndStroke);
end;

procedure TQCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double);
var
  Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double;
begin
  Cx := (X1 + X2) / 2.0;
  Cy := (Y1 + Y2) / 2.0;
  Rx := Abs(X2 - X1) / 2.0;
  Ry := Abs(Y2 - Y1) / 2.0;
  CalcArcAngles(Cx, Cy, X3, Y3, X4, Y4, StartAngle, SweepAngle);
  ApplyState;
  FAgg.ResetPath;
  FAgg.MoveTo(Cx, Cy);
  FAgg.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle);
  FAgg.ClosePolygon;
  FAgg.DrawPath(dpfFillAndStroke);
end;

procedure TQCanvas.Polygon(const Points: TPointDoubleArray);
begin
  if Length(Points) > 1 then
  begin
    ApplyState;
    FAgg.Polygon(PPointDouble(@Points[0]), Length(Points), dpfFillAndStroke);
  end;
end;

procedure TQCanvas.Polygon(const Points: array of TPoint);
var
  PtArr: TPointDoubleArray;
  I: Integer;
begin
  if Length(Points) < 2 then Exit;
  PtArr := Default(TPointDoubleArray);
  SetLength(PtArr, Length(Points));
  for I := 0 to High(Points) do
    PtArr[I] := PointDouble(Points[I].X, Points[I].Y);
  Polygon(PtArr);
end;

procedure TQCanvas.Polyline(const Points: TPointDoubleArray);
begin
  if Length(Points) > 1 then
  begin
    ApplyState;
    FAgg.NoFill;
    FAgg.Polyline(PPointDouble(@Points[0]), Length(Points));
  end;
end;

procedure TQCanvas.Polyline(const Points: array of TPoint);
var
  PtArr: TPointDoubleArray;
  I: Integer;
begin
  if Length(Points) < 2 then Exit;
  PtArr := Default(TPointDoubleArray);
  SetLength(PtArr, Length(Points));
  for I := 0 to High(Points) do
    PtArr[I] := PointDouble(Points[I].X, Points[I].Y);
  Polyline(PtArr);
end;

procedure TQCanvas.PolyBezier(const Points: TPointDoubleArray);
var
  I: Integer;
begin
  if Length(Points) < 4 then Exit;
  ApplyState;
  FAgg.NoFill;
  FAgg.ResetPath;
  FAgg.MoveTo(Points[0].X, Points[0].Y);
  I := 1;
  while I + 2 < Length(Points) do
  begin
    FAgg.CubicCurveTo(Points[I].X, Points[I].Y, Points[I + 1].X, Points[I + 1].Y, Points[I + 2].X, Points[I + 2].Y);
    Inc(I, 3);
  end;
  FAgg.DrawPath(dpfStrokeOnly);
end;

procedure TQCanvas.PolyBezier(const Points: array of TPoint);
var
  PtArr: TPointDoubleArray;
  I: Integer;
begin
  if Length(Points) < 4 then Exit;
  PtArr := Default(TPointDoubleArray);
  SetLength(PtArr, Length(Points));
  for I := 0 to High(Points) do
    PtArr[I] := PointDouble(Points[I].X, Points[I].Y);
  PolyBezier(PtArr);
end;

procedure TQCanvas.PolyBezierTo(const Points: TPointDoubleArray);
var
  I: Integer;
begin
  if Length(Points) < 3 then Exit;
  ApplyState;
  FAgg.ResetPath;
  FAgg.MoveTo(FPenPos.X, FPenPos.Y);
  I := 0;
  while I + 2 < Length(Points) do
  begin
    FAgg.CubicCurveTo(Points[I].X, Points[I].Y, Points[I + 1].X, Points[I + 1].Y, Points[I + 2].X, Points[I + 2].Y);
    Inc(I, 3);
  end;
  FAgg.DrawPath(dpfStrokeOnly);
  FPenPos := Points[High(Points)];
end;

procedure TQCanvas.PolyBezierTo(const Points: array of TPoint);
var
  PtArr: TPointDoubleArray;
  I: Integer;
begin
  if Length(Points) < 3 then Exit;
  PtArr := Default(TPointDoubleArray);
  SetLength(PtArr, Length(Points));
  for I := 0 to High(Points) do
    PtArr[I] := PointDouble(Points[I].X, Points[I].Y);
  PolyBezierTo(PtArr);
end;

{ Text & Metrics }

procedure TQCanvas.TextOut(X, Y: Double; const Text: String);
begin
  FFont.ApplyFont(FFont.Angle);
  FAgg.Text(X, Y, AnsiString(VisualOrderUTF8(Text)));
end;

procedure TQCanvas.TextOutR(X, Y, RotDeg: Double; const Text: String);
var
  SavedAngle: Double;
begin
  SavedAngle := FFont.Angle;
  try
    FFont.ApplyFont(RotDeg);
    FAgg.Text(X, Y, AnsiString(VisualOrderUTF8(Text)));
  finally
    FFont.ApplyFont(SavedAngle);
  end;
end;

procedure TQCanvas.TextRect(const ARect: TRect; X, Y: Double; const Text: String);
var
  OldClip: TRectDouble;
begin
  OldClip := FAgg.ClipBox;
  FAgg.ClipBox(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  TextOut(X, Y, Text);
  FAgg.ClipBox(OldClip.X1, OldClip.Y1, OldClip.X2, OldClip.Y2);
end;

procedure TQCanvas.TextRect(const ARect: TRectDouble; X, Y: Double; const Text: String);
var
  OldClip: TRectDouble;
begin
  OldClip := FAgg.ClipBox;
  FAgg.ClipBox(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2);
  TextOut(X, Y, Text);
  FAgg.ClipBox(OldClip.X1, OldClip.Y1, OldClip.X2, OldClip.Y2);
end;

function TQCanvas.TextWidth(const Text: String): Double;
begin
  if Text = '' then Exit(0.0);
  FFont.ApplyFont(0.0);
  Result := FAgg.TextWidth(AnsiString(Text));
end;

function TQCanvas.TextHeight(const Text: String): Double;
begin
  FFont.ApplyFont(0.0);
  Result := FAgg.FontHeight;
end;

function TQCanvas.TextExtent(const Text: String): TSize;
begin
  Result.cx := Round(TextWidth(Text));
  Result.cy := Round(TextHeight(Text));
end;

{ Graphic Rendering }
procedure TQCanvas.Draw(X, Y: Double; AGraphic: TGraphic);
var
  AggImg: TAgg2DImage;
  TempBmp: TBitmap;
  ConvertedBuffer: PByte;
begin
  if not Assigned(AGraphic) then Exit;
  AggImg := CreateAggImage(AGraphic, TempBmp, ConvertedBuffer);
  if Assigned(AggImg) then
  try
    FAgg.BlendImage(AggImg, X, Y, 255);
  finally
    AggImg.Free;
    if Assigned(ConvertedBuffer) then
      FreeMem(ConvertedBuffer);
    if Assigned(TempBmp) then
      TempBmp.Free;
  end;
end;

procedure TQCanvas.StretchDraw(X1, Y1, X2, Y2: Double; AGraphic: TGraphic);
var
  AggImg: TAgg2DImage;
  TempBmp: TBitmap;
  ConvertedBuffer: PByte;
begin
  if not Assigned(AGraphic) then Exit;
  AggImg := CreateAggImage(AGraphic, TempBmp, ConvertedBuffer);
  if Assigned(AggImg) then
  try
    FAgg.TransformImage(AggImg, X1, Y1, X2, Y2);
  finally
    AggImg.Free;
    if Assigned(ConvertedBuffer) then
      FreeMem(ConvertedBuffer);
    if Assigned(TempBmp) then
      TempBmp.Free;
  end;
end;

procedure TQCanvas.StretchDraw(const ARect: TRect; AGraphic: TGraphic);
begin
  StretchDraw(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, AGraphic);
end;

procedure TQCanvas.StretchDraw(const ARect: TRectDouble; AGraphic: TGraphic);
begin
  StretchDraw(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2, AGraphic);
end;

procedure TQCanvas.CopyRect(const DestRect: TRectDouble; SourceCanvas: TQCanvas; const SourceRect: TRectDouble);
var
  AggImg: TAgg2DImage;
  DataPtr, ConvertedData, SrcRow, DstRow: PByte;
  Stride, AbsStride, Y, X: Integer;
begin
  if (SourceCanvas = nil) or not SourceCanvas.FBufferAllocated or (SourceCanvas.FRawImage.Data = nil) then
    Exit;

  DataPtr := PByte(SourceCanvas.FRawImage.Data);
  Stride := SourceCanvas.FRawImage.Description.BytesPerLine;

  if SourceCanvas.FRawImage.Description.LineOrder = riloBottomToTop then
  begin
    Inc(DataPtr, (SourceCanvas.FHeight - 1) * Stride);
    Stride := -Stride;
  end;

  ConvertedData := nil;

  // Perform on-the-fly channel conversion if pixel formats differ
  if SourceCanvas.PixelFormat <> FPixelFormat then
  begin
    AbsStride := Abs(Stride);
    GetMem(ConvertedData, AbsStride * SourceCanvas.FHeight);
    for Y := 0 to SourceCanvas.FHeight - 1 do
    begin
      SrcRow := DataPtr + (Y * Stride);
      DstRow := ConvertedData + (Y * AbsStride);
      for X := 0 to SourceCanvas.FWidth - 1 do
      begin
        DstRow[X * 4 + FOffsetR] := SrcRow[X * 4 + SourceCanvas.FOffsetR];
        DstRow[X * 4 + FOffsetG] := SrcRow[X * 4 + SourceCanvas.FOffsetG];
        DstRow[X * 4 + FOffsetB] := SrcRow[X * 4 + SourceCanvas.FOffsetB];
        DstRow[X * 4 + FOffsetA] := SrcRow[X * 4 + SourceCanvas.FOffsetA];
      end;
    end;
    AggImg := TAgg2DImage.Create(ConvertedData, SourceCanvas.FWidth, SourceCanvas.FHeight, AbsStride);
  end
  else
    AggImg := TAgg2DImage.Create(DataPtr, SourceCanvas.FWidth, SourceCanvas.FHeight, Stride);

  try
    FAgg.TransformImage(AggImg,
                       Trunc(SourceRect.X1), Trunc(SourceRect.Y1), Ceil(SourceRect.X2), Ceil(SourceRect.Y2),
                       DestRect.X1, DestRect.Y1, DestRect.X2, DestRect.Y2);
  finally
    AggImg.Free;
    if Assigned(ConvertedData) then
      FreeMem(ConvertedData);
  end;
end;

procedure TQCanvas.CopyRect(const DestRect: TRect; SourceCanvas: TQCanvas; const SourceRect: TRect);
begin
  // Forward integer TRect directly to the format-safe TRectDouble overload
  CopyRect(RectDouble(DestRect.Left, DestRect.Top, DestRect.Right, DestRect.Bottom),
           SourceCanvas,
           RectDouble(SourceRect.Left, SourceRect.Top, SourceRect.Right, SourceRect.Bottom));
end;

{ Pipeline, Geometry & Shapes }

procedure TQCanvas.ClearAll(Color: TColor; Alpha: Byte);
var
  RGBVal: LongInt;
begin
  RGBVal := ColorToRGB(Color);
  FAgg.ClearAll(Red(RGBVal), Green(RGBVal), Blue(RGBVal), Alpha);
end;

procedure TQCanvas.ClearClipBox(Color: TColor; Alpha: Byte);
var
  RGBVal: LongInt;
begin
  RGBVal := ColorToRGB(Color);
  FAgg.ClearClipBox(Red(RGBVal), Green(RGBVal), Blue(RGBVal), Alpha);
end;

procedure TQCanvas.SetClipBox(X1, Y1, X2, Y2: Double);
begin
  FAgg.ClipBox(X1, Y1, X2, Y2);
end;

procedure TQCanvas.SetClipBox(const ARect: TRectDouble);
begin
  FAgg.ClipBox(ARect.X1, ARect.Y1, ARect.X2, ARect.Y2);
end;

function TQCanvas.GetClipBox: TRectDouble;
begin
  Result := FAgg.ClipBox;
end;

procedure TQCanvas.ResetClipping;
begin
  FAgg.ClipBox(0, 0, FWidth, FHeight);
end;

procedure TQCanvas.WorldToScreen(var X, Y: Double); begin FAgg.WorldToScreen(X, Y); end;
procedure TQCanvas.ScreenToWorld(var X, Y: Double); begin FAgg.ScreenToWorld(X, Y); end;
function TQCanvas.WorldToScreen(Scalar: Double): Double; begin Result := FAgg.WorldToScreen(Scalar); end;
function TQCanvas.ScreenToWorld(Scalar: Double): Double; begin Result := FAgg.ScreenToWorld(Scalar); end;

procedure TQCanvas.AlignPoint(var X, Y: Double); begin FAgg.AlignPoint(X, Y); end;
function TQCanvas.InBox(WorldX, WorldY: Double): Boolean; begin Result := FAgg.InBox(WorldX, WorldY); end;
function TQCanvas.InBox(const World: TPointDouble): Boolean; begin Result := FAgg.InBox(World); end;

procedure TQCanvas.EllipseCenter(Cx, Cy, Rx, Ry: Double);
begin
  ApplyState;
  FAgg.Ellipse(Cx, Cy, Rx, Ry);
end;

procedure TQCanvas.Circle(Cx, Cy, Radius: Double);
begin
  ApplyState;
  FAgg.Circle(Cx, Cy, Radius);
end;

procedure TQCanvas.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle);
end;

procedure TQCanvas.Pie(Cx, Cy, Rx, Ry, StartAngle, SweepAngle: Double);
begin
  ApplyState;
  FAgg.ResetPath;
  FAgg.MoveTo(Cx, Cy);
  FAgg.Arc(Cx, Cy, Rx, Ry, StartAngle, SweepAngle);
  FAgg.ClosePolygon;
  FAgg.DrawPath(dpfFillAndStroke);
end;

procedure TQCanvas.Star(Cx, Cy, R1, R2, StartAngle: Double; NumRays: Integer);
begin
  ApplyState;
  FAgg.Star(Cx, Cy, R1, R2, StartAngle, NumRays);
end;

procedure TQCanvas.Curve(X1, Y1, X2, Y2, X3, Y3: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.Curve(X1, Y1, X2, Y2, X3, Y3);
end;

procedure TQCanvas.Curve(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.Curve(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TQCanvas.QuadricCurveTo(XCtrl, YCtrl, XTo, YTo: Double);
begin
  FAgg.QuadricCurveTo(XCtrl, YCtrl, XTo, YTo);
  FPenPos := PointDouble(XTo, YTo);
end;

procedure TQCanvas.QuadricCurveTo(XTo, YTo: Double);
begin
  FAgg.QuadricCurveTo(XTo, YTo);
  FPenPos := PointDouble(XTo, YTo);
end;

procedure TQCanvas.QuadricCurveRel(DxCtrl, DyCtrl, DxTo, DyTo: Double);
begin
  FAgg.QuadricCurveRel(DxCtrl, DyCtrl, DxTo, DyTo);
  FPenPos := PointDouble(FPenPos.X + DxTo, FPenPos.Y + DyTo);
end;

procedure TQCanvas.QuadricCurveRel(DxTo, DyTo: Double);
begin
  FAgg.QuadricCurveRel(DxTo, DyTo);
  FPenPos := PointDouble(FPenPos.X + DxTo, FPenPos.Y + DyTo);
end;

procedure TQCanvas.CubicCurveTo(XCtrl1, YCtrl1, XCtrl2, YCtrl2, XTo, YTo: Double);
begin
  FAgg.CubicCurveTo(XCtrl1, YCtrl1, XCtrl2, YCtrl2, XTo, YTo);
  FPenPos := PointDouble(XTo, YTo);
end;

procedure TQCanvas.CubicCurveTo(XCtrl2, YCtrl2, XTo, YTo: Double);
begin
  FAgg.CubicCurveTo(XCtrl2, YCtrl2, XTo, YTo);
  FPenPos := PointDouble(XTo, YTo);
end;

procedure TQCanvas.CubicCurveRel(DxCtrl1, DyCtrl1, DxCtrl2, DyCtrl2, DxTo, DyTo: Double);
begin
  FAgg.CubicCurveRel(DxCtrl1, DyCtrl1, DxCtrl2, DyCtrl2, DxTo, DyTo);
  FPenPos := PointDouble(FPenPos.X + DxTo, FPenPos.Y + DyTo);
end;

procedure TQCanvas.CubicCurveRel(DxCtrl2, DyCtrl2, DxTo, DyTo: Double);
begin
  FAgg.CubicCurveRel(DxCtrl2, DyCtrl2, DxTo, DyTo);
  FPenPos := PointDouble(FPenPos.X + DxTo, FPenPos.Y + DyTo);
end;

procedure TQCanvas.MoveRel(Dx, Dy: Double);
begin
  FPenPos := PointDouble(FPenPos.X + Dx, FPenPos.Y + Dy);
  FAgg.MoveRel(Dx, Dy);
end;

procedure TQCanvas.LineRel(Dx, Dy: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.LineRel(Dx, Dy);
  FPenPos := PointDouble(FPenPos.X + Dx, FPenPos.Y + Dy);
end;

procedure TQCanvas.HorizontalLineTo(X: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.HorizontalLineTo(X);
  FPenPos.X := X;
end;

procedure TQCanvas.HorizontalLineRel(Dx: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.HorizontalLineRel(Dx);
  FPenPos.X := FPenPos.X + Dx;
end;

procedure TQCanvas.VerticalLineTo(Y: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.VerticalLineTo(Y);
  FPenPos.Y := Y;
end;

procedure TQCanvas.VerticalLineRel(Dy: Double);
begin
  ApplyState;
  FAgg.NoFill;
  FAgg.VerticalLineRel(Dy);
  FPenPos.Y := FPenPos.Y + Dy;
end;

procedure TQCanvas.ArcTo(Rx, Ry, Angle: Double; LargeArcFlag, SweepFlag: Boolean; X, Y: Double);
begin
  FAgg.ArcTo(Rx, Ry, Angle, LargeArcFlag, SweepFlag, X, Y);
  FPenPos := PointDouble(X, Y);
end;

procedure TQCanvas.ArcRel(Rx, Ry, Angle: Double; LargeArcFlag, SweepFlag: Boolean; Dx, Dy: Double);
begin
  FAgg.ArcRel(Rx, Ry, Angle, LargeArcFlag, SweepFlag, Dx, Dy);
  FPenPos := PointDouble(FPenPos.X + Dx, FPenPos.Y + Dy);
end;

procedure TQCanvas.FillLinearGradient(X1, Y1, X2, Y2: Double; Color1, Color2: TColor; Alpha1: Byte; Alpha2: Byte; Profile: Double);
begin
  FHasFillGradient := True;
  FAgg.FillLinearGradient(X1, Y1, X2, Y2, GetAggColor(Color1, Alpha1), GetAggColor(Color2, Alpha2), Profile);
end;

procedure TQCanvas.LineLinearGradient(X1, Y1, X2, Y2: Double; Color1, Color2: TColor; Alpha1: Byte; Alpha2: Byte; Profile: Double);
begin
  FHasLineGradient := True;
  FAgg.LineLinearGradient(X1, Y1, X2, Y2, GetAggColor(Color1, Alpha1), GetAggColor(Color2, Alpha2), Profile);
end;

procedure TQCanvas.FillRadialGradient(X, Y, Radius: Double; Color1, Color2: TColor; Alpha1: Byte; Alpha2: Byte);
begin
  FHasFillGradient := True;
  FAgg.FillRadialGradient(X, Y, Radius, GetAggColor(Color1, Alpha1), GetAggColor(Color2, Alpha2), 1.0);
end;

procedure TQCanvas.FillRadialGradient(X, Y, Radius: Double; Color1, Color2, Color3: TColor; A1, A2, A3: Byte);
begin
  FHasFillGradient := True;
  FAgg.FillRadialGradient(X, Y, Radius, GetAggColor(Color1, A1), GetAggColor(Color2, A2), GetAggColor(Color3, A3));
end;

procedure TQCanvas.LineRadialGradient(X, Y, Radius: Double; Color1, Color2: TColor; Alpha1: Byte; Alpha2: Byte);
begin
  FHasLineGradient := True;
  FAgg.LineRadialGradient(X, Y, Radius, GetAggColor(Color1, Alpha1), GetAggColor(Color2, Alpha2), 1.0);
end;

procedure TQCanvas.LineRadialGradient(X, Y, Radius: Double; Color1, Color2, Color3: TColor; A1, A2, A3: Byte);
begin
  FHasLineGradient := True;
  FAgg.LineRadialGradient(X, Y, Radius, GetAggColor(Color1, A1), GetAggColor(Color2, A2), GetAggColor(Color3, A3));
end;

procedure TQCanvas.FillRadialGradient(X, Y, Radius: Double);
begin
  FHasFillGradient := True;
  FAgg.FillRadialGradient(X, Y, Radius);
end;

procedure TQCanvas.LineRadialGradient(X, Y, Radius: Double);
begin
  FHasLineGradient := True;
  FAgg.LineRadialGradient(X, Y, Radius);
end;

procedure TQCanvas.AddDash(DashLen, GapLen: Double);
begin
  FAgg.AddDash(DashLen, GapLen);
end;

procedure TQCanvas.RemoveAllDashes;
begin
  FAgg.RemoveAllDashes;
end;

function TQCanvas.GetTransformations: TAggTransformations;
begin
  Result := FAgg.GetTransformations;
end;

procedure TQCanvas.SetTransformations(var Tr: TAggTransformations);
begin
  FAgg.SetTransformations(Tr);
end;

procedure TQCanvas.SetTransformations(V0, V1, V2, V3, V4, V5: Double);
begin
  FAgg.SetTransformations(V0, V1, V2, V3, V4, V5);
end;

procedure TQCanvas.Rotate(AngleRad: Double);
begin
  FAgg.Rotate(AngleRad);
end;

procedure TQCanvas.Scale(Sx, Sy: Double);
begin
  FAgg.Scale(Sx, Sy);
end;

procedure TQCanvas.Skew(Sx, Sy: Double);
begin
  FAgg.Skew(Sx, Sy);
end;

procedure TQCanvas.Translate(X, Y: Double);
begin
  FAgg.Translate(X, Y);
end;

procedure TQCanvas.ResetTransformations;
begin
  FAgg.ResetTransformations;
end;

procedure TQCanvas.SetAffineTransform(const Trans: TAggTransAffine);
var
  Tr: TAggTransformations;
begin
  Trans.StoreTo(@Tr.AffineMatrix[0]);
  FAgg.SetTransformations(Tr);
end;

procedure TQCanvas.Affine(const Trans: TAggTransAffine);
begin
  FAgg.Affine(Trans);
end;

procedure TQCanvas.Affine(var Tr: TAggTransformations);
begin
  FAgg.Affine(Tr);
end;

procedure TQCanvas.Parallelogram(X1, Y1, X2, Y2: Double; Para: PDouble);
begin
  FAgg.Parallelogram(X1, Y1, X2, Y2, Para);
end;

procedure TQCanvas.Viewport(WorldX1, WorldY1, WorldX2, WorldY2, ScreenX1, ScreenY1, ScreenX2, ScreenY2: Double; Opt: TAggViewportOption);
begin
  FAgg.Viewport(WorldX1, WorldY1, WorldX2, WorldY2, ScreenX1, ScreenY1, ScreenX2, ScreenY2, Opt);
end;

procedure TQCanvas.Viewport(World, Screen: TRectDouble; Opt: TAggViewportOption);
begin
  FAgg.Viewport(World, Screen, Opt);
end;

procedure TQCanvas.ResetPath;
begin
  FAgg.ResetPath;
end;

procedure TQCanvas.ClosePolygon;
begin
  FAgg.ClosePolygon;
end;

procedure TQCanvas.DrawPath(Flag: TAggDrawPathFlag);
begin
  ApplyState;
  FAgg.DrawPath(Flag);
end;

procedure TQCanvas.DrawPathNoTransform(Flag: TAggDrawPathFlag);
begin
  ApplyState;
  FAgg.DrawPathNoTransform(Flag);
end;

procedure TQCanvas.AddLine(X1, Y1, X2, Y2: Double);
begin
  FAgg.AddLine(X1, Y1, X2, Y2);
  FPenPos := PointDouble(X2, Y2);
end;

procedure TQCanvas.AddEllipse(Cx, Cy, Rx, Ry: Double; Dir: TAggDirection);
begin
  FAgg.AddEllipse(Cx, Cy, Rx, Ry, Dir);
end;

procedure TQCanvas.AddEllipse(Center, Radius: TPointDouble; Dir: TAggDirection);
begin
  FAgg.AddEllipse(Center, Radius, Dir);
end;

{ Image Transformations }

procedure TQCanvas.BlendImage(Img: TAgg2DImage; DstX, DstY: Double; Alpha: Cardinal);
begin
  FAgg.BlendImage(Img, DstX, DstY, Alpha);
end;

procedure TQCanvas.BlendImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX, DstY: Double; Alpha: Cardinal);
begin
  FAgg.BlendImage(Img, ImgX1, ImgY1, ImgX2, ImgY2, DstX, DstY, Alpha);
end;

procedure TQCanvas.CopyImage(Img: TAgg2DImage; DstX, DstY: Double);
begin
  FAgg.CopyImage(Img, DstX, DstY);
end;

procedure TQCanvas.CopyImage(Img: TAgg2DImage; const Destination: TPointDouble);
begin
  FAgg.CopyImage(Img, Destination);
end;

procedure TQCanvas.CopyImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX, DstY: Double);
begin
  FAgg.CopyImage(Img, ImgX1, ImgY1, ImgX2, ImgY2, DstX, DstY);
end;

procedure TQCanvas.CopyImage(Img: TAgg2DImage; ImgRect: TRectInteger; const Destination: TPointDouble);
begin
  FAgg.CopyImage(Img, ImgRect, Destination);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; DstX1, DstY1, DstX2, DstY2: Double);
begin
  FAgg.TransformImage(Img, DstX1, DstY1, DstX2, DstY2);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; const Destination: TRectDouble);
begin
  FAgg.TransformImage(Img, Destination);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX1, DstY1, DstX2, DstY2: Double);
begin
  FAgg.TransformImage(Img, ImgX1, ImgY1, ImgX2, ImgY2, DstX1, DstY1, DstX2, DstY2);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; DstX1, DstY1, DstX2, DstY2: Double);
begin
  FAgg.TransformImage(Img, ImgRect, DstX1, DstY1, DstX2, DstY2);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; AParallelogram: PDouble);
begin
  FAgg.TransformImage(Img, AParallelogram);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; AParallelogram: PDouble);
begin
  FAgg.TransformImage(Img, ImgX1, ImgY1, ImgX2, ImgY2, AParallelogram);
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; AParallelogram: PDouble);
begin
  FAgg.TransformImage(Img, ImgRect, AParallelogram);
end;

procedure TQCanvas.TransformImagePath(Img: TAgg2DImage; DstX1, DstY1, DstX2, DstY2: Double);
begin
  FAgg.TransformImagePath(Img, DstX1, DstY1, DstX2, DstY2);
end;

procedure TQCanvas.TransformImagePath(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; DstX1, DstY1, DstX2, DstY2: Double);
begin
  FAgg.TransformImagePath(Img, ImgX1, ImgY1, ImgX2, ImgY2, DstX1, DstY1, DstX2, DstY2);
end;

procedure TQCanvas.TransformImagePath(Img: TAgg2DImage; AParallelogram: PDouble);
begin
  FAgg.TransformImagePath(Img, AParallelogram);
end;

procedure TQCanvas.TransformImagePath(Img: TAgg2DImage; ImgX1, ImgY1, ImgX2, ImgY2: Integer; AParallelogram: PDouble);
begin
  FAgg.TransformImagePath(Img, ImgX1, ImgY1, ImgX2, ImgY2, AParallelogram);
end;

procedure TQCanvas.SetFontForScript(Script: TScriptType);
begin
  FFont.SetForScript(Script);
end;

procedure TQCanvas.SetFontForLangID(ALangID: Integer);
begin
  FFont.SetForLangID(ALangID);
end;

function TQCanvas.GetRow(Y: Cardinal): PByte;
begin
  Result := PByte(FAgg.Row[Y]);
end;

procedure TQCanvas.WorldToScreen(X, Y: PDouble);
begin
  FAgg.WorldToScreen(X, Y);
end;

procedure TQCanvas.ScreenToWorld(X, Y: PDouble);
begin
  FAgg.ScreenToWorld(X, Y);
end;

procedure TQCanvas.AlignPoint(X, Y: PDouble);
begin
  FAgg.AlignPoint(X, Y);
end;

procedure TQCanvas.Polygon(Xy: PPointDouble; NumPoints: Integer; Flag: TAggDrawPathFlag);
begin
  if (Xy <> nil) and (NumPoints > 1) then
  begin
    ApplyState;
    FAgg.Polygon(Xy, NumPoints, Flag);
  end;
end;

procedure TQCanvas.Polyline(Xy: PPointDouble; NumPoints: Integer);
begin
  if (Xy <> nil) and (NumPoints > 1) then
  begin
    ApplyState;
    FAgg.NoFill;
    FAgg.Polyline(Xy, NumPoints);
  end;
end;

procedure TQCanvas.TransformImage(Img: TAgg2DImage; ImgRect: TRectInteger; const Destination: TRectDouble);
begin
  FAgg.TransformImage(Img, ImgRect, Destination);
end;


end.
