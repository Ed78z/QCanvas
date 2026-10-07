unit QFont;

{ ============================================================================}
{ QFont, as part of TQ*/TQSk* packages                                        }
{ Copyright (C) 2026 Ed White (ew78ee@gmail.com)                              }
{                                                                             }
{ Permission to copy, use, modify, sell, and distribute this software for any }
{ purpose is hereby granted, subject to the following conditions:             }
{                                                                             }
{ 1. The above copyright notice and this permission notice must appear in all }
{    copies, substantial portions, or derivative works of this software.      }
{                                                                             }
{ 2. In binary, executable, or compiled distributions, the above copyright    }
{    notice and attribution to Ed White must be reproduced in the accompanying}
{    documentation, license file, or application credits/about dialog.        }
{                                                                             }
{ The software is provided "as is", without express or implied warranty, and  }
{ with no claim as to its suitability for any purpose. In no event shall the  }
{ author be liable for any claim, damages, or other liability arising from    }
{ the use of this software.                                                   }
{ ============================================================================}


{$mode objfpc}{$H+}
{$CODEPAGE UTF8}

interface

uses
  Classes, SysUtils, Forms, Graphics, Controls, QLanguages;


// Checks if a specified font family name is registered and available on the host operating system.
function IsFontInstalled(const AFontName: string): Boolean;

// Returns an ordered fallback list of candidate font family names suitable for a specific script.
function GetOSFontCandidates(Script: TScriptType): TStringArray;

// Overrides the default font selection for a given script with a user-specified typeface name.
procedure SetCustomScriptFont(Script: TScriptType; const AFontName: string);

// Retrieves the custom font family name assigned to a specific script, or an empty string if unset.
function GetCustomScriptFont(Script: TScriptType): string;

// Resets all user-defined script font overrides back to system candidate resolution defaults.
procedure ClearCustomScriptFonts;

// Flushes the internal cache of previously resolved script-to-font matches to force re-evaluation.
procedure ClearFontCache;

// Resolves and returns the best matching installed font family name for a given script.
function GetOSFontForScript(Script: TScriptType): string;

// Resolves and returns the best matching installed font family name for a Windows Language ID (LCID).
function GetOSFontForLangID(ALangID: Integer): string;

// Assigns the optimal resolved font name for a script directly to a TFont instance.
procedure ApplyFont(AFont: TFont; Script: TScriptType); overload;

// Assigns the optimal resolved font name for a Language ID directly to a TFont instance.
procedure ApplyFont(AFont: TFont; ALangID: Integer); overload;

// Accesses a control's font and configures its typeface to match the optimal script font.
procedure ApplyControlFont(AControl: TControl; Script: TScriptType); overload;

// Accesses a control's font and configures its typeface to match the optimal Language ID font.
procedure ApplyControlFont(AControl: TControl; ALangID: Integer); overload;

// Reorders bidirectional text runs and shapes cursive Arabic/Persian glyphs for left-to-right vector rendering.
function VisualOrderUTF8(const S: string): string;

// Locates the physical font file path (.ttf, .otf, .ttc) on disk matching a typeface name and style.
function ResolveFontFile(const AFontName: string; AStyle: TFontStyles = []): string;

//Guaranteed Platform Fallback Font Resolution
function GetPlatformFontFallback: string;

implementation

{$IF DEFINED(ANDROID)}
  {$DEFINE FONTS_ANDROID}
{$ELSEIF DEFINED(DARWIN)}
  {$DEFINE FONTS_MAC}
{$ELSEIF DEFINED(MSWINDOWS)}
  {$DEFINE FONTS_WIN}
{$ELSEIF DEFINED(LINUX) OR DEFINED(BSD) OR DEFINED(UNIX)}
  {$DEFINE FONTS_UNIX}
{$ELSE}
  {$DEFINE FONTS_NONE}
{$ENDIF}

const
  DefaultFontName = 'default';


const
  FONT_SEARCH_DIRS: array[0..11] of string = (
    {$IFDEF FONTS_WIN}
    'C:\Windows\Fonts\',
    'C:\ProgramData\Microsoft\Windows\Fonts\',
    '~\AppData\Local\Microsoft\Windows\Fonts\',
    '', '', '', '', '', '', '', '', ''
    {$ENDIF}
    {$IFDEF FONTS_UNIX}
    '/usr/share/fonts/truetype/',
    '/usr/share/fonts/truetype/dejavu/',
    '/usr/share/fonts/truetype/liberation/',
    '/usr/share/fonts/truetype/msttcorefonts/',
    '/usr/share/fonts/TTF/',
    '/usr/share/fonts/opentype/',
    '/usr/local/share/fonts/',
    '~/.fonts/',
    '~/.local/share/fonts/',
    '', '', ''
    {$ENDIF}
    {$IFDEF FONTS_MAC}
    '/System/Library/Fonts/',
    '/System/Library/Fonts/Supplemental/',
    '/Library/Fonts/',
    '~/Library/Fonts/',
    '/Network/Library/Fonts/',
    '', '', '', '', '', '', ''
    {$ENDIF}
  );

type
  TCardinalArray = array of Cardinal;
  TBooleanArray  = array of Boolean;

  // TControl.Font is protected in the LCL; this cracker gives access to it.
  TControlAccess = class(TControl);

var
  GCustomScriptFonts: array[TScriptType] of string;
  GResolved: array[TScriptType] of string;
  GResolvedValid: array[TScriptType] of Boolean;
  GResolvedTC: string;
  GResolvedTCValid: Boolean;


{ Installed-font check }
function IsFontInstalled(const AFontName: string): Boolean;
var
  I: Integer;
begin
  if (AFontName = '') or SameText(AFontName, DefaultFontName) then
    Exit(True);
  if Screen <> nil then
    for I := 0 to Screen.Fonts.Count - 1 do
      if SameText(Screen.Fonts[I], AFontName) then
        Exit(True);
  Result := False;
