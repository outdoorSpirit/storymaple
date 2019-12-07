unit ColorUtils;

interface

uses
  Windows, SysUtils, Classes, Math, Vcl.Graphics, DX9Textures, AsphyreTypes, AdvGrid;

type
  TColorEffect = (ceNone, ceHue, ceSaturation, ceLight, ceNegative, ceContrast1, ceContrast2,
    ceContrast3, ceContrast4, ceContrast5);

  TColorFunc = class
    class procedure SetGridColor(Bmp: TBitmap; Grid: TAdvStringGrid);
    class procedure SetSpriteColor<T: class>(Entry: T; Row: Integer; UseEquipImages: Boolean = False);
    class procedure HSVvar<T: class>(Texture: T; oHue, oSat, oVal: Integer);
    class procedure Negative<T: class>(Texture: T);
    class procedure IntensityRGBAll<T: class>(Texture: T; r, g, b: Integer);
    class procedure Contrast3<T: class>(Texture: T; Change, Midpoint: Integer; DoRed, DoGreen, DoBlue: Boolean);
    class procedure Colorize<T: class>(Texture: T; Hue: Integer; saturation: Integer; luminosity: Double);
    class procedure HSV2RGB(var px: TRGB32; H, S, v: Integer);
    class procedure RGB2HSV(RGB: TRGB32; var h, s, v: Integer);
    class function blimit(vv: Integer): Integer;
  end;

implementation

uses
  WZIMGFile, WzUtils, Global, Generics.Collections;

class procedure TColorFunc.SetGridColor(Bmp: TBitmap; Grid: TAdvStringGrid);
begin
  var Width := Bmp.Width;
  var Height := Bmp.Height;
  var DoStretch: Boolean;
  if (Height < 180) then
    Grid.DefaultRowHeight := Height + 5
  else
    Grid.DefaultRowHeight := 180;


  //DyeGrid.FixedColWidth := 0;
  Grid.fixedRowHeight := 0;
  for var Row := 0 to 18 do
  begin
    Grid.CreateBitmap(0, Row, False, haCenter, vaCenter).Assign(Bmp);
    case Row of
      0..10:
        TColorFunc.HSVvar(Grid.CellGraphics[0, Row].CellBitmap, Row * 30, 0, 0);
      11:
        TColorFunc.HSVvar(Grid.CellGraphics[0, Row].CellBitmap, 0, 25, 0);
      12:
        TColorFunc.HSVvar(Grid.CellGraphics[0, Row].CellBitmap, 0, -100, 0);
      13:
        TColorFunc.Contrast3<TBitmap>(Grid.CellGraphics[0, Row].CellBitmap, 50, -90, True, False, False);
      14:
        TColorFunc.Contrast3<TBitmap>(Grid.CellGraphics[0, Row].CellBitmap, 50, -90, False, True, False);
      15:
        TColorFunc.Contrast3<TBitmap>(Grid.CellGraphics[0, Row].CellBitmap, 50, -90, False, False, True);
      16:
        TColorFunc.Contrast3<TBitmap>(Grid.CellGraphics[0, Row].CellBitmap, 50, -90, True, True, False);
      17:
        TColorFunc.Contrast3<TBitmap>(Grid.CellGraphics[0, Row].CellBitmap, 50, -90, True, False, True);
      18:
        TColorFunc.Negative(Grid.CellGraphics[0, Row].CellBitmap);
    end;
  end;

end;

class procedure TColorFunc.SetSpriteColor<T>(Entry: T; Row: Integer; UseEquipImages: Boolean = False);
begin
  var ToData: TObjectDictionary<string, TWZIMGEntry>;
  var ToImages: TObjectDictionary<TWZIMGEntry, TDX9LockableTexture>;
  if UseEquipImages then
  begin
    ToData:=EquipData;
    ToImages:=EquipImages;
  end
  else
  begin
    ToData:=WzData;
    ToImages:=Images;
  end;


  case Row of
    0:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages);
    1..10:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceHue, Row * 30);
    11:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceSaturation, 25);
    12:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceSaturation, -100);
    13:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceContrast1);
    14:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceContrast2);
    15:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceContrast3);
    16:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceContrast4);
    17:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceContrast5);
    18:
      DumpData(TWZIMGEntry(Entry), ToData, ToImages, ceNegative);

  end;

end;

class procedure TColorFunc.HSVvar<T>(Texture: T; oHue, oSat, oVal: Integer);
var
  x, y: Integer;
  Hue, Sat, Val: Integer;
  pDest: Pointer;
  nPitch: Integer;
  ARGB: PRGB32;
