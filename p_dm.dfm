object DM_data: TDM_data
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 499
  Width = 1111
  object ado_mydata: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=nwconfig;Persist Security Info=True' +
      ';User ID=sa;Initial Catalog=testAdo;Data Source=192.168.10.3;Use' +
      ' Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Wo' +
      'rkstation ID=ZP01;Use Encryption for Data=False;Tag with column ' +
      'collation when possible=False'
    ConnectionTimeout = 30
    KeepConnection = False
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 201
    Top = 127
  end
  object qry_pub: TADOQuery
    Connection = ado_mydata
    Parameters = <>
    Left = 289
    Top = 127
  end
  object Qry_pub1: TADOQuery
    Connection = ado_mydata
    Parameters = <>
    Left = 425
    Top = 119
  end
  object aplctnvntsCommon: TApplicationEvents
    OnException = aplctnvntsCommonException
    Left = 507
    Top = 135
  end
end
