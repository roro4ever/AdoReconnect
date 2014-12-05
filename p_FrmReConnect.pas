unit p_FrmReConnect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, p_dm, IdBaseComponent, IdComponent,
  IdRawBase, IdRawClient, IdIcmpClient;

type
  TfrmReConnect = class(TForm)
    tmrHint: TTimer;
    Icmp: TIdIcmpClient;
    lblStatus: TLabel;
    lblDosth: TLabel;
    lstInfo: TListBox;
    lblHidden: TLabel;
    tmrPIng: TTimer;
    btnCloseAll: TBitBtn;

    procedure OnConnectSuccess(Sender: Tobject);
    procedure IcmpReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
    procedure lstInfoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrPIngTimer(Sender: TObject);
    procedure lblHiddenClick(Sender: TObject);
    procedure btnCloseAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure SwitchStatus(AStatus: string);
    function SplitString(pString: Pchar; psubString: PChar): TStringList;
  public
    { Public declarations }
    procedure Start;
  end;

var
  frmReConnect: TfrmReConnect;

implementation

const
  ICloseWaitSec = 1; // 自动关闭的等待时间
  StrFormTitle = '尝试重新连接数据库'; // 本窗口的Caption
  StatusConnecting = 'Connecting';
  StatusDisConnected = 'DisConnected';
  StatusConnected = 'Connected';
  FLostPacketRateLowLimit = 30;

var
  INowWaitSec: Integer;
  StrIP: string;
  FLostPacketRate: Double;
  IContiSucc:Integer;

{$R *.dfm}

function TfrmReConnect.SplitString(pString: Pchar; psubString: PChar): TStringList;
var
  nSize, SubStringSize: DWord;
  intI, intJ, intK: DWORD;
  ts: TStringList;
  curChar: Char;
  strString: string;
  strsearchSubStr: string;
begin
  nSize := strLen(pString);
  SubStringSize := strLen(PSubString);
  ts := TStringList.Create;
  strstring := '';
  inti := 0;
  while intI <= (nSize - 1) do
  begin
    if (nsize - inti) >= substringSize then
    begin
      if ((PString + intI)^ = pSubString^) then
      begin
        intk := inti;
        strSearchSubStr := '';
        curchar := (pstring + intk)^;
        strsearchSubStr := strSearchSubStr + Curchar;
        intk := intk + 1;
        for intj := 1 to SubStringSize - 1 do
        begin
          if ((pString + intk)^ = (PSubString + intj)^) then
          begin
            curchar := (pstring + intk)^;
            intk := intk + 1;
            strsearchSubStr := strSearchSubStr + Curchar;
          end
          else
          begin
            inti := intk;
            strString := strString + strSearchSubStr;
            break; //不匹配 退出FOR
          end;
        end;
        if (intJ = substringSize) or (SubStringSize = 1) then
        begin
          inti := intk;
          ts.add(strstring);
          strstring := '';
        end;
      end
      else
      begin
        curChar := (pString + inti)^;
        strstring := strstring + curchar;
        inti := inti + 1;
      end;
      if inti = nsize then
      begin
        ts.Add(strString);
        strString := '';
      end;
    end
    else
    begin //将剩下的字符给作为一个字符串复制给字符串集合
      strString := strstring + string(pString + inti);
      ts.Add(strstring);
      inti := nsize;
    end;
  end;
  Result := ts;
end;

procedure TfrmReConnect.btnCloseAllClick(Sender: TObject);
begin
  if Application.MessageBox('点击“是”后将退出终止整个程序的运行。' + #13#10 
    + '您确定要这么做吗？', '提示', MB_YESNO + MB_ICONQUESTION +
    MB_DEFBUTTON2) = IDYES then
  begin
    Application.Terminate;
  end;
end;

procedure TfrmReConnect.FormCreate(Sender: TObject);
begin
  btnCloseAll.Visible:=False;
  tmrPIng.Enabled:=False;
  tmrPIng.Interval := 250;
  LstInfo.Clear;
  StrIP := SplitString(PChar(GlbConnectionStr), ';').Values['Data Source'];
  if StrIP = '.' then
    StrIP := '127.0.0.1';
  Icmp.Host := StrIP;
  IContiSucc := 0;
  self.Caption := StrFormTitle;
  Icmp.ReceiveTimeout := 1000;
