unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows, Process, registry;

type NomeRedeSenha = Record
      Nomerede : String;
      Senha: String;
End;

Function ExecutarWindows(Executavel: String; Parametros: String): boolean;
Function Execomando(Comando: String): String;
function GetEnvVarValue(const VarName: string): string;
function SalvaRede(NomeRede, Senha: String): String;
function LerRede(): NomeRedeSenha;
function ApagaRede(): boolean;

implementation

function ExecutarWindows(Executavel: String; Parametros: String): boolean;
var
  execwin: TProcess;
begin
  execwin:=TProcess.Create(nil);
  execwin.Executable:=Executavel;
  execwin.Parameters.Add(Parametros);
  execwin.Options:=[poNewConsole];
  execwin.ShowWindow:=swoHide;
  execwin.Execute;

end;

Function Execomando(Comando: String): String; // Inicio Execomando
Const
  C_BUFSIZE = 4096;
var
  Hbk: TProcess;
  Buffer: pointer;
  SStream: TStringStream;
  nread: longint;
  dados : String;
begin
     Hbk := TProcess.Create(nil);

  // Replace the line below with your own command string
  Hbk.CommandLine := Comando;
  //
  Hbk.ShowWindow:= swoHIDE;
  Hbk.Options := [poUsePipes];
  Hbk.Execute;

  // Prepare for capturing output
  Getmem(Buffer, C_BUFSIZE);
  SStream := TStringStream.Create('');

  // Start capturing output
  while Hbk.Running do
  begin
    nread := Hbk.Output.Read(Buffer^, C_BUFSIZE);
    if nread = 0 then
      sleep(100)
    else
      begin
        // Translate raw input to a string
        SStream.size := 0;
        SStream.Write(Buffer^, nread);
          dados := dados + SStream.DataString;
      end;
  end;

  // Capture remainder of the output
  repeat
    nread := Hbk.Output.Read(Buffer^, C_BUFSIZE);
    if nread > 0 then
    begin
      SStream.size := 0;
      SStream.Write(Buffer^, nread);
        dados := dados + SStream.DataString;
    end
  until nread = 0;

  // Clean up
  Hbk.Free;
  Freemem(buffer);
  SStream.Free;
// Retorna resultado
Result := dados;
  End; //Fim Execomando

function GetEnvVarValue(const VarName: string): string;
var
  BufSize: Integer;
begin
  BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
  if BufSize > 0 then
  begin
    SetLength(Result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName),
      PChar(Result), BufSize);
  end
  else
    Result := '';
end;

function SalvaRede(NomeRede, Senha: String): String;
var
Registro:TRegistry;
begin

Registro := TRegistry.Create;
Registro.RootKey:=HKEY_CURRENT_USER;

 if registro.OpenKey('SOFTWARE\WIFI',true) then
   begin
    Registro.WriteString('NomeRede',NomeRede);
    Registro.WriteString('Senha',Senha);
   end;

registro.CloseKey;

registro.Free;

end;

function LerRede(): NomeRedeSenha;
Var
Registro:TRegistry;
begin

Registro := TRegistry.Create;
Registro.RootKey:=HKEY_CURRENT_USER;

  if registro.OpenKey('SOFTWARE\WIFI',true) then
  begin
    Result.NomeRede := Registro.ReadString('NomeRede');
    Result.Senha := Registro.ReadString('Senha');
  end;

  registro.CloseKey;

  registro.Free;

end;

function ApagaRede: boolean;
Var
 Registro:TRegistry;
begin

  Registro := TRegistry.Create;
  Registro.RootKey:=HKEY_CURRENT_USER;

    if registro.OpenKey('SOFTWARE',true) then
     begin
     Registro.DeleteKey('WIFI');
     Result:=False;
     end;

    registro.CloseKey;

    registro.Free;

end;

end.

