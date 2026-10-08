#include 'totvs.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PPE88002
Ponto de entrada para validar o código inteligente na gravação da FNC
@type function
@version  1.00
@author ls809225
@since 21/09/2026
@return boolean, Retorno Booleano
/*/
User Function PPE88002()
    Local aArea      := FwGetArea()
    Local cPrefixo   := "" 
    Local cNumero    := "" 
    Local cSufixo    := "" 
    Local nNovoNum   := 0
    Local nAdiciona  := 1
    Local cCodOrig   := ""
    Local cNovoCod   := ""
    Local cSeq       := ""
    Local cNovoSeq   := "0"
    Local cMsg       := ""
    Local lAlterou   := .F.
    Local lRet       := .T.

    DbSelectArea("QI2")
    QI2->(DbSetOrder(9))
    
    cCodOrig := AllTrim(M->QI2_XCODIN)
    cNovoCod := AllTrim(M->QI2_XCODIN)
    cSeq     := AllTrim(M->QI2_XSEQ)

    While (QI2->(MsSeek(AvKey(FWxFilial("QI2"), "QI2_FILIAL") + AvKey(cNovoCod, "QI2_XCODIN"))))

        lAlterou := .T.
        cPrefixo := SubStr(cNovoCod, 1, 5)
        cNumero  := SubStr(cNovoCod, 6, 4)
        cSufixo  := SubStr(cNovoCod, 10)  
        
        If (SubStr(cNovoCod, 1, 4) == "KDQR")
            nAdiciona := 2
        Else
            nAdiciona := 1 
        EndIf
        
        nNovoNum := Val(cNumero) + nAdiciona
        cNovoCod := cPrefixo + StrZero(nNovoNum, Len(cNumero)) + cSufixo
        cNovoSeq := StrZero(nNovoNum, Len(cSeq)) 

    EndDo

    If (lAlterou)
        M->QI2_XCODIN := cNovoCod      
        M->QI2_XSEQ   := cNovoSeq

        cMsg := "O Código Inteligente original [" + cCodOrig + "] já estava em uso." + CRLF + CRLF
        cMsg += "Foi gerado e gravado automaticamente o novo código: [" + cNovoCod + "]."

        FwAlertInfo(cMsg, "Aviso - Código Inteligente")      
    EndIf     
    
    FwRestArea(aArea)
Return lRet
