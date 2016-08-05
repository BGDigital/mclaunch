unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils;

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
begin
  Caption := 'Âó¿éÆô¶¯Æ÷²âÊÔ';
  re := launch(Edit1.Text, Edit2.Text, Edit3.Text, ComboBox2.Text);
  //ShowMessage(ifthen(re, 'True', 'False'));
  Caption := ifthen(re, 'True', 'False')
end;

end.
