unit QLanguages;

{ ============================================================================}
{ Qanguages, as part of TQ*/TQSk* packages                                    }
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

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;
  
type
  TScriptType = (
    scrUnknown,
    scrLatin,
    scrGerman,
    scrTurkish,
    scrGreek,
    scrCyrillic,
    scrArmenian,
    scrGeorgian,
    scrCherokee,
    scrCoptic,
    scrGlagolitic,
    scrDeseret,
    scrOsage,
    scrAdlam,
    scrGaray,
    scrMedefaidrin,
    scrOldHungarian,
    scrVithkuqi,
    scrWarangCiti,

    // Middle Eastern & Semitic
    scrArabic,
    scrPersian,
    scrHebrew,

    // South Asian & Indic
    scrDevanagari,
    scrBengali,
    scrGurmukhi,
    scrGujarati,
    scrOriya,
    scrTamil,
    scrTelugu,
    scrKannada,
    scrMalayalam,
    scrSinhala,
    scrOlChiki,
    scrMeeteiMayek,

    // Southeast Asian
    scrThai,
    scrKhmer,
    scrLao,
    scrBurmese,
    scrTibetan,

    // Regional, Island & Historic
    scrJavanese,
    scrBalinese,
    scrSundanese,
    scrCham,
    scrTaiTham,
    scrNewTaiLue,
    scrKayahLi,
    scrChakma,
    scrSoraSompeng,
    scrLimbu,
    scrLepcha,
    scrWancho,
    scrMongolian,

    // African
    scrEthiopic,
    scrNKo,
    scrVai,
    scrOsmanya,

    // East Asian (CJK)
    scrCjk,
    scrJapanese,
    scrKorean,

    // Symbols & Geometric
    scrSymbols
  );

var
  DefaultAppLangID: Integer = $0409; // Default: en-US ($0409)

// Code page & Charset conversions
function LangIDToCodePage(ALangID: Integer): Integer;
function CharsetToCodePage(ACharset: Integer): Integer;

// Locale identification & BCP-47 tags
function LangIDToLocaleName(ALangID: Integer): UnicodeString;
function LocaleNameToLangID(const ALocaleName: UnicodeString): Integer;

// Script classification & Standards
function LangIDToScriptType(ALangID: Integer): TScriptType;
function ScriptToDefaultLangID(Script: TScriptType): Integer;
function ScriptName(Script: TScriptType): string;
function ScriptToIso15924(Script: TScriptType): string;
function Iso15924ToScript(const ACode: string): TScriptType;

// Bi-directional text directionality (RTL vs LTR)
function IsScriptRTL(Script: TScriptType): Boolean;
function IsLangIDRTL(ALangID: Integer): Boolean;

// Host OS system language detection
function GetSystemLangID: Integer;
function GetSystemScript: TScriptType;

// High-performance contextual Unicode casing
function UnicodeUCase(const S: UnicodeString; ALangID: Integer = 0): UnicodeString;
function UnicodeLCase(const S: UnicodeString; ALangID: Integer = 0): UnicodeString;

implementation

function LangIDToCodePage(ALangID: Integer): Integer;
const
  // Code page constants for clarity
  CP_UNICODE = 0;       // Unicode required
  CP_WESTERN = 1252;    // Western European
  CP_CENTRAL_EU = 1250; // Central/Eastern European
  CP_CYRILLIC = 1251;   // Cyrillic
  CP_GREEK = 1253;      // Greek
  CP_TURKISH = 1254;    // Turkish
  CP_HEBREW = 1255;     // Hebrew
  CP_ARABIC = 1256;     // Arabic
  CP_BALTIC = 1257;     // Baltic
  CP_VIETNAMESE = 1258; // Vietnamese
  CP_THAI = 874;        // Thai
  CP_JAPANESE = 932;    // Japanese (Shift-JIS)
  CP_CHINESE_SIMP = 936;// Simplified Chinese (GBK)
  CP_KOREAN = 949;      // Korean
  CP_CHINESE_TRAD = 950;// Traditional Chinese (Big5)
var
  PrimaryLangID: Integer;
  FullLCID: Integer;
begin
  PrimaryLangID := ALangID and $3FF;
  FullLCID      := ALangID and $FFFF;
  // Step 1: Handle complex languages requiring full LCID for script distinction
  case PrimaryLangID of
    // CHINESE - Requires full LCID to distinguish Simplified vs Traditional
    $04:
      case FullLCID of
        $0804: Exit(CP_CHINESE_SIMP); // Chinese (Simplified, PRC)
        $1004: Exit(CP_CHINESE_SIMP); // Chinese (Simplified, Singapore)
        $0404: Exit(CP_CHINESE_TRAD); // Chinese (Traditional, Taiwan)
        $0c04: Exit(CP_CHINESE_TRAD); // Chinese (Traditional, Hong Kong SAR)
        $1404: Exit(CP_CHINESE_TRAD); // Chinese (Traditional, Macao SAR)
      else
        Exit(CP_CHINESE_SIMP); // Default to Simplified for unknown variants
      end;
    // SERBIAN/CROATIAN/BOSNIAN - Script variants (Latin vs Cyrillic)
    $1a: // Serbian / Croatian / Bosnian
      case FullLCID of
        $0c1a: Exit(CP_CYRILLIC); // Serbian (Cyrillic, Serbia)
        $1c1a: Exit(CP_CYRILLIC); // Serbian (Cyrillic, Bosnia and Herzegovina)
        $301a: Exit(CP_CYRILLIC); // Serbian (Cyrillic, Montenegro)
        $201a: Exit(CP_CYRILLIC); // Bosnian (Cyrillic, Bosnia and Herzegovina)
        $081a: Exit(CP_CENTRAL_EU); // Serbian (Latin, Serbia)
        $181a: Exit(CP_CENTRAL_EU); // Serbian (Latin, Bosnia and Herzegovina)
        $281a: Exit(CP_CENTRAL_EU); // Serbian (Latin, Montenegro)
        $141a: Exit(CP_CENTRAL_EU); // Bosnian (Latin, Bosnia and Herzegovina)
      else
        Exit(CP_CENTRAL_EU); // Default to Latin
      end;
    $1c: // Albanian - but checking for Serbian (Latin) overlap
      Exit(CP_CENTRAL_EU);
    // AZERI/AZERBAIJANI - Script variants (Latin vs Cyrillic)
    $2c:
      case FullLCID of
        $082c: Exit(CP_CYRILLIC); // Azeri (Cyrillic, Azerbaijan)
        $042c: Exit(CP_TURKISH);  // Azeri (Latin, Azerbaijan)
      else
        Exit(CP_TURKISH); // Default to Latin
      end;
    // UZBEK - Script variants (Latin vs Cyrillic)
    $43:
      case FullLCID of
        $0843: Exit(CP_CYRILLIC); // Uzbek (Cyrillic, Uzbekistan)
        $0443: Exit(CP_TURKISH);  // Uzbek (Latin, Uzbekistan)
      else
        Exit(CP_TURKISH); // Default to Latin
      end;
    // TAJIK - Cyrillic script
    $28:
      Exit(CP_CYRILLIC); // Tajik (Cyrillic)
    // MONGOLIAN - Script variants
    $50:
      case FullLCID of
        $0450: Exit(CP_CYRILLIC); // Mongolian (Cyrillic, Mongolia)
        $0850: Exit(CP_UNICODE);  // Mongolian (Traditional Mongolian, PRC) - needs Unicode
      else
        Exit(CP_CYRILLIC);
      end;
    // PUNJABI - Script variants
    $46:
      case FullLCID of
        $0446: Exit(CP_UNICODE);  // Punjabi (Gurmukhi, India) - needs Unicode
        $0846: Exit(CP_ARABIC);   // Punjabi (Arabic, Pakistan)
      else
        Exit(CP_UNICODE);
      end;
  end;
  // Step 2: Handle languages with consistent code page mappings
  case PrimaryLangID of
    // WESTERN EUROPEAN (CP 1252)
    $06: Result := CP_WESTERN; // Danish
    $07: Result := CP_WESTERN; // German
    $09: Result := CP_WESTERN; // English
    $0a: Result := CP_WESTERN; // Spanish
    $0b: Result := CP_WESTERN; // Finnish
    $0c: Result := CP_WESTERN; // French
    $10: Result := CP_WESTERN; // Italian
    $13: Result := CP_WESTERN; // Dutch
    $14: Result := CP_WESTERN; // Norwegian
    $16: Result := CP_WESTERN; // Portuguese
    $1d: Result := CP_WESTERN; // Swedish
    $36: Result := CP_WESTERN; // Afrikaans
    $3c: Result := CP_WESTERN; // Irish (Gaelic)
    $56: Result := CP_WESTERN; // Galician
    $6b: Result := CP_WESTERN; // Quechua
    $83: Result := CP_WESTERN; // Corsican
    $84: Result := CP_WESTERN; // Alsatian
    $91: Result := CP_WESTERN; // Scottish Gaelic
    // CENTRAL/EASTERN EUROPEAN (CP 1250)
    $05: Result := CP_CENTRAL_EU; // Czech
    $0e: Result := CP_CENTRAL_EU; // Hungarian
    $15: Result := CP_CENTRAL_EU; // Polish
    $18: Result := CP_CENTRAL_EU; // Romanian
    $1b: Result := CP_CENTRAL_EU; // Slovak
    $24: Result := CP_CENTRAL_EU; // Slovenian
    $2e: Result := CP_CENTRAL_EU; // Upper Sorbian / Lower Sorbian
    $42: Result := CP_CENTRAL_EU; // Turkmen
    // CYRILLIC (CP 1251)
    $19: Result := CP_CYRILLIC; // Russian
    $22: Result := CP_CYRILLIC; // Ukrainian
    $23: Result := CP_CYRILLIC; // Belarusian
    $2f: Result := CP_CYRILLIC; // Macedonian
    $3f: Result := CP_CYRILLIC; // Kazakh
    $40: Result := CP_CYRILLIC; // Kyrgyz
    $44: Result := CP_CYRILLIC; // Tatar
    $85: Result := CP_CYRILLIC; // Sakha/Yakut
    $7c: Result := CP_CYRILLIC; // Mohawk (sometimes uses this)
    $90: Result := CP_CYRILLIC; // Bashkir
    // GREEK (CP 1253)
    $08: Result := CP_GREEK; // Greek
    // TURKISH (CP 1254)
    $1f: Result := CP_TURKISH; // Turkish
    // HEBREW (CP 1255)
    $0d: Result := CP_HEBREW; // Hebrew
    $5d: Result := CP_HEBREW; // Yiddish
    // ARABIC (CP 1256)
    $01: Result := CP_ARABIC; // Arabic
    $20: Result := CP_ARABIC; // Urdu
    $29: Result := CP_ARABIC; // Farsi/Persian
    $59: Result := CP_ARABIC; // Sindhi
    $5e: Result := CP_ARABIC; // Uyghur
    // BALTIC (CP 1257)
    $25: Result := CP_BALTIC; // Estonian
    $26: Result := CP_BALTIC; // Latvian
    $27: Result := CP_BALTIC; // Lithuanian
    // VIETNAMESE (CP 1258)
    $2a: Result := CP_VIETNAMESE; // Vietnamese
    // THAI (CP 874)
    $1e: Result := CP_THAI; // Thai
    // JAPANESE (CP 932)
    $11: Result := CP_JAPANESE; // Japanese
    // KOREAN (CP 949)
    $12: Result := CP_KOREAN; // Korean
    // LANGUAGES REQUIRING UNICODE (No suitable single-byte code page)
    $37: Result := CP_UNICODE; // Georgian
    $39: Result := CP_UNICODE; // Hindi
    $3a: Result := CP_UNICODE; // Maltese
    $3b: Result := CP_UNICODE; // Sami (Northern, Southern, Lule, Inari, Skolt)
    $3e: Result := CP_UNICODE; // Malay
    $41: Result := CP_UNICODE; // Swahili
    $45: Result := CP_UNICODE; // Bengali/Bangla
    $47: Result := CP_UNICODE; // Gujarati
    $48: Result := CP_UNICODE; // Odia/Oriya
    $49: Result := CP_UNICODE; // Tamil
    $4a: Result := CP_UNICODE; // Telugu
    $4b: Result := CP_UNICODE; // Kannada
    $4c: Result := CP_UNICODE; // Malayalam
    $4d: Result := CP_UNICODE; // Assamese
    $4e: Result := CP_UNICODE; // Marathi
    $4f: Result := CP_UNICODE; // Sanskrit
    $51: Result := CP_UNICODE; // Burmese
    $53: Result := CP_UNICODE; // Khmer
    $54: Result := CP_UNICODE; // Lao
    $55: Result := CP_UNICODE; // Tibetan
    $57: Result := CP_UNICODE; // Welsh
    $58: Result := CP_UNICODE; // Breton
    $5a: Result := CP_UNICODE; // Divehi/Maldivian
    $5f: Result := CP_UNICODE; // Tamazight
    $61: Result := CP_UNICODE; // Nepali
    $62: Result := CP_UNICODE; // Frisian
    $68: Result := CP_UNICODE; // Hausa
    $6c: Result := CP_UNICODE; // Mapudungun
    $6d: Result := CP_UNICODE; // Bashkir
    $6e: Result := CP_UNICODE; // Luxembourgish
    $6f: Result := CP_UNICODE; // Greenlandic/Kalaallisut
    $70: Result := CP_UNICODE; // Igbo
    $73: Result := CP_UNICODE; // Tigrinya
    $78: Result := CP_UNICODE; // Yi
    $7a: Result := CP_UNICODE; // Mapuche
    $7e: Result := CP_UNICODE; // Breton
    $80: Result := CP_UNICODE; // Uighur
    $81: Result := CP_UNICODE; // Maori
    $82: Result := CP_UNICODE; // Occitan
    $86: Result := CP_UNICODE; // Kinyarwanda
    $87: Result := CP_UNICODE; // Wolof
    $88: Result := CP_UNICODE; // Dari (Persian, Afghanistan)
    $92: Result := CP_UNICODE; // Central Kurdish (Sorani)
    $5c: Result := CP_UNICODE; // Cherokee
    $5b: Result := CP_UNICODE; // Amharic
    $2b: Result := CP_UNICODE; // Armenian
    $32: Result := CP_UNICODE; // Sesotho/Southern Sotho
    $34: Result := CP_UNICODE; // Setswana/Tswana
    $35: Result := CP_UNICODE; // Xhosa
    $33: Result := CP_UNICODE; // Venda
    $52: Result := CP_UNICODE; // Zulu
    $30: Result := CP_UNICODE; // Sutu
    $31: Result := CP_UNICODE; // Tsonga
    $6a: Result := CP_UNICODE; // Yoruba
    $63: Result := CP_UNICODE; // Pashto
    $8c: Result := CP_UNICODE; // Dari
    $64: Result := CP_UNICODE; // Filipino
  else
    // DEFAULT: Unknown language - require Unicode
    Result := CP_UNICODE;
  end;
