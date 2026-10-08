#include 'protheus.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'prtopdef.ch'

/*/{Protheus.doc} PPE32901
Ponto de entrada MVC que realizará a validação se 
campo VRK_XCDCFR - Classificação de Frete, foi preenchido ou não.
@type function
@version  1.00
@author ls809225
@since 21/05/2025
@return boolean, Retorno Booleano
/*/
User Function PPE32901()
	Local aArea     := FwGetArea()
	Local aParam    := PARAMIXB
	Local cIdPonto  := ""
	Local nContador := 0
	Local nTotal    := 0
	Local oObj
	Local oModel
	Local oVRK
	Local cClFrete  := ""
	Local cStatusLn := ""
	Local cSegMod   := ""
	Local cCodProj  := ""
	Local lRetorno  := .T.


	If aParam <> NIL
		oObj     := aParam[1]
		cIdPonto := aParam[2]

		Do Case
		Case cIdPonto == "MODELPOS"
			oModel := FwModelActive()
			oVRK := IIF(oModel != NIL, oModel:GetModel("MODEL_VRK"), NIL)

			If (oVRK != NIL)
				nTotal := oVRK:Length()

				For nContador := 1 To nTotal
					oVRK:GoLine(nContador)

					// Pula linhas marcadas para exclusão
					If (oVRK:IsDeleted(nContador))
						Loop
					EndIf

					cStatusLn := AllTrim("" + oModel:GetValue("MODEL_VRK", "VRK_CANCEL"))

					If (cStatusLn != "1")

						cSegMod  := AllTrim("" + oModel:GetValue("MODEL_VRK", "VRK_SEGMOD"))

						If (Len(cSegMod) >= 10)
							cCodProj := SubStr(cSegMod, 5, 4)
						Else
							cCodProj := AllTrim("" + oModel:GetValue("MODEL_VRK", "VRK_GRUMOD"))
						EndIf

						cQryZ40 := "SELECT * FROM " + RetSQLName("Z40") + " " + ;
							"WHERE D_E_L_E_T_ = ' ' " + ;
							"AND Z40_CDPROJ = '" + cCodProj + "'"
						TCQuery cQryZ40 New Alias "QRY_Z40"

						If (!QRY_Z40->(Eof()))
							cClFrete := QRY_Z40->Z40_CLFRET
						EndIf
						QRY_Z40->(DbCloseArea())

						oModel:SetValue("MODEL_VRK", "VRK_XCDCFR", cClFrete)

						If Empty(cClFrete)
							MsgAlert("O campo 'Class. Frete' (VRK_XCDCFR) é obrigatório na linha " + cValToChar(nContador) + ".", "Validação - Pedido de Venda")
							//lRetorno := .F.
							Exit
						EndIf
					EndIf
				Next
				If (!IsBlind())
					If Empty(oModel:GetValue("MODEL_VRJ", "VRJ_TPFRET"))
						MsgAlert("Tipo de Frete não informado. Verifique Cadastro do Cliente de Entrega")
						//lRetorno := .F.
					EndIf
					If (Empty(oModel:GetValue("MODEL_VRJ", "VRJ_CODTRA")) .AND. oModel:GetValue("MODEL_VRJ", "VRJ_TPFRET") <> 'S')
						MsgAlert("Transportadora não informada. Verifique Cadastro do Cliente de Entrega")
						//lRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndCase
	EndIf

	FwRestArea(aArea)
Return lRetorno