end;

{ Cache / custom fonts}
procedure ClearFontCache;
var
  S: TScriptType;
begin
  for S := Low(TScriptType) to High(TScriptType) do
  begin
    GResolved[S] := '';
    GResolvedValid[S] := False;
  end;
  GResolvedTC := '';
  GResolvedTCValid := False;
end;

procedure SetCustomScriptFont(Script: TScriptType; const AFontName: string);
begin
  GCustomScriptFonts[Script] := AFontName;
  GResolvedValid[Script] := False;
end;

function GetCustomScriptFont(Script: TScriptType): string;
begin
  Result := GCustomScriptFonts[Script];
end;

procedure ClearCustomScriptFonts;
var
  S: TScriptType;
begin
  for S := Low(TScriptType) to High(TScriptType) do
  begin
    GCustomScriptFonts[S] := '';
    GResolvedValid[S] := False;
  end;
end;


{ Candidate data. Lists are ';'-separated, best first}
// Native (OS-shipped or commonly installed) fonts for the current platform.
function NativeFonts(Script: TScriptType): string;
begin
  Result := '';

  {$IFDEF FONTS_WIN}
  case Script of
    scrLatin,
    scrGerman,
    scrTurkish:     Result := 'Segoe UI;Arial;Tahoma';
    scrGreek:       Result := 'Segoe UI;Palatino Linotype;Calibri;Arial';
    scrCyrillic:    Result := 'Segoe UI;Calibri;Arial;Tahoma';
    scrArabic:      Result := 'Tahoma;Segoe UI;Traditional Arabic;Arabic Typesetting';
    scrPersian:     Result := 'Tahoma;Segoe UI;Traditional Arabic';
    scrHebrew:      Result := 'Segoe UI;David;Arial;FrankRuehl';
    scrArmenian:    Result := 'Sylfaen;Segoe UI;Arial AMU';
    scrGeorgian:    Result := 'Sylfaen;Segoe UI';
    scrDevanagari:  Result := 'Nirmala UI;Mangal;Kokila;Utsaah';
    scrBengali:     Result := 'Nirmala UI;Vrinda;Shonar Bangla';
    scrGurmukhi:    Result := 'Nirmala UI;Raavi';
    scrGujarati:    Result := 'Nirmala UI;Shruti';
    scrOriya:       Result := 'Nirmala UI;Kalinga';
    scrTamil:       Result := 'Nirmala UI;Latha;Vijaya';
    scrTelugu:      Result := 'Nirmala UI;Gautami;Vani';
    scrKannada:     Result := 'Nirmala UI;Tunga';
    scrMalayalam:   Result := 'Nirmala UI;Kartika';
    scrSinhala:     Result := 'Nirmala UI;Iskoola Pota';
    scrOlChiki,
    scrMeeteiMayek: Result := 'Nirmala UI';
    scrThai:        Result := 'Leelawadee UI;Leelawadee;Tahoma;Angsana New;Cordia New';
    scrKhmer:       Result := 'Leelawadee UI;Khmer UI;DaunPenh;MoolBoran';
    scrLao:         Result := 'Leelawadee UI;Lao UI;DokChampa';
    scrBurmese:     Result := 'Myanmar Text;Nirmala UI;Padauk';
    scrTibetan:     Result := 'Microsoft Himalaya';
    scrJavanese:    Result := 'Javanese Text;Segoe UI Historic';
    scrNewTaiLue:   Result := 'Microsoft New Tai Lue;Segoe UI Historic';
    scrMongolian:   Result := 'Mongolian Baiti';
    scrBalinese,
    scrSundanese,
    scrCham,
    scrTaiTham,
    scrKayahLi,
    scrChakma,
    scrSoraSompeng,
    scrLimbu,
    scrLepcha,
    scrWancho:      Result := 'Segoe UI Historic';
    scrEthiopic:    Result := 'Nyala;Ebrima;Abyssinica SIL';
    scrNKo,
    scrVai,
    scrOsmanya,
    scrAdlam:       Result := 'Ebrima;Segoe UI Historic';
    scrCjk:         Result := 'Microsoft YaHei UI;Microsoft YaHei;SimSun;SimSun-ExtB';
    scrJapanese:    Result := 'Yu Gothic UI;Meiryo UI;Meiryo;Yu Gothic;MS Gothic';
    scrKorean:      Result := 'Malgun Gothic;Gulim;Batang';
    scrCherokee:    Result := 'Gadugi;Plantagenet Cherokee;Segoe UI';
    scrCoptic,
    scrGlagolitic,
    scrDeseret,
    scrOsage,
    scrOldHungarian:Result := 'Segoe UI Historic;Segoe UI Symbol';
    scrSymbols:     Result := 'Segoe UI Symbol;Segoe UI Emoji;Segoe UI Historic;Arial Unicode MS;DejaVu Sans';
  else
    Result := '';
  end;
  {$ENDIF}

  {$IFDEF FONTS_MAC}
  // The system UI font (SF) is not exposed by family name; the trailing 'default'
  // selects it, and CoreText cascades to other fonts for missing glyphs.
  case Script of
    scrLatin, scrGerman, scrTurkish, scrGreek,
    scrCyrillic:   Result := 'Helvetica Neue;Arial';
    scrArabic,
    scrPersian:    Result := 'Geeza Pro;Damascus';
    scrHebrew:     Result := 'Arial Hebrew;Raanana';
    scrArmenian:   Result := 'Mshtakan';
    scrDevanagari: Result := 'Kohinoor Devanagari;Devanagari Sangam MN';
    scrBengali:    Result := 'Bangla Sangam MN;Bangla MN';
    scrGurmukhi:   Result := 'Gurmukhi Sangam MN;Gurmukhi MN';
    scrGujarati:   Result := 'Gujarati Sangam MN;Gujarati MN';
    scrOriya:      Result := 'Oriya Sangam MN;Oriya MN';
    scrTamil:      Result := 'Tamil Sangam MN;Tamil MN';
    scrTelugu:     Result := 'Telugu Sangam MN;Telugu MN';
    scrKannada:    Result := 'Kannada Sangam MN;Kannada MN';
    scrMalayalam:  Result := 'Malayalam Sangam MN;Malayalam MN';
    scrSinhala:    Result := 'Sinhala Sangam MN;Sinhala MN';
    scrThai:       Result := 'Thonburi;Ayuthaya';
    scrKhmer:      Result := 'Khmer Sangam MN;Khmer MN';
    scrLao:        Result := 'Lao Sangam MN;Lao MN';
    scrBurmese:    Result := 'Myanmar Sangam MN;Myanmar MN';
    scrTibetan:    Result := 'Kailasa;Kokonor';
    scrEthiopic:   Result := 'Kefa';
    scrCjk:        Result := 'PingFang SC;Hiragino Sans GB;Songti SC';
    scrJapanese:   Result := 'Hiragino Sans;Hiragino Kaku Gothic ProN;Hiragino Kaku Gothic Pro';
    scrKorean:     Result := 'Apple SD Gothic Neo;Nanum Gothic';
    scrCherokee:   Result := 'Plantagenet Cherokee';
    scrSymbols:    Result := 'Apple Symbols;Menlo';
  else
    Result := '';
  end;
  {$ENDIF}

  {$IFDEF FONTS_ANDROID}
  // Android ships Roboto and Noto; the Noto table covers the remaining scripts.
  case Script of
    scrLatin, scrGerman, scrTurkish, scrGreek, scrCyrillic:
      Result := 'Roboto;Noto Sans;Droid Sans';
    scrArabic, scrPersian:
      Result := 'Noto Naskh Arabic;Noto Sans Arabic';
    scrCjk, scrJapanese, scrKorean:
      Result := 'Droid Sans Fallback';
  else
    Result := '';
  end;
  {$ENDIF}

  {$IFDEF FONTS_UNIX}
  case Script of
    scrLatin, scrGerman, scrTurkish, scrGreek, scrCyrillic:
      Result := 'DejaVu Sans;Liberation Sans;Noto Sans';
    scrArabic, scrPersian: Result := 'DejaVu Sans;KacstOne';
    scrHebrew, scrArmenian, scrGeorgian: Result := 'DejaVu Sans';

    scrDevanagari: Result := 'Lohit Devanagari;Gargi';
    scrBengali:    Result := 'Lohit Bengali';
    scrGurmukhi:   Result := 'Lohit Gurmukhi';
    scrGujarati:   Result := 'Lohit Gujarati';
    scrOriya:      Result := 'Lohit Oriya';
    scrTamil:      Result := 'Lohit Tamil';
    scrTelugu:     Result := 'Lohit Telugu';
    scrKannada:    Result := 'Lohit Kannada';
    scrMalayalam:  Result := 'Lohit Malayalam';
    scrSinhala:    Result := 'LKLUG';

    scrThai:    Result := 'Loma;Waree';
    scrKhmer:   Result := 'Khmer OS';
    scrLao:     Result := 'Phetsarath OT';
    scrBurmese: Result := 'Padauk';
    scrTibetan: Result := 'Jomolhari';
    scrEthiopic: Result := 'Abyssinica SIL';

    scrCjk:      Result := 'WenQuanYi Micro Hei;Droid Sans Fallback';
    scrJapanese: Result := 'TakaoPGothic;VL PGothic';
    scrKorean:   Result := 'NanumGothic;Baekmuk Dotum';

    scrCherokee, scrCoptic, scrGlagolitic, scrDeseret, scrOldHungarian:
      Result := 'FreeSerif;DejaVu Sans';

    scrSymbols:  Result := 'DejaVu Sans';
  else
    Result := '';
  end;
  {$ENDIF}
