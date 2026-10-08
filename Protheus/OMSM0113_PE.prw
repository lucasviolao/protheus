#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} OMSM0113
Ponto de entrada que vai pegar a informação da classificação de frete
no pedido de veículo e usará a mesma informação no documento de carga
@type function
@version  1
@author ls809225
@since 21/05/2025
@return boolean, Retorno Booleano
/*/
User Function OMSM0113()
  Local aArea     := FwGetArea()
  Local lRetorno := .T.

  // Função que irá atribuir a classificação de frete, caso informada, no documento de carga
  If FWIsInCallStack("VEIA060")
    If ( ExistBlock("PPE32903") )
      lRetorno := ExecBlock("PPE32903",.F.,.F.,PARAMIXB)
      
    EndIf
  EndIf
  
  FwRestArea(aArea)
Return lRetorno
