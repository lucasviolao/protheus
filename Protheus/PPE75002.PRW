#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} PPE75002
@description Função que irá gerar um movimento bancário de débito na 
             conta corrente do concessionario
@type        function
@version     1.00
@author      ls809225
@since       15/08/2025
@return      boolean, Retorno Booleano 
/*/

User Function PPE75002()
	Local aArea     := FwGetArea()
	Local cIdOs     := SF1->F1_XIDOS
	Local nValor    := SF1->F1_VALBRUT
	Local cAgencia  := ''
	Local cBanco    := ''
	Local cConta    := ''
	Local cMoeda    := 'M1'
	Local cHistori  := 'ESTORNO GARANTIA'
	Local aMovBanc  := {}
	Local lRetorno  := .T.

	Private lMsErroAuto    := .F.

	cQrySA6 := "SELECT * FROM " + RetSQLName("SA6") + " " + ;
		"WHERE D_E_L_E_T_ = ' ' " + ;
		"AND A6_FILIAL = '" + Left(SF1->F1_FILIAL, 2) + "' " + ;
		"AND A6_AGENCIA = '" + StrTokArr(cIdOs, ";")[1] + "'"
	TCQuery cQrySA6 New Alias "QRY_SA6"

	If (!QRY_SA6->(Eof()))
		cConta   := QRY_SA6->A6_NUMCON
		cBanco   := QRY_SA6->A6_COD
		cAgencia := QRY_SA6->A6_AGENCIA
	EndIf
	QRY_SA6->(DbCloseArea())

	aMovBanc := {{"E5_FILIAL"  , SF1->F1_FILIAL  , Nil},;
		{"E5_DATA"    , dDataBase       , Nil},;
		{"E5_MOEDA"   , cMoeda          , Nil},;
		{"E5_VALOR"   , nValor          , Nil},;
		{"E5_NATUREZ" , SE2->E2_NATUREZ , Nil},;
		{"E5_BANCO"   , cBanco          , Nil},;
		{"E5_AGENCIA" , cAgencia        , Nil},;
		{"E5_CONTA"   , cConta          , Nil},;
		{"E5_ORIGEM"  , "FINA080"       , Nil},;
		{"E5_XIDOS"   , cIdOs           , Nil},;
		{"E5_CCUSTO"  , SD1->D1_CC      , Nil},;
		{"E5_ITEMD"   , SD1->D1_ITEMCTA , Nil},;
		{"E5_HISTOR"  , cHistori        , Nil}}

	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aMovBanc,3)

	If lMsErroAuto
		MostraErro()
	EndIf

	FwRestArea(aArea)
Return lRetorno