end;

function CharsetToCodePage(ACharset: Integer): Integer;
const
  // Standard Windows charset constants for reference
  ANSI_CHARSET = 0;
  DEFAULT_CHARSET = 1;
  SYMBOL_CHARSET = 2;
  MAC_CHARSET = 77;
  SHIFTJIS_CHARSET = 128;
  HANGEUL_CHARSET = 129;
  JOHAB_CHARSET = 130;
  GB2312_CHARSET = 134;
  CHINESEBIG5_CHARSET = 136;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  VIETNAMESE_CHARSET = 163;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  BALTIC_CHARSET = 186;
  RUSSIAN_CHARSET = 204;
  THAI_CHARSET = 222;
  EASTEUROPE_CHARSET = 238;
  OEM_CHARSET = 254;
begin
  case ACharset of
    // STANDARD WINDOWS CHARSETS (0-255 range, defined by Windows API)
    // Core Windows Charsets
    ANSI_CHARSET: Result := 1252;    // ANSI_CHARSET - Western European (Latin 1)
    DEFAULT_CHARSET: Result := 0;       // DEFAULT_CHARSET - Use system default
    SYMBOL_CHARSET: Result := 42;      // SYMBOL_CHARSET - Symbol fonts (Wingdings, etc.)
    // Macintosh Roman (primary)
    MAC_CHARSET: Result := 10000;  // MAC_CHARSET - Macintosh Roman (Western European)
    // East Asian Charsets
    SHIFTJIS_CHARSET: Result := 932;   // SHIFTJIS_CHARSET - Japanese (Shift-JIS)
    HANGEUL_CHARSET: Result := 949;   // HANGEUL_CHARSET / HANGUL_CHARSET - Korean (Unified Hangul Code)
    JOHAB_CHARSET: Result := 1361;  // JOHAB_CHARSET - Korean (Johab)
    GB2312_CHARSET: Result := 936;   // GB2312_CHARSET - Simplified Chinese (GBK)
    CHINESEBIG5_CHARSET: Result := 950;   // CHINESEBIG5_CHARSET - Traditional Chinese (Big5)
    // European & Middle Eastern Charsets
    GREEK_CHARSET: Result := 1253;  // GREEK_CHARSET - Greek
    TURKISH_CHARSET: Result := 1254;  // TURKISH_CHARSET - Turkish
    VIETNAMESE_CHARSET: Result := 1258;  // VIETNAMESE_CHARSET - Vietnamese
    HEBREW_CHARSET: Result := 1255;  // HEBREW_CHARSET - Hebrew
    ARABIC_CHARSET: Result := 1256;  // ARABIC_CHARSET - Arabic
    BALTIC_CHARSET: Result := 1257;  // BALTIC_CHARSET - Baltic languages (Estonian, Latvian, Lithuanian)
    RUSSIAN_CHARSET: Result := 1251;  // RUSSIAN_CHARSET - Cyrillic (Russian, Bulgarian, Serbian Cyrillic, etc.)
    THAI_CHARSET: Result := 874;   // THAI_CHARSET - Thai
    EASTEUROPE_CHARSET: Result := 1250;  // EASTEUROPE_CHARSET - Central/Eastern European (Polish, Czech, Hungarian, etc.)
    // OEM/DOS Charsets
    OEM_CHARSET: Result := 437;   // OEM_CHARSET - Original IBM PC (US)
    255: Result := 850;   // Extended OEM - Multilingual Latin 1 (Western European DOS)
    // EXTENDED MACINTOSH CHARSETS (78-88 range, non-standard but common)
    78: Result := 10001;  // MAC_JAPANESE - Macintosh Japanese
    79: Result := 10003;  // MAC_CHINESETRAD - Macintosh Traditional Chinese (Big5)
    80: Result := 10008;  // MAC_KOREAN - Macintosh Korean
    81: Result := 10002;  // MAC_CHINESESIMP - Macintosh Simplified Chinese (GB 2312)
    82: Result := 10005;  // MAC_HEBREW - Macintosh Hebrew
    83: Result := 10004;  // MAC_ARABIC - Macintosh Arabic
    84: Result := 10006;  // MAC_GREEK - Macintosh Greek
    85: Result := 10081;  // MAC_TURKISH - Macintosh Turkish
    86: Result := 10021;  // MAC_THAI - Macintosh Thai
    87: Result := 10029;  // MAC_LATIN2 - Macintosh Central Europe
    88: Result := 10007;  // MAC_CYRILLIC - Macintosh Cyrillic
    89: Result := 10010;  // MAC_ROMANIAN - Macintosh Romanian
    90: Result := 10017;  // MAC_UKRAINIAN - Macintosh Ukrainian
    91: Result := 10079;  // MAC_ICELANDIC - Macintosh Icelandic
    92: Result := 10082;  // MAC_CROATIAN - Macintosh Croatian
    // ADDITIONAL OEM/DOS CODE PAGES (100-120 range, custom mapping)
    100: Result := 852;   // OEM Latin 2 - Central/Eastern European (DOS)
    101: Result := 866;   // OEM Cyrillic - Russian (DOS)
    102: Result := 865;   // OEM Nordic - Nordic languages (DOS)
    103: Result := 861;   // OEM Icelandic (DOS)
    104: Result := 855;   // OEM Cyrillic - Serbian, Bulgarian (DOS)
    105: Result := 857;   // OEM Turkish (DOS)
    106: Result := 862;   // OEM Hebrew (DOS)
    107: Result := 864;   // OEM Arabic (DOS)
    108: Result := 863;   // OEM French Canadian (DOS)
    109: Result := 737;   // OEM Greek (DOS)
    110: Result := 775;   // OEM Baltic (DOS)
    111: Result := 869;   // OEM Greek Modern (DOS)
    112: Result := 860;   // OEM Portuguese (DOS)
    113: Result := 858;   // OEM Multilingual Latin 1 with Euro (DOS)
    114: Result := 720;   // OEM Arabic (DOS) - Alternative
    115: Result := 851;   // OEM Greek (DOS) - Alternative
    116: Result := 853;   // OEM Latin 3 (DOS)
    117: Result := 872;   // OEM Cyrillic (DOS)
    118: Result := 874;   // OEM Thai (Windows Thai, but sometimes used as OEM)
    119: Result := 1258;  // OEM Vietnamese fallback
    120: Result := 1125;  // OEM Ukrainian (DOS)
    // ISO-8859 SERIES (300-320 range, custom mapping for ISO standards)
    300: Result := 28591; // ISO-8859-1 (Latin 1) - Western European
    301: Result := 28592; // ISO-8859-2 (Latin 2) - Central European
    302: Result := 28593; // ISO-8859-3 (Latin 3) - South European
    303: Result := 28594; // ISO-8859-4 (Latin 4) - North European/Baltic
    304: Result := 28595; // ISO-8859-5 - Cyrillic
    305: Result := 28596; // ISO-8859-6 - Arabic
    306: Result := 28597; // ISO-8859-7 - Greek
    307: Result := 28598; // ISO-8859-8 - Hebrew (Visual)
    308: Result := 28599; // ISO-8859-9 (Latin 5) - Turkish
    309: Result := 28600; // ISO-8859-10 (Latin 6) - Nordic
    310: Result := 28601; // ISO-8859-11 - Thai (withdrawn, use 874)
    311: Result := 874;   // ISO-8859-11 equivalent - Thai
    312: Result := 28603; // ISO-8859-13 (Latin 7) - Baltic Rim
    313: Result := 28604; // ISO-8859-14 (Latin 8) - Celtic
    314: Result := 28605; // ISO-8859-15 (Latin 9) - Western European with Euro
    315: Result := 28606; // ISO-8859-16 (Latin 10) - South-Eastern European
    // UNICODE VARIANTS (400-410 range, custom mapping)
    400: Result := 1200;  // UTF-16LE (Unicode Little Endian) - Windows default Unicode
    401: Result := 1201;  // UTF-16BE (Unicode Big Endian)
    402: Result := 12000; // UTF-32LE (Unicode 32-bit Little Endian)
    403: Result := 12001; // UTF-32BE (Unicode 32-bit Big Endian)
    404: Result := 65001; // UTF-8 (Unicode 8-bit)
    405: Result := 65000; // UTF-7 (7-bit Unicode, obsolete but still supported)
    // EBCDIC CODE PAGES (500-530 range, custom mapping for mainframe systems)
    500: Result := 37;    // EBCDIC US-Canada
    501: Result := 500;   // EBCDIC International
    502: Result := 875;   // EBCDIC Greek Modern
    503: Result := 1026;  // EBCDIC Turkish (Latin 5)
    504: Result := 20273; // EBCDIC Germany
    505: Result := 20277; // EBCDIC Denmark-Norway
    506: Result := 20278; // EBCDIC Finland-Sweden
    507: Result := 20280; // EBCDIC Italy
    508: Result := 20284; // EBCDIC Latin America-Spain
    509: Result := 20285; // EBCDIC United Kingdom
    510: Result := 20290; // EBCDIC Japanese Katakana Extended
    511: Result := 20297; // EBCDIC France
    512: Result := 20420; // EBCDIC Arabic
    513: Result := 20423; // EBCDIC Greek
    514: Result := 20424; // EBCDIC Hebrew
    515: Result := 20833; // EBCDIC Korean Extended
    516: Result := 20838; // EBCDIC Thai
    517: Result := 20866; // EBCDIC Russian
    518: Result := 20871; // EBCDIC Icelandic
    519: Result := 20880; // EBCDIC Cyrillic Russian
    520: Result := 20905; // EBCDIC Turkish
    521: Result := 20924; // EBCDIC Latin 1 / Open System (1047 + Euro)
    522: Result := 21025; // EBCDIC Cyrillic Serbian-Bulgarian
    523: Result := 1047;  // EBCDIC Latin 1 / Open System
    524: Result := 1140;  // EBCDIC US-Canada with Euro
    525: Result := 1141;  // EBCDIC Germany with Euro
    526: Result := 1142;  // EBCDIC Denmark-Norway with Euro
    527: Result := 1143;  // EBCDIC Finland-Sweden with Euro
    528: Result := 1144;  // EBCDIC Italy with Euro
    529: Result := 1145;  // EBCDIC Latin America-Spain with Euro
    530: Result := 1146;  // EBCDIC United Kingdom with Euro
    531: Result := 1147;  // EBCDIC France with Euro
    532: Result := 1148;  // EBCDIC International with Euro
    533: Result := 1149;  // EBCDIC Icelandic with Euro
    // ADDITIONAL ASIAN CODE PAGES (600-620 range, custom mapping)
    600: Result := 50220; // ISO-2022-JP Japanese (no halfwidth Katakana)
    601: Result := 50221; // ISO-2022-JP Japanese with halfwidth Katakana
    602: Result := 50222; // ISO-2022-JP Japanese (JIS)
    603: Result := 50225; // ISO-2022-KR Korean
    604: Result := 50227; // ISO-2022-CN Simplified Chinese
    605: Result := 51932; // EUC-JP Japanese
    606: Result := 51936; // EUC-CN Simplified Chinese (GB2312)
    607: Result := 51949; // EUC-KR Korean
    608: Result := 52936; // HZ-GB2312 Simplified Chinese
    609: Result := 54936; // GB18030 Simplified Chinese (4-byte)
    610: Result := 20932; // JIS X 0208-1990 & 0212-1990 Japanese
    611: Result := 10001; // x-mac-japanese Macintosh Japanese
    612: Result := 20000; // CNS Taiwan (Chinese Traditional)
    613: Result := 20001; // TCA Taiwan
    614: Result := 20002; // Eten Taiwan (Chinese Traditional)
    615: Result := 20003; // IBM5550 Taiwan (Chinese Traditional)
    616: Result := 20004; // TeleText Taiwan
    617: Result := 20005; // Wang Taiwan (Chinese Traditional)
    618: Result := 20105; // IA5 IRV International Alphabet 5 (7-bit)
    619: Result := 20106; // IA5 German (7-bit)
    620: Result := 20107; // IA5 Swedish (7-bit)
    621: Result := 20108; // IA5 Norwegian (7-bit)
    // ISCII CODE PAGES - INDIAN SCRIPTS (700-720 range, custom mapping)
    700: Result := 57002; // ISCII Devanagari
    701: Result := 57003; // ISCII Bengali
    702: Result := 57004; // ISCII Tamil
    703: Result := 57005; // ISCII Telugu
    704: Result := 57006; // ISCII Assamese
    705: Result := 57007; // ISCII Oriya
    706: Result := 57008; // ISCII Kannada
    707: Result := 57009; // ISCII Malayalam
    708: Result := 57010; // ISCII Gujarati
    709: Result := 57011; // ISCII Punjabi
    // MISCELLANEOUS & LEGACY CODE PAGES (800-850 range, custom mapping)
    800: Result := 708;   // ASMO-708 Arabic
    801: Result := 709;   // ASMO-449+ Arabic
    802: Result := 710;   // Arabic - Transparent Arabic
    803: Result := 720;   // DOS-720 Arabic
    804: Result := 870;   // IBM EBCDIC Multilingual/ROECE (Latin 2)
    805: Result := 1047;  // IBM EBCDIC Latin 1 / Open System
    806: Result := 1141;  // IBM EBCDIC Germany with Euro
    807: Result := 20127; // US-ASCII (7-bit)
    808: Result := 20261; // T.61 (CCITT/ITU)
    809: Result := 20269; // ISO-6937 Non-Spacing Accent
    810: Result := 21027; // Extended/Ext Alpha Lowercase (obsolete)
    811: Result := 29001; // Europa 3
    812: Result := 38598; // ISO-8859-8 Hebrew (Logical)
    813: Result := 50930; // EBCDIC Japanese (Katakana) Extended and Japanese
    814: Result := 50931; // EBCDIC US-Canada and Japanese
    815: Result := 50933; // EBCDIC Korean Extended and Korean
    816: Result := 50935; // EBCDIC Simplified Chinese Extended and Simplified Chinese
    817: Result := 50936; // EBCDIC Simplified Chinese
    818: Result := 50937; // EBCDIC US-Canada and Traditional Chinese
    819: Result := 50939; // EBCDIC Japanese (Latin) Extended and Japanese
    820: Result := 51950; // EUC Traditional Chinese
    821: Result := 10017; // x-mac-ukrainian Macintosh Ukrainian
    822: Result := 10029; // x-mac-ce Macintosh Central Europe
    823: Result := 20866; // KOI8-R Russian (Cyrillic)
    824: Result := 21866; // KOI8-U Ukrainian (Cyrillic)
    825: Result := 28594; // ISO-8859-4 Baltic
    826: Result := 28595; // ISO-8859-5 Cyrillic
    827: Result := 10079; // x-mac-icelandic Macintosh Icelandic
  else
    // DEFAULT/UNKNOWN - Use system default
    Result := 0;
  end;
