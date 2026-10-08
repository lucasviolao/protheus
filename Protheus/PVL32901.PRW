#include 'totvs.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include 'fwmvcdef.ch'
#include 'prtopdef.ch'

/*/{Protheus.doc} PVL32901
Validação inserida no campo VRJ_LOJENT X3_VLDUSER para gatilhar
os campos de TRANSPORTADORA e TIPO DE FRETE 
@type user function
@author Lucas Silva
@since 17/10/2025
@version 1.00
/*/
User Function PVL32901()
	Local cTransp  := ''
	Local cTpFret  := ''
	Local cClient  := M->VRJ_CLIENT
	Local cLoja    := M->VRJ_LOJENT
	Local lRetorno := .T.

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	If(MsSeek(AvKey(FWxFilial("SA1"), "A1_FILIAL") + AvKey(cClient, "A1_COD") + AvKey(cLoja, "A1_LOJA")))
		cTransp := A1_TRANSP
		cTpFret := A1_TPFRET
	EndIf

	M->VRJ_CODTRA := cTransp
	M->VRJ_TPFRET := cTpFret
	SA1->(DbCloseArea())
Return lRetorno
