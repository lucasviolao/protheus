#include "protheus.ch"
#include "totvs.ch"
#include "restful.ch"
#include "tbiconn.ch"
#include "topconn.ch"

WSRESTFUL PWS24801 DESCRIPTION "Apis de cargas da Qualidade (Usuarios, Departamentos e Cargos)"
	WSMETHOD POST DEPARTAMENTOS DESCRIPTION "Carga Departamentos" PATH "/qualidade/depto"
	WSMETHOD POST CARGOS        DESCRIPTION "Carga Cargos"        PATH "/qualidade/cargo"
	WSMETHOD POST USUARIOS      DESCRIPTION "Carga Usuarios"      PATH "/qualidade/usuario"
END WSRESTFUL

WSMETHOD POST DEPARTAMENTOS WSSERVICE PWS24801
	Local cBody    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local oDepto   := JsonObject():New()
	Local oJsonRet := JsonObject():New()
	Local xRetJson := ''
	Local cCodigo  := ''
	Local cNovaFil := ''
	Local cDescri  := ''
	Local cMsg     := ''
	Local cStatus  := ''
	Local nI       := 0
	Local lRetorno := .T.

	If (!Empty(cBody))
		xRetJson := oJson:FromJson(cBody)

		If(ValType(xRetJson) == 'U')

			If (oJson:HasProperty("DEPARTAMENTOS") .and. ValType(oJson['DEPARTAMENTOS']) == 'A')

				For nI := 1 To Len(oJson['DEPARTAMENTOS'])
					lRetorno := .T.
					oDepto   := oJson['DEPARTAMENTOS'][nI]
					cCodigo  := oDepto['QAD_CUSTO']
					cDescri  := oDepto['QAD_DESC']
					cStatus  := oDepto['QAD_STATUS']
					cNovaFil := oDepto['QAD_FILIAL']

					If (Empty(cDescri))
						SetRestFault(400, 'Descricao do departamento nao informada')
						lRetorno := .F.
					EndIf

					DbSelectArea('QAD')
					QAD->(DbSetOrder(1))

					If (QAD->(MsSeek(cNovaFil + cCodigo)))
						RecLock('QAD', .F.)
						QAD->QAD_DESC   := cDescri
						QAD->QAD_STATUS := cStatus
						QAD->(MsUnlock())
						lRetorno := .F.
						cMsg += " Departamento (" + cCodigo + ") atualizado " + CRLF
					EndIf
					QAD->(DbCloseArea())

					If (lRetorno)
						RecLock('QAD', .T.)
						QAD->QAD_FILIAL  := cNovaFil
						QAD->QAD_CUSTO   := cCodigo
						QAD->QAD_DESC    := cDescri
						QAD->QAD_STATUS  := cStatus
						QAD->(MsUnlock())
						cMsg += "Codigo (" +cCodigo+ " - " + DecodeUTF8(cDescri) + ") cadastrado" + CRLF
					EndIf
				Next
			Else
				SetRestFault(400, "JSON nao contem array de departamentos.")
				lRetorno := .F.
			EndIf
		Else
			SetRestFault(400, 'JSON malformado ou invalido')
			lRetorno := .F.
		EndIf
	Else
		SetRestFault(400, 'Nenhuma informacao enviado no body')
		lRetorno := .F.
	EndIf

	oJsonRet['message'] := cMsg
	self:SetResponse(oJsonRet:ToJson())
Return lRetorno

