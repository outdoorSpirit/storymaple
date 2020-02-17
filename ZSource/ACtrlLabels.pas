// ----------------------------------------------------------------------------
// ACtrlLabels.pas             Modified: 02-10-2010               Version: 0.8
// ----------------------------------------------------------------------------
// Original: English
// Definition of TCustomALabel and TALabel.
// ----------------------------------------------------------------------------
// Translation: Portuguese
// Defini��o de TCustomALabel e TALabel.
// ----------------------------------------------------------------------------
// Created by Marcos Gomes.
// ----------------------------------------------------------------------------
unit ACtrlLabels;

interface

uses
  Classes, Controls, SysUtils, Windows,
  // Aspryre units
  AbstractCanvas, AsphyreFonts, AsphyreImages, AsphyreTypes, Vectors2,
  // Asphyre GUI Engine
  ZGameFonts, ZGameFontHelpers, AControls, ACtrlForms, ACtrlTypes;

type
  TCustomALabel = class(TAControl)
  private
    FCanMoveHandle: Boolean;
    FHAlign: THAlign;
    FVAlign: TVAlign;
    FFocusControl: string;
    FPLine: Boolean;
    FTransparent: Boolean;
    procedure SetCanMoveHandle(Value: Boolean); virtual;
    procedure SetFocusControl(Value: string); virtual;
    procedure SetTransparent(Value: Boolean); virtual;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Click; override;
    procedure Paint(DC: HDC); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property CanMoveHandle: Boolean read FCanMoveHandle write SetCanMoveHandle;
    property FocusControl: string read FFocusControl write SetFocusControl;
    property ParagraphLine: Boolean read FPLine write FPLine;
    property TextHorizontalAlign: THAlign read FHAlign write FHAlign;
    property TextVerticalAlign: TVAlign read FVAlign write FVAlign;
    property Transparent: Boolean read FTransparent write SetTransparent;
  end;

  TALabel = class(TCustomALabel)
  published
    property CanMoveHandle;
    property FocusControl;
    property ParagraphLine;
    property TextHorizontalAlign;
    property TextVerticalAlign;
    property Transparent;
    property BorderColor;
    property BorderWidth;
    property Color;
    property Enabled;
    property Font;
    property FontColor;
    property Height;
    //property Image;
    property ImageAlpha;
    property Left;
    property Margin;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property Text;
    property Top;
    property Visible;
    property Width;
  end;

  TALabelClass = class of TALabel;

implementation

uses
  PXT.Graphics, PXT.Types;

var
  XOffSet, YOffSet: Integer;

  { TCustomALabel }

procedure TCustomALabel.AssignTo(Dest: TPersistent);
begin
  ControlState := ControlState + [csReadingState];

  inherited AssignTo(Dest);

  if Dest is TCustomALabel then
    with TCustomALabel(Dest) do
    begin
      CanMoveHandle := Self.CanMoveHandle;
      TextHorizontalAlign := Self.TextHorizontalAlign;
      TextVerticalAlign := Self.TextVerticalAlign;
      FocusControl := Self.FocusControl;
      ParagraphLine := Self.ParagraphLine;
      Transparent := Self.Transparent;
    end;

  ControlState := ControlState - [csReadingState];
end;

procedure TCustomALabel.Click;
var
  Control: TAControl;
begin
  Control := Self.Handle.FindChildControl(FFocusControl, True);
  if Control <> nil then
    if Control is TWControl then
      TWControl(Control).SetFocus;

  inherited Click;
end;

constructor TCustomALabel.Create(AOwner: TComponent);
var
  Num: Integer;
begin
  ControlState := ControlState + [csCreating];

  inherited Create(AOwner);

  if (AOwner <> nil) and (AOwner <> Self) and (AOwner is TWControl) then
  begin
    // Auto generate name
    Num := 1;
    begin
      while AOwner.FindComponent('Label' + IntToStr(Num)) <> nil do
        Inc(Num);
      Name := 'Label' + IntToStr(Num);
    end;
  end;

  // Properties
  Left := 0;
  Top := 0;
  Width := 80;
  Height := 26;

  BorderColor := $80FFFFFF;
  BorderWidth := 0;
  Color.SetFillColor($FFA6CAF0, $FFA6CAF0, $FF4090F0, $FF4090F0);
  Font := 'tahoma10b';
  FontColor.SetFontColor(clWhite2);
  Margin := 2;
  Text := Name;
  Visible := True;

  // Fields
  FCanMoveHandle := True;
  FPLine := False;
  FHAlign := hCenter;
  FVAlign := vMiddle;
  FTransparent := True;

  ControlState := ControlState - [csCreating];
end;

destructor TCustomALabel.Destroy;
begin
  inherited Destroy;
end;

