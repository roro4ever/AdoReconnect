unit uFrmChild;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, ADODB, StdCtrls, Buttons, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid,p_dm,p_FrmAdoReconBase, Grids, DBGrids;

type
  TfrmChild = class(TfrmAdoReconBase)
    btnDataChild: TBitBtn;
    qryChild: TADOQuery;
    dsChild: TDataSource;
    dbgrd1: TDBGrid;
    lbl1: TLabel;
    procedure btnDataChildClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMAdoRestore(var message: TMessage); message WM_ADOReCon;
    procedure ReadData;
    procedure ReadData2;    
  public
    { Public declarations }
  end;

var
  frmChild: TfrmChild;

implementation

{$R *.dfm}

procedure TfrmChild.btnDataChildClick(Sender: TObject);
begin
  // 如果用ReadData，断线重连后就会报错。
  ReadData;
  // 如果用ReadData2，断线重连后就没有报错。  
//  ReadData2;
end;

procedure TfrmChild.ReadData;
begin
  with DM_data.qry_pub do
  begin
    close;
    Connection:=DM_data.ado_mydata;
    SQL.Text:='SELECT * FROM TBadoChild';
    try
      Open;
    except
    end;
  end;
  dsChild.DataSet:=qryChild;
  with qryChild do
  begin
    close;
    SQL.Text:='SELECT * FROM TBadoChild';
    try
      Open;
    except
    end;
  end;
end;

procedure TfrmChild.ReadData2;
begin
  dsChild.DataSet:=qryChild;
  with qryChild do
  begin
    close;
    SQL.Text:='SELECT * FROM TBadoChild';
    try
      Open;
    except
    end;
  end;
end;

procedure TfrmChild.WMAdoRestore(var message: TMessage);
begin
  ReadData;
end;

end.
