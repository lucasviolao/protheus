#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} MT100GE2
@description Ponto de entrada que vai pegar a informação da OS do documento de entrada
             e levar essa informação para o título
@type        function
@version     1.00
@author      ls809225
@since       14/08/2025
@return      boolean, Retorno Booleano 
/*/
User Function MT100GE2()
	Local aArea     := FwGetArea()
	Local lRetorno := .T.

	// Função que irá atribuir a identificação de OS, caso informada, no Título
	If ( ExistBlock("PPE75001") )
		lRetorno := ExecBlock("PPE75001",.F.,.F.,PARAMIXB)

	EndIf

	FwRestArea(aArea)
Return lRetorno
