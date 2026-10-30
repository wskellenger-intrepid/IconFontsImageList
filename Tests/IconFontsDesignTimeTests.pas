unit IconFontsDesignTimeTests;

interface

uses
  DUnitX.TestFramework;

type
  // A form's image list points at a collection in a data module. The designer only fills that reference while
  // the data module is loaded: until then the list has no collection, and opening the form must not fail.
  [TestFixture]
  TIconFontsDesignTimeTests = class
  public
    [Test]
    procedure ReadingAListWithoutACollectionInTheDesignerDoesNotRaise;
    [Test]
    procedure ReadingAListWithoutACollectionAtRunTimeRaises;
    [Test]
    procedure ChangingTheCollectionOfAListWithoutOneStillRaisesInTheDesigner;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  IconFontsVirtualImageList;

type
  // reaches TComponent.SetDesigning, which the designer calls on every component of a form it opens
  TDesignedList = class(TIconFontsVirtualImageList)
  public
    procedure Design;
  end;

procedure TDesignedList.Design;
begin
  SetDesigning(True, False);
end;

{ TIconFontsDesignTimeTests }

procedure TIconFontsDesignTimeTests.ReadingAListWithoutACollectionInTheDesignerDoesNotRaise;
var
  LList: TDesignedList;
begin
  LList := TDesignedList.Create(nil);
  try
    LList.Design;
    Assert.AreEqual(-1, Integer(LList.GetIndexByName('x')), 'an unknown name gives -1');
    Assert.AreEqual('', string(LList.GetNameByIndex(0)), 'an unknown index gives an empty name');
  finally
    LList.Free;
  end;
end;

procedure TIconFontsDesignTimeTests.ReadingAListWithoutACollectionAtRunTimeRaises;
var
  LList: TIconFontsVirtualImageList;
  LRaised: Boolean;
begin
  LList := TIconFontsVirtualImageList.Create(nil);
  try
    LRaised := False;
    try
      LList.GetIndexByName('x');
    except
      on Exception do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'at run time a list with no collection is a bug');
  finally
    LList.Free;
  end;
end;

procedure TIconFontsDesignTimeTests.ChangingTheCollectionOfAListWithoutOneStillRaisesInTheDesigner;
var
  LList: TDesignedList;
  LRaised: Boolean;
begin
  LList := TDesignedList.Create(nil);
  try
    LList.Design;
    LRaised := False;
    try
      LList.AddIcons(1, 2);
    except
      on Exception do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'adding icons to a list with no collection is not a silent no-op');
  finally
    LList.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontsDesignTimeTests);

end.
