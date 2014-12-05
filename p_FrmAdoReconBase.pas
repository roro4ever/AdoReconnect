unit p_FrmAdoReconBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

const
  WM_ADOReCon = WM_USER + 120;

type
  TfrmAdoReconBase = class(TForm)
  private
    procedure BroadMsgtoAllChildren(AMsg: Cardinal; AwParam, AlParam: Integer);
    procedure WMAdoRestore(var message: TMessage); message WM_ADOReCon;
  protected
  public
  end;

var
  frmAdoReconBase: TfrmAdoReconBase;
  CTestInfo: string;

implementation

{$R *.dfm}

{ TfrmAdoReconBase }

procedure TfrmAdoReconBase.BroadMsgtoAllChildren(AMsg: Cardinal; AwParam,
  AlParam: Integer);
var
  I: integer;
  CfrmName, CfrmClassName: string;
  AHandle: THandle;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    if (Screen.Forms[I].InheritsFrom(Self.ClassType)) and (Screen.Forms[I] <>
      Self) then
    begin
      CfrmName := Screen.Forms[I].Name;
      CfrmClassName := Screen.Forms[I].ClassName;
      Ahandle := FindWindow(PAnsiChar(CfrmClassName),
        pchar(CfrmName));
//      Screen.Forms[I].Perform(AMsg, AwParam, AlParam);
      SendMessage(AHandle,AMsg, AwParam, AlParam);
    end;
  end;
end;

procedure TfrmAdoReconBase.WMAdoRestore(var message: TMessage);
begin
  CTestInfo := self.ClassName;
  BroadMsgtoAllChildren(WM_ADOReCon, 0, 0);
end;

end.