end;

function LangIDToLocaleName(ALangID: Integer): UnicodeString;
begin
  case ALangID of
    // ARABIC (ar) - 0x01
    1025: Result := 'ar-SA'; // Arabic (Saudi Arabia)
    2049: Result := 'ar-IQ'; // Arabic (Iraq)
    3073: Result := 'ar-EG'; // Arabic (Egypt)
    4097: Result := 'ar-LY'; // Arabic (Libya)
    5121: Result := 'ar-DZ'; // Arabic (Algeria)
    6145: Result := 'ar-MA'; // Arabic (Morocco)
    7169: Result := 'ar-TN'; // Arabic (Tunisia)
    8193: Result := 'ar-OM'; // Arabic (Oman)
    9217: Result := 'ar-YE'; // Arabic (Yemen)
    10241: Result := 'ar-SY'; // Arabic (Syria)
    11265: Result := 'ar-JO'; // Arabic (Jordan)
    12289: Result := 'ar-LB'; // Arabic (Lebanon)
    13313: Result := 'ar-KW'; // Arabic (Kuwait)
    14337: Result := 'ar-AE'; // Arabic (U.A.E.)
    15361: Result := 'ar-BH'; // Arabic (Bahrain)
    16385: Result := 'ar-QA'; // Arabic (Qatar)
    // BULGARIAN (bg) - 0x02
    1026: Result := 'bg-BG'; // Bulgarian (Bulgaria)
    // CATALAN (ca) - 0x03
    1027: Result := 'ca-ES'; // Catalan (Catalan)
    // CHINESE (zh) - 0x04
    2052: Result := 'zh-CN'; // Chinese (Simplified, PRC)
    4100: Result := 'zh-SG'; // Chinese (Simplified, Singapore)
    1028: Result := 'zh-TW'; // Chinese (Traditional, Taiwan)
    3076: Result := 'zh-HK'; // Chinese (Traditional, Hong Kong SAR)
    5124: Result := 'zh-MO'; // Chinese (Traditional, Macao SAR)
    // CZECH (cs) - 0x05
    1029: Result := 'cs-CZ'; // Czech (Czech Republic)
    // DANISH (da) - 0x06
    1030: Result := 'da-DK'; // Danish (Denmark)
    // GERMAN (de) - 0x07
    1031: Result := 'de-DE'; // German (Germany)
    2055: Result := 'de-CH'; // German (Switzerland)
    3079: Result := 'de-AT'; // German (Austria)
    4103: Result := 'de-LU'; // German (Luxembourg)
    5127: Result := 'de-LI'; // German (Liechtenstein)
    // GREEK (el) - 0x08
    1032: Result := 'el-GR'; // Greek (Greece)
    // ENGLISH (en) - 0x09
    1033: Result := 'en-US'; // English (United States)
    2057: Result := 'en-GB'; // English (United Kingdom)
    3081: Result := 'en-AU'; // English (Australia)
    4105: Result := 'en-CA'; // English (Canada)
    5129: Result := 'en-NZ'; // English (New Zealand)
    6153: Result := 'en-IE'; // English (Ireland)
    7177: Result := 'en-ZA'; // English (South Africa)
    8201: Result := 'en-JM'; // English (Jamaica)
    9225: Result := 'en-029'; // English (Caribbean)
    10249: Result := 'en-BZ'; // English (Belize)
    11273: Result := 'en-TT'; // English (Trinidad and Tobago)
    12297: Result := 'en-ZW'; // English (Zimbabwe)
    13321: Result := 'en-PH'; // English (Philippines)
    14345: Result := 'en-ID'; // English (Indonesia)
    15369: Result := 'en-HK'; // English (Hong Kong SAR)
    16393: Result := 'en-IN'; // English (India)
    17417: Result := 'en-MY'; // English (Malaysia)
    18441: Result := 'en-SG'; // English (Singapore)
    // SPANISH (es) - 0x0a
    1034: Result := 'es-ES'; // Spanish (Spain, Traditional Sort)
    2058: Result := 'es-MX'; // Spanish (Mexico)
    3082: Result := 'es-ES'; // Spanish (Spain, International Sort)
    4106: Result := 'es-GT'; // Spanish (Guatemala)
    5130: Result := 'es-CR'; // Spanish (Costa Rica)
    6154: Result := 'es-PA'; // Spanish (Panama)
    7178: Result := 'es-DO'; // Spanish (Dominican Republic)
    8202: Result := 'es-VE'; // Spanish (Venezuela)
    9226: Result := 'es-CO'; // Spanish (Colombia)
    10250: Result := 'es-PE'; // Spanish (Peru)
    11274: Result := 'es-AR'; // Spanish (Argentina)
    12298: Result := 'es-EC'; // Spanish (Ecuador)
    13322: Result := 'es-CL'; // Spanish (Chile)
    14346: Result := 'es-UY'; // Spanish (Uruguay)
    15370: Result := 'es-PY'; // Spanish (Paraguay)
    16394: Result := 'es-BO'; // Spanish (Bolivia)
    17418: Result := 'es-SV'; // Spanish (El Salvador)
    18442: Result := 'es-HN'; // Spanish (Honduras)
    19466: Result := 'es-NI'; // Spanish (Nicaragua)
    20490: Result := 'es-PR'; // Spanish (Puerto Rico)
    21514: Result := 'es-US'; // Spanish (United States)
    // FINNISH (fi) - 0x0b
    1035: Result := 'fi-FI'; // Finnish (Finland)
    // FRENCH (fr) - 0x0c
    1036: Result := 'fr-FR'; // French (France)
    2060: Result := 'fr-BE'; // French (Belgium)
    3084: Result := 'fr-CA'; // French (Canada)
    4108: Result := 'fr-CH'; // French (Switzerland)
    5132: Result := 'fr-LU'; // French (Luxembourg)
    6156: Result := 'fr-MC'; // French (Monaco)
    // HEBREW (he) - 0x0d
    1037: Result := 'he-IL'; // Hebrew (Israel)
    // HUNGARIAN (hu) - 0x0e
    1038: Result := 'hu-HU'; // Hungarian (Hungary)
    // ICELANDIC (is) - 0x0f
    1039: Result := 'is-IS'; // Icelandic (Iceland)
    // ITALIAN (it) - 0x10
    1040: Result := 'it-IT'; // Italian (Italy)
    2064: Result := 'it-CH'; // Italian (Switzerland)
    // JAPANESE (ja) - 0x11
    1041: Result := 'ja-JP'; // Japanese (Japan)
    // KOREAN (ko) - 0x12
    1042: Result := 'ko-KR'; // Korean (Korea)
    // DUTCH (nl) - 0x13
    1043: Result := 'nl-NL'; // Dutch (Netherlands)
    2067: Result := 'nl-BE'; // Dutch (Belgium)
    // NORWEGIAN (no/nb/nn) - 0x14
    1044: Result := 'nb-NO'; // Norwegian (Bokmål, Norway)
    2068: Result := 'nn-NO'; // Norwegian (Nynorsk, Norway)
    // POLISH (pl) - 0x15
    1045: Result := 'pl-PL'; // Polish (Poland)
    // PORTUGUESE (pt) - 0x16
    1046: Result := 'pt-BR'; // Portuguese (Brazil)
    2070: Result := 'pt-PT'; // Portuguese (Portugal)
    // ROMANSH (rm) - 0x17
    1047: Result := 'rm-CH'; // Romansh (Switzerland)
    // ROMANIAN (ro) - 0x18
    1048: Result := 'ro-RO'; // Romanian (Romania)
    // RUSSIAN (ru) - 0x19
    1049: Result := 'ru-RU'; // Russian (Russia)
    // CROATIAN/SERBIAN/BOSNIAN (hr/sr/bs) - 0x1a
    1050: Result := 'hr-HR'; // Croatian (Croatia)
    4122: Result := 'hr-BA'; // Croatian (Bosnia and Herzegovina)
    2074: Result := 'sr-Latn-CS'; // Serbian (Latin, Serbia)
    3098: Result := 'sr-Cyrl-CS'; // Serbian (Cyrillic, Serbia)
    6170: Result := 'sr-Latn-BA'; // Serbian (Latin, Bosnia and Herzegovina)
    7194: Result := 'sr-Cyrl-BA'; // Serbian (Cyrillic, Bosnia and Herzegovina)
    10266: Result := 'sr-Latn-ME'; // Serbian (Latin, Montenegro)
    11290: Result := 'sr-Cyrl-ME'; // Serbian (Cyrillic, Montenegro)
    5146: Result := 'bs-Latn-BA'; // Bosnian (Latin, Bosnia and Herzegovina)
    8218: Result := 'bs-Cyrl-BA'; // Bosnian (Cyrillic, Bosnia and Herzegovina)
    // SLOVAK (sk) - 0x1b
    1051: Result := 'sk-SK'; // Slovak (Slovakia)
    // ALBANIAN (sq) - 0x1c
    1052: Result := 'sq-AL'; // Albanian (Albania)
    // SWEDISH (sv) - 0x1d
    1053: Result := 'sv-SE'; // Swedish (Sweden)
    2077: Result := 'sv-FI'; // Swedish (Finland)
    // THAI (th) - 0x1e
    1054: Result := 'th-TH'; // Thai (Thailand)
    // TURKISH (tr) - 0x1f
    1055: Result := 'tr-TR'; // Turkish (Turkey)
    // URDU (ur) - 0x20
    1056: Result := 'ur-PK'; // Urdu (Islamic Republic of Pakistan)
    // INDONESIAN (id) - 0x21
    1057: Result := 'id-ID'; // Indonesian (Indonesia)
    // UKRAINIAN (uk) - 0x22
    1058: Result := 'uk-UA'; // Ukrainian (Ukraine)
    // BELARUSIAN (be) - 0x23
    1059: Result := 'be-BY'; // Belarusian (Belarus)
    // SLOVENIAN (sl) - 0x24
    1060: Result := 'sl-SI'; // Slovenian (Slovenia)
    // ESTONIAN (et) - 0x25
    1061: Result := 'et-EE'; // Estonian (Estonia)
    // LATVIAN (lv) - 0x26
    1062: Result := 'lv-LV'; // Latvian (Latvia)
    // LITHUANIAN (lt) - 0x27
    1063: Result := 'lt-LT'; // Lithuanian (Lithuania)
    // TAJIK (tg) - 0x28
    1064: Result := 'tg-Cyrl-TJ'; // Tajik (Cyrillic, Tajikistan)
    // PERSIAN/FARSI (fa) - 0x29
    1065: Result := 'fa-IR'; // Persian (Iran)
    // VIETNAMESE (vi) - 0x2a
    1066: Result := 'vi-VN'; // Vietnamese (Vietnam)
    // ARMENIAN (hy) - 0x2b
    1067: Result := 'hy-AM'; // Armenian (Armenia)
    // AZERI/AZERBAIJANI (az) - 0x2c
    1068: Result := 'az-Latn-AZ'; // Azeri (Latin, Azerbaijan)
    2092: Result := 'az-Cyrl-AZ'; // Azeri (Cyrillic, Azerbaijan)
    // BASQUE (eu) - 0x2d
    1069: Result := 'eu-ES'; // Basque (Basque)
    // UPPER SORBIAN/LOWER SORBIAN (hsb/dsb) - 0x2e
    1070: Result := 'hsb-DE'; // Upper Sorbian (Germany)
    2094: Result := 'dsb-DE'; // Lower Sorbian (Germany)
    // MACEDONIAN (mk) - 0x2f
    1071: Result := 'mk-MK'; // Macedonian (North Macedonia)
    // SETSWANA/TSWANA (tn) - 0x32
    1074: Result := 'tn-ZA'; // Setswana (South Africa)
    2098: Result := 'tn-BW'; // Setswana (Botswana)
    // XHOSA (xh) - 0x34
    1076: Result := 'xh-ZA'; // isiXhosa (South Africa)
    // ZULU (zu) - 0x35
    1077: Result := 'zu-ZA'; // isiZulu (South Africa)
    // AFRIKAANS (af) - 0x36
    1078: Result := 'af-ZA'; // Afrikaans (South Africa)
    // GEORGIAN (ka) - 0x37
    1079: Result := 'ka-GE'; // Georgian (Georgia)
    // FAROESE (fo) - 0x38
    1080: Result := 'fo-FO'; // Faroese (Faroe Islands)
    // HINDI (hi) - 0x39
    1081: Result := 'hi-IN'; // Hindi (India)
    // MALTESE (mt) - 0x3a
    1082: Result := 'mt-MT'; // Maltese (Malta)
    // SAMI (se/sma/smj/smn/sms) - 0x3b
    1083: Result := 'se-NO'; // Sami (Northern, Norway)
    2107: Result := 'se-SE'; // Sami (Northern, Sweden)
    3131: Result := 'se-FI'; // Sami (Northern, Finland)
    4155: Result := 'smj-NO'; // Sami (Lule, Norway)
    5179: Result := 'smj-SE'; // Sami (Lule, Sweden)
    6203: Result := 'sma-NO'; // Sami (Southern, Norway)
    7227: Result := 'sma-SE'; // Sami (Southern, Sweden)
    8251: Result := 'smn-FI'; // Sami (Inari, Finland)
    9275: Result := 'sms-FI'; // Sami (Skolt, Finland)
    // IRISH (ga) - 0x3c
    1084: Result := 'ga-IE'; // Irish (Ireland)
    // MALAY (ms) - 0x3e
    1086: Result := 'ms-MY'; // Malay (Malaysia)
    2110: Result := 'ms-BN'; // Malay (Brunei Darussalam)
    // KAZAKH (kk) - 0x3f
    1087: Result := 'kk-KZ'; // Kazakh (Kazakhstan)
    // KYRGYZ (ky) - 0x40
    1088: Result := 'ky-KG'; // Kyrgyz (Kyrgyzstan)
    // SWAHILI (sw) - 0x41
    1089: Result := 'sw-KE'; // Kiswahili (Kenya)
    // TURKMEN (tk) - 0x42
    1090: Result := 'tk-TM'; // Turkmen (Turkmenistan)
    // UZBEK (uz) - 0x43
    1091: Result := 'uz-Latn-UZ'; // Uzbek (Latin, Uzbekistan)
    2115: Result := 'uz-Cyrl-UZ'; // Uzbek (Cyrillic, Uzbekistan)
    // TATAR (tt) - 0x44
    1092: Result := 'tt-RU'; // Tatar (Russia)
    // BENGALI (bn) - 0x45
    1093: Result := 'bn-IN'; // Bengali (India)
    2117: Result := 'bn-BD'; // Bengali (Bangladesh)
    // PUNJABI (pa) - 0x46
    1094: Result := 'pa-IN'; // Punjabi (India)
    2118: Result := 'pa-Arab-PK'; // Punjabi (Pakistan)
    // GUJARATI (gu) - 0x47
    1095: Result := 'gu-IN'; // Gujarati (India)
    // ODIA/ORIYA (or) - 0x48
    1096: Result := 'or-IN'; // Odia (India)
    // TAMIL (ta) - 0x49
    1097: Result := 'ta-IN'; // Tamil (India)
    2121: Result := 'ta-LK'; // Tamil (Sri Lanka)
    // TELUGU (te) - 0x4a
    1098: Result := 'te-IN'; // Telugu (India)
    // KANNADA (kn) - 0x4b
    1099: Result := 'kn-IN'; // Kannada (India)
    // MALAYALAM (ml) - 0x4c
    1100: Result := 'ml-IN'; // Malayalam (India)
    // ASSAMESE (as) - 0x4d
    1101: Result := 'as-IN'; // Assamese (India)
    // MARATHI (mr) - 0x4e
    1102: Result := 'mr-IN'; // Marathi (India)
    // SANSKRIT (sa) - 0x4f
    1103: Result := 'sa-IN'; // Sanskrit (India)
    // MONGOLIAN (mn) - 0x50
    1104: Result := 'mn-MN'; // Mongolian (Cyrillic, Mongolia)
    2128: Result := 'mn-Mong-CN'; // Mongolian (Traditional Mongolian, PRC)
    3152: Result := 'mn-Mong-MN'; // Mongolian (Traditional Mongolian, Mongolia)
    // TIBETAN (bo) - 0x51
    1105: Result := 'bo-CN'; // Tibetan (PRC)
    // WELSH (cy) - 0x52
    1106: Result := 'cy-GB'; // Welsh (United Kingdom)
    // KHMER (km) - 0x53
    1107: Result := 'km-KH'; // Khmer (Cambodia)
    // LAO (lo) - 0x54
    1108: Result := 'lo-LA'; // Lao (Lao P.D.R.)
    // BURMESE (my) - 0x55
    1109: Result := 'my-MM'; // Burmese (Myanmar)
    // GALICIAN (gl) - 0x56
    1110: Result := 'gl-ES'; // Galician (Galician)
    // KONKANI (kok) - 0x57
    1111: Result := 'kok-IN'; // Konkani (India)
    // MANIPURI (mni) - 0x58
    1112: Result := 'mni-IN'; // Manipuri (India)
    // SINDHI (sd) - 0x59
    1113: Result := 'sd-Deva-IN'; // Sindhi (Devanagari, India)
    2137: Result := 'sd-Arab-PK'; // Sindhi (Pakistan)
    // SYRIAC (syr) - 0x5a
    1114: Result := 'syr-SY'; // Syriac (Syria)
    // SINHALESE (si) - 0x5b
    1115: Result := 'si-LK'; // Sinhala (Sri Lanka)
    // CHEROKEE (chr) - 0x5c
    1116: Result := 'chr-Cher-US'; // Cherokee (United States)
    // INUKTITUT (iu) - 0x5d
    1117: Result := 'iu-Cans-CA'; // Inuktitut (Syllabics, Canada)
    2141: Result := 'iu-Latn-CA'; // Inuktitut (Latin, Canada)
    // AMHARIC (am) - 0x5e
    1118: Result := 'am-ET'; // Amharic (Ethiopia)
    // TAMAZIGHT (tzm) - 0x5f
    1119: Result := 'tzm-Latn-DZ'; // Tamazight (Latin, Algeria)
    2143: Result := 'tzm-Tfng-MA'; // Central Atlas Tamazight (Tifinagh, Morocco)
    // KASHMIRI (ks) - 0x60
    1120: Result := 'ks-Arab-IN'; // Kashmiri (Arabic)
    // NEPALI (ne) - 0x61
    1121: Result := 'ne-NP'; // Nepali (Nepal)
    2145: Result := 'ne-IN'; // Nepali (India)
    // FRISIAN (fy) - 0x62
    1122: Result := 'fy-NL'; // Frisian (Netherlands)
    // PASHTO (ps) - 0x63
    1123: Result := 'ps-AF'; // Pashto (Afghanistan)
    // FILIPINO (fil) - 0x64
    1124: Result := 'fil-PH'; // Filipino (Philippines)
    // DIVEHI (dv) - 0x65
    1125: Result := 'dv-MV'; // Divehi (Maldives)
    // HAUSA (ha) - 0x68
    1128: Result := 'ha-Latn-NG'; // Hausa (Latin, Nigeria)
    // YORUBA (yo) - 0x6a
    1130: Result := 'yo-NG'; // Yoruba (Nigeria)
    // QUECHUA (quz) - 0x6b
    1131: Result := 'quz-BO'; // Quechua (Bolivia)
    2155: Result := 'quz-EC'; // Quechua (Ecuador)
    3179: Result := 'quz-PE'; // Quechua (Peru)
    // SESOTHO SA LEBOA (nso) - 0x6c
    1132: Result := 'nso-ZA'; // Sesotho sa Leboa (South Africa)
    // BASHKIR (ba) - 0x6d
    1133: Result := 'ba-RU'; // Bashkir (Russia)
    // LUXEMBOURGISH (lb) - 0x6e
    1134: Result := 'lb-LU'; // Luxembourgish (Luxembourg)
    // GREENLANDIC (kl) - 0x6f
    1135: Result := 'kl-GL'; // Greenlandic (Greenland)
    // IGBO (ig) - 0x70
    1136: Result := 'ig-NG'; // Igbo (Nigeria)
    // YI (ii) - 0x78
    1144: Result := 'ii-CN'; // Yi (PRC)
    // MAPUDUNGUN (arn) - 0x7a
    1146: Result := 'arn-CL'; // Mapudungun (Chile)
    // MOHAWK (moh) - 0x7c
    1148: Result := 'moh-CA'; // Mohawk (Canada)
    // BRETON (br) - 0x7e
    1150: Result := 'br-FR'; // Breton (France)
    // UIGHUR (ug) - 0x80
    1152: Result := 'ug-CN'; // Uyghur (PRC)
    // MAORI (mi) - 0x81
    1153: Result := 'mi-NZ'; // Maori (New Zealand)
    // OCCITAN (oc) - 0x82
    1154: Result := 'oc-FR'; // Occitan (France)
    // CORSICAN (co) - 0x83
    1155: Result := 'co-FR'; // Corsican (France)
    // ALSATIAN (gsw) - 0x84
    1156: Result := 'gsw-FR'; // Alsatian (France)
    // YAKUT/SAKHA (sah) - 0x85
    1157: Result := 'sah-RU'; // Yakut (Russia)
    // KICHE (qut) - 0x86
    1158: Result := 'qut-GT'; // K'iche (Guatemala)
    // KINYARWANDA (rw) - 0x87
    1159: Result := 'rw-RW'; // Kinyarwanda (Rwanda)
    // WOLOF (wo) - 0x88
    1160: Result := 'wo-SN'; // Wolof (Senegal)
    // DARI (prs) - 0x8c
    1164: Result := 'prs-AF'; // Dari (Afghanistan)
    // SCOTTISH GAELIC (gd) - 0x91
    1169: Result := 'gd-GB'; // Scottish Gaelic (United Kingdom)
    // CENTRAL KURDISH (ku) - 0x92
    1170: Result := 'ku-Arab-IQ'; // Central Kurdish (Iraq)
  else
    Result := ''; // Unknown/Unsupported locale
  end;
