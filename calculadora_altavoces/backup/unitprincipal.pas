unit UnitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

const nro_lineas = 20;

type

  { TForm1 }

  TLinea = array of Single;
  TCircuito = array of TLinea;
  TForm1 = class(TForm)
    btnNuevaLinea: TButton;
    btnNuevaResistencia: TButton;
    btnLimpiar: TButton;
    edtOhmios: TEdit;
    GroupBox1: TGroupBox;
    lstLineas: TListBox;
    PanelResultado: TPanel;
    procedure btnLimpiarClick(Sender: TObject);
    procedure btnNuevaLineaClick(Sender: TObject);
    procedure btnNuevaResistenciaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    circuito_calculos : TCircuito;
    nro_elementos : Integer;
    linea_seleccionada : Integer;
    resistenciaCircuito : Single;
    procedure MostrarLineas();
    procedure InsertarEnLineaResistencia(linea : Integer;valor:Single);
    function CalcularResistencia() : Single;
    procedure MostrarResistencia();
  public
    Destructor Destroy; overload;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i : Integer;
begin
     SetLength(circuito_calculos,nro_lineas);
     nro_elementos:=0;
     for i:=0 to nro_lineas do
     begin
       SetLength(circuito_calculos[i],nro_lineas);
     end;
end;

destructor TForm1.Destroy;
begin
     SetLength(circuito_calculos,0);
end;

procedure TForm1.btnNuevaLineaClick(Sender: TObject);
begin
  if (nro_elementos<nro_lineas) then
  begin
       Inc(nro_elementos);
  end;
  MostrarLineas();
end;

procedure TForm1.btnLimpiarClick(Sender: TObject);
var
  i: Integer;
begin
  lstLineas.Items.Clear;
  begin
     SetLength(circuito_calculos,0);
     SetLength(circuito_calculos,nro_lineas);
     nro_elementos:=0;
     for i:=0 to nro_lineas do
     begin
       SetLength(circuito_calculos[i],0);
       SetLength(circuito_calculos[i],nro_lineas);
     end;
  end;
  resistenciaCircuito:=0.0;
  MostrarResistencia();
end;

procedure TForm1.btnNuevaResistenciaClick(Sender: TObject);
var
  strOhmios : string;
  valorResistencia : Single;
begin
  if (linea_seleccionada>-1) and (nro_elementos>0) then
  begin
  strOhmios := edtOhmios.Text;
  if (TryStrToFloat(strOhmios,valorResistencia)) then
  begin
       if (valorResistencia>0) then
       begin
             linea_seleccionada:=lstLineas.ItemIndex;
             InsertarEnLineaResistencia(lstLineas.ItemIndex,valorResistencia);
       end;
  end;
  lstLineas.SetFocus;
  lstLineas.ItemIndex:=linea_seleccionada;
  CalcularResistencia();
  MostrarResistencia();
  end;
end;

procedure TForm1.InsertarEnLineaResistencia(linea : Integer;valor:Single);
var
  lineaAModificar : TLinea;
  idx : Integer;
begin
  lineaAModificar:=circuito_calculos[linea];
  idx:=0;
  while (lineaAModificar[idx]<>0) do
  begin
       Inc(idx);
  end;
  lineaAModificar[idx]:=valor;
  MostrarLineas();
end;

procedure TForm1.MostrarLineas();
var i,j : Integer;
    linea_aux : TLinea;
    strRes : string;
    strLinea : string;
begin
  lstLineas.Items.Clear;
  lstLineas.Items.BeginUpdate;
     for i:=1 to nro_elementos do
     begin
       strRes:='';
       strLinea:='';
       linea_aux:=self.circuito_calculos[i-1];
        // Mostrar las Resistencias.

       for j:=1 to nro_lineas do
       begin
            if (linea_aux[j-1]>0) then
               strRes:=strRes + FloatToStr(linea_aux[j-1])+ ',';
       end;

       strLinea:='Linea ' + IntToStr(i) + ' : ' + strRes;
       lstLineas.Items.Add(strLinea);
     end;
     lstLineas.Items.EndUpdate;

end;

function TForm1.CalcularResistencia : Single;
var
    i,j : Integer;
    linea_aux : TLinea;
    sumaLinea : Single;
    sumasEnLineas : array  of Single;
    sumaInvertida : Single;
begin
     sumaInvertida:=0.0;
     SetLength(sumasEnLineas,nro_lineas);
     // Calculamos la resistencia del circuito de cada linea sumando.
     for i:=1 to nro_elementos do
     begin
          linea_aux:=circuito_calculos[i-1];
          sumaLinea:=0.0;
          for j:=0 to nro_lineas do
          begin
               sumaLinea:=sumaLinea+linea_aux[j];
          end;
          sumasEnLineas[i-1]:=sumaLinea;
          // Sumamos la resistencia invertida
          if (sumaLinea>0.0) then
             sumaInvertida:=sumaInvertida + (1/sumaLinea);
     end;
     resistenciaCircuito:=1/sumaInvertida;
     return resistenciaCircuito;
end;

procedure TForm1.MostrarResistencia();
begin
     PanelResultado.Caption:=FloatToStr(resistenciaCircuito) + ' Ohmios';
end;
end.