begin
  //var Output := TDX9LockableTexture(Texture);
  if Texture is TDX9LockableTexture then
    with TDX9LockableTexture(Texture) do
    begin
      Lock(Rect(0, 0, Width, Height), pDest, nPitch);
      ARGB := pDest;
      for y := 0 to Height - 1 do
      begin
        for x := 0 to Width - 1 do
        begin
          RGB2HSV(ARGB^, Hue, Sat, Val);
          HSV2RGB(ARGB^, Hue + oHue, Sat + oSat, Val + oVal);
          Inc(ARGB);
        end;
      end;
      Unlock;
     // TDX9LockableTexture(Result) := Output;
    end
  else if Texture is TBitmap then
    with TBitmap(Texture) do
    begin
      for y := 0 to Height - 1 do
      begin
        ARGB := ScanLine[y];
        for x := 0 to Width - 1 do
        begin
          RGB2HSV(ARGB^, Hue, Sat, Val);
          HSV2RGB(ARGB^, Hue + oHue, Sat + oSat, Val + oVal);
          Inc(ARGB);
        end;
      end;
    end

end;

class procedure TColorFunc.Negative<T>(Texture: T);
var
  col, row: Integer;
  ppx: PRGB32;
  p_byte: PByte;
  pDest: Pointer;
  nPitch: Integer;
begin
  if Texture is TDX9LockableTexture then
    with TDX9LockableTexture(Texture) do
    begin
      Lock(Rect(0, 0, Width, Height), pDest, nPitch);
      p_byte := pDest;
      for row := 0 to Height - 1 do
      begin
        for col := 0 to Width - 1 do
        begin
          p_byte^ := 255 - p_byte^;
          Inc(p_byte);
          p_byte^ := 255 - p_byte^;
          Inc(p_byte);
          p_byte^ := 255 - p_byte^;
          Inc(p_byte);
          Inc(p_byte);
        end;
      end;
      Unlock;
    end
  else if Texture is TBitmap then
    with TBitmap(Texture) do
    begin
      case PixelFormat of
        pf24bit:
          for row := 0 to Height - 1 do
          begin
            ppx := ScanLine[row];
            for col := 0 to Width - 1 do
            begin
              ppx^.r := 255 - ppx^.r;
              ppx^.g := 255 - ppx^.g;
              ppx^.b := 255 - ppx^.b;
              Inc(ppx);
            end;
          end;
        pf32bit:
          for row := 0 to Height - 1 do
          begin
            p_byte := ScanLine[row];
            for col := 0 to Width - 1 do
            begin
              p_byte^ := 255 - p_byte^;
              Inc(p_byte);
              p_byte^ := 255 - p_byte^;
              Inc(p_byte);
              p_byte^ := 255 - p_byte^;
              Inc(p_byte);
              Inc(p_byte);
            end;
          end;
      end;
    end;

end;

class function TColorFunc.blimit(vv: Integer): Integer;
begin
  if vv < 0 then
    Result := 0
  else if vv > 255 then
    Result := 255
  else
    Result := vv;
end;

class procedure TColorFunc.IntensityRGBAll<T>(Texture: T; r, g, b: Integer);
var
  x, y: Integer;
  e: PRGB32;
  per1: Double;
  LUTR, LUTG, LUTB: array[0..255] of Byte;
  pDest: Pointer;
  nPitch: Integer;
begin

  for x := 0 to 255 do
  begin
    LUTR[x] := blimit(x + r);
    LUTG[x] := blimit(x + g);
    LUTB[x] := blimit(x + b);
  end;

  if Texture is TDX9LockableTexture then
    with TDX9LockableTexture(Texture) do
    begin
      Lock(Rect(0, 0, Width, Height), pDest, nPitch);
      e := pDest;
      for y := 0 to Height - 1 do
      begin
        for x := 0 to Width - 1 do
        begin
          with e^ do
          begin
            r := LUTR[r];
            g := LUTG[g];
            b := LUTB[b];
          end;
          Inc(e);
        end;
      end;
      Unlock;
    end
  else if Texture is TBitmap then
    with TBitmap(Texture) do
      for y := 0 to Height - 1 do
      begin
        e := ScanLine[y];
        for x := 0 to Width - 1 do
        begin
          with e^ do
          begin
            r := LUTR[r];
            g := LUTG[g];
            b := LUTB[b];
          end;
          Inc(e);
        end;
      end;
end;

class procedure TColorFunc.Contrast3<T>(Texture: T; Change, Midpoint: Integer; DoRed, DoGreen, DoBlue: Boolean);
var
  i, x, y: Integer;
  rgb: PRGB32;
  contrast: Double;
  modifier: Integer;
  LUT1: array[0..255] of Integer;
  pDest: Pointer;
  nPitch: Integer;
begin
  if Change = 0 then
    Exit;

  if Change < -255 then
    Change := -255;
  if Change > 255 then
    Change := 255;

  if Midpoint < -100 then
    Midpoint := -100;
  if Midpoint > 100 then
    Midpoint := 100;

  i := Change + 100;

  if i = 100 then
    contrast := 1
  else if i < 100 then
    contrast := 1 / (5 - (i / 25))
  else
    contrast := ((i - 100) / 50) + 1;

  modifier := 100 + Midpoint;
  for i := 0 to 255 do
    LUT1[i] := blimit(Trunc(((i - modifier) * contrast) + modifier));

  if Texture is TDX9LockableTexture then
    with TDX9LockableTexture(Texture) do
    begin
      Lock(Rect(0, 0, Width, Height), pDest, nPitch);
      rgb := pDest;
      for y := 0 to Height - 1 do
      begin
        for x := 0 to Width - 1 do
        begin
          with rgb^ do
          begin
            if DoRed then
              r := LUT1[r];
            if DoGreen then
              g := LUT1[g];
            if DoBlue then
              b := LUT1[b];
          end;
          Inc(rgb);
        end;
      end;
      unlock;
    end
  else if Texture is TBitmap then
    with TBitmap(Texture) do
    begin
      for y := 0 to Height - 1 do
      begin
        rgb := Scanline[y];
        for x := 0 to Width - 1 do
        begin
          with rgb^ do
          begin
            if DoRed then
              r := LUT1[r];
            if DoGreen then
              g := LUT1[g];
            if DoBlue then
              b := LUT1[b];
          end;
          Inc(rgb);
        end;

      end;
    end;