end;

function NativeFontsTraditionalChinese: string;
begin
  Result := '';
  {$IFDEF FONTS_WIN}
  Result := 'Microsoft JhengHei UI;Microsoft JhengHei;PMingLiU;MingLiU-ExtB';
  {$ENDIF}
  {$IFDEF FONTS_MAC}
  Result := 'PingFang TC;Heiti TC;Songti TC';
  {$ENDIF}
  {$IFDEF FONTS_ANDROID}
  Result := 'Droid Sans Fallback';
  {$ENDIF}
  {$IFDEF FONTS_UNIX}
  Result := 'WenQuanYi Zen Hei;Droid Sans Fallback';
  {$ENDIF}
end;

// Google Noto fallbacks: identical on every platform.
function NotoFamilies(Script: TScriptType): string;
begin
  case Script of
    scrLatin:       Result := 'Noto Sans';
    scrGerman:      Result := 'Noto Sans';
    scrTurkish:     Result := 'Noto Sans';
    scrGreek:       Result := 'Noto Sans';
    scrCyrillic:    Result := 'Noto Sans';
    scrArabic:      Result := 'Noto Sans Arabic';
    scrPersian:     Result := 'Noto Sans Arabic';
    scrHebrew:      Result := 'Noto Sans Hebrew';
    scrArmenian:    Result := 'Noto Sans Armenian';
    scrGeorgian:    Result := 'Noto Sans Georgian';
    scrDevanagari:  Result := 'Noto Sans Devanagari';
    scrBengali:     Result := 'Noto Sans Bengali';
    scrGurmukhi:    Result := 'Noto Sans Gurmukhi';
    scrGujarati:    Result := 'Noto Sans Gujarati';
    scrOriya:       Result := 'Noto Sans Oriya';
    scrTamil:       Result := 'Noto Sans Tamil';
    scrTelugu:      Result := 'Noto Sans Telugu';
    scrKannada:     Result := 'Noto Sans Kannada';
    scrMalayalam:   Result := 'Noto Sans Malayalam';
    scrSinhala:     Result := 'Noto Sans Sinhala';
    scrOlChiki:     Result := 'Noto Sans Ol Chiki';
    scrMeeteiMayek: Result := 'Noto Sans Meetei Mayek';
    scrThai:        Result := 'Noto Sans Thai';
    scrKhmer:       Result := 'Noto Sans Khmer';
    scrLao:         Result := 'Noto Sans Lao';
    scrBurmese:     Result := 'Noto Sans Myanmar';
    scrTibetan:     Result := 'Noto Serif Tibetan;Noto Sans Tibetan';
    scrJavanese:    Result := 'Noto Sans Javanese';
    scrBalinese:    Result := 'Noto Sans Balinese';
    scrSundanese:   Result := 'Noto Sans Sundanese';
    scrCham:        Result := 'Noto Sans Cham';
    scrTaiTham:     Result := 'Noto Sans Tai Tham';
    scrNewTaiLue:   Result := 'Noto Sans New Tai Lue';
    scrKayahLi:     Result := 'Noto Sans Kayah Li';
    scrChakma:      Result := 'Noto Sans Chakma';
    scrSoraSompeng: Result := 'Noto Sans Sora Sompeng';
    scrLimbu:       Result := 'Noto Sans Limbu';
    scrLepcha:      Result := 'Noto Sans Lepcha';
    scrWancho:      Result := 'Noto Sans Wancho';
    scrMongolian:   Result := 'Noto Sans Mongolian';
    scrEthiopic:    Result := 'Noto Sans Ethiopic';
    scrNKo:         Result := 'Noto Sans NKo';
    scrVai:         Result := 'Noto Sans Vai';
    scrOsmanya:     Result := 'Noto Sans Osmanya';
    scrAdlam:       Result := 'Noto Sans Adlam';
    scrCherokee:    Result := 'Noto Sans Cherokee';
    scrCoptic:      Result := 'Noto Sans Coptic';
    scrGlagolitic:  Result := 'Noto Sans Glagolitic';
    scrDeseret:     Result := 'Noto Sans Deseret';
    scrOsage:       Result := 'Noto Sans Osage';
    scrGaray:       Result := 'Noto Sans Garay';
    scrMedefaidrin: Result := 'Noto Sans Medefaidrin';
    scrOldHungarian:Result := 'Noto Sans Old Hungarian';
    scrVithkuqi:    Result := 'Noto Sans Vithkuqi';
    scrWarangCiti:  Result := 'Noto Sans Warang Citi';
    scrCjk:         Result := 'Noto Sans CJK SC';
    scrJapanese:    Result := 'Noto Sans CJK JP';
    scrKorean:      Result := 'Noto Sans CJK KR';
    scrSymbols:     Result := 'Noto Sans Symbols 2;Noto Sans Symbols';
  else
    Result := '';
  end;
