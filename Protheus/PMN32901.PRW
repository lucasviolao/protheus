#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "FwMvcDef.ch"


/*/{Protheus.doc} PMN32901
Tela para parametrização Código do Projeto x Classificação de Frete.
@type user function
@author Lucas Silva
@since 	18/09/2025	
@version 1.0.0
/*/
User Function PMN32901
	Local aArea   	:= GetArea()
	Private oBrowse := FwLoadBrw("PMN32901")
	oBrowse:Activate()
	RestArea(aArea)
Return

/*
    Definição do Browse - Apresentação dos dados
*/
Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("Z40")
	oBrowse:SetDescription('Parametrização de Regras Cód. Projeto x Class. Frete')
	oBrowse:SetMenuDef("PMN32901")

Return oBrowse

/*
    Definio do Menu - Itens de menu
*/
Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina Title 'Pesquisar'  Action 'VIEWDEF.PMN32901' OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PMN32901' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.PMN32901' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.PMN32901' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.PMN32901' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.PMN32901' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.PMN32901' OPERATION 9 ACCESS 0
Return aRotina

/*
    Definio do Model - Regras de negcio e dados
*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStPai := FWFormStruct(1, 'Z40')

	oModel := MPFormModel():New('PMN3291M')

	oModel:AddFields('Z40MASTER',Nil,oStPai)
	oModel:SetPrimaryKey({})
	oModel:SetDescription("Criação de Regras Cod.Proj x Class.Frete")
Return oModel

/*
    Definio da View - Interface visual
*/
Static Function ViewDef()
	Local oModel
	Local oStrZ40
	Local oView
	oStrZ40 := FwFormStruct(2, 'Z40')
	oModel	:= FWLoadModel('PMN32901')
	oView   := FWFormView():New()


	oView:SetModel(oModel)
	oView:AddField("VIEW_Z40",oStrZ40, "Z40MASTER")
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView("VIEW_Z40", "TELA")
Return oView
