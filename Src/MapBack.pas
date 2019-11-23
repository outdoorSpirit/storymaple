unit MapBack;

interface

uses
  Windows, SysUtils, StrUtils, AsphyreSprite, Generics.Collections, WZIMGFile, Global,
  AbstractCanvas, Tools, MapleCharacter, MapleMap, WzUtils, System.Types;

type
  TMapBack = class(TBackgroundSprite)
  private
    InfoPath: string;
    FFrame: Integer;
    FHasAnim: Boolean;
    RX: Integer;
    RY: Integer;
    PosX, PosY: Integer;
    BackType: Integer;
    FTime: Integer;
    FDelta: Real;
    Front: Integer;
    MoveR: Integer;
    MoveH: Integer;
    MoveType: Integer;
    Origin: TPoint;
  public
    procedure DoMove(const Movecount: Single); override;
    procedure DoDraw; override;
    class var
      ResetPos: Boolean;
    class procedure Create; overload;
  end;

implementation

uses
  SaveMapUnit, MainUnit,ColorUtils, OptionsFormUnit;

var
  cc: Integer;

class procedure TMapBack.Create;
var
  Entry, AniEntry, Iter, Iter2, Child, Source: TWZIMGEntry;
  HasLoad: TList<TWZIMGEntry>;
  InfoPath, bS, No: string;
  Ani, Flip, I, CX, CY, Alpha, ZLayer, _Front: Integer;
  WX, WY: Single;
