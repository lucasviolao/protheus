#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} PPE75001
@description Função que irá atribuir a identificação da OS, caso informada no título.
@type        function
@version     1.00
@author      ls809225
@since       14/08/2025
@return      boolean, Retorno Booleano 
/*/

User Function PPE75001()
	Local nOpc     := PARAMIXB[2]
	Local lRetorno := .T.
	Local cPortado := AllTrim(StrTokArr(SF1->F1_XIDOS, ";")[1])
	Local cHistori := "CREDITO EM GARANTIA"

	If (nOpc == 1)

		If (!Empty(AllTrim(SF1->F1_XIDOS)))
			SE2->E2_XIDOS   := AvKey(SF1->F1_XIDOS, "E2_XIDOS")
			SE2->E2_ITEMCTA := AvKey(SD1->D1_ITEMCTA, "E2_ITEMCTA")
			SE2->E2_CCUSTO  := AvKey(SD1->D1_CC, "E2_CCUSTO")
			SE2->E2_HIST    := AvKey(cHistori, "E2_HIST")

			If (cPortado >= '50000')
				SE2->E2_PORTADO := AvKey("SUZ", "E2_PORTADO")
			Else
				SE2->E2_PORTADO := AvKey("MIT", "E2_PORTADO")
			EndIF
		EndIF

	EndIf
Return lRetorno
