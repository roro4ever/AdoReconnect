unit p_dm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  Db, ADODB, ExtCtrls, AppEvnts;

const

  {连接失败的错误号(SQLSERVER) 在简体版本下，显示不出最后一位}
  CONNECTABORT_SQLSERVER1 = '08S0 ';
  {连接失败的错误号(SQLSERVER)}
  CONNECTABORT_SQLSERVER2 = '08S01';
  {连接不上服务器的的错误号(SQLSERVER)}
  CONNECTFAULT_SQLSERVER = '08001';
  {TAdoQuery连接失败}
  ConnectFailed = '连接失败';
  {一般性网络错误}
  GeneralNetError = '一般性网络错误';

type

  // AdoConnection辅助类
  TAdoConnHelper = class
  private
    FBEnable: Boolean;
    FIReconnectCount: Integer;
    FIDisConnectCount: Integer;
    FStrAdoConnString: string;
    FAdoConn: TADOConnection;
    procedure SetAdoConn(AACon: TADOConnection);
    procedure OnAdoConnExecuteComplete(Connection: TADOConnection;
      RecordsAffected: Integer; const Error: Error; var EventStatus:
      TEventStatus;
      const Command: _Command; const Recordset: _Recordset);
    function IsConnected: Boolean;
    procedure CheckAndReconnect;
  public
    property IReconnectCount: Integer read FIReconnectCount;
    property IDisConnectCount: Integer read FIDisConnectCount;
    property AdoConn: TADOConnection read FAdoConn write SetAdoConn;
    property BIsConnected: Boolean read IsConnected;
    property StrAdoConn: string read FStrAdoConnString write FStrAdoConnString;
    property BEnable: boolean read FBEnable;
    function Connect(BShowError: Boolean = False): Boolean;
    procedure NotifyAll;
    constructor Create;
    destructor Destroy; override;
  end;

  TDM_data = class(TDataModule)
    ado_mydata: TADOConnection;
    qry_pub: TADOQuery;
    Qry_pub1: TADOQuery;
    aplctnvntsCommon: TApplicationEvents;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure aplctnvntsCommonException(Sender: TObject; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM_data: TDM_data;

  //全局连接字符串
  GlbConnectionStr: string;
  GlbAdoHelper: TAdoConnHelper;
  AppName: string;

implementation
uses p_FrmReConnect, Forms, p_FrmAdoReconBase;

{$R *.DFM}

procedure TDM_data.aplctnvntsCommonException(Sender: TObject; E: Exception);
begin
  // 如果是“一般性网络错误”、“连接失败”，又启用了断线重连，并且断线重连检测已经断开
  //则不再显示错误信息。以免挡住自动重连窗体
  if not GlbAdoHelper.BEnable then
  begin
    application.MessageBox(pchar('发现错误!' + #13 + '错误信息:' + e.Message),
      '注意', 16);
    exit;
  end;
  if not ((Pos(GeneralNetError, e.Message) > 0) or (Pos(ConnectFailed,
    e.Message)
    > 0)) then
  begin
    application.MessageBox(pchar('发现错误!' + #13 + '错误信息:' + e.Message),
      '注意', 16);
    exit;
  end;
end;

procedure TAdoConnHelper.CheckAndReconnect;
var
  I: Integer;
  Cname: string;
begin
  if not GlbAdoHelper.BEnable then
    Exit;
  if GlbAdoHelper.BIsConnected then
    exit;
  // 怀疑是AdoQuery的Bug
  // 目的：消除AdoQuery.Dataset.RecordsetState=[stExecuting]状态
  // 触发OnExecuteComplete事件的AdoQuery，
  // 在事件触发后，active=inactive, 而Dataset.RecordsetState=[stExecuting]，
  // 这会导致Query.open进入死循环，堆栈溢出。
  with FAdoConn do
  begin
    for I := 0 to DataSetCount - 1 do
    begin
      if (DataSets[I].Active = False) and (DataSets[I].RecordsetState =
        [stExecuting]) then
      begin
        if DataSets[I] is TADOQuery then
        begin
          Cname := DataSets[I].Name;
          if Pos('tmp', Cname) > 0 then
            TADOQuery(DataSets[I]).Free;
        end;
      end;
    end;
  end;
  if Assigned(frmReConnect) and frmReConnect.Active then
    exit;
  try
    if not Assigned(frmReConnect) then
      frmReConnect := TfrmReConnect.Create(Application);
    frmReConnect.ShowModal;
  finally
    FreeAndNil(frmReConnect);
  end;
  NotifyAll;
end;

procedure TDM_data.DataModuleCreate(Sender: TObject);
var
  I: integer;
begin
  ado_mydata.KeepConnection := True;
  //  ado_mydata.KeepConnection := False;
  ado_mydata.LoginPrompt := False;
  GlbConnectionStr :=
    'Provider=SQLOLEDB.1;Password=nwconfig;Persist Security Info=True;User ID=sa;'
    + 'Initial Catalog=testAdo;Data Source=192.168.10.3;Use Procedure for Prepare=1;'
    + 'Auto Translate=True;Packet Size=4096;Workstation ID=ZP01;'
    + 'Use Encryption for Data=False;Tag with column collation when possible=False';
  GlbAdoHelper := TAdoConnHelper.Create;
  GlbAdoHelper.StrAdoConn := GlbConnectionStr;
  AppName := 'xyz';
  //  AppName:='';
  if AppName = 'xyz' then
    GlbAdoHelper.AdoConn := ado_mydata
  else
    GlbAdoHelper.AdoConn := nil;
end;

procedure TDM_data.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(GlbAdoHelper);
end;

constructor TAdoConnHelper.Create;
begin
  inherited;
  FBEnable := False;
  FAdoConn := nil;
  FStrAdoConnString := '';
  FIReconnectCount := 0;
  FIDisConnectCount := 0;
end;

destructor TAdoConnHelper.Destroy;
begin
  FreeAndNil(FAdoConn);
  inherited;
end;

function TAdoConnHelper.IsConnected: Boolean;
var
  tmpStrError: string;
  I: Integer;
begin
  result := false;
  tmpStrError := '';
  for I := 0 to FAdoConn.Errors.Count - 1 do
  begin
    tmpStrError := tmpStrError + #13 + #10 + FAdoConn.Errors.Item[I].Description
      + '|'
      +
      inttostr(FAdoConn.Errors.Item[I].Number) + '|' +
      FAdoConn.Errors.Item[I].Source + '|' +
      FAdoConn.Errors.Item[I].SQLState + '|';
  end;
  FAdoConn.Errors.Clear;
  if
    (Pos(CONNECTABORT_SQLSERVER1, tmpStrError) > 0)
    or (Pos(CONNECTABORT_SQLSERVER2, tmpStrError) > 0)
    or (Pos(CONNECTFAULT_SQLSERVER, tmpStrError) > 0)
    or (Pos(ConnectFailed, tmpStrError) > 0)
    or (Pos(GeneralNetError, tmpStrError) > 0) then
  begin
    FIDisConnectCount := FIDisConnectCount + 1;
    Exit;
  end;
  result := True;
end;

procedure TAdoConnHelper.NotifyAll;
var
  AHandle: THandle;
begin
  // Msg to DM_Data
//  Application.ProcessMessages;
//  AHandle := AllocateHWnd(DM_data.WMAdoRestore);
//  PostMessage(AHandle, WM_ADOReCon, 0, 0);
//  DeallocateHWND(AHandle);
  // Msg to BaseForm
  Application.ProcessMessages;
  Ahandle := FindWindow(PAnsiChar('TFrmAdoReconBase'),
    pchar('frmAdoReconBase'));
  //  PostMessage(Ahandle, WM_ADOReCon, 0, 0);
  SendMessage(Ahandle, WM_ADOReCon, 0, 0);
end;

procedure TAdoConnHelper.OnAdoConnExecuteComplete(Connection: TADOConnection;
  RecordsAffected: Integer; const Error: Error; var EventStatus: TEventStatus;
  const Command: _Command; const Recordset: _Recordset);
var
  I: Integer;
  Cname: string;
begin
  //  if EventStatus = esErrorsOccured then
//    CheckAndReconnect;
  if not GlbAdoHelper.BEnable then
    Exit;
  if GlbAdoHelper.BIsConnected then
    exit;
  // 怀疑是AdoQuery的Bug
  // 目的：消除AdoQuery.Dataset.RecordsetState=[stExecuting]状态
  // 触发OnExecuteComplete事件的AdoQuery，
  // 在事件触发后，active=inactive, 而Dataset.RecordsetState=[stExecuting]，
  // 这会导致Query.open进入死循环，堆栈溢出。
  with FAdoConn do
  begin
    for I := 0 to DataSetCount - 1 do
    begin
      if (DataSets[I].Active = False) and (DataSets[I].RecordsetState =
        [stExecuting]) then
      begin
        if DataSets[I] is TADOQuery then
        begin
          //          Cname := DataSets[I].Name;
          //          if Pos('tmp', Cname) > 0 then
          //            TADOQuery(DataSets[I]).Free;
        end;
      end;
    end;
  end;
  if Assigned(frmReConnect) and frmReConnect.Active then
    exit;
  try
    if not Assigned(frmReConnect) then
      frmReConnect := TfrmReConnect.Create(Application);
    frmReConnect.ShowModal;
  finally
    FreeAndNil(frmReConnect);
  end;
  NotifyAll;
end;

function TAdoConnHelper.Connect(BShowError: Boolean = False): Boolean;
var
  I: integer;
  BtryAgain: boolean;
  procedure OnOff;
  begin
    FAdoConn.Connected := False;
    FAdoConn.ConnectionString := FStrAdoConnString;
    FAdoConn.Connected := True;
  end;
begin
  if not FBEnable then
  begin
    //    result := True;
    exit;
  end;
  Result := False;
  BtryAgain := False;
  I := 0;
  repeat
    try
      OnOff;
      FAdoConn.Execute('select 1 "nettest"');
      BtryAgain := True;
    except
      on e: Exception do
      begin
        I := I + 1;
        if I > 3 then
        begin
          if BShowError then
            Application.MessageBox(PChar('TAdohelper.Connect函数连接数据库失败！'
              + e.Message),
              '错误', MB_OK + MB_ICONSTOP)
          else
            raise;
          Exit;
        end;
      end;
    end;
  until (BtryAgain);
  FIReconnectCount := FIReconnectCount + 1;
  Result := True;
end;

procedure TAdoConnHelper.SetAdoConn(AACon: TADOConnection);
begin
  if not Assigned(AACon) then
  begin
    FreeAndNil(FAdoConn);
    FBEnable := false;
    exit;
  end;
  {因为对于Persist Info=false 的 AACon 无法读出连接字符串，
  故ConnectionString 另外赋值}
  FAdoConn := AACon;
  FBEnable := True;
  // 赋予断线检测能力方法1
  FAdoConn.OnExecuteComplete := OnAdoConnExecuteComplete;
end;

end.
