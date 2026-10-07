{******************************************************************************}
{                                                                              }
{       Icon Fonts ImageList: An extended ImageList for Delphi/VCL             }
{       to simplify use of Icons (resize, colors and more...)                  }
{                                                                              }
{       Copyright (c) 2019-2025 (Ethea S.r.l.)                                 }
{       Author: Carlo Barazzetta                                               }
{       Contributors:                                                          }
{         Nicola Tambascia                                                     }
{         Luca Minuti                                                          }
{                                                                              }
{       https://github.com/EtheaDev/IconFontsImageList                         }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit IconFontsItems;

interface

{$INCLUDE IconFontsImageList.inc}

uses
  Classes
  , ImgList
  , Windows
  , Graphics
{$IFDEF D10_4+}
  , System.UITypes
{$ENDIF}
{$IFDEF HiDPISupport}
  , Messaging
{$ENDIF}
{$IFDEF GDI+}
  , Winapi.GDIPOBJ
  , Winapi.GDIPAPI
{$ENDIF}
  , Controls
  , Forms;

resourcestring
  ERR_ICONFONTS_VALUE_NOT_ACCEPTED = 'Value %s not accepted!';

const
  DEFAULT_OPACITY = 255;
  DEFAULT_DISABLE_FACTOR = 100;
  ZOOM_DEFAULT = 100;

type
  TIconFontItem = class;
  TIconFontItems = class;

  TIconFont = class(TObject)
  private
    FFontName: TFontName;
    FFontIconDec: Integer;
    FFontColor: TColor;
    FMaskColor: TColor;
    FOpacity: Byte;
    FIconName: string;
    FDisabledFactor: Byte;
  public
    function GetBitmap(const AWidth, AHeight: Integer;
      const AFontName: TFontName; AFontIconDec: Integer;
      const AFontColor, AMaskColor: TColor;
      const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AOpacity: Byte = DEFAULT_OPACITY;
      const AZoom: Integer = ZOOM_DEFAULT;
      const ASecondaryFontIconDec: Integer = 0;
      const ASecondaryFontColor: TColor = clNone;
      const ASecondaryOpacity: Byte = DEFAULT_OPACITY): TBitmap;
    procedure Assign(Source: TIconFont);
    {$IFDEF GDI+}
    procedure PaintToGDI(const AGraphics: TGPGraphics;
      const X, Y, AWidth, AHeight: Single;
      const AFontName: TFontName; AFontIconDec: Integer;
      const AFontColor: TColor; const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AOpacity: Byte = DEFAULT_OPACITY;
      const AZoom: Integer = ZOOM_DEFAULT);
    {$ENDIF}
    procedure PaintTo(const ACanvas: TCanvas;
      const X, Y, AWidth, AHeight: Integer;
      const AFontName: TFontName; AFontIconDec: Integer;
      const AFontColor, AMaskColor: TColor;
      const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AZoom: Integer = ZOOM_DEFAULT);
  end;

  TIconFontItem = class(TCollectionItem)
  private
    FIconFont: TIconFont;
    FFontName: TFontName;
    FFontIconDec: Integer;
    FFontColor: TColor;
    FMaskColor: TColor;
    FIconName: string;
    FFontIcon2Dec: Integer;
    FFontColor2: TColor;
    procedure SetFontColor(const AValue: TColor);
    procedure SetFontName(const AValue: TFontName);
    procedure SetMaskColor(const AValue: TColor);
    procedure SetIconName(const AValue: string);
    procedure SetFontIconHex(const AValue: string);
    procedure SetFontIconDec(const AValue: Integer);
    function GetFontIconDec: Integer;
    function GetFontIconHex: string;
    procedure SetFontColor2(const AValue: TColor);
    procedure SetFontIcon2Hex(const AValue: string);
    procedure SetFontIcon2Dec(const AValue: Integer);
    function GetFontIcon2Dec: Integer;
    function GetFontIcon2Hex: string;
    function StoreFontColor2: Boolean;
    procedure ResolveSecondaryIcon(const ALFontColor: TColor; const AOpacity: Byte;
      const ADuotone: Boolean; const ADuotoneOffset: Integer; const ADuotoneOpacity: Byte;
      out ASecondaryFontIconDec: Integer; out ASecondaryFontColor: TColor;
      out ASecondaryOpacity: Byte);
    procedure Changed;
    function GetCharacter: WideString;
    function GetCategory: string;
    function GetName: string;
    procedure SetCategory(const Value: string);
    procedure SetName(const Value: string);
    function ExtractCategory(const S: String): String;
    function ExtractName(const S: String): String;
    procedure BuildIconName(const ACategory, AName: String);
    function StoreFontColor: Boolean;
    function StoreMaskColor: Boolean;
    function StoreFontName: Boolean;
    function GetIconFont: TIconFont;
    function GetIconFontItems: TIconFontItems;
  protected
    procedure SetIndex(Value: Integer); override;
  public
    function GetBitmap(const AWidth, AHeight: Integer;
      const AEnabled: Boolean; AOpacity: Byte = DEFAULT_OPACITY;
      const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AZoom: Integer = ZOOM_DEFAULT;
      const ADuotone: Boolean = False;
      const ADuotoneOffset: Integer = $100000;
      const ADuotoneOpacity: Byte = 102): TBitmap;
    {$IFDEF GDI+}
    procedure PaintTo(const ACanvas: TCanvas;
      const X, Y, AWidth, AHeight: Integer;
      const AEnabled: Boolean = True; const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AOpacity: Byte = DEFAULT_OPACITY;
      const AZoom: Integer = ZOOM_DEFAULT;
      const ADuotone: Boolean = False;
      const ADuotoneOffset: Integer = $100000;
      const ADuotoneOpacity: Byte = 102);
    {$ELSE}
    procedure PaintTo(const ACanvas: TCanvas;
      const X, Y, AWidth, AHeight: Integer;
      out AMaskColor: TColor;
      const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
      const AZoom: Integer = ZOOM_DEFAULT);
    {$ENDIF}
    function GetDisplayName: string; override;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function FontNameOfIcon: TFontName;
    property Character: WideString read GetCharacter;
    property IconFontItems: TIconFontItems read GetIconFontItems;
    property IconFont: TIconFont read GetIconFont;
    property Name: string read GetName write SetName;
    property Category: string read GetCategory write SetCategory;
  published
    property FontIconDec: Integer read GetFontIconDec write SetFontIconDec stored true default 0;
    property FontIconHex: string read GetFontIconHex write SetFontIconHex stored false;
    property FontName: TFontName read FFontName write SetFontName stored StoreFontName;
    property FontColor: TColor read FFontColor write SetFontColor stored StoreFontColor;
    property MaskColor: TColor read FMaskColor write SetMaskColor stored StoreMaskColor;
    property IconName: string read FIconName write SetIconName;
    //Duotone secondary layer: FontIcon2Dec defaults to FontIconDec+DuotoneOffset
    //(owner's Duotone/DuotoneOffset) when left at 0; FontColor2 defaults to the
    //resolved primary FontColor (drawn at DuotoneOpacity) when left at clDefault.
    property FontIcon2Dec: Integer read GetFontIcon2Dec write SetFontIcon2Dec stored true default 0;
    property FontIcon2Hex: string read GetFontIcon2Hex write SetFontIcon2Hex stored false;
    property FontColor2: TColor read FFontColor2 write SetFontColor2 stored StoreFontColor2 default clDefault;
  end;

  TIconFontItemChangedProc = procedure (Sender: TIconFontItem) of object;
  TCheckFontNameProc = procedure (const AFontName: TFontName) of object;
  TGetOwnerAttributesProc = procedure (out AFontName: TFontName;
  out AFontColor, AMaskColor: TColor) of object;

  {TIconFontItems}
  TIconFontItems = class(TOwnedCollection)
  private
    FOnItemChanged: TIconFontItemChangedProc;
    FOnCheckFont: TCheckFontNameProc;
    FGetOwnerAttributes: TGetOwnerAttributesProc;
    FOwnerFontName: TFontName;
    FOwnerFontColor: TColor;
    FOwnerMaskColor: TColor;
    procedure UpdateOwnerAttributes;
    function GetItem(AIndex: Integer): TIconFontItem;
    procedure SetItem(AIndex: Integer; const Value: TIconFontItem);
    procedure ItemChanged(const AItem: TIconFontItem);
    function IsCharAvailable(const ABitmap: TBitmap;
      const AFontIconDec: Integer): Boolean;
  protected
  public
    constructor Create(const AOwner: TPersistent;
      const ItemClass: TCollectionItemClass;
      const AOnItemChanged: TIconFontItemChangedProc;
      const AOnCheckFont: TCheckFontNameProc;
      const AGetOwnerAttributes: TGetOwnerAttributesProc);
    procedure UpdateIconsAttributes(const AFontColor, AMaskColor: TColor;
      const AFontName: TFontName = '');
    //Single Icon Method
    function AddIcon(const AChar: Integer; const AIconName: string;
      const AFontName: TFontName = ''; const AFontColor: TColor = clDefault;
      const AMaskColor: TColor = clNone): TIconFontItem; overload;
    function AddIcon(const AChar: WideChar; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; const AMaskColor: TColor = clNone): TIconFontItem; overload;
    function AddIcon(const AChar: Integer; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; const AMaskColor: TColor = clNone): TIconFontItem; overload;
    //Multiple icons methods
    function AddIcons(const AFrom, ATo: WideChar; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
      const ACheckValid: Boolean = False): Integer;  overload;
    function AddIcons(const AFrom, ATo: Integer; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
      const ACheckValid: Boolean = False): Integer;  overload;
    function AddIcons(const ASourceString: WideString;
      const AFontName: TFontName = ''): Integer; overload;

    function Add: TIconFontItem;
    procedure Assign(Source: TPersistent); override;
    function Insert(AIndex: Integer): TIconFontItem;
    procedure Delete(AIndex: Integer);
    function GetIconByName(const AIconName: string): TIconFontItem;
    function IndexOf(const S: string): Integer; virtual;
    property Items[Index: Integer]: TIconFontItem read GetItem write SetItem; default;
  end;

function IsFontIconValidValue(const AFontIconDec: Integer): Boolean;

//GDI+, which draws the icons, does not see fonts an application loads from memory with
//AddFontMemResourceEx. Register those fonts here as well; AData must stay valid while the
//application runs (resource data does).
procedure IconFontsAddMemoryFont(const AData: Pointer; const ASize: Integer);

//True if AFontName is installed or was registered with IconFontsAddMemoryFont
function IconFontsFontAvailable(const AFontName: TFontName): Boolean;

{$IFDEF GDI+}
type
  TIconFontsPaintProc = reference to procedure(const AGraphics: TGPGraphics);

//Paints through an off-screen 32-bit bitmap, then copies it to ADC at (X, Y). GDI+ drops text
//anti-aliasing when it draws straight to a window DC in some sessions (Remote Desktop), but always
//anti-aliases into a bitmap. APaint draws in bitmap coordinates: (0, 0) is the top left.
procedure IconFontsPaintBuffered(const ADC: HDC; const X, Y, AWidth, AHeight: Integer;
  const APaint: TIconFontsPaintProc);
{$ENDIF}

implementation

uses
  SysUtils
  , IconFontsUtils
  , Math
  , ComCtrls
  {$IFDEF DXE3+}
  , System.Character
  , Themes
  {$ENDIF}
  {$IFDEF GDI+}
  , Winapi.CommCtrl
  {$ENDIF}
  , StrUtils
  ;

const
  CATEGORY_SEP = '\';

{$IFDEF GDI+}
var
  _PrivateFonts: TGPPrivateFontCollection;
{$ENDIF}

function IsFontIconValidValue(const AFontIconDec: Integer): Boolean;
begin
  Result := ((AFontIconDec >= $0000) and (AFontIconDec <= $D7FF)) or
    ((AFontIconDec >= $E000) and (AFontIconDec < $FFFF)) or  //D800 to DFFF are reserved for code point values for Surrogate Pairs
    ((AFontIconDec >= $010000) and (AFontIconDec <= $10FFFF)); //Surrogate Pairs
end;

procedure IconFontsAddMemoryFont(const AData: Pointer; const ASize: Integer);
begin
  {$IFDEF GDI+}
  if not Assigned(_PrivateFonts) then
    _PrivateFonts := TGPPrivateFontCollection.Create;
  _PrivateFonts.AddMemoryFont(AData, ASize);
  {$ENDIF}
end;

{$IFDEF GDI+}
//Returns the registered family named AFontName, or nil
function PrivateFontFamily(const AFontName: TFontName): TGPFontFamily;
begin
  Result := nil;
  if Assigned(_PrivateFonts) then
  begin
    Result := TGPFontFamily.Create(AFontName, _PrivateFonts);
    if Result.GetLastStatus <> Ok then
      FreeAndNil(Result);
  end;
end;
{$ENDIF}

{$IFDEF GDI+}
procedure IconFontsPaintBuffered(const ADC: HDC; const X, Y, AWidth, AHeight: Integer;
  const APaint: TIconFontsPaintProc);
var
  LBitmap: TGPBitmap;
  LGraphics: TGPGraphics;
begin
  if (AWidth <= 0) or (AHeight <= 0) then
    Exit;
  LBitmap := TGPBitmap.Create(AWidth, AHeight, PixelFormat32bppPARGB);
  try
    LGraphics := TGPGraphics.Create(LBitmap);
    try
      LGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
      APaint(LGraphics);
    finally
      LGraphics.Free;
    end;
    LGraphics := TGPGraphics.Create(ADC);
    try
      LGraphics.DrawImage(LBitmap, X, Y, AWidth, AHeight);
    finally
      LGraphics.Free;
    end;
  finally
    LBitmap.Free;
  end;
end;
{$ENDIF}

function IconFontsFontAvailable(const AFontName: TFontName): Boolean;
{$IFDEF GDI+}
var
  LFamily: TGPFontFamily;
{$ENDIF}
begin
  Result := Screen.Fonts.IndexOf(AFontName) <> -1;
  {$IFDEF GDI+}
  if not Result then
  begin
    LFamily := PrivateFontFamily(AFontName);
    Result := Assigned(LFamily);
    LFamily.Free;
  end;
  {$ENDIF}
end;

{$IFDEF GDI+}
function GPColor(Col: TColor; Alpha: Byte): TGPColor;

type
  TInvRGBQUAD = packed record
  rgbRed: Byte;
  rgbGreen: Byte;
  rgbBlue: Byte;
  rgbReserved: Byte;
end;

var
  rec: TInvRGBQuad;
  rec2: TRGBQuad;
  ciCol: Cardinal;
begin
  { This will get the RGB color from a system colour, then we can
  convert this value to a GDI+ colour }
  rec := TInvRGBQuad(Col);
  if rec.rgbReserved = 128 then // $80 then {or =128}
  begin
  ciCol := $80000000 XOR DWORD(Col);
  ciCol := GetSysColor(ciCol);
  rec2 := TRGBQuad(ciCol);
  { Could also just use REC here, and pass Blue where red is
  requested, and Red where blue is requested, should probably
  still result in the same effect }
  Result := MakeColor(Alpha, rec2.rgbRed, rec2.rgbGreen, rec2.rgbBlue);
  end else
  Result := MakeColor(Alpha, rec.rgbRed, rec.rgbGreen, rec.rgbBlue);
end;
{$ENDIF}

{ TIconFontItem }

procedure TIconFontItem.Assign(Source: TPersistent);
begin
  if Source is TIconFontItem then
  begin
    FFontName := TIconFontItem(Source).FFontName;
    FFontIconDec := TIconFontItem(Source).FFontIconDec;
    FFontColor := TIconFontItem(Source).FFontColor;
    FMaskColor := TIconFontItem(Source).FMaskColor;
    FIconName := TIconFontItem(Source).FIconName;
    FFontIcon2Dec := TIconFontItem(Source).FFontIcon2Dec;
    FFontColor2 := TIconFontItem(Source).FFontColor2;
  end
  else
    inherited Assign(Source);
end;

constructor TIconFontItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FIconFont := TIconFont.Create;
  FFontIconDec := 0;
  FFontColor := clDefault;
  FMaskColor := clNone;
  FFontIcon2Dec := 0;
  FFontColor2 := clDefault;
end;

destructor TIconFontItem.Destroy;
begin
  FIconFont.Free;
  inherited Destroy;
end;

function TIconFontItem.StoreFontColor: Boolean;
begin
  IconFontItems.UpdateOwnerAttributes;
  Result := (FFontColor <> IconFontItems.FOwnerFontColor) and
    (FFontColor <> clDefault);
end;

function TIconFontItem.StoreFontName: Boolean;
begin
  IconFontItems.UpdateOwnerAttributes;
  Result := (FFontName <> IconFontItems.FOwnerFontName) and
    (FFontName <> '');
end;

function TIconFontItem.StoreMaskColor: Boolean;
begin
  IconFontItems.UpdateOwnerAttributes;
  Result := (FMaskColor <> IconFontItems.FOwnerMaskColor) and
    (FMaskColor <> clNone);
end;

function TIconFontItem.StoreFontColor2: Boolean;
begin
  Result := FFontColor2 <> clDefault;
end;

procedure TIconFontItem.ResolveSecondaryIcon(const ALFontColor: TColor; const AOpacity: Byte;
  const ADuotone: Boolean; const ADuotoneOffset: Integer; const ADuotoneOpacity: Byte;
  out ASecondaryFontIconDec: Integer; out ASecondaryFontColor: TColor;
  out ASecondaryOpacity: Byte);
begin
  if FFontIcon2Dec <> 0 then
    ASecondaryFontIconDec := FFontIcon2Dec
  else if ADuotone and (FFontIconDec <> 0) then
    ASecondaryFontIconDec := FFontIconDec + ADuotoneOffset
  else
    ASecondaryFontIconDec := 0;

  if ASecondaryFontIconDec = 0 then
  begin
    ASecondaryFontColor := clNone;
    ASecondaryOpacity := AOpacity;
    Exit;
  end;

  if FFontColor2 <> clDefault then
  begin
    //Explicit override: a genuinely distinct color, drawn at normal opacity
    ASecondaryFontColor := FFontColor2;
    ASecondaryOpacity := AOpacity;
  end
  else
  begin
    //Default duotone look: same color as the primary layer, dimmed
    ASecondaryFontColor := ALFontColor;
    ASecondaryOpacity := ADuotoneOpacity;
  end;
end;

function TIconFontItem.GetBitmap(const AWidth, AHeight: Integer;
  const AEnabled: Boolean; AOpacity: Byte = DEFAULT_OPACITY;
  const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
  const AZoom: Integer = ZOOM_DEFAULT;
  const ADuotone: Boolean = False;
  const ADuotoneOffset: Integer = $100000;
  const ADuotoneOpacity: Byte = 102): TBitmap;
var
  LFontColor, LMaskColor: TColor;
  LFontName: TFontName;
  LSecondaryFontIconDec: Integer;
  LSecondaryFontColor: TColor;
  LSecondaryOpacity: Byte;
begin
  //Default values from ImageList if not supplied from Item
  IconFontItems.UpdateOwnerAttributes;
  if FMaskColor <> clNone then
    LMaskColor := FMaskColor
  else
    LMaskColor := IconFontItems.FOwnerMaskColor;
  if FFontColor <> clDefault then
    LFontColor := FFontColor
  else
    LFontColor := IconFontItems.FOwnerFontColor;

  if not AEnabled then
    LFontColor := GrayscaleColor(LFontColor);

  LFontName := FontNameOfIcon;

  if Assigned(IconFontItems.FOnCheckFont) then
    IconFontItems.FOnCheckFont(LFontName);

  {$IFDEF GDI+}
  ResolveSecondaryIcon(LFontColor, AOpacity, ADuotone, ADuotoneOffset, ADuotoneOpacity,
    LSecondaryFontIconDec, LSecondaryFontColor, LSecondaryOpacity);
  {$ELSE}
  LSecondaryFontIconDec := 0;
  LSecondaryFontColor := clNone;
  LSecondaryOpacity := AOpacity;
  {$ENDIF}

  Result := FIconFont.GetBitmap(AWidth, AHeight, LFontName,
    FFontIconDec, LFontColor, LMaskColor, AEnabled, ADisabledFactor,
    AOpacity, AZoom, LSecondaryFontIconDec, LSecondaryFontColor, LSecondaryOpacity);
end;

function TIconFontItem.GetName: string;
begin
  Result := ExtractName(FIconName);
end;

function TIconFontItem.GetCategory: string;
begin
  Result := ExtractCategory(FIconName);
end;

procedure TIconFontItem.SetCategory(const Value: string);
begin
  BuildIconName(Value, Name);
end;

function TIconFontItem.GetCharacter: WideString;
begin
{$IFDEF DXE3+}
  {$WARN SYMBOL_DEPRECATED OFF}
  Result := ConvertFromUtf32(FFontIconDec);
  {$WARN SYMBOL_DEPRECATED ON}
{$ELSE}
  Result := WideChar(FFontIconDec);
{$ENDIF}
end;

function TIconFontItem.GetDisplayName: string;
begin
  Result := Format('%s - Hex: %s%s',
    [FFontName, FontIconHex, ifthen(FIconName<>'', ' - ('+FIconName+')', '')]);
end;

function TIconFontItem.GetFontIconDec: Integer;
begin
  Result := FFontIconDec;
end;

function TIconFontItem.GetFontIconHex: string;
begin
  if FFontIconDec <> 0 then
    Result := RightStr('0000'+IntToHex(FFontIconDec, 1),5)
  else
    Result := '';
end;

function TIconFontItem.GetFontIcon2Dec: Integer;
begin
  Result := FFontIcon2Dec;
end;

function TIconFontItem.GetFontIcon2Hex: string;
begin
  //Secondary (duotone) codepoints commonly land beyond $FFFF (e.g. primary+$100000),
  //so this needs up to 6 hex digits, unlike the primary FontIconHex (4-5 digits).
  if FFontIcon2Dec <> 0 then
    Result := RightStr('000000'+IntToHex(FFontIcon2Dec, 1),6)
  else
    Result := '';
end;

function TIconFontItem.GetIconFont: TIconFont;
begin
  Result := FIconFont;
end;

function TIconFontItem.GetIconFontItems: TIconFontItems;
begin
  Result := TIconFontItems(Collection);
end;

{$IFDEF GDI+}
procedure TIconFontItem.PaintTo(const ACanvas: TCanvas;
  const X, Y, AWidth, AHeight: Integer;
  const AEnabled: Boolean = True; const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
  const AOpacity: Byte = DEFAULT_OPACITY;
  const AZoom: Integer = ZOOM_DEFAULT;
  const ADuotone: Boolean = False;
  const ADuotoneOffset: Integer = $100000;
  const ADuotoneOpacity: Byte = 102);
{$ELSE}
procedure TIconFontItem.PaintTo(const ACanvas: TCanvas;
  const X, Y, AWidth, AHeight: Integer;
  out AMaskColor: TColor;
  const AEnabled: Boolean = True; const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
  const AZoom: Integer = ZOOM_DEFAULT);
{$ENDIF}
var
  LFontColor: TColor;
  LFontName: TFontName;
{$IFDEF GDI+}
  LSecondaryFontIconDec: Integer;
  LSecondaryFontColor: TColor;
  LSecondaryOpacity: Byte;
{$ENDIF}
begin
  //Default values from ImageList if not supplied from Item
  IconFontItems.UpdateOwnerAttributes;
  {$IFNDEF GDI+}
  if FMaskColor <> clNone then
    AMaskColor := FMaskColor
  else
    AMaskColor := IconFontItems.FOwnerMaskColor;
  {$ENDIF}
  if FFontColor <> clDefault then
    LFontColor := FFontColor
  else
    LFontColor := IconFontItems.FOwnerFontColor;

  if not AEnabled then
    LFontColor := GrayscaleColor(LFontColor);

  LFontName := FontNameOfIcon;

  {$IFDEF GDI+}
  ResolveSecondaryIcon(LFontColor, AOpacity, ADuotone, ADuotoneOffset, ADuotoneOpacity,
    LSecondaryFontIconDec, LSecondaryFontColor, LSecondaryOpacity);
  IconFontsPaintBuffered(ACanvas.Handle, X, Y, AWidth, AHeight,
    procedure(const AGraphics: TGPGraphics)
    begin
      FIconFont.PaintToGDI(AGraphics, 0, 0, AWidth, AHeight,
        LFontName, FFontIconDec, LFontColor,
        AEnabled, ADisabledFactor, AOpacity, AZoom);
      if LSecondaryFontIconDec <> 0 then
        FIconFont.PaintToGDI(AGraphics, 0, 0, AWidth, AHeight,
          LFontName, LSecondaryFontIconDec, LSecondaryFontColor,
          AEnabled, ADisabledFactor, LSecondaryOpacity, AZoom);
    end);
  {$ELSE}
  FIconFont.PaintTo(ACanvas, X, Y, AWidth, AHeight, LFontName,
    FFontIconDec, LFontColor, AMaskColor, AEnabled, ADisabledFactor, AZoom);
  {$ENDIF}
end;

procedure TIconFontItem.SetFontColor(const AValue: TColor);
begin
  if AValue <> FFontColor then
  begin
    FFontColor := AValue;
    Changed;
  end;
end;

procedure TIconFontItem.SetFontColor2(const AValue: TColor);
begin
  if AValue <> FFontColor2 then
  begin
    FFontColor2 := AValue;
    Changed;
  end;
end;

function TIconFontItem.ExtractName(const S: String): String;
var
  LPos: Integer;
begin
  LPos := Pos(CATEGORY_SEP, S);
  if LPos > 0 then
    Result := Copy(S, LPos+1, MaxInt)
  else
    Result := S;
end;

function TIconFontItem.FontNameOfIcon: TFontName;
begin
  if FFontName <> '' then
    Result := FFontName
  else
    Result := IconFontItems.FOwnerFontName;
end;

function TIconFontItem.ExtractCategory(const S: String): String;
var
  LPos: Integer;
begin
  LPos := Pos(CATEGORY_SEP, S);
  if LPos > 0 then
    Result := Copy(S, 1, LPos-1)
  else
    Result := '';
end;

procedure TIconFontItem.BuildIconName(const ACategory, AName: String);
begin
  if ACategory <> '' then
    IconName := ACategory + CATEGORY_SEP + AName
  else
    IconName := AName;
end;

procedure TIconFontItem.SetName(const Value: string);
begin
  BuildIconName(Category, Value);
end;

procedure TIconFontItem.SetFontIconDec(const AValue: Integer);
begin
  if AValue <> FFontIconDec then
  begin
    if not IsFontIconValidValue(AValue) then
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[IntToHex(AValue, 1)]);
    FFontIconDec := AValue;
    Changed;
  end;
