unit Fm_Address;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,
  Vcl.StdCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, StdCtrls, Classes,
  Controls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    XMLDocument1: TXMLDocument;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  url: String;
begin
  url := 'http://api.map.baidu.com/geocoder/v2/?ak=nWfyG2kNOMaPLaa1okpVYVSunbguOT0P'
        +'&callback=renderReverse&location=31.22336999743,121.53840596111'
        +'output=xml&pois=1';
  XmlDocument1.LoadFromFile(url);
  memo1.Lines:=XmlDocument1.XML;
  memo2.Lines.Add(XmlDocument1.DocumentElement.ChildNodes['result'].ChildNodes
       ['formatted_address'].NodeValue);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
 url: String;
begin

  url := 'http://api.map.baidu.com/geocoder/v2/?ak=nWfyG2kNOMaPLaa1okpVYVSunbguOT0P'
        +'&callback=renderOption&output=xml&address='+Trim(edit1.Text);
  xmlDocument1.LoadFromFile(url);
  memo1.Lines := XmlDocument1.XML;
  memo2.Lines.Add(Xmldocument1.DocumentElement.ChildNodes['result'].ChildNodes
          ['location'].ChildNodes['lat'].NodeValue);
  memo2.Lines.Add(Xmldocument1.DocumentElement.ChildNodes['result'].ChildNodes
          ['location'].ChildNodes['lng'].NodeValue);
end;

end.