end;


{ List building}
procedure AddUnique(var Arr: TStringArray; const Name: string);
var
  I: Integer;
begin
  if Name = '' then Exit;
  for I := 0 to High(Arr) do
    if SameText(Arr[I], Name) then Exit;
  SetLength(Arr, Length(Arr) + 1);
  Arr[High(Arr)] := Name;
end;

procedure AddList(var Arr: TStringArray; const List: string);
var
  P, Start: Integer;
begin
  Start := 1;
  for P := 1 to Length(List) + 1 do
    if (P > Length(List)) or (List[P] = ';') then
    begin
      AddUnique(Arr, Trim(Copy(List, Start, P - Start)));
      Start := P + 1;
    end;
end;

// On Linux/BSD/Android the Noto families are the most reliable choice for
// non-Latin scripts, so they go first there. On Windows/macOS the OS fonts do.
function NotoFirstFor({%H-}Script: TScriptType): Boolean;
begin
  {$IF DEFINED(FONTS_UNIX) OR DEFINED(FONTS_ANDROID)}
  Result := not (Script in [scrLatin, scrGerman, scrTurkish, scrGreek, scrCyrillic]);
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function BuildCandidates(const Native, Noto: string; NotoFirst: Boolean): TStringArray;
begin
  Result := nil;
  if NotoFirst then AddList(Result, Noto);
  AddList(Result, Native);
  AddList(Result, Noto);
  AddUnique(Result, DefaultFontName);// always last
end;

function GetOSFontCandidates(Script: TScriptType): TStringArray;
begin
  Result := BuildCandidates(NativeFonts(Script), NotoFamilies(Script), NotoFirstFor(Script));
end;

function FirstInstalled(const Candidates: TStringArray): string;
var
  I: Integer;
begin
  for I := Low(Candidates) to High(Candidates) do
  begin
    if SameText(Candidates[I], DefaultFontName) then
      Exit(DefaultFontName);
    if IsFontInstalled(Candidates[I]) then
      Exit(Candidates[I]);
  end;
  Result := DefaultFontName;
end;


{ Resolution}
function GetOSFontForScript(Script: TScriptType): string;
var
  CustomFont: string;
begin
  if GResolvedValid[Script] then Exit(GResolved[Script]);

  CustomFont := GetCustomScriptFont(Script);
  if (CustomFont <> '') and IsFontInstalled(CustomFont) then
    Result := CustomFont
  else
    Result := FirstInstalled(GetOSFontCandidates(Script));

  GResolved[Script] := Result;
  GResolvedValid[Script] := True;
end;

function IsTraditionalChineseLangID(ALangID: Integer): Boolean;
begin
  case ALangID and $FFFF of
    $0404,  // zh-TW
    $0C04,  // zh-HK
    $1404,  // zh-MO
    $7C04:  // zh-Hant
      Result := True;
  else
    Result := False;
  end;
end;

function GetOSFontForLangID(ALangID: Integer): string;
begin
  if IsTraditionalChineseLangID(ALangID) then
  begin
    if not GResolvedTCValid then
    begin
      GResolvedTC := FirstInstalled(
        BuildCandidates(NativeFontsTraditionalChinese, 'Noto Sans CJK TC', NotoFirstFor(scrCjk)));
      GResolvedTCValid := True;
    end;
    Exit(GResolvedTC);
  end;
  Result := GetOSFontForScript(LangIDToScriptType(ALangID));
