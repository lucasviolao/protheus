#include 'totvs.ch'
#include 'protheus.ch'
#include 'topconn.ch'

User Function PPE32905(aMVC)
    Local oModel    := Nil
    Local cIdPonto  := ""
    Local lRet      := .T.
    
    If ValType(aMVC) == "A"
        oModel   := aMVC[1]
        cIdPonto := aMVC[2]
    Else
        oModel   := PARAMIXB[1]
        cIdPonto := PARAMIXB[2]
    EndIf

    If cIdPonto == "MODELCOMMITT" .OR. cIdPonto == "MODELPOS"
        lRet := fAlteraValorEX(oModel)
    EndIf

Return lRet

Static Function fAlteraValorEX(oModel)
    Local oModelGW8  := oModel:GetModel("GFEA044_GW8")
    Local nI         := 0
    Local aAreaSD1   := SD1->(GetArea())
    Local aAreaSF1   := SF1->(GetArea())
    Local aAreaDKD   := DKD->(GetArea())
    Local nOpc       := oModel:GetOperation()
    Local cChave     := ""
    Local nValFinal  := 0
    
    If (nOpc == 3 .Or. nOpc == 4) .And. (SF1->F1_EST == "EX")
        
        For nI := 1 To oModelGW8:Length()
            oModelGW8:GoLine(nI)
            
            
            If !oModelGW8:IsDeleted()
                
                DbSelectArea("SD1")
                SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
                
                cChave := xFilial("SD1")
                cChave += SF1->F1_DOC
                cChave += SF1->F1_SERIE
                cChave += SF1->F1_FORNECE
                cChave += SF1->F1_LOJA
                cChave += PadR(oModelGW8:GetValue("GW8_ITEM"), tamsx3('D1_COD') [1]) // Código do Produto
                cChave += oModelGW8:GetValue("GW8_SEQ")   // Sequência do Item
                
                If SD1->(DbSeek(cChave))
                    DbSelectArea("DKD")
                    DKD->(DbSetOrder(1)) //DKD_FILIAL+DKD_DOC+DKD_SERIE+DKD_FORNEC+DKD_LOJA+DKD_ITEM+DTOS(DKD_EMISSA)+DKD_ESPECI


                    If (DKD->(MsSeek((AvKey(FWxFilial("DKD"),"DKD_FILIAL"))+ AvKey(SF1->F1_DOC, "DKD_DOC") + AvKey(SF1->F1_SERIE, "DKD_SERIE") + AvKey(SF1->F1_FORNECE, "DKD_FORNEC")+ AvKey(SF1->F1_LOJA, "DKD_LOJA") + AvKey(SD1->D1_ITEM, "DKD_ITEM"))))
                        If (DKD->DKD_XMOTOR != ' ')
                            nValFinal :=  DKD->DKD_VALBRU
                            oModelGW8:LoadValue("GW8_VALOR", nValFinal)
                        Else   
                            nValFinal :=  SD1->D1_BASEICM
                            oModelGW8:LoadValue("GW8_VALOR", nValFinal)        
                        EndIf
                    EndIf
                    DKD->(DbCloseArea())
                EndIf
                SD1->(DbCloseArea())
            EndIf
        Next nI
    EndIf

    RestArea(aAreaDKD)
    RestArea(aAreaSF1)
    RestArea(aAreaSD1)
Return .T.