begin
  HasLoad := TList<TWZIMGEntry>.Create;
  for Iter in TMap.ImgFile.Child['back'].Children do
  begin
    bS := Iter.Get('bS', '');
    No := Iter.Get('no', '0');

    _Front := Iter.Get('front', '0');
    Flip := Iter.Get('f', '0');
    Ani := Iter.Get('ani', '0');
    if Ani > 1 then
      Ani := 0;

    CX := Iter.Get('cx', '0');
    CY := Iter.Get('cy', '0');
    Alpha := Iter.Get('a', '255');

    ZLayer := StrToInt(Iter.Name);
    if bS = '' then
      Continue;
    if (bS = 'lebenLab') and (Ani = 1) then
      Continue;
    if Ani = 0 then
    begin
      if MapWz.GetImgFile('Back/' + bS + '.img') <> nil then
        Entry := GetImgEntry('Map/Back/' + bS + '.img/back/' + No)

      else if Map001Wz.GetImgFile('Back/' + bS + '.img') <> nil then
        Entry := GetImgEntry('Map001/Back/' + bS + '.img/back/' + No)
      else
        Entry := GetImgEntry('Map2/Back/' + bS + '.img/back/' + No);

      if Entry = nil then
        Continue;

      if not HasLoad.contains(Entry) then
      begin
        HasLoad.Add(Entry);
        if OptionsForm.CheckBox2.Checked then
          DumpData(Entry, WzData, Images, ceSaturation, -100)
        else
          DumpData(Entry, WzData, Images);
      end;
    end;

    if Ani = 1 then
    begin
      if MapWz.GetImgFile('Back/' + bS + '.img') <> nil then
        AniEntry := GetImgEntry('Map/Back/' + bS + '.img/ani/' + No)
      else if Map001Wz.GetImgFile('Back/' + bS + '.img') <> nil then
        AniEntry := GetImgEntry('Map001/Back/' + bS + '.img/ani/' + No)
      else
        AniEntry := GetImgEntry('Map2/Back/' + bS + '.img/ani/' + No);

      if AniEntry = nil then
        Continue;

      if not HasLoad.contains(AniEntry) then
      begin
        HasLoad.Add(AniEntry);
        if OptionsForm.CheckBox2.Checked then
          DumpData(AniEntry, WzData, Images, ceSaturation, -100)
        else
          DumpData(AniEntry, WzData, Images);
      end;
    end;

    with TMapBack.Create(BackEngine[_Front]) do
    begin
      PosX := Iter.Get('x', '0');
      PosY := Iter.Get('y', '0');
      BackType := Iter.Get('type', '0');
      RX := Iter.Get('rx', '0');
      RY := Iter.Get('ry', '0');
      Front := _Front;
      if Flip = 1 then
        MirrorX := True;
      if Ani = 1 then
        FHasAnim := True
      else
        FHasAnim := False;
      FFrame := 0;

      ImageLib := Images;

      if Ani = 0 then
      begin
        InfoPath := Entry.GetPath;
        ImageEntry := Entry;
        if ImageEntry.Get('blend', '0') then
          BlendMode := deAdd;
      end;

      if Ani = 1 then
      begin
        InfoPath := AniEntry.GetPath;
        ImageEntry := WzData[InfoPath + '/0'];
        MoveType := ImageEntry.Get('moveType', '0');
        MoveR := ImageEntry.Get('moveR', '0');
        MoveH := ImageEntry.Get('moveH', '0');
      end;

      Width := PatternWidth;
      Height := PatternHeight;

      Offset.X := ImageEntry.Get('origin').Vector.X;
      Offset.Y := ImageEntry.Get('origin').Vector.Y;
      if Offset.X < 0 then
        Offset.X := 0;
      if Offset.X > Width then
        Offset.X := Width;

      if CX = 0 then
        Width := PatternWidth
      else
        Width := CX;

      if CY = 0 then
        Height := PatternHeight
      else
        Height := CY;

      WX := SpriteEngine.WorldX;
      WY := SpriteEngine.WorldY;
      SetMapSize(1, 1);
      X := -PosX - (100 + RX) / 100 * (WX + DisplaySize.X / 2) + WX;
      Y := -PosY - (100 + RY) / 100 * (WY + DisplaySize.Y / 2) + WY;
      Z := ZLayer;

      case BackType of
        // no tile
        0:
          begin
            Tiled := False;
          end;
        // tiled   horizontal
        1:
          begin
            Tiled := True;
            TileMode := tmHorizontal;
          end;
        // tiled  vertical
        2:
          begin
            Tiled := True;
            TileMode := tmVertical;
          end;
        // tiled horizontal + tiled vertical
        3:
          begin
            Tiled := True;
            TileMode := tmFull;
          end;
        // scrolling H, tiled horizontal
        4:
          begin
            Tiled := True;
            TileMode := tmHorizontal;
          end;
        // scrolling V, tiled vertical
        5:
          begin
            Tiled := True;
            TileMode := tmVertical;
          end;
        // scrolling H, tiled horizontal+tiled vertical
        6:
          begin
            Tiled := True;
            TileMode := tmFull;
          end;
        // scrolling V, tiled horizontal+tiled vertical
        7:
          begin
            Tiled := True;
            TileMode := tmFull;
          end;

      end;
    end;

  end;

  HasLoad.Free;

end;

procedure TMapBack.DoMove(const Movecount: Single);
var
  a0, a1, Delay, MoveW, MoveP, OffSetY: Integer;
  AniAlpha: Single;
