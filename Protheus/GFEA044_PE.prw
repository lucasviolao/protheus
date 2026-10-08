#include 'totvs.ch'
#include 'protheus.ch'
#include 'topconn.ch'

User Function GFEA044()
    Local xRet := .T.

    If ValType(PARAMIXB) == "A" .And. ExistBlock("PPE32905")
        xRet := ExecBlock("PPE32905", .F., .F., PARAMIXB)
    EndIf

Return xRet