end;

class procedure TColorFunc.Colorize<T>(Texture: T; Hue: Integer; Saturation: Integer; Luminosity: Double);
var
  i, row, col: Integer;
  px: PRGB32;
  rgb: TRGB32;
  v: Integer;
  pDest: Pointer;
  nPitch: Integer;
const
  RedToGrayCoef = 21;
  GreenToGrayCoef = 71;
  BlueToGrayCoef = 8;
begin
  if Texture is TDX9LockableTexture then
    with TDX9LockableTexture(Texture) do
    begin
      Lock(Rect(0, 0, Width, Height), pDest, nPitch);
      px := pDest;
      for row := 0 to Height - 1 do
      begin
        for col := 0 to Width - 1 do
        begin
          with px^ do
            v := Trunc((r * RedToGrayCoef + g * GreenToGrayCoef + b * BlueToGrayCoef) shr 8 * Luminosity);
          HSV2RGB(px^, Hue, Saturation, v);
          Inc(px);
        end;
      end;
      Unlock;
    end
  else if Texture is TBitmap then
    with TBitmap(Texture) do
    begin
      for row := 0 to Height - 1 do
      begin
        px := Scanline[row];
        for col := 0 to Width - 1 do
        begin
          with px^ do
            v := Trunc((r * RedToGrayCoef + g * GreenToGrayCoef + b * BlueToGrayCoef) shr 8 * Luminosity);
          HSV2RGB(px^, Hue, Saturation, v);
          Inc(px);
        end;

      end;
    end;

end;

class procedure TColorFunc.HSV2RGB(var px: TRGB32; H, S, V: Integer);
const
  divisor: Integer = 99 * 60;
var
  f: Integer;
  hTemp: Integer;
  p, q, t: Integer;
  VS: Integer;
begin
  // check limits (changed at 2.1.1)
  if H < 0 then
    H := 360 + H
  else if H > 359 then
    H := H - 360;
  if S < 0 then
    S := 0
  else if S > 99 then
    S := 99;
  if V < 0 then
    V := 0
  else if V > 99 then
    V := 99;
  //
  if S = 0 then
  begin
    px.r := V;
    px.g := V;
    px.b := V;
  end
  else
  begin
    if H = 360 then
      hTemp := 0
    else
      hTemp := H;
    f := hTemp mod 60;
    hTemp := hTemp div 60;
    VS := V * S;
    p := V - VS div 99;
    q := V - (VS * f) div divisor;
    t := V - (VS * (60 - f)) div divisor;
    with px do
    begin
      case hTemp of
        0:
          begin
            r := V;
            g := t;
            b := p
          end;
        1:
          begin
            r := q;
            g := V;
            b := p
          end;
        2:
          begin
            r := p;
            g := V;
            b := t
          end;
        3:
          begin
            r := p;
            g := q;
            b := V
          end;
        4:
          begin
            r := t;
            g := p;
            b := V
          end;
        5:
          begin
            r := V;
            g := p;
            b := q
          end;
      end
    end
  end;
  px.r := Round(px.r / 99 * 255);
  px.g := Round(px.g / 99 * 255);
  px.b := Round(px.b / 99 * 255);
end;

class procedure TColorFunc.RGB2HSV(RGB: TRGB32; var h, s, v: Integer);

  procedure MinMaxInt(const i, j, k: Integer; var min, max: Integer);
  begin
    if i > j then
    begin
      if i > k then
        max := i
      else
        max := k;
      if j < k then
        min := j
      else
        min := k
    end
    else
    begin
      if j > k then
        max := j
      else
        max := k;
      if i < k then
        min := i
      else
        min := k
    end;
  end;

var
  Delta: Integer;
  MinValue: Integer;
  r, g, b: Integer;
begin
  r := Round(RGB.r / 255 * 99);
  g := Round(RGB.g / 255 * 99);
  b := Round(RGB.b / 255 * 99);
  MinMaxInt(r, g, b, MinValue, v);
  Delta := v - MinValue;
  if v = 0 then
    s := 0
  else
    s := (99 * Delta) div v;
  if s = 0 then
    h := 0
  else
  begin
    if r = v then
      h := (60 * (g - b)) div Delta
    else if g = v then
      h := 120 + (60 * (b - r)) div Delta
    else if b = v then
      h := 240 + (60 * (r - g)) div Delta;
    if h < 0 then
      h := h + 360;
  end;
end;

initialization

finalization

end.

