#include "totvs.ch"
#include "topconn.ch"
#include "protheus.ch"


/*/{Protheus.doc} M461SER
Ponto de entrada utilizado para, no momento de carga de controle em terceiros
pegar as informações de numero e serie da NF que vier informado no pedido de venda.
@type user function
@author Lucas Silva
@since 08/09/2025
@version 1.00
@return logical, Retorno Lógico
/*/
User Function M461SER()
	Local lRetorno := .T.

	If (ExistBlock("PPE03701"))
		lRetorno := ExecBlock("PPE03701", .F., .F., PARAMIXB)
	EndIf
Return lRetorno