end;


// UNICODE CASING & SCRIPT CLASSIFICATION
function LangIDToScriptType(ALangID: Integer): TScriptType;
var
  PrimaryLangID, FullLCID: Integer;
begin
  if ALangID = 0 then Exit(scrLatin);
  PrimaryLangID := ALangID and $3FF;
  FullLCID      := ALangID and $FFFF;
  case PrimaryLangID of
    $07: Exit(scrGerman);   // German 
    $1f: Exit(scrTurkish);  // Turkish 
    $08: Exit(scrGreek);    // Greek
    $2b: Exit(scrArmenian); // Armenian
    $37: Exit(scrGeorgian); // Georgian
    $5c: Exit(scrCherokee); // Cherokee

    // Middle Eastern
    $01: Exit(scrArabic);   // Arabic
    $29: Exit(scrPersian);  // Persian (Farsi)
    $0d: Exit(scrHebrew);   // Hebrew

    // South Asian & Indic
    $39: Exit(scrDevanagari); // Hindi / Marathi / Sanskrit / Nepali
    $45: Exit(scrBengali);    // Bengali / Assamese
    $46: Exit(scrGurmukhi);   // Punjabi
    $47: Exit(scrGujarati);   // Gujarati
    $48: Exit(scrOriya);      // Oriya (Odia)
    $49: Exit(scrTamil);      // Tamil
    $4a: Exit(scrTelugu);     // Telugu
    $4b: Exit(scrKannada);    // Kannada
    $4c: Exit(scrMalayalam);  // Malayalam
    $5b: Exit(scrSinhala);    // Sinhala

    // Southeast Asian
    $1e: Exit(scrThai);       // Thai
    $53: Exit(scrKhmer);      // Khmer
    $54: Exit(scrLao);        // Lao
    $55: Exit(scrBurmese);    // Burmese (Myanmar)
    $51: Exit(scrTibetan);    // Tibetan

    // East Asian (CJK)
    $04: Exit(scrCjk);        // Chinese
    $11: Exit(scrJapanese);   // Japanese
    $12: Exit(scrKorean);     // Korean

    // Mongolian & African
    $50: Exit(scrMongolian);  // Mongolian
    $5e: Exit(scrEthiopic);   // Amharic / Ethiopic

    // Cyrillic dominant
    $19, $22, $23, $28, $2f, $3f, $40, $44, $85, $90:
      Exit(scrCyrillic);
    // Multilingual Cyrillic / Latin script variants
    $1a: // Serbian / Bosnian
      case FullLCID of
        $0c1a, $1c1a, $301a, $201a: Exit(scrCyrillic);
      else
        Exit(scrLatin);
      end;
    $2c: // Azeri
      case FullLCID of
        $082c: Exit(scrCyrillic);
      else
        Exit(scrTurkish); // Azeri Latin follows Turkish dotted-i rules
      end;
    $43: // Uzbek
      case FullLCID of
        $0843: Exit(scrCyrillic);
      else
        Exit(scrLatin);
      end;
    // Latin Script Languages
    $05, $06, $09, $0a, $0b, $0c, $0e, $10, $13, $14, $15, $16, $17, $18, $1b,
    $1c, $1d, $21, $24, $25, $26, $27, $2a, $2d, $2e, $32, $34, $35, $36, $38,
    $3a, $3b, $3c, $3e, $41, $42, $52, $56, $62, $64, $68, $6a, $6b, $6e, $6f,
    $70, $7a, $7e, $81, $82, $83, $84, $86, $87, $91:
      Exit(scrLatin);
  else
    Exit(scrLatin);
  end;