WSMETHOD POST CARGOS WSSERVICE PWS24801
	Local cBody    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local oCargo   := JsonObject():New()
	Local oJsonRet := JsonObject():New()
	Local xRetJson := ''
	Local cCodigo  := ''
	Local cDescri  := ''
	Local cCargo   := ''
	//Local cDscCg   := ''
	Local cMsg     := ''
	Local nI       := 0
	Local lRetorno := .T.

	If (!Empty(cBody))
		xRetJson := oJson:FromJson(cBody)

		If(ValType(xRetJson) == 'U')

			If (oJson:HasProperty("CARGOS") .and. ValType(oJson['CARGOS']) == 'A')
				For nI := 1 To Len(oJson['CARGOS'])
					lRetorno := .T.
					oCargo   := oJson['CARGOS'][nI]
					cCodigo  := oCargo['QAC_FUNCAO']
					cDescri  := oCargo['QAC_DESC']
					cCargo   := oCargo['QAC_CARGO']
					//cDscCg   := oCargo['QAC_DESCCG']

					If (Empty(cDescri))
						SetRestFault(400, 'Descricao do Cargo nao informada')
						lRetorno := .F.
					EndIf

					DbSelectArea('QAC')
					QAD->(DbSetOrder(1))

					If (QAC->(MsSeek(FWxFilial('QAC') + cCodigo)))
						RecLock('QAC', .F.)
						QAC->QAC_DESC   := cDescri
						QAC->QAC_CARGO  := cCargo
						//QAC->QAC_DESCCG := cDscCg
						QAC->(MsUnlock())
						lRetorno := .F.
						cMsg += " Cargo (" + cCodigo + ") atualizado " + CRLF
					EndIf
					QAC->(DbCloseArea())

					If (lRetorno)
						RecLock('QAC', .T.)
						QAC->QAC_FUNCAO := cCodigo
						QAC->QAC_DESC   := cDescri
						QAC->QAC_CARGO  := cCargo
						//QAC->QAC_DESCCG := cDscCg
						QAC->(MsUnlock())
						cMsg += "Codigo (" +cCodigo+ " - " + DecodeUTF8(cDescri) + ") cadastrado" + CRLF
					EndIf
				Next
			Else
				SetRestFault(400, "JSON nao contem array de CARGOS.")
				lRetorno := .F.
			EndIf
		Else
			SetRestFault(400, 'JSON malformado ou invalido')
			lRetorno := .F.
		EndIf
	Else
		SetRestFault(400, 'Nenhuma informacao enviado no body')
		lRetorno := .F.
	EndIf

	oJsonRet['message'] := cMsg
	self:SetResponse(oJsonRet:ToJson())
Return lRetorno

