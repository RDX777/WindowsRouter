unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, strutils, unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckGroup1: TCheckGroup;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1Enter(Sender: TObject);
    procedure LabeledEdit2Enter(Sender: TObject);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    function verservico(): Boolean;
    procedure criarini;
    procedure Pegar_Nome_Redes(Tipo: String);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.criarini;
 var
   arq: TextFile;
   CaminhoTXT: String;
begin
  CaminhoTXT:= GetEnvVarValue('AppData')+ '\Microsoft\Windows\Start Menu\Programs\Startup\IniWiFi.bat';

  AssignFile(arq, pchar(CaminhoTXT));
  Rewrite(arq);

  WriteLn (arq, '@echo off');
  WriteLn (arq, 'netsh wlan start hostednetwork');
  WriteLn (arq, 'exit');

  CloseFile(arq);

end;

procedure TForm1.Pegar_Nome_Redes(Tipo: String);
Var
  Nome_Redes: TStringList;
  i: Integer;
begin

  Nome_Redes := TStringList.Create;
  Nome_Redes.Delimiter := ' ';
  Nome_Redes.QuoteChar := '|';
  Nome_Redes.DelimitedText := Execomando('cmd /c cscript ' + ExtractFilePath(ParamStr(0)) + 'Names_Conn.vbs "' + Tipo + '"');

  if Tipo = 'NotHosted' then
  Begin
  for i := 15 to Nome_Redes.Count-1 do
    if AnsiContainsStr(Nome_Redes[i], 'Conex') then
     ComboBox1.Items.Add('Conexão ' + Copy(pchar(Nome_Redes[i]), 8, strlen(pchar(Nome_Redes[i]))) )
    else
     ComboBox1.Items.Add(Nome_Redes[i]);
  end
  else if  Tipo = 'Hosted' then
  begin
    for i := 15 to Nome_Redes.Count-1 do
    if AnsiContainsStr(Nome_Redes[i], 'Conex') then
     Label3.Caption := 'Conexão ' + Copy(pchar(Nome_Redes[i]), 8, strlen(pchar(Nome_Redes[i])))
    else
     Label3.Caption := Nome_Redes[i];
  end;
  Nome_Redes.Free;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 if Label1.Visible = True then
  Label1.Visible:= False
 else
  Label1.Visible:=True;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if (LabeledEdit1.text <> 'Digite a senha da rede...') and (LabeledEdit2.Text <> 'Digite o nome da rede...') then
       Button1.Enabled:=True;
end;

function TForm1.verservico(): Boolean;
begin
   if Execomando('cmd /c sc query WlanSvc | find "4  RUNNING"') = '' then
  begin

    Button3.Enabled:= True;

    CheckGroup1.Controls[1].Enabled:= True;

    Label1.Font.Color:=clRed;
    Label1.Caption:='WlanSvc não esta em execução';

    Timer1.Enabled:=True;

    Result:= True;

  end
   else
   begin
    Button3.Enabled:= False;

    CheckGroup1.Controls[1].Enabled:= False;

    Label1.Font.Color:=clDefault;
    Label1.Caption:='WlanSvc esta em execução';

    Timer1.Enabled:=False;

    Result:= False;

   end;

end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if LabeledEdit1.Text <> 'Digite a senha da rede...' then
   if CheckBox1.Checked = True then
     LabeledEdit1.EchoMode:= emNormal
   else
     LabeledEdit1.EchoMode:= emPassword ;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   MessageDlg(Execomando('cmd /c netsh wlan stop hostednetwork'), mtConfirmation, [mbOk], 0);

     ExecutarWindows('cscript', '"' + ExtractFilePath(ParamStr(0)) + 'Share_Conn.vbs" "' + ComboBox1.Items[ComboBox1.itemindex] + '" False');

  Label3.Caption:='Conexão...';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  MessageDlg(Execomando('cmd /c sc start WlanSvc'), mtConfirmation, [mbOk], 0);

  if CheckGroup1.Checked[1] = True then
    MessageDlg(Execomando('cmd /c sc config WlanSvc start=auto'), mtConfirmation, [mbOk], 0);

  Timer1.Enabled:=False;

  verservico();
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  MessageDlg(Execomando('cmd /c netsh wlan start hostednetwork'), mtConfirmation, [mbOk], 0);

  Pegar_Nome_Redes('Hosted');

     if ComboBox1.Items[ComboBox1.itemindex] <> 'Sem Compartilhamento' then
      begin
      ExecutarWindows('cscript', '"' + ExtractFilePath(ParamStr(0)) + 'Share_Conn.vbs" "' + ComboBox1.Items[ComboBox1.itemindex] + '" True');
      end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  MessageDlg(Execomando('cmd /c netsh wlan set hostednetwork mode=disallow'), mtConfirmation, [mbOk], 0);

   ExecutarWindows('cscript', '"' + ExtractFilePath(ParamStr(0)) + 'Share_Conn.vbs" "' + ComboBox1.Items[ComboBox1.itemindex] + '" False');

  Label3.Caption:='Conexão...';
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  DeleteFile(pchar(GetEnvVarValue('AppData')+ '\Microsoft\Windows\Start Menu\Programs\Startup\IniWiFi.bat'));

  ApagaRede();

  LabeledEdit1.EchoMode:=emNormal;
  LabeledEdit1.Text:= 'Digite a senha da rede...';
  LabeledEdit1.Font.Color:=clScrollBar;

  LabeledEdit2.Text:= 'Digite o nome da rede...';
  LabeledEdit2.Font.Color:=clScrollBar;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  campo1, campo2: string;
