#include "totvs.ch"
#include "topconn.ch"
#include "protheus.ch"


/*/{Protheus.doc} PPE03702
Ponto de entrada utilizado para, no momento de carga de controle em terceiros
pegar as informações de numero, serie e chave da NF que vier informado
no pedido de venda.
@type user function
@author Lucas Silva
@since 08/09/2025
@version 1.00
@return logical, Retorno Lógico
/*/
User Function PPE03702()
    Local aArea := FwGetArea()
    Local lRetorno := .T.

    If (!Empty(SC5->C5_XCHVLEG) .AND. !Empty(SC5->C5_XNOTALG) .AND. !Empty(SC5->C5_XSERIEL))
    
        Reclock("SF2",.F.)
            SF2->F2_CHVNFE := SC5->C5_XCHVLEG
            //SF2->F2_SERIE  := SC5->C5_XSERIEL
            //SF2->F2_DOC    := SC5->C5_XNOTALG
        MsUnlock()
        
        // AJUSTE SF3
        TCSQLExec("UPDATE " + RetSqlName("SF3") + " SET F3_CHVNFE = '" + SC5->C5_XCHVLEG  + "' WHERE F3_FILIAL = '" + SF2->F2_FILIAL + "' AND F3_NFISCAL = '" + SF2->F2_DOC + "' AND F3_SERIE = '" + SF2->F2_SERIE + "' AND F3_CLIEFOR = '" + SF2->F2_CLIENTE + "' AND F3_LOJA = '" + SF2->F2_LOJA + "' AND D_E_L_E_T_ = ' ' " )

        // AJUSTE SFT
        TCSQLExec("UPDATE " + RetSqlName("SFT") + " SET FT_CHVNFE = '" + SC5->C5_XCHVLEG  + "' WHERE FT_FILIAL = '" + SF2->F2_FILIAL + "' AND FT_NFISCAL = '" + SF2->F2_DOC + "' AND FT_SERIE = '" + SF2->F2_SERIE + "' AND FT_CLIEFOR = '" + SF2->F2_CLIENTE + "' AND FT_LOJA = '" + SF2->F2_LOJA + "' AND D_E_L_E_T_ = ' ' " )                                                                       
        

    EndIf

  
    //SetMV("MV_TPNRNFS", "3")

    FwRestArea(aArea)
Return lRetorno
