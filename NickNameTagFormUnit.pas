unit NickNameTagFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, AdvObj,
  BaseGrid, AdvGrid, Vcl.StdCtrls;

type
  TNickNameForm = class(TForm)
    NickNameGrid: TAdvStringGrid;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure NickNameGridClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure Button1Click(Sender: TObject);
    procedure NickNameGridClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NickNameForm: TNickNameForm;

implementation

{$R *.dfm}
uses
  NameTag, WZIMGFile, WZDirectory, WzUtils, Global, StrUtils;

procedure TNickNameForm.Button1Click(Sender: TObject);
begin
  TNickNameTag.Delete;
  ActiveControl := nil;
end;

procedure TNickNameForm.FormClick(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TNickNameForm.FormCreate(Sender: TObject);
begin
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
end;

procedure TNickNameForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_MENU then
    Key := 0;
end;

procedure TNickNameForm.FormShow(Sender: TObject);
begin
  if NickNameGrid.Cells[1, 1] <> '' then
    Exit;

  var RowCount := -1;
  NickNameGrid.BeginUpdate;
  for var Iter in GetImgEntry('Item.wz/Install/0370.img/').Children do
  begin

  //  if GetImgEntry('Character.WZ/Accessory/' + img.Name + '/info/medalTag') = nil then
    //  Continue;
   // var TagNum:= Iter.Get('info/nickTaf').Data;
   // if  GetImgEntry('UI.wz/NameTag.img/medal/' + string(TagNum)) = nil then
     //Continue;

    var ID := Iter.Name;
    Inc(RowCount);
    NickNameGrid.RowCount := RowCount + 1;
    NickNameGrid.Cells[1, RowCount] := ID;
    if HasImgEntry('String.wz/Ins.img/' + IDToInt(ID)) then
      NickNameGrid.Cells[3, RowCount] := GetImgEntry('String.wz/Ins.img/' + IDToInt(ID)).Get('Name', '');

    var Entry := Iter.Get2('info/icon');
    if Entry <> nil then
    begin
      var Bmp := Entry.Canvas.DumpBmp;
      NickNameGrid.CreateBitmap(2, RowCount, False, haCenter, vaCenter).Assign(Bmp);
      Bmp.Free;
    end;

  end;
  NickNameGrid.SortByColumn(1);
  NickNameGrid.EndUpdate;
end;

procedure TNickNameForm.NickNameGridClick(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TNickNameForm.NickNameGridClickCell(Sender: TObject; ARow, ACol: Integer);
begin
  TNickNameTag.Delete;
  TNickNameTag.Create(NickNameGrid.Cells[1, ARow]);
  ActiveControl := nil;
end;

end.