begin

  case BackType of
    0, 1, 2, 3:
      begin
        if SpriteEngineVelX <> 0 then
          X := X - RX * SpriteEngineVelX / 100;
        if SpriteEngineVelY <> 0 then
          Y := Y - RY * SpriteEngineVelY / 100;
      end;

    4, 6:
      begin
        if SpriteEngineVelX <> 0 then
          X := X + SpriteEngineVelX;
        if SpriteEngineVelY <> 0 then
          Y := Y - RY * SpriteEngineVelY / 100;
        X := X - RX * 5 / 60;
      end;

    5, 7:
      begin
        if SpriteEngineVelX <> 0 then
          X := X - RX * SpriteEngineVelX / 100;
        if SpriteEngineVelY <> 0 then
          Y := Y + SpriteEngineVelY;
        Y := Y - RY * 5 / 60;
      end;
  end;

  if ResetPos then
  begin
    X := -PosX - (100 + RX) / 100 * (SpriteEngine.WorldX + DisplaySize.X / 2) + SpriteEngine.WorldX;
    Y := -PosY - (100 + RY) / 100 * (SpriteEngine.WorldY + DisplaySize.Y / 2 + TMap.OffSetY) + SpriteEngine.WorldY;
  end;

  if TMap.SaveMap then
  begin
    X := -PosX - (100 + RX) / 100 * (SpriteEngine.WorldX + 1366 / 2) + SpriteEngine.WorldX;
    if Front = 1 then
    begin
      if TMap.Info.ContainsKey('VRLeft') then
        Y := -PosY - (100 + RY) / 100 * (TMap.Bottom - 600 + (600 / 2)) + TMap.Top
      else
        Y := -PosY - (100 + RY) / 100 * (TMap.SaveMapBottom - 600 + (600 / 2) - 100) + TMap.Top;
    end
    else
    begin
      if TMap.Info.ContainsKey('VRLeft') then
        Y := -PosY - (100 + RY * StrToFloat(SaveMapForm.ComboBox2.Text)) / 100 * (TMap.Bottom - 600
          + (600 / 2)) + TMap.Top - StrToInt(SaveMapForm.ComboBox1.Text)
      else
        Y := -PosY - (100 + RY * StrToFloat(SaveMapForm.ComboBox2.Text)) / 100 * (TMap.SaveMapBottom
          - 600 + (600 / 2) - 100) + TMap.Top - StrToInt(SaveMapForm.ComboBox1.Text);
    end;
  end;

  if FHasAnim then
  begin
    ImageEntry := WzData[InfoPath + '/' + FFrame.ToString];
    Delay := ImageEntry.Get('delay', '100');
    a0 := ImageEntry.Get('a0', '-1');
    a1 := ImageEntry.Get('a1', '-1');

    FTime := FTime + 17;
    if FTime > Delay then
    begin
      FFrame := FFrame + 1;
      if not WzData.ContainsKey(InfoPath + '/' + FFrame.ToString) then
        FFrame := 0;
      FTime := 0;
    end;

    if (a0 <> -1) and (a1 = -1) then
      Alpha := ImageEntry.Get('a0', '-1');
    AniAlpha := a0 - (a0 - a1) * FTime / Delay;

    if FTime > 0 then
      Alpha := Trunc(AniAlpha);

    MoveP := ImageEntry.Get('moveP', '0');
    // MoveH := WzData[ImagePath].Get('moveH', '0');
    MoveW := ImageEntry.Get('moveW', '0');

    if Boolean(MoveType) then
    begin
      // FDelta := FDelta + TimeDelta;
      FDelta := FDelta + 0.017;
      case MoveType of
        1:
          begin
            if Boolean(MoveP) then
              X := X + -MoveW * Cos(FDelta * 1000 * 2 * Pi / MoveP) / 60
            else
              X := X + -MoveW * Cos(FDelta) / 60;
          end;
        2:
          begin
            if Boolean(MoveP) then
              Y := Y + -MoveH * Cos(FDelta * 2 * Pi * 1000 / MoveP) / 60
            else
              Y := Y + -MoveH * Cos(FDelta) / 60;
          end;
        3:
          begin
            DrawMode := 1;
            Angle := Angle + (17 / MoveR) * Pi * 2;
            Offset.X := 0;
            Offset.Y := 0;
          end;
      end;

    end;

    if ImageEntry.Get('origin') <> nil then
      Origin := ImageEntry.Get('origin').Vector;

    case MirrorX of
      True:
        Offset.X := -Origin.X + PatternWidth;
      False:
        Offset.X := Origin.X;
    end;
    Offset.Y := Origin.Y;

  end;

end;

procedure TMapBack.DoDraw;
begin
  if ResetPos then
    ResetPos := False;
  if TMap.ShowBack then
    inherited;
end;

end.

