#include "totvs.ch"
#include "protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#include "topconn.ch"

/**
 * VEIA060
 *
 * Ponto de entrada padro MVC da rotina VEIA060 
 *
 * @author mc809289
 * @since 22/04/2025
 * @version 1.0.0
 */
User Function VEIA060()
	Local aParam    := PARAMIXB
	Local aArea     := FwGetArea()
	Local xRet      := .T.
	Local oObj
	Local cIdPonto
	Local cIdModel

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		If cIdPonto == 'FORMLINEPOS'
			If cIdModel == 'MODEL_VRK'
				If ExistFunc("U_PPE80605") // GAP 806 -> 919
					xRet := U_PPE80605(oObj)
				EndIf
			EndIf

			If cIdModel == 'MODEL_RESUMO'

				If ExistFunc("U_PPE81615") // GAP 816g6
				/*If M->VRJ_TIPVEN == "05" .AND. M->VRJ_XTXCMX <= 0
					FWRestArea(aArea)
					xRet := .F.
					Help(, , "Help", , "Falha ao validar o pedido Ecomex!", 1, 0, , , , , , {"Verifique o campo taxa cmx!"})
					Return xRet
				Else*/
					xRet := U_PPE81615(oObj)
				//EndIf
				EndIf
			EndIf
		EndIf

		/*
		Dhalton Marcelino - 01/10/2025
		GAP993: Gera Pedido de Compras pras despesas vinculadas ao faturamento do veículo.
		*/
		If( ExistBlock("PPE99301") )
			ExecBlock("PPE99301",.F.,.F.,PARAMIXB)
		Endif

		//Wilker - HPE - 20250602 - Gap178_193_197_199
		If(ExistFunc("u_PP317801"))
			xRet := u_PP317801()
		EndIf

		// Valida se campo VRK_XCDCFR foi informado no preenchimento da linha do pedido de veículo
		If ( ExistBlock("PPE32901") )
			xRet := ExecBlock("PPE32901",.F.,.F.,PARAMIXB)
		EndIf

		// Atualiza campo VRK_VALDES com o valor do desconto conforme tabela Z39
  		If ( ExistBlock("PPE08601") )
    		xRet := ExecBlock("PPE08601",.F.,.F.,PARAMIXB)
  		EndIf
		/*
		Pedro Augusto - 15/09/2025
		GAP962: libera upload de notas de comissão na extranet no ato de faturamento
		*/
		If( ExistBlock("PPE96201") )
			ExecBlock("PPE96201",.F.,.F.,PARAMIXB)
		Endif
		
		/*
		Giordano Trabach - HUB Plataformas - 20/10/2025
		GAP634: Reseta o totalizador interno do pedido e a validação de retorno, usado pelo PE VX002INI
		*/
		//Validar a ativação/início do modelo
		If(cIdPonto == 'MODELVLDACTIVE')
			If(ExistBlock('PVL63401'))
				U_PVL63401(.T.)
			EndIf
		EndIf
		
		If cIdPonto == 'MODELCOMMITTTS'
			//ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
			/*
				Rubens Guilardi Jr. - HUB Plataformas - 21/10/2025
				GAP81606: Gravar campos customizados na tabela de VRJ após a gravação do pedido
			*/
			If(ExistBlock('PPE81612'))
				U_PPE81612()
			EndIf	
		EndIf	

		If cIdPonto == 'MODELPOS'
             //cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
			 /*
				Rubens Guilardi Jr. - HUB Plataformas - 21/10/2025
				GAP81606: Impedir alteração em pedido aguardando ecomex
			*/
            If ( ExistBlock("PPE81613") )
				xRet := U_PPE81613()
			EndIf
		EndIf

        /*
		Paula Denise - 19/11/2025
		GAP903 - Verificar Bloqueio de Clientes
        */
		If ( xRet .and. ExistBlock("PVL90302") .and. cIdPonto == "MODELVLDACTIVE" )
			xRet := U_PVL90302(oObj)
		EndIf

	Endif

	FwRestArea(aArea)

Return xRet
