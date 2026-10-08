#include 'totvs.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} QNCVLDNC
Ponto de entrada para executar ações e/ou validar gravação da FNC
@type function
@version  1.00
@author ls809225
@since 21/09/2026
@return boolean, Retorno Booleano
/*/
User Function QNCVLDNC()
    Local aArea := FwGetArea()
    Local lRet  := .T.

    If Inclui        
        If Existblock("PPE88002")
            lRet := U_PPE88002()
        EndIf
	EndIf

    FwRestArea(aArea)
Return lRet