end;

procedure TIconFontItem.SetFontIconHex(const AValue: string);
begin
  try
    if (Length(AValue) = 4) or (Length(AValue) = 5) then
      FontIconDec := StrToInt('$' + AValue)
    else if (Length(AValue) = 0) then
      FontIconDec := 0
    else
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[AValue]);
  except
    On E: EConvertError do
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[AValue])
    else
      raise;
  end;
end;

procedure TIconFontItem.SetFontIcon2Dec(const AValue: Integer);
begin
  if AValue <> FFontIcon2Dec then
  begin
    if (AValue <> 0) and not IsFontIconValidValue(AValue) then
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[IntToHex(AValue, 1)]);
    FFontIcon2Dec := AValue;
    Changed;
  end;
end;

procedure TIconFontItem.SetFontIcon2Hex(const AValue: string);
begin
  try
    if (Length(AValue) = 4) or (Length(AValue) = 5) or (Length(AValue) = 6) then
      FontIcon2Dec := StrToInt('$' + AValue)
    else if (Length(AValue) = 0) then
      FontIcon2Dec := 0
    else
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[AValue]);
  except
    On E: EConvertError do
      raise Exception.CreateFmt(ERR_ICONFONTS_VALUE_NOT_ACCEPTED,[AValue])
    else
      raise;
  end;
