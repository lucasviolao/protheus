#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} OMSM0115
Ponto de entrada que vai pegar a informação da classificação de frete
no pedido de veículo e usará a mesma informação no documento de carga e romaneio de carga
@type function
@version  1.00
@author Lucas Silva
@since 24/09/2025
@return boolean, Retorno Booleano
/*/
User Function PPE32904()
	Local aArea            := FwGetArea()
	Local oModelNFS        := PARAMIXB[1]
	Local cNumPedido       := VRJ->VRJ_PEDIDO
	Local cNumeroTransacao := VV0->VV0_NUMTRA
	Local cNumRomaneio     := GW1->GW1_NRROM
	Local cClasseFrete     := ''
	Local cTipoVeiculo     := ''
	Local cCodProj         := ''
	Local cSegMod          := ''
	Local cChaveGW1 := ""
	Local lRetorno

	cChaveGW1 := PadR(oModelNFS:GetValue('GFEA044_GW1','GW1_FILIAL'),TamSx3('GW1_FILIAL')[1]) + ;
		PadR(oModelNFS:GetValue('GFEA044_GW1','GW1_CDTPDC'),TamSx3('GW1_CDTPDC')[1]) + ;
		PadR(oModelNFS:GetValue('GFEA044_GW1','GW1_EMISDC'),TamSx3('GW1_EMISDC')[1]) + ;
		PadR(oModelNFS:GetValue('GFEA044_GW1','GW1_SERDC') ,TamSx3('GW1_SERDC')[1]) + ;
		PadR(oModelNFS:GetValue('GFEA044_GW1','GW1_NRDC')  ,TamSx3('GW1_NRDC')[1])

	cQryVRK := "SELECT * FROM " + RetSQLName("VRK") + " " + ;
		"WHERE D_E_L_E_T_ = ' ' " + ;
		"AND VRK_FILIAL = '" + FWxFilial('VRK') + "' " + ;
		"AND VRK_PEDIDO = '" + cNumPedido + "' " + ;
		"AND VRK_NUMTRA = '" + cNumeroTransacao + "'"
	TCQuery cQryVRK New Alias "QRY_VRK"

	If (!QRY_VRK->(Eof()))
		cClasseFrete := QRY_VRK->VRK_XCDCFR
		cSegMod      := AllTrim(QRY_VRK->VRK_SEGMOD)

		If (Len(cSegMod) >= 10)
			cCodProj := SubStr(cSegMod, 5, 4)
		Else
			cCodProj := AllTrim(QRY_VRK->VRK_GRUMOD)
		EndIf

		cQryZ40 := "SELECT * FROM " + RetSQLName("Z40") + " " + ;
			"WHERE D_E_L_E_T_ = ' ' " + ;
			"AND Z40_CDPROJ = '" + cCodProj + "'"
		TCQuery cQryZ40 New Alias "QRY_Z40"

		If (!QRY_Z40->(Eof()))
			cTipoVeiculo := QRY_Z40->Z40_CDTPVC
		EndIf
		QRY_Z40->(DbCloseArea())
	EndIf
	QRY_VRK->(DbCloseArea())

	If (!Empty(cClasseFrete))

		DbSelectArea("GW1")
		GW1->(DbSetOrder(1))
		If (GW1->(MsSeek(cChaveGW1)))
			GW1->GW1_ROMTV := cTipoVeiculo
			GW1->GW1_ROMCF := cClasseFrete
		EndIf
		GW1->(DbCloseArea())

		DbSelectArea("GWN")
		GWN->(DbSetOrder(1))
		If (GWN->(MsSeek(AvKey(FWxFilial("GWN"), "GWN_FILIAL") + AvKey(cNumRomaneio, "GWN_NRROM"))))
			GWN->GWN_CDTPVC := cTipoVeiculo
			GWN->GWN_CDCLFR := cClasseFrete
		EndIf
		GWN->(DbCloseArea())


	EndIf

	oModelNFS:Deactivate()
	oModelNFS:Destroy()
	oModelNFS := Nil
	FwRestArea(aArea)

Return lRetorno