end;


{ Applicators}
procedure ApplyFont(AFont: TFont; Script: TScriptType);
begin
  if AFont = nil then Exit;
  AFont.Name := GetOSFontForScript(Script);// returns 'default' when nothing matches
end;

procedure ApplyFont(AFont: TFont; ALangID: Integer);
begin
  if AFont = nil then Exit;
  AFont.Name := GetOSFontForLangID(ALangID);
end;

procedure ApplyControlFont(AControl: TControl; Script: TScriptType);
begin
  if AControl = nil then Exit;
  ApplyFont(TControlAccess(AControl).Font, Script);
end;

procedure ApplyControlFont(AControl: TControl; ALangID: Integer);
begin
  if AControl = nil then Exit;
  ApplyFont(TControlAccess(AControl).Font, ALangID);
end;

{Low-Level UTF-8 Stream Decoding }
function UTF8FetchNextCode(P: PAnsiChar; out Code: Cardinal; out Step: Integer): Boolean;
var
  B: Byte;
begin
  Result := False;
  if (P = nil) or (P^ = #0) then Exit;
  B := Byte(P^);
  if B < $80 then
  begin
    Code := B;
    Step := 1;
  end
  else if (B and $E0) = $C0 then
  begin
    Code := ((B and $1F) shl 6) or (Byte(P[1]) and $3F);
    Step := 2;
  end
  else if (B and $F0) = $E0 then
  begin
    Code := ((B and $0F) shl 12) or ((Byte(P[1]) and $3F) shl 6) or (Byte(P[2]) and $3F);
    Step := 3;
  end
  else
  begin
    Code := ((B and $07) shl 18) or ((Byte(P[1]) and $3F) shl 12) or ((Byte(P[2]) and $3F) shl 6) or (Byte(P[3]) and $3F);
    Step := 4;
  end;
  Result := True;
end;

{Low-Level UTF-8 Stream Encoding }
procedure UTF8AppendCode(var Dest: string; Code: Cardinal);
begin
  if Code < $80 then
    Dest := Dest + AnsiChar(Code)
  else if Code < $800 then
    Dest := Dest + AnsiChar($C0 or (Code shr 6)) + AnsiChar($80 or (Code and $3F))
  else if Code < $10000 then
    Dest := Dest + AnsiChar($E0 or (Code shr 12)) + AnsiChar($80 or ((Code shr 6) and $3F)) + AnsiChar($80 or (Code and $3F))
  else
    Dest := Dest + AnsiChar($F0 or (Code shr 18)) + AnsiChar($80 or ((Code shr 12) and $3F)) + AnsiChar($80 or ((Code shr 6) and $3F)) + AnsiChar($80 or (Code and $3F));
end;


{Unicode RTL Script Block Identification     }
function IsCodepointRTL(C: Cardinal): Boolean;
begin
  Result :=
    ((C >= $0590) and (C <= $05FF)) or   // Hebrew
    ((C >= $0600) and (C <= $06FF)) or   // Arabic / Persian / Urdu
    ((C >= $0700) and (C <= $074F)) or   // Syriac
    ((C >= $0750) and (C <= $077F)) or   // Arabic Supplement
    ((C >= $0780) and (C <= $07BF)) or   // Thaana (Dhivehi)
    ((C >= $07C0) and (C <= $07FF)) or   // N'Ko
    ((C >= $0800) and (C <= $083F)) or   // Samaritan
    ((C >= $0840) and (C <= $085F)) or   // Mandaic
    ((C >= $08A0) and (C <= $08FF)) or   // Arabic Extended-A
    ((C >= $FB1D) and (C <= $FB4F)) or   // Hebrew Presentation Forms
    ((C >= $FB50) and (C <= $FDFF)) or   // Arabic Presentation Forms-A
    ((C >= $FE70) and (C <= $FEFF)) or   // Arabic Presentation Forms-B
    ((C >= $10800) and (C <= $1083F)) or // Cypriot / Imperial Aramaic
    ((C >= $10B40) and (C <= $10B5F)) or // Inscriptional Parthian
    ((C >= $10C80) and (C <= $10CFF)) or // Old Hungarian (RTL)
    ((C >= $10D40) and (C <= $10D8F)) or // Garay
    ((C >= $1E900) and (C <= $1E95F));   // Adlam
end;

{Arabic Joining Capability Check}
function CanArabicConnect(CodePoint: Cardinal; CheckLeft: Boolean): Boolean;
begin
  if not (((CodePoint >= $0621) and (CodePoint <= $08FF)) or
          ((CodePoint >= $FB50) and (CodePoint <= $FEFC))) then
    Exit(False);

  case CodePoint of
    0, 32, $0621: Exit(False); // Space or standalone Hamza never connects

    // All Right-Only (non-dual) connectors:
    $0622..$0625, $0627, $0629, $062F..$0632, $0648, $0671, $0688, $0691, $0698,
    $FE81, $FE82, $FE8D, $FE8E, $FE93, $FE94, $FEA9..$FEB0, $FEED, $FEEE, $FB8A, $FB8B:
    begin
      if CheckLeft then
        Result := (CodePoint <> $0621) // Can receive incoming connection from before
      else
        Result := False;      // Cannot connect forward to subsequent character
    end;
  else
    Result := True;
  end;
end;

{Contextual Glyph Mapping into Unicode Presentation Forms}
function MapArabicPresentationForm(C: Cardinal; ConnectPrev, ConnectNext: Boolean): Cardinal;
begin
  Result := C;
  case C of
    //Dual-Joiners: 4 Forms (Isolated, Final, Initial, Medial)
    $0628: // Beh (ب)
      if ConnectPrev and ConnectNext then Result := $FE92
      else if ConnectPrev then Result := $FE90
      else if ConnectNext then Result := $FE91
      else Result := $FE8F;

    $067E: // Peh (پ - Persian)
      if ConnectPrev and ConnectNext then Result := $FB59
      else if ConnectPrev then Result := $FB57
      else if ConnectNext then Result := $FB58
      else Result := $FB56;

    $062A: // Teh (ت)
      if ConnectPrev and ConnectNext then Result := $FE98
      else if ConnectPrev then Result := $FE96
      else if ConnectNext then Result := $FE97
      else Result := $FE95;

    $062B: // Theh / Seh (ث)
      if ConnectPrev and ConnectNext then Result := $FE9C
      else if ConnectPrev then Result := $FE9A
      else if ConnectNext then Result := $FE9B
      else Result := $FE99;

    $062C: // Jeem (ج)
      if ConnectPrev and ConnectNext then Result := $FEA0
      else if ConnectPrev then Result := $FE9E
      else if ConnectNext then Result := $FE9F
      else Result := $FE9D;

    $0686: // Tcheh / Cheh (چ - Persian)
      if ConnectPrev and ConnectNext then Result := $FB7D
      else if ConnectPrev then Result := $FB7B
      else if ConnectNext then Result := $FB7C
      else Result := $FB7A;

    $062D: // Hah / Heh-ye Jimi (ح)
      if ConnectPrev and ConnectNext then Result := $FEA4
      else if ConnectPrev then Result := $FEA2
      else if ConnectNext then Result := $FEA3
      else Result := $FEA1;

    $062E: // Khah / Khe (خ)
      if ConnectPrev and ConnectNext then Result := $FEA8
      else if ConnectPrev then Result := $FEA6
      else if ConnectNext then Result := $FEA7
      else Result := $FEA5;

    $0633: // Seen (س)
      if ConnectPrev and ConnectNext then Result := $FEB4
      else if ConnectPrev then Result := $FEB2
      else if ConnectNext then Result := $FEB3
      else Result := $FEB1;

    $0634: // Sheen (ش)
      if ConnectPrev and ConnectNext then Result := $FEB8
      else if ConnectPrev then Result := $FEB6
      else if ConnectNext then Result := $FEB7
      else Result := $FEB5;

    $0635: // Sad (ص)
      if ConnectPrev and ConnectNext then Result := $FEBC
      else if ConnectPrev then Result := $FEBA
      else if ConnectNext then Result := $FEBB
      else Result := $FEB9;

    $0636: // Zad / Dad (ض)
      if ConnectPrev and ConnectNext then Result := $FEC0
      else if ConnectPrev then Result := $FEBE
      else if ConnectNext then Result := $FEBF
      else Result := $FEBD;

    $0637: // Tah / Ta (ط)
      if ConnectPrev and ConnectNext then Result := $FEC4
      else if ConnectPrev then Result := $FEC2
      else if ConnectNext then Result := $FEC3
      else Result := $FEC1;

    $0638: // Zah / Za (ظ)
      if ConnectPrev and ConnectNext then Result := $FEC8
      else if ConnectPrev then Result := $FEC6
      else if ConnectNext then Result := $FEC7
      else Result := $FEC5;

    $0639: // Ain (ع)
      if ConnectPrev and ConnectNext then Result := $FECC
      else if ConnectPrev then Result := $FECA
      else if ConnectNext then Result := $FECB
      else Result := $FEC9;

    $063A: // Ghain (غ)
      if ConnectPrev and ConnectNext then Result := $FED0
      else if ConnectPrev then Result := $FECE
      else if ConnectNext then Result := $FECF
      else Result := $FECD;

    $0641: // Feh (ف)
      if ConnectPrev and ConnectNext then Result := $FED4
      else if ConnectPrev then Result := $FED2
      else if ConnectNext then Result := $FED3
      else Result := $FED1;

    $0642: // Qaf (ق)
      if ConnectPrev and ConnectNext then Result := $FED8
      else if ConnectPrev then Result := $FED6
      else if ConnectNext then Result := $FED7
      else Result := $FED5;

    $06A9: // Keheh / Kaf (ک - Persian)
      if ConnectPrev and ConnectNext then Result := $FB91
      else if ConnectPrev then Result := $FB8F
      else if ConnectNext then Result := $FB90
      else Result := $FB8E;

    $0643: // Kaf (ك - Arabic form)
      if ConnectPrev and ConnectNext then Result := $FEDC
      else if ConnectPrev then Result := $FEDA
      else if ConnectNext then Result := $FEDB
      else Result := $FED9;

    $06AF: // Gaf (گ - Persian)
      if ConnectPrev and ConnectNext then Result := $FB95
      else if ConnectPrev then Result := $FB93
      else if ConnectNext then Result := $FB94
      else Result := $FB92;

    $0644: // Lam (ل)
      if ConnectPrev and ConnectNext then Result := $FEE0
      else if ConnectPrev then Result := $FEDE
      else if ConnectNext then Result := $FEDF
      else Result := $FEDD;

    $0645: // Meem (م)
      if ConnectPrev and ConnectNext then Result := $FEE4
      else if ConnectPrev then Result := $FEE2
      else if ConnectNext then Result := $FEE3
      else Result := $FEE1;

    $0646: // Noon (ن)
      if ConnectPrev and ConnectNext then Result := $FEE8
      else if ConnectPrev then Result := $FEE6
      else if ConnectNext then Result := $FEE7
      else Result := $FEE5;

    $0647: // Heh / Heh-ye Dow-Cheshm (ه)
      if ConnectPrev and ConnectNext then Result := $FEEC
      else if ConnectPrev then Result := $FEEA
      else if ConnectNext then Result := $FEEB
      else Result := $FEE9;

    $06CC: // Yeh (ی - Persian: dotless isolated/final, dotted initial/medial)
      if ConnectPrev and ConnectNext then Result := $FBFF // Medial
      else if ConnectPrev then Result := $FBFD            // Final
      else if ConnectNext then Result := $FBFE            // Initial
      else Result := $FBFC;                               // Isolated

    $064A: // Yeh (ي - Arabic, with dots)
      if ConnectPrev and ConnectNext then Result := $FEF4
      else if ConnectPrev then Result := $FEF2
      else if ConnectNext then Result := $FEF3
      else Result := $FEF1;

    //Right-Only Connectors (Non-Dual Joiners): 2 Forms (Isolated, Final)
    $0622: if ConnectPrev then Result := $FE82 else Result := $FE81; // Alef with Madda (آ)
    $0627: if ConnectPrev then Result := $FE8E else Result := $FE8D; // Alef (ا)
    $062F: if ConnectPrev then Result := $FEAA else Result := $FEA9; // Dal (د)
    $0630: if ConnectPrev then Result := $FEAC else Result := $FEAB; // Zal / Thal (ذ)
    $0631: if ConnectPrev then Result := $FEAE else Result := $FEAD; // Reh (ر)
    $0632: if ConnectPrev then Result := $FEB0 else Result := $FEAF; // Zain (ز)
    $0698: if ConnectPrev then Result := $FB8B else Result := $FB8A; // Zhe (ژ - Persian)
    $0648: if ConnectPrev then Result := $FEEE else Result := $FEED; // Waw (و)
    $0629: if ConnectPrev then Result := $FE94 else Result := $FE93; // Teh Marbuta (ة)
  end;
end;

{In-Place Arabic / Persian Cursive Shaping}
procedure ShapeArabicRun(var CPs: TCardinalArray; var TotalCount: Integer);
var
  Orig: TCardinalArray;
  I, WriteIdx: Integer;
  PrevC, NextC, CurC: Cardinal;
  ConnPrev, ConnNext: Boolean;
begin
  if TotalCount <= 0 then Exit;

  //Collapse Lam + Alef ligatures into presentation forms
  WriteIdx := 0;
  I := 0;
  while I < TotalCount do
  begin
    if (CPs[I] = $0644) and (I + 1 < TotalCount) and
       ((CPs[I + 1] = $0622) or (CPs[I + 1] = $0627)) then
    begin
      ConnPrev := (WriteIdx > 0) and CanArabicConnect(CPs[WriteIdx - 1], False);
      case CPs[I + 1] of
        $0622: // Lam + Alef with Madda (لآ)
          if ConnPrev then CPs[WriteIdx] := $FEF6 else CPs[WriteIdx] := $FEF5;
        $0627: // Lam + Alef (لا)
          if ConnPrev then CPs[WriteIdx] := $FEFC else CPs[WriteIdx] := $FEFB;
      end;
      Inc(WriteIdx);
      Inc(I, 2);
    end
    else
    begin
      CPs[WriteIdx] := CPs[I];
      Inc(WriteIdx);
      Inc(I);
    end;
  end;
  TotalCount := WriteIdx;
  SetLength(CPs, TotalCount);

  //In-place contextual shaping using static snapshot
  Orig := Default(TCardinalArray);
  SetLength(Orig, TotalCount);
  for I := 0 to TotalCount - 1 do
    Orig[I] := CPs[I];

  for I := 0 to TotalCount - 1 do
  begin
    CurC := Orig[I];
    if ((CurC >= $0600) and (CurC <= $06FF)) or
       ((CurC >= $0750) and (CurC <= $077F)) or
       ((CurC >= $08A0) and (CurC <= $08FF)) then
    begin
      if I > 0 then PrevC := Orig[I - 1] else PrevC := 0;
      if I + 1 < TotalCount then NextC := Orig[I + 1] else NextC := 0;

      ConnPrev := CanArabicConnect(PrevC, False);
      ConnNext := CanArabicConnect(NextC, True);

      CPs[I] := MapArabicPresentationForm(CurC, ConnPrev, ConnNext);
    end;
  end;
end;

function VisualOrderUTF8(const S: string): string;
var
  CPs: TCardinalArray;
  IsRTL: TBooleanArray;
  P: PAnsiChar;
  Code: Cardinal;
  Step, Count, I, RunStart, RunEnd: Integer;
begin
  Result := '';
  if S = '' then Exit;

  CPs := Default(TCardinalArray);
  IsRTL := Default(TBooleanArray);
  SetLength(CPs, Length(S));
  SetLength(IsRTL, Length(S));

  P := PAnsiChar(S);
  Count := 0;

  // Step A: Decode UTF-8 and identify RTL characters
  while UTF8FetchNextCode(P, Code, Step) do
  begin
    CPs[Count] := Code;
    IsRTL[Count] := IsCodepointRTL(Code);
    Inc(Count);
    Inc(P, Step);
  end;

  SetLength(CPs, Count);
  SetLength(IsRTL, Count);

  // Step B: Contextual joining for Arabic / Persian runs
  ShapeArabicRun(CPs, Count);

  // Step C: Run-by-run BiDi visual reordering
  I := 0;
  while I < Count do
  begin
    if IsRTL[I] then
    begin
      RunStart := I;
      while (I < Count) and (IsRTL[I] or (CPs[I] = 32)) do
        Inc(I);
      RunEnd := I - 1;

      while (RunEnd > RunStart) and (CPs[RunEnd] = 32) do
        Dec(RunEnd);

      for RunEnd := RunEnd downto RunStart do
        UTF8AppendCode(Result, CPs[RunEnd]);

      while (RunStart + (I - 1 - RunStart) > RunEnd) and
            (RunEnd + 1 < Count) and (CPs[RunEnd + 1] = 32) do
      begin
        UTF8AppendCode(Result, 32);
        Inc(RunEnd);
      end;
    end
    else
    begin
      UTF8AppendCode(Result, CPs[I]);
      Inc(I);
    end;
  end;
end;

{Cross-Platform User Home Path Expansion     }
function ExpandFontUserHome(const APath: string): string;
var
  HomeDir: string;
begin
  Result := APath;
  if (Length(Result) > 0) and (Result[1] = '~') then
  begin
    {$IFDEF FONTS_WIN}
    HomeDir := GetEnvironmentVariable('USERPROFILE');
    {$ELSE}
    HomeDir := GetEnvironmentVariable('HOME');
    {$ENDIF}
    Result := HomeDir + Copy(Result, 2, Length(Result));
  end;
end;


{Search Path Traversal     }
function FindFontInSearchPaths(const AFileName: string): string;
var
  D, CleanDir: string;
  Cand: string;
begin
  Result := '';
  for D in FONT_SEARCH_DIRS do
  begin
    if D = '' then Continue;
    CleanDir := IncludeTrailingPathDelimiter(ExpandFontUserHome(D));
    Cand := CleanDir + AFileName;
    if FileExists(Cand) then
      Exit(Cand);
  end;
end;


{Extension Probing (.ttf, .otf, .ttc)   }
function ProbeFontExtensions(const ABaseName: string): string;
begin
  Result := FindFontInSearchPaths(ABaseName + '.ttf');
  if Result <> '' then Exit;
  Result := FindFontInSearchPaths(ABaseName + '.otf');
  if Result <> '' then Exit;
  Result := FindFontInSearchPaths(ABaseName + '.ttc');
end;


{Typeface & Style Disk Filename Mapping}
function MapFamilyToDiskFileName(const ABaseName: string; AStyle: TFontStyles): string;
begin
  Result := ABaseName;
  {$IFDEF FONTS_WIN}
  // CJK and East Asian system font collections
  if SameText(ABaseName, 'Microsoft YaHei') or SameText(ABaseName, 'Microsoft YaHei UI') then
    Result := 'msyh'
  else if SameText(ABaseName, 'SimSun') or SameText(ABaseName, 'NSimSun') then
    Result := 'simsun'
  else if SameText(ABaseName, 'Microsoft JhengHei') or SameText(ABaseName, 'Microsoft JhengHei UI') then
    Result := 'msjh'
  else if SameText(ABaseName, 'Yu Gothic') or SameText(ABaseName, 'Yu Gothic UI') then
    Result := 'YuGothM'
  else if SameText(ABaseName, 'Meiryo') or SameText(ABaseName, 'Meiryo UI') then
    Result := 'meiryo'
  else if SameText(ABaseName, 'Malgun Gothic') then
    Result := 'malgun'
  // Common Latin & Western Windows font variants
  else if SameText(ABaseName, 'Arial') then
  begin
    if (fsBold in AStyle) and (fsItalic in AStyle) then Result := 'arialbi'
    else if fsBold in AStyle then Result := 'arialbd'
    else if fsItalic in AStyle then Result := 'ariali'
    else Result := 'arial';
  end
  else if SameText(ABaseName, 'Segoe UI') then
  begin
    if (fsBold in AStyle) and (fsItalic in AStyle) then Result := 'segoeuiz'
    else if fsBold in AStyle then Result := 'segoeuib'
    else if fsItalic in AStyle then Result := 'segoeuii'
    else Result := 'segoeui';
  end
  else if SameText(ABaseName, 'Tahoma') then
  begin
    if fsBold in AStyle then Result := 'tahomabd'
    else Result := 'tahoma';
  end;
  {$ENDIF}
end;


{Guaranteed Platform Fallback Font Resolution}
function GetPlatformFontFallback: string;
begin
  {$IFDEF FONTS_WIN}
  if FileExists('C:\Windows\Fonts\arial.ttf') then Exit('C:\Windows\Fonts\arial.ttf');
  if FileExists('C:\Windows\Fonts\segoeui.ttf') then Exit('C:\Windows\Fonts\segoeui.ttf');
  if FileExists('C:\Windows\Fonts\tahoma.ttf') then Exit('C:\Windows\Fonts\tahoma.ttf');
  {$ENDIF}

  {$IFDEF FONTS_UNIX}
  Result := FindFontInSearchPaths('DejaVuSans.ttf');
  if Result <> '' then Exit;
  Result := FindFontInSearchPaths('LiberationSans-Regular.ttf');
  if Result <> '' then Exit;
  {$ENDIF}

  {$IFDEF FONTS_MAC}
  if FileExists('/System/Library/Fonts/Helvetica.ttc') then Exit('/System/Library/Fonts/Helvetica.ttc');
  if FileExists('/System/Library/Fonts/Supplemental/Arial.ttf') then Exit('/System/Library/Fonts/Supplemental/Arial.ttf');
  if FileExists('/Library/Fonts/Arial.ttf') then Exit('/Library/Fonts/Arial.ttf');
  {$ENDIF}

  Result := '';
end;


{High-Level Font Resolver  }
function ResolveFontFile(const AFontName: string; AStyle: TFontStyles = []): string;
var
  BaseName: string;
  ResolvedPath: string;
begin
  // Step 1: Direct path verification
  if FileExists(AFontName) then
    Exit(AFontName);

  BaseName := ChangeFileExt(AFontName, '');

  // Step 2: Apply style-specific and CJK system file aliases
  BaseName := MapFamilyToDiskFileName(BaseName, AStyle);

  // Step 3: Probe with standard extensions (.ttf, .otf, .ttc)
  ResolvedPath := ProbeFontExtensions(BaseName);
  if ResolvedPath <> '' then Exit(ResolvedPath);

  // Step 4: Retry without whitespace for multi-word family names
  ResolvedPath := ProbeFontExtensions(StringReplace(BaseName, ' ', '', [rfReplaceAll]));
  if ResolvedPath <> '' then Exit(ResolvedPath);

  // Step 5: Guaranteed platform fallback
  ResolvedPath := GetPlatformFontFallback;
  if ResolvedPath <> '' then Exit(ResolvedPath);

  Result := AFontName;
end;


initialization
  ClearCustomScriptFonts;
  ClearFontCache;

end.