end;

procedure TIconFontItem.SetFontName(const AValue: TFontName);
begin
  if AValue <> FFontName then
  begin
    FFontName := AValue;
    Changed;
  end;
end;

procedure TIconFontItem.SetIconName(const AValue: string);
begin
  FIconName := AValue;
end;

procedure TIconFontItem.SetIndex(Value: Integer);
begin
  if Value <> Index then
  begin
    inherited;
    Changed;
  end;
end;

procedure TIconFontItem.SetMaskColor(const AValue: TColor);
begin
  if AValue <> FMaskColor then
  begin
    FMaskColor := AValue;
    Changed;
  end;
end;

procedure TIconFontItem.Changed;
begin
  if Assigned(Collection) then
    IconFontItems.ItemChanged(Self);
end;

{ TIconFontItems }

function TIconFontItems.Add: TIconFontItem;
begin
  Result := TIconFontItem(inherited Add);
end;

function TIconFontItems.AddIcons(const AFrom, ATo: Integer;
  const AFontName: TFontName; const AFontColor: TColor; AMaskColor: TColor;
  const ACheckValid: Boolean): Integer;
var
  LChar: Integer;
  LIsValid: Boolean;
  LBitmap: TBitmap;
begin
  LBitmap := nil;
  try
    if ACheckValid then
    begin
      LBitmap := TBitmap.Create;
      LBitmap.Width := 10;
      LBitmap.Height := 10;
      with LBitmap.Canvas do
      begin
        Font.Name := AFontName;
        Font.Height := 10;
        Font.Color := clBlack;
        Brush.Color := clWhite;
      end;
    end;
    Result := 0;
    for LChar := AFrom to ATo do
    begin
      if ACheckValid then
        LIsValid := IsFontIconValidValue(LChar) and IsCharAvailable(LBitmap, LChar)
      else
        LIsValid := IsFontIconValidValue(LChar);
      if LIsValid then
      begin
        AddIcon(LChar, AFontName, AFontColor, AMaskColor);
        Inc(Result);
      end;
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure TIconFontItems.Assign(Source: TPersistent);
begin
(*
  if (Source is TIconFontItems) then
  begin
    TControl(Owner).StopDrawing(True);
    try
      inherited;
    finally
      IconFontsImageList.StopDrawing(False);
    end;
    IconFontsImageList.RecreateBitmaps;
  end
  else
*)
    inherited;
