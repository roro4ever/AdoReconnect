program ProjRecnt;

uses
  Forms,
  ufrmMainAdo in 'ufrmMainAdo.pas' {frmMain},
  p_dm in 'p_dm.pas' {DM_data: TDataModule},
  p_FrmReConnect in 'p_FrmReConnect.pas' {frmReConnect},
  p_FrmAdoReconBase in 'p_FrmAdoReconBase.pas' {frmAdoReconBase},
  uFrmChild in 'uFrmChild.pas' {frmChild};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDM_data, DM_data);
  Application.CreateForm(TfrmReConnect, frmReConnect);
  Application.CreateForm(TfrmAdoReconBase, frmAdoReconBase);
  Application.Run;
end.