end;

procedure TfrmReConnect.FormShow(Sender: TObject);
begin
  //SwitchStatus(StatusDisConnected);
  Start;
end;

procedure TfrmReConnect.IcmpReply(ASender: TComponent;
  const AReplyStatus: TReplyStatus);
var
  Msg: string;
  Tm: integer;
begin
  with AReplyStatus do
  begin
    Msg := ' ReplyFrom=' + StrIP;
    Msg := Msg + ' RecvBytes=' + IntToStr(BytesReceived); //返回字节数
    Msg := Msg + ' TTL=' + IntToStr(TimeToLive); //返回生存时间
    Tm := MsRoundTripTime; //返回执行时间
    if Tm < 1 then
      Tm := 1;
    Msg := Msg + ' Time=' + IntToStr(Tm) + 'ms';
    LstInfo.Items.Add(msg); //保存信息
    if lstInfo.Items.Count > 5 then
      lstInfo.Items.Delete(0);
    Lstinfo.ItemIndex := Lstinfo.Items.Count - 1;
    //无数据返回
    if (BytesReceived = 0) or (TimeToLive = 0) then
      IContiSucc := 0
    else
      IContiSucc := IContiSucc + 1;
    // 当切换到正在连接，或连接成功的状态时，会停止Ping，以免再次触发重连。
    if IContiSucc = 1 then
      SwitchStatus(StatusConnecting)
    else
      SwitchStatus(StatusDisConnected);
  end;
end;

procedure TfrmReConnect.lblHiddenClick(Sender: TObject);
begin
  btnCloseAll.Visible:=not btnCloseAll.Visible;
end;

procedure TfrmReConnect.lstInfoClick(Sender: TObject);
begin
end;

{-------------------------------------------------------------------------------
  过程名:    TfrmReConnect.SwithDisplay
  解释:      根据参数切换lable的显示
  日期:      2014.07.10
  参数:      AStatus: string   断线状态；正在连接; 连接成功
  返回值:    无
-------------------------------------------------------------------------------}

procedure TfrmReConnect.Start;
begin
  SwitchStatus(StatusDisConnected);
end;

procedure TfrmReConnect.SwitchStatus(AStatus: string);
begin
  if AStatus = StatusDisConnected then
  begin
    lblStatus.Caption := '客户端已失去与数据库服务器的连接';
    lblDosth.Caption := '正在测试是否可连接数据库服务器...';
    tmrHint.Enabled := false;
    tmrHint.OnTimer := nil;
    tmrPIng.Enabled := True;
  end;
  if AStatus = StatusConnecting then
  begin
    lblStatus.Caption := '客户端已失去与数据库服务器的连接';
    lblDosth.Caption := '尝试重新连接数据库中...';
    tmrHint.Enabled := False;
    tmrHint.OnTimer := nil;
    tmrPIng.Enabled := False;
    if GlbAdoHelper.Connect() then
      SwitchStatus(StatusConnected)
    else
      SwitchStatus(StatusDisConnected);
  end;
  if AStatus = StatusConnected then
  begin
    INowWaitSec := ICloseWaitSec;
    tmrHint.Enabled := True;
    tmrHint.OnTimer := OnConnectSuccess;
    tmrPIng.Enabled := False;
  end;
end;

procedure TfrmReConnect.tmrPIngTimer(Sender: TObject);
begin
  try
    frmReConnect.Icmp.Ping;
  except
  end;
end;

procedure TfrmReConnect.OnConnectSuccess(Sender: Tobject);
var
  tmphandle: Thandle;
begin
  INowWaitSec := INowWaitSec - 1;
  lblStatus.Caption := '连接数据库成功！';
  lblDosth.Caption := IntToStr(ICloseWaitSec) +
    '秒钟后本窗口自动关闭。';
  if INowWaitSec = 0 then
  begin
    tmrHint.Enabled := False;
    Self.Close;
  end;
end;

end.