end;

function ScriptToDefaultLangID(Script: TScriptType): Integer;
begin
  case Script of
    // Middle Eastern & Semitic
    scrArabic:        Result := $0401; // Arabic (Saudi Arabia)
    scrPersian:       Result := $0429; // Persian (Iran)
    scrHebrew:        Result := $040D; // Hebrew (Israel)

    // South Asian & Indic
    scrDevanagari:    Result := $0439; // Hindi
    scrBengali:       Result := $0445; // Bengali
    scrGurmukhi:      Result := $0446; // Punjabi
    scrGujarati:      Result := $0447; // Gujarati
    scrOriya:         Result := $0448; // Oriya (Odia)
    scrTamil:         Result := $0449; // Tamil
    scrTelugu:        Result := $044A; // Telugu
    scrKannada:       Result := $044B; // Kannada
    scrMalayalam:     Result := $044C; // Malayalam
    scrSinhala:       Result := $045B; // Sinhala
    scrOlChiki:       Result := $0448; // Santali / Odia region ($0448)
    scrMeeteiMayek:   Result := $0458; // Manipuri ($0458)

    // Southeast Asian
    scrThai:          Result := $041E; // Thai
    scrKhmer:         Result := $0453; // Khmer
    scrLao:           Result := $0454; // Lao
    scrBurmese:       Result := $0455; // Burmese
    scrTibetan:       Result := $0451; // Tibetan

    // Regional, Island & Historic
    scrJavanese:      Result := $0421; // Indonesian ($0421)
    scrBalinese:      Result := $0421; // Balinese / Indonesia
    scrSundanese:     Result := $0421; // Sundanese / Indonesia
    scrCham:          Result := $042A; // Vietnamese ($042A)
    scrTaiTham:       Result := $041E; // Northern Thai ($041E)
    scrNewTaiLue:     Result := $041E; // Tai Lue ($041E)
    scrKayahLi:       Result := $0455; // Kayah Li / Myanmar ($0455)
    scrChakma:        Result := $0445; // Chakma / Bangladesh ($0445)
    scrSoraSompeng:   Result := $0448; // Sora / Odisha ($0448)
    scrLimbu:         Result := $0461; // Limbu / Nepal ($0461)
    scrLepcha:        Result := $0461; // Lepcha / Sikkim ($0461)
    scrWancho:        Result := $0439; // Wancho / Arunachal Pradesh ($0439)
    scrMongolian:     Result := $0450; // Mongolian

    // African
    scrEthiopic:      Result := $045E; // Amharic
    scrNKo:           Result := $0488; // N'Ko / West Africa ($0488)
    scrVai:           Result := $0409; // Vai / Liberia ($0409)
    scrOsmanya:       Result := $0477; // Somali ($0477)
    scrAdlam:         Result := $0468; // Fulani / Nigeria ($0468)
    scrGaray:         Result := $0488; // Wolof ($0488)
    scrMedefaidrin:   Result := $0470; // Igbo / Nigeria ($0470)

    // East Asian (CJK)
    scrCjk:           Result := $0804; // Chinese (Simplified, PRC)
    scrJapanese:      Result := $0411; // Japanese
    scrKorean:        Result := $0412; // Korean

    // European, Caucasian & Historic
    scrGreek:         Result := $0408; // Greek
    scrCyrillic:      Result := $0419; // Russian
    scrArmenian:      Result := $042B; // Armenian
    scrGeorgian:      Result := $0437; // Georgian
    scrGerman:        Result := $0407; // German
    scrTurkish:       Result := $041F; // Turkish
    scrLatin:         Result := $0409; // English (US)
    scrCherokee:      Result := $045C; // Cherokee
    scrCoptic:        Result := $0401; // Coptic / Egypt ($0401)
    scrGlagolitic:    Result := $041A; // Old Slavic / Croatia ($041A)
    scrDeseret:       Result := $0409; // Utah ($0409)
    scrOsage:         Result := $0409; // Osage ($0409)
    scrOldHungarian:  Result := $040E; // Hungarian ($040E)
    scrVithkuqi:      Result := $041C; // Albanian ($041C)
    scrWarangCiti:    Result := $0439; // Ho / India ($0439)
    scrSymbols:       Result := $0409; // Symbols / International
    else
      Result := DefaultAppLangID;
  end;
