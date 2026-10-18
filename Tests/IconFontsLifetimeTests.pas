unit IconFontsLifetimeTests;

interface

uses
  DUnitX.TestFramework;

type
  // A collection shared by several virtual image lists (one per form, each form created and freed as the
  // user opens and closes it) holds callbacks into the last list attached to it. A freed list must not
  // leave them behind: the collection would call into freed memory on its next draw.
  [TestFixture]
  TIconFontsLifetimeTests = class
  public
    [Test]
    procedure FreeingTheListThatSetTheCallbacksClearsThem;
    [Test]
    procedure FreeingAnEarlierListKeepsTheLaterListsCallbacks;
    [Test]
    procedure AfterTheListIsFreedTheCollectionUsesItsOwnAttributes;
    [Test]
    procedure MovingAListToAnotherCollectionClearsItsCallbacksOnTheFirst;
  end;

implementation

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Graphics,
  IconFontsItems,
  IconFontsImageListBase,
  IconFontsImageCollection,
  IconFontsVirtualImageList;

type
  // reaches the collection's protected GetOwnerAttributes, which the items call when they draw
  TCollectionAccess = class(TIconFontsImageCollection);

  // an OnFontMissing handler, as a form would assign one to its list
  TFontMissingHandler = class
    procedure FontMissing(const AFontName: TFontName);
  end;

procedure TFontMissingHandler.FontMissing(const AFontName: TFontName);
begin
end;

function UpdateTarget(ACollection: TIconFontsImageCollection): Pointer;
var
  LProc: TGetOwnerAttributesProc;
begin
  LProc := ACollection.UpdateOwnerAttributes;
  Result := TMethod(LProc).Data;
end;

function ChangedTarget(ACollection: TIconFontsImageCollection): Pointer;
var
  LProc: TIconFontItemChangedProc;
begin
  LProc := ACollection.NotifyItemChanged;
  Result := TMethod(LProc).Data;
end;

function MissingTarget(ACollection: TIconFontsImageCollection): Pointer;
var
  LProc: TIconFontMissing;
begin
  LProc := ACollection.OnFontMissing;
  Result := TMethod(LProc).Data;
end;

function NewList(ACollection: TIconFontsImageCollection;
  AHandler: TFontMissingHandler = nil): TIconFontsVirtualImageList;
begin
  Result := TIconFontsVirtualImageList.Create(nil);
  if Assigned(AHandler) then
    Result.OnFontMissing := AHandler.FontMissing;
  Result.ImageCollection := ACollection;
end;

{ TIconFontsLifetimeTests }

procedure TIconFontsLifetimeTests.FreeingTheListThatSetTheCallbacksClearsThem;
var
  LCollection: TIconFontsImageCollection;
  LList: TIconFontsVirtualImageList;
  LHandler: TFontMissingHandler;
begin
  LCollection := TIconFontsImageCollection.Create(nil);
  LHandler := TFontMissingHandler.Create;
  try
    LList := NewList(LCollection, LHandler);
    Assert.AreEqual(Pointer(LList), UpdateTarget(LCollection), 'attaching the list sets the callbacks');
    Assert.AreEqual(Pointer(LHandler), MissingTarget(LCollection), 'attaching the list passes its OnFontMissing');
    LList.Free;
    Assert.IsNull(UpdateTarget(LCollection), 'UpdateOwnerAttributes still points at the freed list');
    Assert.IsNull(ChangedTarget(LCollection), 'NotifyItemChanged still points at the freed list');
    Assert.IsNull(MissingTarget(LCollection), 'OnFontMissing still is the freed list''s handler');
  finally
    LHandler.Free;
    LCollection.Free;
  end;
end;

procedure TIconFontsLifetimeTests.FreeingAnEarlierListKeepsTheLaterListsCallbacks;
var
  LCollection: TIconFontsImageCollection;
  LFirst, LSecond: TIconFontsVirtualImageList;
  LFirstHandler, LSecondHandler: TFontMissingHandler;
begin
  LCollection := TIconFontsImageCollection.Create(nil);
  LFirstHandler := TFontMissingHandler.Create;
  LSecondHandler := TFontMissingHandler.Create;
  LSecond := nil;
  try
    LFirst := NewList(LCollection, LFirstHandler);
    LSecond := NewList(LCollection, LSecondHandler);
    LFirst.Free;
    Assert.AreEqual(Pointer(LSecond), UpdateTarget(LCollection), 'the later list lost UpdateOwnerAttributes');
    Assert.AreEqual(Pointer(LSecond), ChangedTarget(LCollection), 'the later list lost NotifyItemChanged');
    Assert.AreEqual(Pointer(LSecondHandler), MissingTarget(LCollection), 'the later list lost OnFontMissing');
  finally
    LSecond.Free;
    LSecondHandler.Free;
    LFirstHandler.Free;
    LCollection.Free;
  end;
end;

procedure TIconFontsLifetimeTests.AfterTheListIsFreedTheCollectionUsesItsOwnAttributes;
var
  LCollection: TIconFontsImageCollection;
  LFontName: TFontName;
  LFontColor, LMaskColor: TColor;
begin
  LCollection := TIconFontsImageCollection.Create(nil);
  try
    LCollection.FontName := 'Collection Font';
    LCollection.FontColor := clRed;
    NewList(LCollection).Free;
    TCollectionAccess(LCollection).GetOwnerAttributes(LFontName, LFontColor, LMaskColor);
    Assert.AreEqual('Collection Font', string(LFontName));
    Assert.AreEqual(Integer(clRed), Integer(LFontColor));
  finally
    LCollection.Free;
  end;
end;

procedure TIconFontsLifetimeTests.MovingAListToAnotherCollectionClearsItsCallbacksOnTheFirst;
var
  LFirst, LSecond: TIconFontsImageCollection;
  LList: TIconFontsVirtualImageList;
begin
  LFirst := TIconFontsImageCollection.Create(nil);
  LSecond := TIconFontsImageCollection.Create(nil);
  LList := nil;
  try
    LList := NewList(LFirst);
    LList.ImageCollection := LSecond;
    Assert.IsNull(UpdateTarget(LFirst), 'the first collection still calls the list it no longer belongs to');
    Assert.AreEqual(Pointer(LList), UpdateTarget(LSecond), 'the second collection did not get the callbacks');
  finally
    LList.Free;
    LSecond.Free;
    LFirst.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontsLifetimeTests);

end.
