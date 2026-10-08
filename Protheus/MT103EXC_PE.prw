#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/**************************************************************************************************
{Protheus.doc} MT103EXC
@description	Ponto de entrada para exclusao do documento de entrada
@type   		User Function 
@author			Edie Carlos 
@version   		1.00
@since     		30/06/2025
@return         Nil
**************************************************************************************************/
/*************************************************************************************************
{Protheus.doc} MT103EXC
@description   Ponto de entrada que vai gerar um movimento de débito no conta corrente do 
               concessionario caso tenha o campo F1_XIDOS preenchido 
@type          User Function
@version       1.00
@since         15/08/2025
@author        ls809225
@return        boolean, Retorno Booleano
**************************************************************************************************/
/*************************************************************************************************
{Protheus.doc} MT103EXC
@description   Ponto de entrada que vai validar a exclusão de um Documento de Entrada 
@type          User Function
@version       1.00
@since         16/09/2025
@author        Dhalton Marcelino
@return        boolean, Retorno Booleano
**************************************************************************************************/
User Function MT103EXC()
    Local lRet       := .T.
	Local aAreaP25   := P25->(GetArea())
	Local aArea      := FwGetArea()
	Local cNumOe     := ""
    Local cForn      := ""
    Local cLoja      := ""
    Local cSerie     := ""
    Local cNota      := ""
    Local cFilNFe    := ""
    Local cTpNota    := ""
    Local lPermitido := .T.

    //Valida se nota foi gerada OE e pode ser excluida
	P25->(dbSetOrder(1))
	If P25->(dbSeek(xFilial("P25")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
    	cNumOe := P25->P25_PONUM
		If Empty(P25->P25_STATUS) .OR. P25->P25_STATUS $ "100.199"
			lRet:=.T.
		else
        	lRet := .F.
        	MsgInfo("Essa nota fiscal não pode ser excluida, OE já iniciada")
        EndIf 
   
	EndIf

	// Se tiver OS informada veio da garantia
	If (SF1->F1_XIDOS != ' ')
		// Função que irá gerar o movimento de débito na cc do concessionario
		If ( ExistBlock("PPE75002") )
			lRet := ExecBlock("PPE75002",.F.,.F.,PARAMIXB)
		EndIf

	EndIf

	RestArea(aAreaP25)
	FwRestArea(aArea)

    // Coleta dados somente se SF1 estiver aberta
    If Select("SF1") > 0
        cFilNFe  := SF1->F1_FILIAL
        cForn    := SF1->F1_FORNECE
        cLoja    := SF1->F1_LOJA
        cNota    := SF1->F1_DOC
        cSerie   := SF1->F1_SERIE
        dEmissao := SF1->F1_EMISSAO
        cTpNota  := SF1->F1_TIPO
    EndIf

    // Só valida se SD1 estiver aberta e condição bater
    If Select("SD1") > 0 .And. SD1->D1_LOCAL == 'A1'
        If ExistFunc("U_PPE94701")
            lPermitido := u_PPE94701(cFilNFe, cForn, cLoja, cNota, cSerie, dEmissao, cTpNota)
        EndIf

        If !lPermitido
            MsgAlert("Exclusão não permitida pelas validações do People.","MT103EXC")
            lRet := .F.
        EndIf
    EndIf

    If lRet
        // 14/01/26 - Atilio - Validar exclusão de nota do processo de industrialização externa
        If FindFunction("U_PPE20102")
            lRet := U_PPE20102( 5)
        EndIf

        // 01/03/26 - Kimura - Qaundo ocorrer a exclusão de uma nota de importação, os dados também serão limpos na P60 e P51 para evitar 
        //que o processo de importação tente buscar os dados antigos e gere um erro por não encontrar a nota na base.
        If FindFunction("U_PPE81606")
            If SF1->F1_FORMUL == "S" .AND. SF1->F1_EST == "EX"
                lRet := U_PPE81606(SF1->F1_DOC, SF1->F1_SERIE)
            Endif
        EndIf
    EndIf

Return lRet