end;


constructor TIconFontItems.Create(const AOwner: TPersistent;
  const ItemClass: TCollectionItemClass;
  const AOnItemChanged: TIconFontItemChangedProc;
  const AOnCheckFont: TCheckFontNameProc;
  const AGetOwnerAttributes: TGetOwnerAttributesProc);
begin
  FOnItemChanged := AOnItemChanged;
  FOnCheckFont := AOnCheckFont;
  FGetOwnerAttributes := AGetOwnerAttributes;
  inherited Create(AOwner, ItemClass);
end;

procedure TIconFontItems.Delete(AIndex: Integer);
begin
  inherited Delete(AIndex);
  ItemChanged(nil);
end;

function TIconFontItems.GetIconByName(const AIconName: string): TIconFontItem;
var
  I: Integer;
  LIconFontItem: TIconFontItem;
begin
  Result := nil;
  for I := 0 to Count -1 do
  begin
    LIconFontItem := Items[I];
    if SameText(LIconFontItem.IconName, AIconName) then
    begin
      Result := LIconFontItem;
      Break;
    end;
  end;
end;

function TIconFontItems.GetItem(AIndex: Integer): TIconFontItem;
begin
  Result := TIconFontItem(inherited GetItem(AIndex));
end;

function TIconFontItems.IndexOf(const S: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if SameText(Items[Result].IconName, S) then
      Exit;
  Result := -1;
end;

function TIconFontItems.Insert(AIndex: Integer): TIconFontItem;
begin
  Result := TIconFontItem(inherited Insert(AIndex));
  ItemChanged(Result);
end;

procedure TIconFontItems.SetItem(AIndex: Integer;
  const Value: TIconFontItem);
begin
  inherited SetItem(AIndex, Value);
end;

procedure TIconFontItems.UpdateIconsAttributes(const AFontColor, AMaskColor: TColor;
  const AFontName: TFontName = '');
var
  I: Integer;
  LIconFontItem: TIconFontItem;
begin
  if (AFontColor <> clNone) and (AMaskColor <> clNone) then
  begin
    for I := 0 to Count -1 do
    begin
      LIconFontItem := Items[I];
      if AFontName <> '' then
        LIconFontItem.FontName := AFontName;
      LIconFontItem.FontColor := AFontColor;
      LIconFontItem.MaskColor := AMaskColor;
    end;
  end;
end;

procedure TIconFontItems.UpdateOwnerAttributes;
begin
  FGetOwnerAttributes(FOwnerFontName, FOwnerFontColor, FOwnerMaskColor);
end;

procedure TIconFontItems.ItemChanged(const AItem: TIconFontItem);
begin
  if Assigned(FOnItemChanged) then
    FOnItemChanged(AItem);
end;

function TIconFontItems.IsCharAvailable(
  const ABitmap: TBitmap;
  const AFontIconDec: Integer): Boolean;
var
  Cnt: DWORD;
  len: Integer;
  buf : array of WORD;
  I: Integer;
  S: WideString;
  msBlank, msIcon: TMemoryStream;
  LIsSurrogate: Boolean;
  LRect: TRect;
begin
  Result := False;
  if Assigned(ABitmap) then
  begin
    LIsSurrogate := (AFontIconDec >= $010000) and (AFontIconDec <= $10FFFF);
    if LIsSurrogate then
    begin
      //To support surrogate Characters I cannot use GetGlyphIndicesW so I'm drawing the Character on a Canvas and
      //check if is already blank: this method is quite slow
      LRect := Rect(0,0, ABitmap.Width, ABitmap.Height);
      ABitmap.Canvas.FillRect(LRect);
      msBlank := TMemoryStream.Create;
      msIcon := TMemoryStream.Create;
      try
        ABitmap.SaveToStream(msBlank);
        {$IFDEF DXE3+}
        {$WARN SYMBOL_DEPRECATED OFF}
        S := ConvertFromUtf32(AFontIconDec);
        {$WARN SYMBOL_DEPRECATED ON}
        ABitmap.Canvas.TextOut(0, 0, S);
        {$ELSE}
        S := WideChar(AFontIconDec);
        TextOutW(ABitmap.Canvas.Handle, 0, 0, PWideChar(S), 1);
        {$ENDIF}
        ABitmap.SaveToStream(msIcon);
        Result := not ((msBlank.Size = msIcon.Size) and CompareMem(msBlank.Memory, msIcon.Memory, msBlank.Size));
      finally
        msBlank.Free;
        msIcon.Free;
      end;
    end
    else
    begin
      //Check for non surrogate pairs, using GetGlyphIndices
      S := WideChar(AFontIconDec);
      len := Length(S);
      SetLength( buf, len);
      {$IFDEF D2010+}
      Cnt := GetGlyphIndicesW( ABitmap.Canvas.Handle, PWideChar(S), len, @buf[0], GGI_MARK_NONEXISTING_GLYPHS);
      {$ELSE}
      {$WARN SUSPICIOUS_TYPECAST OFF}
      Cnt := GetGlyphIndicesW( ABitmap.Canvas.Handle, PAnsiChar(S), len, @buf[0], GGI_MARK_NONEXISTING_GLYPHS);
      {$ENDIF}
      if Cnt > 0 then
      begin
        for i := 0 to Cnt-1 do
          Result := buf[i] <> $FFFF;
      end;
    end;
  end;
end;

function TIconFontItems.AddIcons(const AFrom, ATo: WideChar;
  const AFontName: TFontName; const AFontColor: TColor; AMaskColor: TColor;
  const ACheckValid: Boolean): Integer;
begin
  Result := AddIcons(Ord(AFrom), Ord(ATo), AFontName, AFontColor, AMaskColor, ACheckValid);
end;

function TIconFontItems.AddIcons(const ASourceString: WideString;
  const AFontName: TFontName): Integer;
{$IFDEF DXE3+}
var
  LChar: UCS4Char;
  I, L, ICharLen: Integer;
{$ENDIF}
begin
  Result := 0;
  {$IFDEF DXE3+}
  L := Length(ASourceString);
  I := 1;
  while I <= L do
  begin
    {$WARN SYMBOL_DEPRECATED OFF}
    if IsSurrogate(ASourceString[I]) then
    begin
      LChar := ConvertToUtf32(ASourceString, I, ICharLen);
    end
    else
    begin
      ICharLen := 1;
      LChar := UCS4Char(ASourceString[I]);
    end;
    {$WARN SYMBOL_DEPRECATED ON}
    AddIcon(Ord(LChar), AFontName);
    Inc(I, ICharLen);
    Inc(Result);
  end;
  {$ENDIF}
end;

function TIconFontItems.AddIcon(const AChar: Integer;
  const AIconName: string; const AFontName: TFontName = '';
  const AFontColor: TColor = clDefault;
  const AMaskColor: TColor = clNone): TIconFontItem;
begin
  Result := Add;
  try
    Result.IconName := AIconName;
    Result.FontIconDec := AChar;
    if AFontColor <> clDefault then
      Result.FontColor := AFontColor;
    if AMaskColor <> clNone then
      Result.MaskColor := AMaskColor;
  except
    Delete(Result.Index);
    raise;
  end;
end;

function TIconFontItems.AddIcon(const AChar: WideChar;
  const AFontName: TFontName; const AFontColor,
  AMaskColor: TColor): TIconFontItem;
begin
  Result := AddIcon(Ord(AChar), '', AFontName, AFontColor, AMaskColor);
end;

function TIconFontItems.AddIcon(const AChar: Integer;
  const AFontName: TFontName; const AFontColor,
  AMaskColor: TColor): TIconFontItem;
begin
  Result := AddIcon(AChar, '', AFontName, AFontColor, AMaskColor);
end;

{ TIconFont }

procedure TIconFont.Assign(Source: TIconFont);
begin
  FFontName := Source.FFontName;
  FFontIconDec := Source.FFontIconDec;
  FFontColor := Source.FFontColor;
  FMaskColor := Source.FMaskColor;
  FOpacity := Source.FOpacity;
  FIconName := Source.FIconName;
  FDisabledFactor :=  Source.FDisabledFactor;
end;

function TIconFont.GetBitmap(const AWidth, AHeight: Integer;
  const AFontName: TFontName; AFontIconDec: Integer;
  const AFontColor, AMaskColor: TColor;
  const AEnabled: Boolean = True;
  const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
  const AOpacity: Byte = DEFAULT_OPACITY;
  const AZoom: Integer = ZOOM_DEFAULT;
  const ASecondaryFontIconDec: Integer = 0;
  const ASecondaryFontColor: TColor = clNone;
  const ASecondaryOpacity: Byte = DEFAULT_OPACITY): TBitmap;
{$IFDEF GDI+}
var
  LGraphics: TGPGraphics;
{$ENDIF}
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf32bit;
  {$IFDEF GDI+}
  if TStyleManager.IsCustomStyleActive then
    Result.Canvas.Brush.Color := StyleServices.GetSystemColor(clWindow)
  else
    Result.Canvas.Brush.Color := ColorToRGB(clWindow);
  Result.SetSize(AWidth, AHeight);
  {$ELSE}
    {$IFDEF DXE+}
    Result.alphaFormat := afIgnored;
    Result.SetSize(AWidth, AHeight);
    {$ELSE}
    Result.Width := AWidth;
    Result.Height := AHeight;
    {$ENDIF}
  {$ENDIF}
  {$IFDEF GDI+}
  LGraphics := TGPGraphics.Create(Result.Canvas.Handle);
  try
    LGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
    PaintToGDI(LGraphics, 0, 0, AWidth, AHeight, AFontName,
      AFontIconDec, AFontColor, AEnabled, ADisabledFactor, AOpacity, AZoom);
    if ASecondaryFontIconDec <> 0 then
      PaintToGDI(LGraphics, 0, 0, AWidth, AHeight, AFontName,
        ASecondaryFontIconDec, ASecondaryFontColor, AEnabled, ADisabledFactor,
        ASecondaryOpacity, AZoom);
  finally
    LGraphics.Free;
  end;
  {$ELSE}
  PaintTo(Result.Canvas, 0, 0, AWidth, AHeight, AFontName,
    AFontIconDec, AFontColor, AMaskColor, AEnabled, ADisabledFactor, AZoom);
  {$ENDIF}
end;

procedure TIconFont.PaintTo(const ACanvas: TCanvas;
  const X, Y, AWidth, AHeight: Integer;
  const AFontName: TFontName; AFontIconDec: Integer;
  const AFontColor, AMaskColor: TColor;
  const AEnabled: Boolean = True;
  const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR;
  const AZoom: Integer = ZOOM_DEFAULT);
var
  S: WideString;
  LX, LY: Integer;
  LRect: TRect;
  LFontColor: TColor;
  LFontHeight: Integer;
begin
  if not AEnabled then
    LFontColor := DisabledColor(AFontColor,
      Round(DEFAULT_DISABLE_FACTOR * ADisabledFactor / 255))
  else
    LFontColor := AFontColor;

  with ACanvas do
  begin
    Font.Name := AFontName;
    LFontHeight := Round(AHeight * AZoom / ZOOM_DEFAULT);
    Font.Height := LFontHeight;
    Font.Color := LFontColor;
    Brush.Color := AMaskColor;
    LRect.Left := X;
    LRect.Top := Y;
    {$IFDEF DXE8+}
    LRect.Width := AWidth;
    LRect.Height := AHeight;
    {$ELSE}
    LRect.Right := X + AWidth;
    LRect.Bottom := Y + AHeight;
    {$ENDIF}
    FillRect(LRect);

    if AZoom <> 100 then
    begin
      LX := Round((X + AWidth - (AZoom / ZOOM_DEFAULT * AWidth)) / 2);
      LY := Round((Y + AHeight - (AZoom / ZOOM_DEFAULT * AHeight)) / 2);
    end
    else
    begin
      LX := X;
      LY := Y;
    end;

    {$IFDEF DXE3+}
    {$WARN SYMBOL_DEPRECATED OFF}
    S := ConvertFromUtf32(AFontIconDec);
    {$WARN SYMBOL_DEPRECATED ON}
    TextOut(LX, LY, S);
    {$ELSE}
    S := WideChar(AFontIconDec);
    TextOutW(ACanvas.Handle, LX, LY, PWideChar(S), 1);
    {$ENDIF}
  end;
end;

{$IFDEF GDI+}
procedure TIconFont.PaintToGDI(const AGraphics: TGPGraphics;
  const X, Y, AWidth, AHeight: Single;
  const AFontName: TFontName; AFontIconDec: Integer;
  const AFontColor: TColor; const AEnabled: Boolean = True;
  const ADisabledFactor: Byte = DEFAULT_DISABLE_FACTOR; const AOpacity: Byte = DEFAULT_OPACITY;
  const AZoom: Integer = ZOOM_DEFAULT);
var
  LSolidBrush: TGPSolidBrush;
  LBounds: TGPRectF;
  LFamily: TGPFontFamily;
  LFont: TGPFont;
  LFontColor: TColor;
  LPoint: TGPPointF;
  S: WideString;
  LFontSize: Single;
begin
  LSolidBrush := nil;
  LFont := nil;
  LFamily := nil;
  try
    LBounds.X := X;
    LBounds.Y := Y;
    LBounds.Width := AWidth;
    LBounds.Height := AHeight;

    if not AEnabled then
      LFontColor := DisabledColor(AFontColor,
        Round(DEFAULT_DISABLE_FACTOR * ADisabledFactor / 255))
    else
      LFontColor := AFontColor;

    LSolidBrush := TGPSolidBrush.Create(GPColor(LFontColor, AOpacity));

    LFontSize := AHeight * AZoom / ZOOM_DEFAULT;
    //A registered memory font wins over an installed one, so every machine draws the same glyphs
    LFamily := PrivateFontFamily(AFontName);
    if Assigned(LFamily) then
      LFont := TGPFont.Create(LFamily, LFontSize, FontStyleRegular, UnitPixel)
    else
      LFont := TGPFont.Create(AFontName, LFontSize, FontStyleRegular, UnitPixel);

    AGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
    AGraphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    if AZoom <> 100 then
    begin
      LPoint.X := ((LBounds.X + AWidth - (AZoom / ZOOM_DEFAULT * AWidth)) / 2)
        - ((AZoom / ZOOM_DEFAULT * AWidth) / 6);
      LPoint.Y := (LBounds.Y + AHeight - (AZoom / ZOOM_DEFAULT * AHeight)) / 2;
    end
    else
    begin
      LPoint.X := LBounds.X - (AWidth / 6); //Offset to align character to left
      LPoint.Y := LBounds.Y;
    end;

    {$WARN SYMBOL_DEPRECATED OFF}
    S := ConvertFromUtf32(AFontIconDec);
    {$WARN SYMBOL_DEPRECATED ON}
    AGraphics.DrawString(S, Length(S), LFont, LPoint, LSolidBrush);
  finally
    LFont.Free;
    LFamily.Free;
    LSolidBrush.Free;
  end;
end;
{$ENDIF}

{$IFDEF GDI+}
initialization

finalization
  //runs before Winapi.GDIPOBJ shuts GDI+ down
  _PrivateFonts.Free;
{$ENDIF}

end.
