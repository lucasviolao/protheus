#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "FwMvcDef.ch"


/*/{Protheus.doc} PMN11631
Tela para parametrização Código do Projeto x Classificação de Frete.
@type user function
@author Lucas Silva
@since 	18/09/2025	
@version 1.0.0
/*/
User Function PMN11631
	Local aArea   	:= GetArea()
	Private oBrowse := FwLoadBrw("PMN11631")

	oBrowse:AddLegend("Z48->Z48_STATUS == 'N'", "RED"		, "Não processado", "1")
	oBrowse:AddLegend("Z48->Z48_STATUS == 'P'", "GREEN" , "Processado com sucesso", "1")

	oBrowse:Activate()
	RestArea(aArea)
Return

/*
    Definição do Browse - Apresentação dos dados
*/
Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("Z48")
	oBrowse:SetDescription('Painel de Enderecamento - OP Beneficiamento')
	oBrowse:SetMenuDef("PMN11631")

Return oBrowse

/*
    Definio do Menu - Itens de menu
*/
Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina Title 'Pesquisar'  Action 'VIEWDEF.PMN11631' OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PMN11631' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.PMN11631' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.PMN11631' OPERATION 8 ACCESS 0
Return aRotina

/*
    Definio do Model - Regras de negcio e dados
*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStPai := FWFormStruct(1, 'Z48')

	oModel := MPFormModel():New('PMN3291M')

	oModel:AddFields('Z48MASTER',Nil,oStPai)
	oModel:SetPrimaryKey({})
	oModel:SetDescription("Painel de Enderecamento - OP Beneficiamento")
Return oModel

/*
    Definio da View - Interface visual
*/
Static Function ViewDef()
	Local oModel
	Local oStrZ48
	Local oView
	oStrZ48 := FwFormStruct(2, 'Z48')
	oModel	:= FWLoadModel('PMN11631')
	oView   := FWFormView():New()


	oView:SetModel(oModel)
	oView:AddField("VIEW_Z48",oStrZ48, "Z48MASTER")
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView("VIEW_Z48", "TELA")
Return oView