end;

function IsScriptRTL(Script: TScriptType): Boolean;
begin
  case Script of
    scrArabic,
    scrPersian,
    scrHebrew,
    scrNKo,
    scrAdlam,
    scrGaray,
    scrOldHungarian:
      Result := True;
  else
    Result := False;
  end;
end;

function IsLangIDRTL(ALangID: Integer): Boolean;
begin
  Result := IsScriptRTL(LangIDToScriptType(ALangID));
end;

function ScriptToIso15924(Script: TScriptType): string;
begin
  case Script of
    scrLatin, scrGerman, scrTurkish: Result := 'Latn';
    scrGreek:        Result := 'Grek';
    scrCyrillic:     Result := 'Cyrl';
    scrArmenian:     Result := 'Armn';
    scrGeorgian:     Result := 'Geor';
    scrCherokee:     Result := 'Cher';
    scrCoptic:       Result := 'Copt';
    scrGlagolitic:   Result := 'Glag';
    scrDeseret:      Result := 'Dsrt';
    scrOsage:        Result := 'Osge';
    scrAdlam:        Result := 'Adlm';
    scrGaray:        Result := 'Gara';
    scrMedefaidrin:  Result := 'Medf';
    scrOldHungarian: Result := 'Hung';
    scrVithkuqi:     Result := 'Vith';
    scrWarangCiti:   Result := 'Wara';
    scrArabic:       Result := 'Arab';
    scrPersian:      Result := 'Arab';
    scrHebrew:       Result := 'Hebr';
    scrDevanagari:   Result := 'Deva';
    scrBengali:      Result := 'Beng';
    scrGurmukhi:     Result := 'Guru';
    scrGujarati:     Result := 'Gujr';
    scrOriya:        Result := 'Orya';
    scrTamil:        Result := 'Taml';
    scrTelugu:       Result := 'Telu';
    scrKannada:      Result := 'Knda';
    scrMalayalam:    Result := 'Mlym';
    scrSinhala:      Result := 'Sinh';
    scrOlChiki:      Result := 'Olck';
    scrMeeteiMayek:  Result := 'Mtei';
    scrThai:         Result := 'Thai';
    scrKhmer:        Result := 'Khmr';
    scrLao:          Result := 'Laoo';
    scrBurmese:      Result := 'Mymr';
    scrTibetan:      Result := 'Tibt';
    scrJavanese:     Result := 'Java';
    scrBalinese:     Result := 'Bali';
    scrSundanese:    Result := 'Sund';
    scrCham:         Result := 'Cham';
    scrTaiTham:      Result := 'Lana';
    scrNewTaiLue:    Result := 'Talu';
    scrKayahLi:      Result := 'Kali';
    scrChakma:       Result := 'Cakm';
    scrSoraSompeng:  Result := 'Sora';
    scrLimbu:        Result := 'Limb';
    scrLepcha:       Result := 'Lepc';
    scrWancho:       Result := 'Wcho';
    scrMongolian:    Result := 'Mong';
    scrEthiopic:     Result := 'Ethi';
    scrNKo:          Result := 'Nkoo';
    scrVai:          Result := 'Vaii';
    scrOsmanya:      Result := 'Osma';
    scrCjk:          Result := 'Hani';
    scrJapanese:     Result := 'Jpan';
    scrKorean:       Result := 'Kore';
    scrSymbols:      Result := 'Zsym';
  else
    Result := 'Zxxx';
  end;
end;

function Iso15924ToScript(const ACode: string): TScriptType;
var
  S: string;
begin
  S := UpperCase(Trim(ACode));
  if (S = 'LATN') then Result := scrLatin
  else if (S = 'GREK') then Result := scrGreek
  else if (S = 'CYRL') then Result := scrCyrillic
  else if (S = 'ARMN') then Result := scrArmenian
  else if (S = 'GEOR') then Result := scrGeorgian
  else if (S = 'CHER') then Result := scrCherokee
  else if (S = 'COPT') then Result := scrCoptic
  else if (S = 'GLAG') then Result := scrGlagolitic
  else if (S = 'DSRT') then Result := scrDeseret
  else if (S = 'OSGE') then Result := scrOsage
  else if (S = 'ADLM') then Result := scrAdlam
  else if (S = 'GARA') then Result := scrGaray
  else if (S = 'MEDF') then Result := scrMedefaidrin
  else if (S = 'HUNG') then Result := scrOldHungarian
  else if (S = 'VITH') then Result := scrVithkuqi
  else if (S = 'WARA') then Result := scrWarangCiti
  else if (S = 'ARAB') then Result := scrArabic
  else if (S = 'HEBR') then Result := scrHebrew
  else if (S = 'DEVA') then Result := scrDevanagari
  else if (S = 'BENG') then Result := scrBengali
  else if (S = 'GURU') then Result := scrGurmukhi
  else if (S = 'GUJR') then Result := scrGujarati
  else if (S = 'ORYA') then Result := scrOriya
  else if (S = 'TAML') then Result := scrTamil
  else if (S = 'TELU') then Result := scrTelugu
  else if (S = 'KNDA') then Result := scrKannada
  else if (S = 'MLYM') then Result := scrMalayalam
  else if (S = 'SINH') then Result := scrSinhala
  else if (S = 'OLCK') then Result := scrOlChiki
  else if (S = 'MTEI') then Result := scrMeeteiMayek
  else if (S = 'THAI') then Result := scrThai
  else if (S = 'KHMR') then Result := scrKhmer
  else if (S = 'LAOO') then Result := scrLao
  else if (S = 'MYMR') then Result := scrBurmese
  else if (S = 'TIBT') then Result := scrTibetan
  else if (S = 'JAVA') then Result := scrJavanese
  else if (S = 'BALI') then Result := scrBalinese
  else if (S = 'SUND') then Result := scrSundanese
  else if (S = 'CHAM') then Result := scrCham
  else if (S = 'LANA') then Result := scrTaiTham
  else if (S = 'TALU') then Result := scrNewTaiLue
  else if (S = 'KALI') then Result := scrKayahLi
  else if (S = 'CAKM') then Result := scrChakma
  else if (S = 'SORA') then Result := scrSoraSompeng
  else if (S = 'LIMB') then Result := scrLimbu
  else if (S = 'LEPC') then Result := scrLepcha
  else if (S = 'WCHO') then Result := scrWancho
  else if (S = 'MONG') then Result := scrMongolian
  else if (S = 'ETHI') then Result := scrEthiopic
  else if (S = 'NKOO') then Result := scrNKo
  else if (S = 'VAII') then Result := scrVai
  else if (S = 'OSMA') then Result := scrOsmanya
  else if (S = 'HANI') then Result := scrCjk
  else if (S = 'JPAN') then Result := scrJapanese
  else if (S = 'KORE') then Result := scrKorean
  else if (S = 'ZSYM') then Result := scrSymbols
  else Result := scrUnknown;
end;

