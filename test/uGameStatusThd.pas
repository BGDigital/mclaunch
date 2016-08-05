unit uGameStatusThd;

interface

uses
  Classes, Windows, TlHelp32, SysUtils;

type
  TGameStatusThd = class(TThread)
  private
    m_Handle: THandle;
    FEvent: THandle;
  protected
    procedure Execute; override;
  public
    constructor Create(aHandle: THandle);
  end;

implementation

var
  hGameWindow: HWND;    //ÓÎÏ·´°¿Ú¾ä±ú

function ProcessIdToName(PID:DWORD):string;
var
  hSnapshot:THandle;
  PE:PROCESSENTRY32;
begin
  Result:='';
  hSnapshot:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  pe.dwSize:= sizeof(PROCESSENTRY32);
  if Process32First(hSnapshot, pe) <> False then
  begin
    while (Process32Next(hSnapshot, pe)) do
    begin
      if (pe.th32ProcessID = PID) then
      begin
        Result:=pe.szExeFile;
        Break;
      end;
    end;
  end;
end;

function EnumWindowsProc_2(hwnd: HWND; lParam: LPARAM): Boolean; stdcall;
var
  buf: array[Byte] of Char;
  str: string;

  processID: Cardinal;
begin
  GetWindowText(hwnd, buf, SizeOf(buf));
  if buf <> '' then
  begin
    Str := buf;
    if LowerCase(Copy(str, 1, 9)) = 'minecraft' then
    begin
      GetWindowThreadProcessId(hwnd, processID);
      if (ProcessIdToName(processID) = 'java.exe') or (ProcessIdToName(processID) = 'javaw.exe') then
      begin
        hGameWindow := hwnd;
      end;
    end;
  end;
  Result := True;
end;

constructor TGameStatusThd.Create(aHandle: THandle);
begin
  // TODO -cMM: TGameStatus.Create default body inserted
  m_Handle := aHandle;
  FreeOnTerminate := True;
  FEvent:= CreateEvent(nil, false, true, 'MCMaster_Game_Launch_Status_XingfuQiu');
  inherited Create(False);
end;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TGameStatus.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TGameStatus }

procedure TGameStatusThd.Execute;
begin
  while True do
  begin
    WaitForSingleObject(FEvent, 1000);
    hGameWindow := 0;
    EnumWindows(@EnumWindowsProc_2, 0);
    if hGameWindow <> 0 then
    begin
      sendMessage(m_Handle, 3864, 0, 0);
      Break;
    end;
  end;
end;

end.