begin

  SalvaRede(LabeledEdit2.Text, LabeledEdit1.Text);

  if CheckGroup1.Checked[0] = True then
   criarini;

  ExecutarWindows('netsh', 'wlan stop hostednetwork');

  campo1:= '';
  campo2:= '';

  if Pos(' ',LabeledEdit2.Text) <> 0 then
   campo1:='"';

  if Pos(' ',LabeledEdit1.Text) <> 0 then
   campo2:='"';

  if (Length(LabeledEdit1.text) < 8) or (Length(LabeledEdit1.text) > 64) then
   begin
    MessageDlg('A senha deve ter de 8 a 63 caracteres!', mtwarning, [mbOk], 0);
    Exit;
   end;

  if (LabeledEdit2.Text <> '') and (LabeledEdit1.Text <> '') then
   begin
   if verservico() = True then
    if MessageDlg('Deseja executar WlanSvc agora?', mtwarning,  [mbYes, mbNo], 0) = 6 then
     Button3Click(Sender);

    MessageDlg(Execomando('cmd /c netsh wlan set hostednetwork mode=allow ssid='+ campo1 + LabeledEdit2.Text + campo1 +' key=' + campo2 + LabeledEdit1.Text + campo2 + ' keyUsage=persistent'), mtConfirmation, [mbOk], 0);

   if MessageDlg('Deseja iniciar a rede agora?', mtConfirmation,  [mbYes, mbNo], 0) = 6 then
    begin
    Button4Click(Sender);

     if ComboBox1.Items[ComboBox1.itemindex] <> 'Sem Compartilhamento' then
      begin
      ExecutarWindows('cscript', '"' + ExtractFilePath(ParamStr(0)) + 'Share_Conn.vbs" "' + ComboBox1.Items[ComboBox1.itemindex] + '" True');
      end;
    end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   verservico();

 if (LerRede.NomeRede <> '') and  (LerRede.Senha <> '') then
  begin
   LabeledEdit1.EchoMode:=emPassword;
   LabeledEdit2.Text:=LerRede.NomeRede;
   LabeledEdit1.Text:=LerRede.Senha;
  end;

 if Execomando('cmd /c whoami /priv /nh | find "SeTakeOwnershipPrivilege"') = '' then
  begin
   ShowMessage('Execute como administrador');
   Application.Terminate;
   Exit;
  end;

 Pegar_Nome_Redes('NotHosted');

 Pegar_Nome_Redes('Hosted');

end;

procedure TForm1.LabeledEdit1Enter(Sender: TObject);
begin
    if ((LabeledEdit1.Text = 'Digite a senha da rede...') or (LabeledEdit1.Text = LerRede.Senha)) and (LabeledEdit1.Font.Color <> clGrayText) then
    begin
      LabeledEdit1.clear;
      LabeledEdit1.Font.Color:=clDefault;

      if CheckBox1.Enabled = True then
       LabeledEdit1.EchoMode:=emPassword
       else
       LabeledEdit1.EchoMode:=emNormal;
    end;
end;

procedure TForm1.LabeledEdit2Enter(Sender: TObject);
begin
  if ((LabeledEdit2.Text = 'Digite o nome da rede...') or (LabeledEdit2.Text = LerRede.NomeRede)) and (LabeledEdit2.Font.Color <> clGrayText) then
    begin
      LabeledEdit2.clear;
      LabeledEdit2.Font.Color:=clDefault;
    end;
end;

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
  Label1.Caption:='';
end;

end.

