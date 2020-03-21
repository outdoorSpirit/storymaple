unit WorldMapFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Generics.collections;

type
  TWorldMapForm = class(TForm)
    Image1: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    HasLoad: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WorldMapForm: TWorldMapForm;

implementation

{$R *.dfm}
uses
  MainUnit, WZIMGFile, WZDirectory, WzUtils, Global;

procedure TWorldMapForm.FormActivate(Sender: TObject);
begin
  if HasLoad then
    Exit;
  WorldMapForm.Top:=-2500;
  HasLoad := True;
  var WorldMapGrid := MainForm.WorldMapGrid;
  WorldMapGrid.ColWidths[0] := 0;
  WorldMapGrid.ColWidths[1] := 180;

  var Dict := TDictionary<string, string>.Create;
  //Dict.Add('BWorldMap.img', '�������@��');
  Dict.Add('GWorldMap.img', '��������');
  Dict.Add('MWorldMap.img', '��l�@��');
  Dict.Add('SWorldMap.img', '�s�P�@��');
  Dict.Add('WorldMap.img', '�������@��');
  Dict.Add('WorldMap000.img', '�����q ');
  Dict.Add('WorldMap010.img', '���h�Q�Ȯq');
  Dict.Add('WorldMap0101.img', '�P������');
  Dict.Add('WorldMap011.img', '�H����');
  Dict.Add('WorldMap012.img', '�_�ۧ�');
  Dict.Add('WorldMap0121.img', '�Z�����@�ɾ�');
  Dict.Add('WorldMap015.img', 'WorldMap015 ');
  Dict.Add('WorldMap016.img', '�Ӯa���~�ǰ|');
  Dict.Add('WorldMap017.img', '����Ƕ�㨽�I');
  Dict.Add('WorldMap018.img', '��������');
  Dict.Add('WorldMap019.img', 'ۣۣ����');
  Dict.Add('WorldMap020.img', '�B�쳷��s��');
  Dict.Add('WorldMap021.img', '�o���q�|');
  Dict.Add('WorldMap022.img', '��l������');
  Dict.Add('WorldMap030.img', '���w����');
  Dict.Add('WorldMap031.img', '�ɶ��q�D');
  Dict.Add('WorldMap032.img', '���F�˪L ');
  Dict.Add('WorldMap033.img', '�ڤۥD�D������ ');
  Dict.Add('WorldMap034.img', '���ܧ�');
  Dict.Add('WorldMap035.img', '�a�y���å���');
  Dict.Add('WorldMap040.img', '���@��');
  Dict.Add('WorldMap041.img', '���@��2');
  Dict.Add('WorldMap050.img', '�̯Ǻ��˪L');
  Dict.Add('WorldMap051.img', '�`�ڥ� ');
  Dict.Add('WorldMap052.img', '�������H�J���J��');
  Dict.Add('WorldMap060.img', '�Z�����');
  Dict.Add('WorldMap061.img', '�����x�q ');
  Dict.Add('WorldMap070.img', '�ǧƨF�z ');
  Dict.Add('WorldMap071.img', '�j��������');
  Dict.Add('WorldMap072.img', '�ǧƨF�z�ۥѶT���a�a');
  Dict.Add('WorldMap080.img', '�ɶ�����');
  Dict.Add('WorldMap081.img', ' ���Ӥ���');
  Dict.Add('WorldMap082.img', '���N���e');
  Dict.Add('WorldMap0821.img', '���u���ȳ~');
  Dict.Add('WorldMap0822.img', '���㺸��');
  Dict.Add('WorldMap08221.img', '�I�檺���q');
  Dict.Add('WorldMap0823.img', '�ڤ����ԫ�����');
  Dict.Add('WorldMap0824.img', '�����˪L�����d�R ');
  Dict.Add('WorldMap0825.img', '�O�Ъh�A�]�i�Դ�');
  Dict.Add('WorldMap0826.img', '��l�����㴵�ة� ');
  Dict.Add('WorldMap090.img', '�C�p��');
  Dict.Add('WorldMap100.img', '�箦');
  Dict.Add('WorldMap101.img', '���㨺���l');
  Dict.Add('WorldMap110.img', ' �J�w�����Z');
  Dict.Add('WorldMap111.img', '����X��');
  Dict.Add('WorldMap120.img', 'Crystal Garden');
  Dict.Add('WorldMap130.img', '�U����');
  Dict.Add('WorldMap140.img', '���O�u��');
  Dict.Add('WorldMap141.img', '�ɧg����');
  Dict.Add('WorldMap143.img', '�J�ԩ_��');
  Dict.Add('WorldMap152.img', '�ӳ����q');
  Dict.Add('WorldMap153.img', '�J���ǯ�');
  Dict.Add('WorldMap154.img', '������');
  Dict.Add('WorldMap155.img', '��������');
  Dict.Add('WorldMap160.img', '�饻��');
  Dict.Add('WorldMap161.img', 'ۣۣ����');
  Dict.Add('WorldMap163.img', '����');
  Dict.Add('WorldMap164.img', '���� ');
  Dict.Add('WorldMap167.img', '�F�� ');
  Dict.Add('WorldMap169.img', '�´v��');
  Dict.Add('WorldMap170.img', '�J�����ȴ�');
  Dict.Add('WorldMap171.img', '�����C��');
  Dict.Add('WorldMap172.img', 'Spring Vally');
  Dict.Add('WorldMap173.img', 'The afterlands');
  Dict.Add('WorldMap174.img', '���S��');
  Dict.Add('WorldMap175.img', 'Beautyroid');
  Dict.Add('WorldMap176.img', '�������֦a ');
  Dict.Add('WorldMap180.img', '�y�ժ��W��');
  Dict.Add('WorldMap181.img', '���W�l�� ');
  Dict.Add('WorldMap190.img', '�Z��׵���');
  Dict.Add('WorldMap191.img', '�ȭ�ù�i ');
  Dict.Add('WorldMap200.img', '���ǫ�');
  Dict.Add('WorldMapJP.img', '���h�Q�Ȯq ');
  Dict.Add('WorldMapTW.img', '�x�W');

  var Row := -1;
  for var Iter in TWZDirectory(MapWz.Root.Entry['WorldMap']).Files do
  begin
    Inc(Row);
    WorldMapGrid.RowCount := Row + 1;
    WorldMapGrid.Cells[0, Row] := Iter.Name;
    if Dict.ContainsKey(Iter.Name) then
      WorldMapGrid.Cells[1, Row] := Dict[Iter.Name]
    else
      WorldMapGrid.Cells[1, Row] := Iter.Name;
  end;
  WorldMapGrid.SortByColumn(0);
  Dict.Free;
end;

procedure TWorldMapForm.FormClick(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TWorldMapForm.FormCreate(Sender: TObject);
begin
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
end;

procedure TWorldMapForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_MENU then
    Key := 0;
end;

end.

