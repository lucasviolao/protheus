#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} PPE32903
Função que irá atribuir a classificação de frete, caso informada no pedido de veículo, 
no Documento de Carga
@type function
@version  1.00
@author ls809225
@since 21/05/2025
@return boolean, Retorno Booleano
/*/
User Function PPE32903()
	Local oModelGW8        := PARAMIXB[1]
	Local aArea            := FwGetArea()
	Local cNumPedido       := VRJ->VRJ_PEDIDO
	Local cNumeroTransacao := VV0->VV0_NUMTRA
	Local cClasseFrete     := ''
	Local cQryVRK          := ''
	Local lRetorno         := .T.


	cQryVRK := "SELECT * FROM " + RetSQLName("VRK") + " " + ;
		"WHERE D_E_L_E_T_ = ' ' " + ;
		"AND VRK_FILIAL = '" + FWxFilial('VRK') + "' " + ;
		"AND VRK_PEDIDO = '" + cNumPedido + "' " + ;
		"AND VRK_NUMTRA = '" + cNumeroTransacao + "'"
	TCQuery cQryVRK New Alias "QRY_VRK"

	If !QRY_VRK->(Eof())
		cClasseFrete := QRY_VRK->VRK_XCDCFR
	EndIf

	If (AvKey(oModelGW8:GetValue('GW8_CDCLFR'), "GW8_CDCLFR") != AvKey(cClasseFrete, VRK_XCDCFR))
		oModelGW8:SetValue("GW8_CDCLFR", cClasseFrete)
	EndIf
	QRY_VRK->(DbCloseArea())

	FwRestArea(aArea)
Return lRetorno
