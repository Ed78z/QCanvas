unit Unit1;

{$mode objfpc}{$H+}
{$CODEPAGE UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Types,
  QLanguages, QFont, QCanvas;

type
  { TForm1 }
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1Paint(Sender: TObject);
    procedure Panel2Paint(Sender: TObject);
  private
    FBmpGdi: TBitmap;
    FBmpAgg: TBitmap;
    FQCanvasBmp: TQCanvas;
    FQCanvasPanel: TQCanvas;

    procedure DrawGdiShapes(ACanvas: TCanvas; AWidth, AHeight: Integer);
    procedure DrawAggShapes(AQCanvas: TQCanvas; {%H-}AWidth, AHeight: Integer);
    procedure DrawGdiRotatedText(ACanvas: TCanvas; AWidth, AHeight: Integer);
    procedure DrawAggRotatedText(AQCanvas: TQCanvas; {%H-}AWidth, AHeight: Integer);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FBmpGdi := TBitmap.Create;
  FBmpGdi.SetSize(Image1.Width, Image1.Height);
  FBmpGdi.PixelFormat := pf32bit;

  FBmpAgg := TBitmap.Create;
  FBmpAgg.SetSize(Image2.Width, Image2.Height);
  FBmpAgg.PixelFormat := pf32bit;

  FQCanvasBmp := TQCanvas.Create;
  FQCanvasPanel := TQCanvas.Create;

  // Top Left: Render GDI Shapes into Image1 bitmap
  DrawGdiShapes(FBmpGdi.Canvas, FBmpGdi.Width, FBmpGdi.Height);
  Image1.Picture.Assign(FBmpGdi);

  // Top Right: Render AGG Shapes into Image2 bitmap
  FBmpAgg.BeginUpdate(False);
  try
    FQCanvasBmp.AttachToBitmap(FBmpAgg);
    DrawAggShapes(FQCanvasBmp, FBmpAgg.Width, FBmpAgg.Height);
  finally
    FBmpAgg.EndUpdate(False);
  end;
  Image2.Picture.Assign(FBmpAgg);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FQCanvasPanel.Free;
  FQCanvasBmp.Free;
  FBmpAgg.Free;
  FBmpGdi.Free;
end;

procedure TForm1.Panel1Paint(Sender: TObject);
begin
  // Bottom Left: Direct GDI rendering with rotation
  DrawGdiRotatedText(Panel1.Canvas, Panel1.ClientWidth, Panel1.ClientHeight);
end;

procedure TForm1.Panel2Paint(Sender: TObject);
begin
  // Bottom Right: TQCanvas presenting directly to Window DC
  FQCanvasPanel.BeginPaint(Panel2.Canvas, Panel2.ClientWidth, Panel2.ClientHeight);
  try
    DrawAggRotatedText(FQCanvasPanel, Panel2.ClientWidth, Panel2.ClientHeight);
  finally
    FQCanvasPanel.EndPaint;
  end;
end;

{ Top Images: Vector Geometry, Gradient, and Alpha Comparison}
procedure TForm1.DrawGdiShapes(ACanvas: TCanvas; AWidth, AHeight: Integer);
var
  I: Integer;
  Angle: Double;
  X2, Y2: Integer;
  Pts: array[0..2] of TPoint;
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.FillRect(0, 0, AWidth, AHeight);

  // 1. Ray Burst: Standard aliased lines
  ACanvas.Pen.Color := $00808080;
  ACanvas.Pen.Width := 1;
  for I := 0 to 11 do
  begin
    Angle := I * (Pi / 6.0);
    X2 := 65 + Round(50 * Cos(Angle));
    Y2 := 65 + Round(50 * Sin(Angle));
    ACanvas.MoveTo(65, 65);
    ACanvas.LineTo(X2, Y2);
  end;

  // 2. Thick Curves (GDI limitation: Flat/Solid stroke, no gradient)
  ACanvas.Pen.Color := clNavy;
  ACanvas.Pen.Width := 10;
  ACanvas.Brush.Style := bsClear;
  ACanvas.Ellipse(140, 20, 220, 100);

  // 3. Polygon
  Pts[0] := Point(240, 95);
  Pts[1] := Point(285, 20);
  Pts[2] := Point(290, 95);
  ACanvas.Pen.Color := clMaroon;
  ACanvas.Pen.Width := 3;
  ACanvas.Brush.Color := clSilver;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Polygon(Pts);

  // 4. Overlapping Shapes (GDI limitation: Solid only, no alpha blending)
  ACanvas.Pen.Color := clBlue;
  ACanvas.Pen.Width := 2;
  ACanvas.Brush.Color := clBlue;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Ellipse(30, 140, 150, 260);

  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Width := 2;
  ACanvas.Brush.Color := clRed;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Ellipse(90, 140, 210, 260);

  ACanvas.Pen.Color := clLime;
  ACanvas.Pen.Width := 2;
  ACanvas.Brush.Color := clLime;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Ellipse(60, 180, 180, 290);

  // Caption
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Name := 'Arial';
  ACanvas.Font.Size := 9;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clDkGray;
  ACanvas.TextOut(10, AHeight - 22, 'GDI: Aliased Edges, No Alpha, No Gradients');
end;

procedure TForm1.DrawAggShapes(AQCanvas: TQCanvas; AWidth, AHeight: Integer);
var
  I: Integer;
  Angle: Double;
  X2, Y2: Double;
  Pts: array[0..2] of TPoint;
begin
  AQCanvas.ClearAll(clWhite, 255);

  // 1. Ray Burst: Subpixel Antialiased Vector Lines
  AQCanvas.Pen.Color := $00808080;
  AQCanvas.Pen.Width := 1.0;
  AQCanvas.Brush.Style := bsClear;
  for I := 0 to 11 do
  begin
    Angle := I * (Pi / 6.0);
    X2 := 65.0 + (50.0 * Cos(Angle));
    Y2 := 65.0 + (50.0 * Sin(Angle));
    AQCanvas.Line(65.0, 65.0, X2, Y2);
  end;

  // 2. Thick Curves with Linear Gradient Outline
  AQCanvas.Pen.Width := 10.0;
  AQCanvas.Pen.Cap := lcRound;
  AQCanvas.Brush.Style := bsClear;
  AQCanvas.LineLinearGradient(140, 20, 220, 100, clNavy, clAqua, 255, 255);
  AQCanvas.Ellipse(140.0, 20.0, 220.0, 100.0);

  // 3. Smooth Polygon with Subpixel Radial Fill
  Pts[0] := Point(240, 95);
  Pts[1] := Point(285, 20);
  Pts[2] := Point(290, 95);
  AQCanvas.Pen.Color := clMaroon;
  AQCanvas.Pen.Width := 3.0;
  AQCanvas.FillRadialGradient(270, 60, 45, clWhite, clBlack, 255, 220);
  AQCanvas.Polygon(Pts);

  // 4. Overlapping Translucent Discs (Porter-Duff Alpha Compositing)
  AQCanvas.Pen.Width := 2.0;

  AQCanvas.Pen.Color := clBlue;
  AQCanvas.Pen.Alpha := 210;
  AQCanvas.Brush.Color := clBlue;
  AQCanvas.Brush.Alpha := 140;
  AQCanvas.Ellipse(30.0, 140.0, 150.0, 260.0);

  AQCanvas.Pen.Color := clRed;
  AQCanvas.Pen.Alpha := 210;
  AQCanvas.Brush.Color := clRed;
  AQCanvas.Brush.Alpha := 140;
  AQCanvas.Ellipse(90.0, 140.0, 210.0, 260.0);

  AQCanvas.Pen.Color := clLime;
  AQCanvas.Pen.Alpha := 210;
  AQCanvas.Brush.Color := clLime;
  AQCanvas.Brush.Alpha := 140;
  AQCanvas.Ellipse(60.0, 180.0, 180.0, 290.0);

  // Caption
  AQCanvas.Brush.Style := bsClear;
  AQCanvas.SetFontForScript(scrLatin);
  AQCanvas.Font.Size := 9.0;
  AQCanvas.Font.Color := clDkGray;
  AQCanvas.Font.Alpha := 255;
  AQCanvas.Font.Cache := fcRaster;
  AQCanvas.TextOut(10.0, AHeight - 22.0, 'AGG: 8-bit AA, True Alpha, Gradient Paths');
end;

procedure TForm1.DrawGdiRotatedText(ACanvas: TCanvas; AWidth, AHeight: Integer);
var
  Y: Integer;
  OldOrient: Integer;
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.FillRect(0, 0, AWidth, AHeight);

  ACanvas.Brush.Style := bsClear;
  OldOrient := ACanvas.Font.Orientation;
  try
    // -22.5 degrees in GDI 0.1 deg increments
    ACanvas.Font.Orientation := -225;
    Y := 10;

    // 0. Persian
    ApplyFont(ACanvas.Font, scrPersian);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := $00804000;
    ACanvas.TextOut(20, Y, 'Persian: درود جهان');
    Inc(Y, 38);

    // 1. Latin
    ApplyFont(ACanvas.Font, scrLatin);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := clBlack;
    ACanvas.TextOut(20, Y, 'Latin: Standard Font Render');
    Inc(Y, 38);

    // 2. Greek
    ApplyFont(ACanvas.Font, scrGreek);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := clNavy;
    ACanvas.TextOut(20, Y, 'Greek: Ελληνική γλώσσα');
    Inc(Y, 38);

    // 3. Cyrillic
    ApplyFont(ACanvas.Font, scrCyrillic);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := clMaroon;
    ACanvas.TextOut(20, Y, 'Cyrillic: Русский текст');
    Inc(Y, 38);

    // 4. CJK
    ApplyFont(ACanvas.Font, scrCjk);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := $00008000;
    ACanvas.TextOut(20, Y, 'Chinese: 中文字体测试');
    Inc(Y, 38);

    // 5. Hebrew
    ApplyFont(ACanvas.Font, scrHebrew);
    ACanvas.Font.Size := 11;
    ACanvas.Font.Color := clPurple;
    ACanvas.TextOut(20, Y, 'Hebrew: עברית שלום');
  finally
    ACanvas.Font.Orientation := OldOrient;
  end;

  // Caption
  ApplyFont(ACanvas.Font, scrLatin);
  ACanvas.Font.Size := 9;
  ACanvas.Font.Color := clDkGray;
  ACanvas.TextOut(10, AHeight - 22, 'GDI: -22.5° Rotated, No Alpha, Jagged Vectors');
end;

procedure TForm1.DrawAggRotatedText(AQCanvas: TQCanvas; AWidth, AHeight: Integer);
var
  Y: Double;
  RotAngle: Double;
begin
  AQCanvas.ClearAll(clWhite, 255);
  AQCanvas.Pen.Style := psClear;

  RotAngle := -22.5;
  Y := 10.0;

  // 0. Persian (Rotated + Alpha 220 + RTL Run Reversal)
  AQCanvas.SetFontForScript(scrPersian);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := $00804000;
  AQCanvas.Font.Alpha := 220;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Persian: درود جهان');
  Y := Y + 38.0;

  // 1. Latin (Alpha: 230)
  AQCanvas.SetFontForScript(scrLatin);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := clBlack;
  AQCanvas.Font.Alpha := 230;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Latin: Standard Font Render');
  Y := Y + 38.0;

  // 2. Greek (Alpha: 200)
  AQCanvas.SetFontForScript(scrGreek);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := clNavy;
  AQCanvas.Font.Alpha := 200;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Greek: Ελληνική γλώσσα');
  Y := Y + 38.0;

  // 3. Cyrillic (Alpha: 190)
  AQCanvas.SetFontForScript(scrCyrillic);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := clMaroon;
  AQCanvas.Font.Alpha := 190;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Cyrillic: Русский текст');
  Y := Y + 38.0;

  // 4. CJK (Alpha: 210)
  AQCanvas.SetFontForScript(scrCjk);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := $00008000;
  AQCanvas.Font.Alpha := 210;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Chinese: 中文字体测试');
  Y := Y + 38.0;

  // 5. Hebrew (Alpha: 180 + BiDi Run Order)
  AQCanvas.SetFontForScript(scrHebrew);
  AQCanvas.Font.Size := 11.0;
  AQCanvas.Font.Color := clPurple;
  AQCanvas.Font.Alpha := 180;
  AQCanvas.Font.Cache := fcVector;
  AQCanvas.TextOutR(20.0, Y, RotAngle, 'Hebrew: עברית שלום');

  // Caption
  AQCanvas.SetFontForScript(scrLatin);
  AQCanvas.Font.Size := 9.0;
  AQCanvas.Font.Color := clDkGray;
  AQCanvas.Font.Alpha := 255;
  AQCanvas.Font.Cache := fcRaster;
  AQCanvas.TextOut(10.0, AHeight - 22.0, 'AGG: -22.5° Subpixel Vector Rotation & Real Alpha');
end;



end.
