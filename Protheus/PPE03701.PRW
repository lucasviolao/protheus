#include "totvs.ch"
#include "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} PPE03701
Ponto de entrada utilizado para, no momento de carga de controle em terceiros
pegar as informações de numero e serie da NF que vier informado no pedido de venda.
@type user function
@author Lucas Silva
@since 08/09/2025
@version 1.00
@return logical, Retorno Lógico
/*/
User Function PPE03701()
	Local aArea    := FwGetArea()
	Local lRetorno := .T.
    //Local nNumProv := 0  

	If (!Empty(SC5->C5_XNOTALG) .AND. !Empty(SC5->C5_XSERIEL))
		//nNumProv := Val(SC5->C5_XNOTALG)
		//If (GetMV("MV_TPNRNFS") == "3")
		//SetMV("MV_TPNRNFS", "1")
		cNumero := SC5->C5_XNOTALG
		cSerie  := SC5->C5_XSERIEL
		//EndIf


	EndIf

	FwRestArea(aArea)
Return lRetorno