WSMETHOD POST USUARIOS WSSERVICE PWS24801
	Local cBody    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local oUser    := JsonObject():New()
	Local oJsonRet := JsonObject():New()
	Local nI       := 0
	Local cFilOri
	Local cMatric
	Local cCCusto
	Local lRetorno := .T.

	oJsonRet['processados'] := {}
	oJsonRet['atualizado']  := {}
	oJsonRet['pendente']    := {}
	oJsonRet['erros']       := {}

	If (!Empty(cBody))
		xRetJson := oJson:FromJson(cBody)

		If(ValType(xRetJson) == 'U')

			If (oJson:HasProperty("USUARIOS") .and. ValType(oJson['USUARIOS']) == 'A')
				For nI := 1 To Len(oJson['USUARIOS'])
					cFilOri  := ''
					cMatric  := ''
					cCCusto  := ''
					lRetorno := .T.
					oUser    := oJson['USUARIOS'][nI]

					cQryQAA := "SELECT * FROM " + RetSQLName("QAA") + " WHERE D_E_L_E_T_ = ' '"
					//cQryQAA += "AND QAA_STATUS = '1'"
					//cQryQAA += "AND D_E_L_E_T_ = ' ' "
					cQryQAA += "AND QAA_MAT = '" + oUser['QAA_MAT'] + "'"
					cQryQAA += "AND QAA_FILIAL = '" + oUser['QAA_FILIAL'] + "'"
					TCQuery cQryQAA New Alias "QRY_QAA"
					QRY_QAA->(DbGoTop())

					If (!QRY_QAA->(EoF()))
						cFilOri := Alltrim(QRY_QAA->QAA_FILIAL)
						cMatric := Alltrim(QRY_QAA->QAA_MAT)
						cCCusto := Alltrim(QRY_QAA->QAA_CC)

						QRY_QAA->(DbCloseArea())
					Else
						Begin Transaction
						// Reclock de inserção
							RecLock('QAA', .T.)
							QAA->QAA_FILIAL := oUser['QAA_FILIAL']
							QAA->QAA_TPUSR  := oUser['QAA_TPUSR']
							QAA->QAA_MAT    := oUser['QAA_MAT']
							QAA->QAA_NOME   := oUser['QAA_NOME']
							QAA->QAA_STATUS := oUser['QAA_STATUS']
							QAA->QAA_APELID := oUser['QAA_LOGIN']
							QAA->QAA_CC     := oUser['QAA_CC']
							QAA->QAA_CODFUN := oUser['QAA_CODFUN']
							QAA->QAA_INICIO := SToD(oUser['QAA_INICIO'])
							QAA->QAA_LOGIN  := oUser['QAA_LOGIN']
							QAA->QAA_EMAIL  := oUser['QAA_EMAIL']
							QAA->QAA_RECMAI := oUser['QAA_RECMAI']
							QAA->QAA_TPMAIL := oUser['QAA_TPMAIL']
							QAA->QAA_DISTSN := oUser['QAA_DISTSN']
							QAA->QAA_TPRCBT := oUser['QAA_TPRCBT']
							QAA->QAA_TPWORD := oUser['QAA_TPWORD']
							QAA->QAA_RECFNC := oUser['QAA_RECFNC']
							QAA->QAA_AUDIT  := oUser['QAA_AUDIT']
							QAA->(MsUnlock())
						End Transaction

						oRegistro := JsonObject():New()
						oRegistro['login'] := oUser['QAA_LOGIN']
						oRegistro['nome']  := oUser['QAA_NOME']
						aAdd(oJsonRet['processados'], oRegistro)
						QRY_QAA->(DbCloseArea())
					EndIf

					If(!Empty(cFilOri) .AND. !Empty(cCCusto))
						If (cFilOri != oUser['QAA_FILIAL'] .OR. cCCusto != oUser['QAA_CC'])

							cQuery := "SELECT QD4_MATBX AS MATRICULA, QD4_DOCTO AS PENDENCIA, 'QDO' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QD4") + " WHERE D_E_L_E_T_ = ' ' AND QD4_PENDEN = 'P' "
							cQuery += "AND QD4_MATBX = '" + oUser['QAA_MAT'] + "' "
							cQuery += "UNION "
							cQuery += "SELECT QDS_MATBX AS MATRICULA, QDS_DOCTO AS PENDENCIA, 'QDO' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QDS") + " WHERE D_E_L_E_T_ = ' ' AND QDS_PENDEN = 'P' "
							cQuery += "AND QDS_MATBX = '" + oUser['QAA_MAT'] + "' "
							cQuery += "UNION  "
							cQuery += "SELECT QDU_MATBX AS MATRICULA, QDU_DOCTO AS PENDENCIA, 'QDO' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QDU") + " WHERE D_E_L_E_T_ = ' ' AND QDU_PENDEN = 'P' "
							cQuery += "AND QDU_MATBX = '" + oUser['QAA_MAT'] + "' "
							cQuery += "UNION  "
							cQuery += "SELECT QDP_MATBX AS MATRICULA, QDP_DESSOL AS PENDENCIA, 'QDO' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QDP") + " WHERE D_E_L_E_T_ = ' ' AND QDP_PENDEN = 'P' "
							cQuery += "AND QDP_MATBX = '" + oUser['QAA_MAT'] + "' "
							cQuery += "UNION  "
							cQuery += "SELECT QUB_AUDLID AS MATRICULA, QUB_NUMAUD AS PENDENCIA, 'QAD' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QUB") + " WHERE D_E_L_E_T_ = ' '  "
							cQuery += "AND QUB_AUDLID = '" + oUser['QAA_MAT'] + "' "
							cQuery += "AND QUB_ENCREA = ' ' "
							cQuery += "UNION "
							cQuery += "SELECT A.QUH_CODAUD AS MATRICULA, A.QUH_NUMAUD AS PENDENCIA, 'QAD' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QUH") + " A "
							cQuery += "INNER JOIN " + RetSQLName("QUB") + " B ON A.QUH_NUMAUD = B.QUB_NUMAUD "
							cQuery += "WHERE A.D_E_L_E_T_ = ' ' "
							cQuery += "AND B.D_E_L_E_T_ = ' ' "
							cQuery += "AND A.QUH_CODAUD = '" + oUser['QAA_MAT'] + "' "
							cQuery += "AND B.QUB_ENCREA = ' ' "
							cQuery += "UNION "
							cQuery += "SELECT QI2_MATRES AS MATRICULA, QI2_XCODIN AS PENDENCIA, 'QNC' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QI2") + " WHERE D_E_L_E_T_ = ' '  "
							cQuery += "AND QI2_MATRES = '" + oUser['QAA_MAT'] + "' "
							cQuery += "AND QI2_CONREA = ' ' "
							cQuery += "UNION "
							cQuery += "SELECT QI3_MAT AS MATRICULA, QI3_CODIGO AS PENDENCIA, 'QNC' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QI3") + " WHERE D_E_L_E_T_ = ' '  "
							cQuery += "AND QI3_MAT = '" + oUser['QAA_MAT'] + "' "
							cQuery += "AND QI3_ENCREA = ' ' "
							cQuery += "UNION "
							cQuery += "SELECT QI5_MAT AS MATRICULA, QI5_CODIGO AS PENDENCIA, 'QNC' AS MODULO, '' AS TIPO "
							cQuery += "FROM " + RetSQLName("QI5") + " WHERE D_E_L_E_T_ = ' '  "
							cQuery += "AND QI5_MAT = '" + oUser['QAA_MAT'] + "' "
							cQuery += "AND QI5_STATUS != '4' "
							TCQuery cQuery New Alias "QRY_PEND"
							QRY_PEND->(DbGoTop())

							If (!QRY_PEND->(EoF()))
								While (!QRY_PEND->(EoF()))
									oPendente := JsonObject():New()
									oPendente['login']         := oUser['QAA_LOGIN']
									oPendente['nome']          := oUser['QAA_NOME']
									oPendente['filialOrigem']  := cFilOri
									oPendente['filialDestino'] := oUser['QAA_FILIAL']
									oPendente['ccOrigem']      := cCCusto
									oPendente['ccDestino']     := oUser['QAA_CC']
									oPendente['pendencia']     := QRY_PEND->PENDENCIA
									oPendente['modulo']        := QRY_PEND->MODULO
									aAdd(oJsonRet['pendente'], oPendente)
									QRY_PEND->(DbSkip())
								EndDo
							Else
								DbSelectArea('QAA')
								QAA->(DbSetOrder(1))

								If(QAA->(MsSeek(AvKey(oUser['QAA_FILIAL'], "QAA_FILIAL") + AvKey(oUser['QAA_MAT'], "QAA_MAT"))))
									If(oUser['QAA_CC'] != cCCusto)
										Begin Transaction
											RecLock('QAA', .F.)
											QAA->QAA_CC := oUser['QAA_CC']
											QAA->(MsUnlock())
											oAtualiza := JsonObject():New()
											oAtualiza['login'] := oUser['QAA_LOGIN']
											oAtualiza['nome']  := oUser['QAA_NOME']
											aAdd(oJsonRet['atualizado'], oAtualiza)
										End Transaction
									Else
										oErro := JsonObject():New()
										oErro['login'] := oUser['QAA_LOGIN']
										oErro['nome']  := oUser['QAA_NOME']
										oErro['erro']  := 'Login ja cadastrado na filial e cc informados'
										aAdd(oJsonRet['erros'], oErro)
									EndIf
								Else
									If(cFilOri == oUser['QAA_FILIAL'])
										If(QAA->(MsSeek(AvKey(cFilOri, "QAA_FILIAL") + AvKey(oUser['QAA_MAT'], "QAA_MAT"))))
											Begin Transaction
												RecLock('QAA', .F.)
												QAA->QAA_CC     := oUser['QAA_CC']
												QAA->(MsUnlock())
												
												// Reclock QAB (TRANSFERENCIA) e QAA (Cadastro User)
												RecLock('QAB', .T.)
												QAB->QAB_FILD := cFilOri
												QAB->QAB_MATD := oUser['QAA_MAT']
												QAB->QAB_CCD  := cCCusto
												QAB->QAB_FILP := oUser['QAA_FILIAL']
												QAB->QAB_MATP := oUser['QAA_MAT']
												QAB->QAB_CCP  := oUser['QAA_CC']
												QAB->QAB_DATA := DATE()
												QAB->(MsUnlock())
											End Transaction
										EndIf
									Else
										If(QAA->(MsSeek(AvKey(cFilOri, "QAA_FILIAL") + AvKey(oUser['QAA_MAT'], "QAA_MAT"))))
											Begin Transaction
												RecLock('QAA', .F.)
												QAA->QAA_STATUS := '2'
												QAA->QAA_FIM    := DATE()
												QAA->(MsUnlock())

												//Reclock QAB (TRANSFERENCIA) e QAA (Cadastro User)
												RecLock('QAB', .T.)
												QAB->QAB_FILD := cFilOri
												QAB->QAB_MATD := oUser['QAA_MAT']
												QAB->QAB_CCD  := cCCusto
												QAB->QAB_FILP := oUser['QAA_FILIAL']
												QAB->QAB_MATP := oUser['QAA_MAT']
												QAB->QAB_CCP  := oUser['QAA_CC']
												QAB->QAB_DATA := DATE()
												QAB->(MsUnlock())

												RecLock('QAA', .T.)
												QAA->QAA_FILIAL := oUser['QAA_FILIAL']
												QAA->QAA_TPUSR  := oUser['QAA_TPUSR']
												QAA->QAA_MAT    := oUser['QAA_MAT']
												QAA->QAA_NOME   := oUser['QAA_NOME']
												QAA->QAA_APELID := oUser['QAA_LOGIN']
												QAA->QAA_CC     := oUser['QAA_CC']
												QAA->QAA_CODFUN := oUser['QAA_CODFUN']
												QAA->QAA_INICIO := SToD(oUser['QAA_INICIO'])
												QAA->QAA_LOGIN  := oUser['QAA_LOGIN']
												QAA->QAA_EMAIL  := oUser['QAA_EMAIL']
												QAA->QAA_RECMAI := oUser['QAA_RECMAI']
												QAA->QAA_TPMAIL := oUser['QAA_TPMAIL']
												QAA->QAA_DISTSN := oUser['QAA_DISTSN']
												QAA->QAA_TPRCBT := oUser['QAA_TPRCBT']
												QAA->QAA_TPWORD := oUser['QAA_TPWORD']
												QAA->QAA_RECFNC := oUser['QAA_RECFNC']
												QAA->QAA_AUDIT  := oUser['QAA_AUDIT']
												QAA->(MsUnlock())
											End Transaction
										EndIf

									EndIf
									oTransfer := JsonObject():New()
									oTransfer['login'] := oUser['QAA_LOGIN']
									oTransfer['nome']  := oUser['QAA_NOME']
									aAdd(oJsonRet['atualizado'], oTransfer)
								EndIf
							EndIf
							QRY_PEND->(DbCloseArea())

						Else
							//RECLOCK ATUALIZA QAA (Cadastro User)
							DbSelectArea('QAA')
							QAA->(DbSetOrder(1))

							If (QAA->(MsSeek(AvKey(oUser['QAA_FILIAL'], "QAA_FILIAL") + AvKey(oUser['QAA_MAT'], "QAA_MAT"))))
								Begin Transaction
									RecLock('QAA', .F.)
									QAA->QAA_TPUSR  := oUser['QAA_TPUSR']
									QAA->QAA_NOME   := oUser['QAA_NOME']
									QAA->QAA_STATUS := oUser['QAA_STATUS']
									QAA->QAA_APELID := oUser['QAA_LOGIN']
									QAA->QAA_CODFUN := oUser['QAA_CODFUN']
									QAA->QAA_INICIO := SToD(oUser['QAA_INICIO'])
									QAA->QAA_LOGIN  := oUser['QAA_LOGIN']
									QAA->QAA_EMAIL  := oUser['QAA_EMAIL']
									QAA->QAA_RECMAI := oUser['QAA_RECMAI']
									QAA->QAA_TPMAIL := oUser['QAA_TPMAIL']
									//QAA->QAA_DISTSN := oUser['QAA_DISTSN']
									QAA->QAA_TPRCBT := oUser['QAA_TPRCBT']
									QAA->QAA_TPWORD := oUser['QAA_TPWORD']
									QAA->QAA_RECFNC := oUser['QAA_RECFNC']
									//QAA->QAA_AUDIT  := oUser['QAA_AUDIT']
									QAA->(MsUnlock())
								End Transaction

								oAtualiza := JsonObject():New()
								oAtualiza['login'] := oUser['QAA_LOGIN']
								oAtualiza['nome']  := oUser['QAA_NOME']
								aAdd(oJsonRet['atualizado'], oAtualiza)
							EndIf
							QAA->(DbCloseArea())
						EndIf
					EndIf

				Next
			Else
				SetRestFault(400, "JSON nao contem array de USUARIOS.")
				lRetorno := .F.
			EndIf
		Else
			SetRestFault(400, 'JSON malformado ou invalido')
			lRetorno := .F.
		EndIf
	Else
		SetRestFault(400, 'Nenhuma informacao enviado no body')
		lRetorno := .F.
	EndIf

	//oJsonRet['processados'] := aProcess
	//oJsonRet['pendente']    := aPendent
	self:SetResponse(oJsonRet:ToJson())
Return lRetorno