{$IFDEF MSWINDOWS}
function GetUserDefaultLCID: LongWord; stdcall; external 'kernel32.dll';
{$ENDIF}

function GetSystemLangID: Integer;
{$IFNDEF MSWINDOWS}
var
  Env: string;
  P: Integer;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Result := Integer(GetUserDefaultLCID);
  if Result = 0 then
    Result := DefaultAppLangID;
  {$ELSE}
  Env := GetEnvironmentVariable('LC_ALL');
  if Env = '' then Env := GetEnvironmentVariable('LC_MESSAGES');
  if Env = '' then Env := GetEnvironmentVariable('LANG');
  if Env <> '' then
  begin
    P := Pos('.', Env);
    if P > 0 then Delete(Env, P, Length(Env));
    P := Pos('@', Env);
    if P > 0 then Delete(Env, P, Length(Env));
    Result := LocaleNameToLangID(Env);
    if Result <> 0 then Exit;
  end;
  Result := DefaultAppLangID;
  {$ENDIF}
end;

function GetSystemScript: TScriptType;
begin
  Result := LangIDToScriptType(GetSystemLangID);
end;

function LocaleNameToLangID(const ALocaleName: UnicodeString): Integer;
var
  Norm: string;
begin
  Norm := StringReplace(LowerCase(Trim(string(ALocaleName))), '_', '-', [rfReplaceAll]);
  if Norm = '' then Exit(0);

  // Common locales
  if (Norm = 'en') or (Norm = 'en-us') then Exit($0409);
  if (Norm = 'en-gb') then Exit($0809);
  if (Norm = 'en-ca') then Exit($1009);
  if (Norm = 'en-au') then Exit($0C09);
  if (Norm = 'de') or (Norm = 'de-de') then Exit($0407);
  if (Norm = 'de-at') then Exit($0C07);
  if (Norm = 'de-ch') then Exit($0807);
  if (Norm = 'fr') or (Norm = 'fr-fr') then Exit($040C);
  if (Norm = 'fr-ca') then Exit($0C0C);
  if (Norm = 'fr-be') then Exit($080C);
  if (Norm = 'fr-ch') then Exit($100C);
  if (Norm = 'es') or (Norm = 'es-es') then Exit($0C0A);
  if (Norm = 'es-mx') then Exit($080A);
  if (Norm = 'it') or (Norm = 'it-it') then Exit($0410);
  if (Norm = 'pt') or (Norm = 'pt-br') then Exit($0416);
  if (Norm = 'pt-pt') then Exit($0816);
  if (Norm = 'ru') or (Norm = 'ru-ru') then Exit($0419);
  if (Norm = 'zh') or (Norm = 'zh-cn') or (Norm = 'zh-hans') then Exit($0804);
  if (Norm = 'zh-tw') or (Norm = 'zh-hant') then Exit($0404);
  if (Norm = 'zh-hk') then Exit($0C04);
  if (Norm = 'ja') or (Norm = 'ja-jp') then Exit($0411);
  if (Norm = 'ko') or (Norm = 'ko-kr') then Exit($0412);
  if (Norm = 'ar') or (Norm = 'ar-sa') then Exit($0401);
  if (Norm = 'ar-eg') then Exit($0C01);
  if (Norm = 'fa') or (Norm = 'fa-ir') then Exit($0429);
  if (Norm = 'he') or (Norm = 'he-il') then Exit($040D);
  if (Norm = 'hi') or (Norm = 'hi-in') then Exit($0439);
  if (Norm = 'bn') or (Norm = 'bn-in') then Exit($0445);
  if (Norm = 'tr') or (Norm = 'tr-tr') then Exit($041F);
  if (Norm = 'nl') or (Norm = 'nl-nl') then Exit($0413);
  if (Norm = 'pl') or (Norm = 'pl-pl') then Exit($0415);
  if (Norm = 'uk') or (Norm = 'uk-ua') then Exit($0422);
  if (Norm = 'el') or (Norm = 'el-gr') then Exit($0408);
  if (Norm = 'th') or (Norm = 'th-th') then Exit($041E);
  if (Norm = 'vi') or (Norm = 'vi-vn') then Exit($042A);
  if (Norm = 'sv') or (Norm = 'sv-se') then Exit($041D);
  if (Norm = 'da') or (Norm = 'da-dk') then Exit($0406);
  if (Norm = 'fi') or (Norm = 'fi-fi') then Exit($040B);
  if (Norm = 'no') or (Norm = 'nb') or (Norm = 'nb-no') then Exit($0414);
  if (Norm = 'cs') or (Norm = 'cs-cz') then Exit($0405);
  if (Norm = 'hu') or (Norm = 'hu-hu') then Exit($040E);
  if (Norm = 'ro') or (Norm = 'ro-ro') then Exit($0418);
  if (Norm = 'id') or (Norm = 'id-id') then Exit($0421);
  if (Norm = 'ms') or (Norm = 'ms-my') then Exit($043E);
  if (Norm = 'ta') or (Norm = 'ta-in') then Exit($0449);
  if (Norm = 'te') or (Norm = 'te-in') then Exit($044A);
  if (Norm = 'ur') or (Norm = 'ur-pk') then Exit($0420);
  if (Norm = 'pa') or (Norm = 'pa-in') then Exit($0446);
  if (Norm = 'mr') or (Norm = 'mr-in') then Exit($044E);
  if (Norm = 'gu') or (Norm = 'gu-in') then Exit($0447);
  if (Norm = 'kn') or (Norm = 'kn-in') then Exit($044B);
  if (Norm = 'ml') or (Norm = 'ml-in') then Exit($044C);
  if (Norm = 'sw') or (Norm = 'sw-ke') then Exit($0441);
  if (Norm = 'ka') or (Norm = 'ka-ge') then Exit($0437);
  if (Norm = 'hy') or (Norm = 'hy-am') then Exit($042B);
  if (Norm = 'sr') or (Norm = 'sr-cyrl') then Exit($0C1A);
  if (Norm = 'sr-latn') then Exit($081A);
  if (Norm = 'hr') or (Norm = 'hr-hr') then Exit($041A);
  if (Norm = 'bs') or (Norm = 'bs-latn') then Exit($141A);
  if (Norm = 'bs-cyrl') then Exit($201A);
  if (Norm = 'sk') or (Norm = 'sk-sk') then Exit($041B);
  if (Norm = 'sl') or (Norm = 'sl-si') then Exit($0424);
  if (Norm = 'bg') or (Norm = 'bg-bg') then Exit($0402);
  if (Norm = 'ca') or (Norm = 'ca-es') then Exit($0403);
  if (Norm = 'af') or (Norm = 'af-za') then Exit($0436);
  if (Norm = 'et') or (Norm = 'et-ee') then Exit($0425);
  if (Norm = 'lv') or (Norm = 'lv-lv') then Exit($0426);
  if (Norm = 'lt') or (Norm = 'lt-lt') then Exit($0427);
  if (Norm = 'kk') or (Norm = 'kk-kz') then Exit($043F);
  if (Norm = 'uz') or (Norm = 'uz-latn') then Exit($0443);
  if (Norm = 'uz-cyrl') then Exit($0843);
  if (Norm = 'az') or (Norm = 'az-latn') then Exit($042C);
  if (Norm = 'az-cyrl') then Exit($082C);
  if (Norm = 'am') or (Norm = 'am-et') then Exit($045E);
  if (Norm = 'km') or (Norm = 'km-kh') then Exit($0453);
  if (Norm = 'lo') or (Norm = 'lo-la') then Exit($0454);
  if (Norm = 'my') or (Norm = 'my-mm') then Exit($0455);
  if (Norm = 'ne') or (Norm = 'ne-np') then Exit($0461);
  if (Norm = 'si') or (Norm = 'si-lk') then Exit($045B);
  if (Norm = 'mn') or (Norm = 'mn-mn') then Exit($0450);
  if (Norm = 'chr') or (Norm = 'chr-us') then Exit($045C);

  // Fallback: extract primary language (2-letter)
  if Length(Norm) > 2 then
    Result := LocaleNameToLangID(UnicodeString(Copy(Norm, 1, 2)))
  else
    Result := 0;
end;

function ScriptName(Script: TScriptType): string;
begin
  case Script of
    scrLatin:        Result := 'Latin';
    scrGerman:       Result := 'German (Latin)';
    scrTurkish:      Result := 'Turkish (Latin)';
    scrGreek:        Result := 'Greek';
    scrCyrillic:     Result := 'Cyrillic';
    scrArmenian:     Result := 'Armenian';
    scrGeorgian:     Result := 'Georgian';
    scrCherokee:     Result := 'Cherokee';
    scrCoptic:       Result := 'Coptic';
    scrGlagolitic:   Result := 'Glagolitic';
    scrDeseret:      Result := 'Deseret';
    scrOsage:        Result := 'Osage';
    scrAdlam:        Result := 'Adlam';
    scrGaray:        Result := 'Garay';
    scrMedefaidrin:  Result := 'Medefaidrin';
    scrOldHungarian: Result := 'Old Hungarian';
    scrVithkuqi:     Result := 'Vithkuqi';
    scrWarangCiti:   Result := 'Warang Citi';
    scrArabic:       Result := 'Arabic';
    scrPersian:      Result := 'Persian';
    scrHebrew:       Result := 'Hebrew';
    scrDevanagari:   Result := 'Devanagari';
    scrBengali:      Result := 'Bengali';
    scrGurmukhi:     Result := 'Gurmukhi';
    scrGujarati:     Result := 'Gujarati';
    scrOriya:        Result := 'Oriya';
    scrTamil:        Result := 'Tamil';
    scrTelugu:       Result := 'Telugu';
    scrKannada:      Result := 'Kannada';
    scrMalayalam:    Result := 'Malayalam';
    scrSinhala:      Result := 'Sinhala';
    scrOlChiki:      Result := 'Ol Chiki';
    scrMeeteiMayek:  Result := 'Meetei Mayek';
    scrThai:         Result := 'Thai';
    scrKhmer:        Result := 'Khmer';
    scrLao:          Result := 'Lao';
    scrBurmese:      Result := 'Burmese';
    scrTibetan:      Result := 'Tibetan';
    scrJavanese:     Result := 'Javanese';
    scrBalinese:     Result := 'Balinese';
    scrSundanese:    Result := 'Sundanese';
    scrCham:         Result := 'Cham';
    scrTaiTham:      Result := 'Tai Tham';
    scrNewTaiLue:    Result := 'New Tai Lue';
    scrKayahLi:      Result := 'Kayah Li';
    scrChakma:       Result := 'Chakma';
    scrSoraSompeng:  Result := 'Sora Sompeng';
    scrLimbu:        Result := 'Limbu';
    scrLepcha:       Result := 'Lepcha';
    scrWancho:       Result := 'Wancho';
    scrMongolian:    Result := 'Mongolian';
    scrEthiopic:     Result := 'Ethiopic';
    scrNKo:          Result := 'NKo';
    scrVai:          Result := 'Vai';
    scrOsmanya:      Result := 'Osmanya';
    scrCjk:          Result := 'CJK';
    scrJapanese:     Result := 'Japanese';
    scrKorean:       Result := 'Korean';
    scrSymbols:      Result := 'Symbols';
    else
      Result := 'Unknown';
  end;