procedure TCustomALabel.MouseDown;
begin
  // Start move the form Handle
  if (FCanMoveHandle) and (Handle is TAForm) then
  begin
    if (Button = mbLeft) and (TAForm(Handle).CanMove) then
    begin
      XOffSet := X - TAForm(Handle).Left;
      YOffSet := Y - TAForm(Handle).Top;
      TAForm(Handle).IsMoving := True;
    end;
  end;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomALabel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  // Move the form Handle
  if (FCanMoveHandle) and (Handle is TAForm) then
  begin
    if TAForm(Handle).IsMoving = True then
    begin
      TAForm(Handle).Left := X - XOffSet;
      TAForm(Handle).Top := Y - YOffSet;
    end;
  end;

  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomALabel.MouseUp;
begin
  // Stop move the form Handle
  if (FCanMoveHandle) and (Handle is TAForm) then
  begin
    if (Button = mbLeft) and (TAForm(Handle).IsMoving) then
      TAForm(Handle).IsMoving := False;
  end;

  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomALabel.Paint(DC: HDC);
var
  X, Y: Integer;
begin
  // Set initial values
  X := ClientLeft;
  Y := ClientTop;

  // Draw Border
  if BorderWidth > 0 then
  begin
    AEngine.Canvas.FillRect(FloatRect(X, Y, X + Width, Y + BorderWidth), BorderColor);
    AEngine.Canvas.FillRect(FloatRect(X, Y + BorderWidth, X + BorderWidth, Y + Height - BorderWidth), BorderColor);
    AEngine.Canvas.FillRect(FloatRect(X, Y + Height - BorderWidth, X + Width, Y + Height), BorderColor);
    AEngine.Canvas.FillRect(FloatRect(X + Width - BorderWidth, Y + BorderWidth, X + Width, Y +
      Height - BorderWidth), BorderColor);
  end;

  // Draw Background
  if not FTransparent then
  begin
    if AImage.Initialized then
    begin
    {
      AEngine.Canvas.UseTexturePx(AImage,
        pxBounds4(0 + BorderWidth, 0 + BorderWidth,
          AImage.Width - (BorderWidth * 2),
          AImage.Height - (BorderWidth * 2)));
      AEngine.Canvas.TexMap(pRect4(Rect(X + BorderWidth, Y + BorderWidth,
            X + Width - BorderWidth, Y + Height - BorderWidth)),
        cAlpha4(ImageAlpha), deNormal);
     }
      var TexCoord := Quad(0 + BorderWidth, 0 + BorderWidth, AImage.Parameters.Width - (BorderWidth
        * 2), AImage.Parameters.Height - (BorderWidth * 2));
      AEngine.Canvas.Quad(AImage, Quad(IntRectBDS(X + BorderWidth, Y + BorderWidth, X + Width -
        BorderWidth, Y + Height - BorderWidth)), TexCoord, $FFFFFFFF);
    end
    else
    begin
      AEngine.Canvas.FillRect(FloatRect(X + BorderWidth, Y + BorderWidth, X + Width - BorderWidth, Y +
        Height - BorderWidth), cardinal(Color));
    end;
  end;

  // Draw Text
  {
  if AFont <> nil then
  begin
    if Text <> '' then
      AFont.TextRectEx(Point2(X + BorderWidth + Margin,
          Y + BorderWidth + Margin+1),
        Point2(Width - (BorderWidth * 2) - (Margin * 2),
          Height - (BorderWidth * 2) - (Margin * 2)), Text,
        cColor2(FontColor), 1.0, FHAlign, FVAlign, FPLine);
  end;
  }

  if FZFont <> nil then
  begin
    if Text <> '' then
    begin
      FZFont.Color := cColor4(FontColor.Top, FontColor.Top, FontColor.Bottom, FontColor.Bottom);
      FZFont.TextOutRect(DC, Point2(X + BorderWidth + Margin, Y + BorderWidth + Margin + 1), Point2(Width
        - (BorderWidth * 2) - (Margin * 2), Height - (BorderWidth * 2) - (Margin * 2)), Text, 0, 0,
        FPLine, GetZHAlign(FHAlign), GetZVAlign(FVAlign));
    end;
  end; { else
  if AFont <> nil then
  begin
    if Text <> '' then
      AFont.TextRectEx(Point2(X + BorderWidth + Margin,
          Y + BorderWidth + Margin+1),
        Point2(Width - (BorderWidth * 2) - (Margin * 2),
          Height - (BorderWidth * 2) - (Margin * 2)), Text,
        cColor2(FontColor), 1.0, FHAlign, FVAlign, FPLine);
  end;
       }
end;

procedure TCustomALabel.SetCanMoveHandle(Value: Boolean);
begin
  if FCanMoveHandle <> Value then
    FCanMoveHandle := Value;
end;

procedure TCustomALabel.SetFocusControl(Value: string);
begin
  if FFocusControl <> Value then
    FFocusControl := Value;
end;

procedure TCustomALabel.SetTransparent(Value: Boolean);
begin
  if FTransparent <> Value then
    FTransparent := Value;
end;

initialization
  RegisterClasses([TCustomALabel, TALabel]);

finalization
  UnRegisterClasses([TCustomALabel, TALabel]);

end.

