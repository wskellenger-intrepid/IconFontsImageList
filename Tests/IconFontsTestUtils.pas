unit IconFontsTestUtils;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  IconFontsVirtualImageList;

const
  // icons are drawn into a 16px box at (16, 16) on a 48px bitmap, leaving room to see overflow
  BOX = 16;

//Reads a font file below the Tests folder and registers it with IconFontsAddMemoryFont. Keep the
//result for as long as the font is used: GDI+ reads that memory.
function RegisterMemoryFont(const ARelativePath: string): TBytes;

//A 16px virtual image list over a new collection holding one icon, both owned by AOwner
function CreateList(const AFontName: string; const ACodepoint, AZoom: Integer;
  const AOwner: TComponent): TIconFontsVirtualImageList;

//Draws icon 0 of AList into its box on a new white bitmap
function DrawToBitmap(const AList: TIconFontsVirtualImageList): TBitmap;

//Draws ACodepoint from AFontName in black
function Render(const AFontName: string; const ACodepoint: Integer; const AZoom: Integer = 100): TBitmap;

function Grey(const ABitmap: TBitmap; const X, Y: Integer): Integer;

function InkCount(const ABitmap: TBitmap): Integer;

implementation

uses
  System.IOUtils,
  System.Types,
  System.UITypes,
  IconFontsItems,
  IconFontsImageCollection;

function RegisterMemoryFont(const ARelativePath: string): TBytes;
begin
  Result := TFile.ReadAllBytes(TPath.Combine(ExtractFilePath(ParamStr(0)), ARelativePath));
  IconFontsAddMemoryFont(@Result[0], Length(Result));
end;

function CreateList(const AFontName: string; const ACodepoint, AZoom: Integer;
  const AOwner: TComponent): TIconFontsVirtualImageList;
var
  LCollection: TIconFontsImageCollection;
begin
  LCollection := TIconFontsImageCollection.Create(AOwner);
  LCollection.FontName := AFontName;
  LCollection.FontColor := clBlack;
  LCollection.IconFontItems.AddIcon(ACodepoint, '');
  Result := TIconFontsVirtualImageList.Create(AOwner);
  Result.Width := BOX;
  Result.Height := BOX;
  Result.Zoom := AZoom;
  Result.ImageCollection := LCollection;
end;

function DrawToBitmap(const AList: TIconFontsVirtualImageList): TBitmap;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(3 * BOX, 3 * BOX);
  Result.Canvas.Brush.Color := clWhite;
  Result.Canvas.FillRect(Rect(0, 0, 3 * BOX, 3 * BOX));
  AList.Draw(Result.Canvas, BOX, BOX, 0);
end;

function Render(const AFontName: string; const ACodepoint: Integer; const AZoom: Integer = 100): TBitmap;
var
  LOwner: TComponent;
begin
  LOwner := TComponent.Create(nil);
  try
    Result := DrawToBitmap(CreateList(AFontName, ACodepoint, AZoom, LOwner));
  finally
    LOwner.Free;
  end;
end;

function Grey(const ABitmap: TBitmap; const X, Y: Integer): Integer;
var
  C: TColor;
begin
  C := ABitmap.Canvas.Pixels[X, Y];
  Result := (TColorRec(C).R + TColorRec(C).G + TColorRec(C).B) div 3;
end;

function InkCount(const ABitmap: TBitmap): Integer;
var
  X, Y: Integer;
begin
  Result := 0;
  for X := 0 to ABitmap.Width - 1 do
    for Y := 0 to ABitmap.Height - 1 do
      if Grey(ABitmap, X, Y) < 128 then
        Inc(Result);
end;

end.
