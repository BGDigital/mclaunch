unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, uGameStatusThd;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label4: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Label3: TLabel;
    ComboBox2: TComboBox;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure GetGameRunStatus(var Message: TMessage); message 3864;
  public
    { Public declarations }
  end;
  function launch(aGamePath, aUserName, aMaxMemory, aJavaVer: String): Boolean; stdcall; external 'mclaunch.dll';
  
var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var
  re: Boolean;
  thd: TGameStatusThd;
begin
  Caption := '�������������';
  thd := TGameStatusThd.Create(Handle);
  re := launch(Edit1.Text, Edit2.Text, Edit3.Text, ComboBox2.Text);
  //ShowMessage(ifthen(re, 'True', 'False'));
  Caption := ifthen(re, 'True', 'False')
end;

procedure TForm1.GetGameRunStatus(var Message: TMessage);
begin
  ShowMessage('�յ���Ϣ��,֪����Ϸ����������');
  Application.Minimize;
end;

end.