end;


// Decodes a 32-bit codepoint at S[Index], advancing Index across surrogate pairs
function FetchNextCodepoint(const S: UnicodeString; var Index: Integer; Len: Integer): UCS4Char;
var
  W1, W2: Word;
begin
  W1 := Ord(S[Index]);
  if (W1 >= $D800) and (W1 <= $DBFF) and (Index < Len) then
  begin
    W2 := Ord(S[Index + 1]);
    if (W2 >= $DC00) and (W2 <= $DFFF) then
    begin
      Inc(Index);
      Result := ((W1 - $D800) shl 10) + (W2 - $DC00) + $10000;
      Exit;
    end;
  end;
  Result := W1;
end;

// Encodes a 32-bit codepoint back into UTF-16
procedure AppendCodepoint(var Dest: UnicodeString; var DestPos: Integer; C: UCS4Char);
var
  Offset: LongWord;
begin
  if C <= $FFFF then
  begin
    Dest[DestPos] := WideChar(C);
    Inc(DestPos);
  end
  else
  begin
    Offset := C - $10000;
    Dest[DestPos]     := WideChar($D800 + (Offset shr 10));
    Dest[DestPos + 1] := WideChar($DC00 + (Offset and $03FF));
    Inc(DestPos, 2);
  end;
end;

function IsWordBoundary(C: UCS4Char): Boolean;
begin
  Result := (C <= $0020) or (C = Ord('.')) or (C = Ord(',')) or
            (C = Ord(';')) or (C = Ord(':')) or (C = Ord('!')) or
            (C = Ord('?')) or (C = Ord('-')) or (C = Ord('(')) or (C = Ord(')'));
end;

function UnicodeUCase(const S: UnicodeString; ALangID: Integer = 0): UnicodeString;
var
  i, Len, DestPos: Integer;
  C: UCS4Char;
  Script: TScriptType;
begin
  Len := Length(S);
  if Len = 0 then Exit('');
  Script := LangIDToScriptType(ALangID);
  SetLength(Result, Len * 2);
  DestPos := 1;
  i := 1;
  while i <= Len do
  begin
    C := FetchNextCodepoint(S, i, Len);
    // Fast path: ASCII (0..127) bypasses all non-Latin SMP/BMP blocks
    if C < $0080 then
    begin
      if (Script = scrTurkish) and (C = $0069) then // Latin small 'i' -> dotted capital I
        C := $0130
      else if (C >= $0061) and (C <= $007A) then // 'a'..'z'
        Dec(C, $0020);
      AppendCodepoint(Result, DestPos, C);
      Inc(i);
      Continue;
    end;

    // 1. Language-Specific Overrides
    if (Script = scrGerman) and (C = $00DF) then
    begin
      Result[DestPos] := 'S';
      Result[DestPos + 1] := 'S';
      Inc(DestPos, 2);
      Inc(i);
      Continue;
    end;
    if (Script = scrTurkish) and (C = $0131) then
      C := $0049;
    // 2. SMP Plane 1 Blocks
    if (C >= $104D8) and (C <= $104FB) then Dec(C, $0028)        // Osage
    else if (C >= $1E922) and (C <= $1E943) then Dec(C, $0022)   // Adlam
    else if (C >= $10428) and (C <= $1044F) then Dec(C, $0028)   // Deseret
    else if (C >= $10D70) and (C <= $10D95) then Dec(C, $0030)   // Garay
    else if (C >= $10CC0) and (C <= $10CDF) then Dec(C, $0040)   // Old Hungarian
    else if (C >= $10597) and (C <= $105B1) then Dec(C, $0027)   // Vithkuqi
    else if (C >= $16E60) and (C <= $16E7F) then Dec(C, $0020)   // Medefaidrin
    else if (C >= $118C0) and (C <= $118DF) then Dec(C, $0020)   // Warang Citi
    // 3. BMP Plane 0 Blocks
    // Unified Greek Block (Basic + Final Sigma + Accents)
    else if (C >= $03AC) and (C <= $03CE) then
    begin
      if C = $03C2 then C := $03A3 // Check final sigma FIRST!
      else if (C >= $03B1) and (C <= $03C9) then Dec(C, $0020)
      else case C of
        $03AC: C := $0386; // ά -> Ά
        $03AD: C := $0388; // έ -> Έ
        $03AE: C := $0389; // ή -> Ή
        $03AF: C := $038A; // ί -> Ί
        $03CC: C := $038C; // ό -> Ό
        $03CD: C := $038E; // ύ -> Ύ
        $03CE: C := $038F; // ώ -> Ώ
      end;
    end
    else if (C >= $03B1) and (C <= $03C9) then Dec(C, $0020)     // Basic Greek
    else if C = $03C2 then C := $03A3                            // Greek Final Sigma
    else if (C >= $0430) and (C <= $044F) then Dec(C, $0020)     // Basic Cyrillic
    else if (C >= $0450) and (C <= $045F) then Dec(C, $0050)     // Cyrillic Supplement (Ukrainian, Serbian)
    else if ((C >= $0460) and (C <= $047F)) or ((C >= $048A) and (C <= $052F)) then // Cyrillic Extended (Kazakh, Tatar)
    begin
      if (C and 1) = 1 then Dec(C);
    end
    else if (C >= $0561) and (C <= $0586) then Dec(C, $0030)     // Armenian
    else if (C >= $10D0) and (C <= $10FA) then Inc(C, $0BC0)     // Georgian Mkhedruli -> Mtavruli
    else if (C >= $AB70) and (C <= $ABBF) then Dec(C, $97D0)     // Cherokee
    else if (C >= $2C30) and (C <= $2C5E) then Dec(C, $0030)     // Glagolitic
    else if (C >= $2C80) and (C <= $2CE3) and ((C and 1) = 1) then Dec(C) // Coptic
    else if (C >= $0061) and (C <= $007A) then Dec(C, $0020)     // Basic Latin
    else if (C >= $00E0) and (C <= $00FE) and (C <> $00F7) then Dec(C, $0020) // Latin-1 Supplement
    // Latin Extended-A, Extended-B, and Extended Additional (Vietnamese)
    else if ((C >= $0100) and (C <= $0177)) or
            ((C >= $01CD) and (C <= $01DC)) or
            ((C >= $1E00) and (C <= $1EFF)) then
    begin
      if (C and 1) = 1 then Dec(C);
    end;
    AppendCodepoint(Result, DestPos, C);
    Inc(i);
  end;
  SetLength(Result, DestPos - 1);
end;

function UnicodeLCase(const S: UnicodeString; ALangID: Integer = 0): UnicodeString;
var
  i, Len, DestPos, NextIdx: Integer;
  C, NextC: UCS4Char;
  Script: TScriptType;
  IsFinal: Boolean;
begin
  Len := Length(S);
  if Len = 0 then Exit('');
  Script := LangIDToScriptType(ALangID);
  SetLength(Result, Len * 2);
  DestPos := 1;
  i := 1;
  while i <= Len do
  begin
    C := FetchNextCodepoint(S, i, Len);
    // Fast path: ASCII (0..127) bypasses all non-Latin SMP/BMP blocks
    if C < $0080 then
    begin
      if (Script = scrTurkish) and (C = $0049) then // Latin capital 'I' -> dotless small i
        C := $0131
      else if (C >= $0041) and (C <= $005A) then // 'A'..'Z'
        Inc(C, $0020);
      AppendCodepoint(Result, DestPos, C);
      Inc(i);
      Continue;
    end;

    // 1. Language-Specific Overrides
    if (Script = scrTurkish) and (C = $0130) then
      C := $0069; // Turkish capital dotted I -> small i
    // 2. SMP Plane 1 Blocks
    if (C >= $104B0) and (C <= $104D3) then Inc(C, $0028)
    else if (C >= $1E900) and (C <= $1E921) then Inc(C, $0022)
    else if (C >= $10400) and (C <= $10427) then Inc(C, $0028)
    else if (C >= $10D40) and (C <= $10D65) then Inc(C, $0030)
    else if (C >= $10C80) and (C <= $10C9F) then Inc(C, $0040)
    else if (C >= $10570) and (C <= $1058A) then Inc(C, $0027)
    else if (C >= $16E40) and (C <= $16E5F) then Inc(C, $0020)
    else if (C >= $118A0) and (C <= $118BF) then Inc(C, $0020)
    // 3. BMP Plane 0 Blocks
    // Greek Accented (Tonos)
    else if (C >= $0386) and (C <= $038F) then
    begin
      case C of
        $0386: C := $03AC; // Ά -> ά
        $0388: C := $03AD; // Έ -> έ
        $0389: C := $03AE; // Ή -> ή
        $038A: C := $03AF; // Ί -> ί
        $038C: C := $03CC; // Ό -> ό
        $038E: C := $03CD; // Ύ -> ύ
        $038F: C := $03CE; // Ώ -> ώ
      end;
    end
    else if C = $03A3 then // Greek Contextual Sigma
    begin
      NextIdx := i + 1;
      if NextIdx > Len then
        IsFinal := True
      else
      begin
        NextC := FetchNextCodepoint(S, NextIdx, Len);
        IsFinal := IsWordBoundary(NextC);
      end;
      if IsFinal then C := $03C2 else C := $03C3;
    end
    else if (C >= $0391) and (C <= $03A9) then Inc(C, $0020)     // Basic Greek
    else if (C >= $0410) and (C <= $042F) then Inc(C, $0020)     // Basic Cyrillic
    else if (C >= $0400) and (C <= $040F) then Inc(C, $0050)     // Cyrillic Supplement (Ukrainian, Serbian)
    else if ((C >= $0460) and (C <= $047F)) or ((C >= $048A) and (C <= $052F)) then // Cyrillic Extended (Kazakh, Tatar)
    begin
      if (C and 1) = 0 then Inc(C);
    end
    else if (C >= $0531) and (C <= $0556) then Inc(C, $0030)     // Armenian
    else if (C >= $1C90) and (C <= $1CBA) then Dec(C, $0BC0)     // Georgian Mtavruli -> Mkhedruli
    else if (C >= $13A0) and (C <= $13EF) then Inc(C, $97D0)     // Cherokee
    else if (C >= $2C00) and (C <= $2C2E) then Inc(C, $0030)     // Glagolitic
    else if (C >= $2C80) and (C <= $2CE3) and ((C and 1) = 0) then Inc(C) // Coptic
    else if (C >= $0041) and (C <= $005A) then Inc(C, $0020)     // Basic Latin
    else if (C >= $00C0) and (C <= $00DE) and (C <> $00D7) then Inc(C, $0020) // Latin-1 Supplement
    // Latin Extended-A, Extended-B, and Extended Additional (Vietnamese)
    else if ((C >= $0100) and (C <= $0177)) or
            ((C >= $01CD) and (C <= $01DC)) or
            ((C >= $1E00) and (C <= $1EFF)) then
    begin
      if (C and 1) = 0 then Inc(C);
    end;
    AppendCodepoint(Result, DestPos, C);
    Inc(i);
  end;
  SetLength(Result, DestPos - 1);
end;

end.
