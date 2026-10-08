#include "protheus.ch"
#include "totvs.ch"
#include "topconn.ch"


Static nPosChassi  := 1 //Coluna A no Excel
Static nPosFornece := 2 //Coluna B no Excel
Static nPosLoja    := 3 //Coluna C no Excel
Static nPosNumNota := 4 //Coluna D no Excel
Static nPosSerieNF := 5 //Coluna E no Excel
Static nPosChaveNF := 6 //Coluna F no Excel
Static nPosDataNF  := 7 //Coluna G no Excel



/*/{Protheus.doc} PMN99001
Função para importar informações de veiculos em poder de terceiros via csv
@type user function
@author Lucas Silva
@since 29/10/2025
@version 1.00
/*/
User Function PMN99001()
	Local aArea     := FwGetArea()
	Private cArqOri := ""

	//Mostra o prompt para selecionar arquivos
	cArqOri := tFileDialog("CSV files (*.csv) ", 'Seleção de Arquivos', , , .F.,)

	//Se tiver o arquivo de origem
	If (!Empty(cArqOri))

		//Somente se existir o arquivo e for com a extensão CSV
		If (File(cArqOri) .AND. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3))) == 'CSV'
			Processa({|| fImporta()}, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida", "Atenção")
		EndIf
	EndIf

	FwRestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/

Static Function fImporta()
    Local aArea        := FwGetArea()
    Local cArqLog      := "zImpCSV_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas   := 0
    Local cLinAtu      := ""
    Local nLinhaAtu    := 0
    Local aLinha       := {}
    Local nX
    Local oArquivo
    Local aLinhas
    Local cChassi      := ""
    Local cCodForn     := ""
    Local cLojForn     := ""
    Local cNumNF       := ""
    Local cSerieNF     := ""
    Local cChaveNF     := ""
    Local cNfeDt       := ""       
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""
    Private cTeste     := ""
    Private aRet       := {}
	Private _cSldBf    := .T.
    Private _cTes      := SuperGetMV("HP_TESSREM",.F.,"542")
	Private cSerie     := SuperGetMV("HP_SERIREM",.F.,"001")
    Private _cForPgto  := SuperGetMV("HP_PGTOSRM",.F.,"001")
	Private _cVend     := SuperGetMV("HP_VENDSRM",.F.,"3")
	Private _cTransp   := SuperGetMV("HP_TRASREM",.F.,"000005")
	Private cEndHpe    := SuperGetMV("HP_ENDHPE",.F.,"PATIO HPE")
	Private cEndSada   := SuperGetMV("HP_ENDSADA",.F.,"PATIO SADA")


    //Se a pasta de log não existir, cria ela
    If (!ExistDir(cDirLog))
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())

        //Se não for fim do arquivo
        If (!oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
				cNumNF       := ""
				cSerieNF     := ""
				cChaveNF     := ""
				dNfeDt       := CToD("")
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")
                  
                //Se não for o cabeçalho (encontrar o texto "chassi" na linha atual)
                If (! "chassi" $ Lower(cLinAtu))
  
                    //Zera as variaveis
                    cChassi   := aLinha[nPosChassi]
                    cCodForn  := aLinha[nPosFornece]
                    cLojForn  := aLinha[nPosLoja]
                    cNumNF    := aLinha[nPosNumNota]
                    cSerieNF  := aLinha[nPosSerieNF]
                    cChaveNF  := aLinha[nPosChaveNF]
                    cNfeDt    := aLinha[nPosDataNF]

                    BuscaChassi(cChassi)

                    aRet := VldChassi(cChassi, cCodForn, cLojForn)

                    If (len(aRet) > 0)
				        For nX := 1 to Len(aRet)
					        MsgStop(aRet[nX][2],"Atencao")
							cLog +=  "- Lin " + cValToChar(nLinhaAtu) + " - " + aRet[nX][2]
				        Next nX
			        Else
				        FwMsgRun( ,{|| U_SaidaVeiculo(cChassi, cCodForn, cLojForn, cNumNF, cSerieNF, cChaveNF, cNfeDt, @cLog, @nLinhaAtu)  } , "Processando", "Aguarde...Efetuando carga de veiculos em terceiro." )
			        EndIf
  
                    //DbSelectArea('SA2')
                    //SA2->(DbSetOrder(1)) // Filial + Código + Loja
  
                    //Se conseguir posicionar no fornecedor
                    /*If SA2->(DbSeek(FWxFilial('SA2') + cCodForn + cLojForn))
                        cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", fornecedor [" + cCodForn + cLojForn + " - " + Upper(SA2->A2_NREDUZ) + "] " +;
                            "a observação foi alterada, antes: [" + Alltrim(SA2->A2_X_OBS) + "], agora: [" + Alltrim(cObserv) + "];" + CRLF
  
                        //Realiza a alteração do fornecedor
                        RecLock('SA2', .F.)
                            SA2->A2_X_OBS  := cObserv
                        SA2->(MsUnlock())
  
                    Else
                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", fornecedor e loja [" + cCodForn + cLojForn + "] não encontrados no Protheus;" + CRLF
                    EndIf*/
                      
                Else
                    cLog += "- Lin " + cValToChar(nLinhaAtu) + " - linha não processada - cabeçalho;" + CRLF
                EndIf
                  
            EndDo
  
            //Se tiver log, mostra ele
            If (!Empty(cLog))
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
  
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
  
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf


    FwRestArea(aArea)
Return


Static Function BuscaChassi(cChassi)

	Private cGruVei  := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))

	If (Empty(cChassi))
		Return
	Endif

	dbSelectArea("VV1")
	dbSetOrder(2)
	If (dbSeek(xFilial("VV1")+ cChassi))

		dbSelectArea("VVG")
		VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
		VVG->(DbSeek( VV1->(VV1_FILENT+VV1_TRACPA+VV1_CHAINT)))

		cLocAux := VV1->VV1_LOCPAD
		If (Empty(cLocAux))
			cLocAux := GETMV("MV_LOCVEIN") //Novo
			If (VV1->VV1_ESTVEI == '1')
				cLocAux := GETMV("MV_LOCVEIU") //Usado
			EndIf
		EndIf
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

		//_cChaVei 	:= VV1->VV1_CHASSI
		//_cCor 		:= VV1->VV1_CORVEI
		//_cDescri	:= SB1->B1_DESC
	EndIf
Return

Static Function VldChassi(cChassi, cCodForn, cLojForn)

	Local aRet := {}

	dbSelectArea("SF4")
	dbSetOrder(1)
	If (dbSeek(xFilial("SF4")+_cTes))

		If (SF4->F4_ESTOQUE == 'S')
			cQryAlias := GetNextAlias()
			cQuery := "SELECT BF_NUMSERI FROM "+RetSqlName("SBF")+" SBF "
			cQuery += " WHERE BF_FILIAL ='"+xFilial("SBF")+"' AND "
			cQuery += "     BF_NUMSERI = '"+cChassi+"' AND "
			cQuery += "     BF_QUANT-BF_EMPENHO > 0 AND "
			cQuery += "     SBF.D_E_L_E_T_ <> '*' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )

			(cQryAlias)->(dbGoTop())
			If ((cQryAlias)->(eof()))
				aadd(aRet,{.F.,"Chassi "+Alltrim(cChassi)+" não possui saldo em estoque!"})
			EndIf

			(cQryAlias)->(dbCloseArea())
		Else
			cQryAlias := GetNextAlias()
			cQuery := "SELECT D2_NUMSERI FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SB6")+" SB6 "
			cQuery += " WHERE D2_FILIAL ='"+xFilial("SD2")+"' AND "
			cQuery += "     D2_CLIENTE = '"+cCodForn+"' AND "
			cQuery += "     D2_LOJA = '"+cLojForn+"' AND "
			cQuery += "     D2_TES = '"+_cTes+"' AND "
			cQuery += "     D2_NUMSERI = '"+cChassi+"' AND "
			cQuery += "     SD2.D_E_L_E_T_ <> '*' AND "
			cQuery += "     B6_FILIAL = D2_FILIAL AND "
			cQuery += "     B6_IDENT = D2_IDENTB6 AND "
			cQuery += "     B6_PODER3 = 'R' AND "
			cQuery += "     B6_SALDO > 0 AND "
			cQuery += "     SB6.D_E_L_E_T_ <> '*' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
			(cQryAlias)->(dbGoTop())
			If (!(cQryAlias)->(eof()))
				aadd(aRet,{.F.,"Saida do Chassi "+Alltrim(cChassi)+" efetuada anteriormente!"})
			EndIf
			(cQryAlias)->(dbCloseArea())
		EndIf
	EndIf
Return aRet

User Function SaidaVeiculo(cChassi, cCodForn, cLojForn, cNumNF, cSerieNF, cChaveNF, cNfeDt, cLog, nLinhaAtu)
	Local xAutoCab     	:= {} // Campos Cabecalho
	Local xAutoItens   	:= {} // Campos Itens
	Local xAutoIt       := {}
	Local nCusAtu 		:= 0
	Local cLogAux       := ""
	
	cLog +=  CRLF + "- Lin " + cValToChar(nLinhaAtu) + " - "

	Private lMsErroAuto := .f.
	Private cGruVei  := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+Avkey(cCodForn,"A2_COD")+AvKey(cLojForn,"A2_LOJA"))

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+_cForPgto)

	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+_cVend)

	dbSelectArea("SA4")
	dbSetOrder(1)
	dbSeek(xFilial("SA4")+_cTransp)

	aAdd(xAutoCab,{"VV0_FILIAL"  ,xFilial("VV0")		,Nil})
	aAdd(xAutoCab,{"VV0_CLIFOR"  ,"F"					,Nil})
	aAdd(xAutoCab,{"VV0_FORPRO"  ,"1"   		 		,Nil})
	aAdd(xAutoCab,{"VV0_CODCLI"  ,SA2->A2_COD			,Nil})
	aAdd(xAutoCab,{"VV0_LOJA"    ,SA2->A2_LOJA			,Nil})
	aAdd(xAutoCab,{"VV0_FORPAG"  ,SE4->E4_CODIGO		,Nil})
	aAdd(xAutoCab,{"VV0_CODVEN"  ,SA3->A3_COD			,Nil})
	aAdd(xAutoCab,{"VV0_CODTRA"  ,SA4->A4_COD			,Nil})

	dbSelectArea("VV1")
	dbSetOrder(2)
	dbSeek(xFilial("VV1")+cChassi)

	_nRecVV1 := VV1->(RECNO())

	dbSelectArea("VVG")
	VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
	VVG->(DbSeek( VV1->(VV1_FILENT+VV1_TRACPA+VV1_CHAINT)))

	cLocAux := VV1->VV1_LOCPAD
	If (Empty(cLocAux))
		cLocAux := GETMV("MV_LOCVEIN") //Novo
		If (VV1->VV1_ESTVEI == '1')
			cLocAux := GETMV("MV_LOCVEIU") //Usado
		EndIf
	EndIf
	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	SB1->(dbSetOrder(1))
	If (Empty(cLocAux))
		cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	EndIf
	SB2->(dbSetOrder(1))
	If (SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux)))
		nCusAtu := round(SB2->B2_CM1,2) // Custo Atual do Equipamento
	EndIf

	xAutoIt := {}

	aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVA")	,Nil})
	aAdd(xAutoIt,{"VVA_CHASSI"  ,VV1->VV1_CHASSI,Nil})
	aAdd(xAutoIt,{"VVA_CODTES"  ,_cTes			,Nil})
	aAdd(xAutoIt,{"VVA_VALVDA"  ,nCusAtu		,Nil})
	aAdd(xAutoIt,{"VVA_VALMOV"  ,nCusAtu		,Nil})
	aAdd(xAutoItens,xAutoIt)

	SetFunName('VEIXA013')


	

	If (SX5->(MsSeek(AvKey(FwCodFil(),"X5_FILIAL") + AvKey('01', "X5_TABELA") + AvKey(cSerieNF, "X5_CHAVE"))))
		Reclock("SX5", .F.)
		SX5->X5_DESCRI  := cNumNF
		SX5->X5_DESCSPA := cNumNF
		SX5->X5_DESCENG := cNumNF
		MsUnlock()
	EndIf


	
	//cNumero   := NxtSX5Nota(cSerieNF)
	aNumNFSF2 := {.F.,cNumNF,cSerieNF,cChaveNF,cNfeDt}

	//cNumero := NxtSX5Nota(cSerie)
	//aNumNFSF2 := {.F.,cNumero,cSerie}
	SetMV("MV_TPNRNFS", "1")
	
	If U_HPEXX001(xAutoCab,xAutoItens,{},3,"3",NIL,,aNumNFSF2,"1", @cLogAux)
		
		dbSelectArea("VV1")
		dbGoto(_nRecVV1)
		RecLock("VV1",.F.)
		VV1->VV1_SITVEI := "0"
		MsUnlock()
		// INCLUIR FUNCAO PARA ENDEREÇAMENTO



		cQryAlias := GetNextAlias()
		cQuery := "SELECT BF_NUMSERI FROM "+RetSqlName("SBF")+" SBF "
		cQuery += " WHERE BF_FILIAL ='"+xFilial("SBF")+"' AND "
		cQuery += "     BF_NUMSERI = '"+VV1->VV1_CHASSI+"' AND "
		cQuery += "     BF_QUANT-BF_EMPENHO > 0 AND "
		cQuery += "     BF_LOCALIZ= '"+cEndHpe+"'  AND "
		cQuery += "     SBF.D_E_L_E_T_ <> '*' "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )

		(cQryAlias)->(dbGoTop())
		if (cQryAlias)->(eof())
			_cSldBf:=.F.
			//aadd(aRet,{.F.,"Chassi "+Alltrim(_cChassi)+" não possui saldo em estoque!"})
		endif

		(cQryAlias)->(dbCloseArea())


		IF _cSldBf
			_aTransp := {}
			AADD(_atransp,SB1->B1_COD)//1
			AADD(_atransp,1)   //2
			AADD(_atransp,cLocAux)  //3
			AADD(_atransp,cEndHpe)  //4
			AADD(_atransp,SB1->B1_COD)    //5
			AADD(_atransp,cLocAux)  //6
			AADD(_atransp,cEndSada)  //7
			AADD(_atransp,VV1->VV1_SEGMOD)  //8
			AADD(_atransp,VV1->VV1_CHASSI)  //9

			u_TransfereSada() // gerar transferencia para Patio Sada
			MsUnlock()
		EndIf 
	EndIf
	cLog += cLogAux + CRLF

Return


/*/
	_____________________________________________________________________________
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¦¦+-------------s---------------------------------------------------------+¦¦
	¦¦¦Programa  ¦ TransfereSada ¦ Autor ¦ Wilker Marçal   ¦ Data ¦ 23/05/2025¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Descriçào ¦ Gera transferencia de endereço                             ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Uso       ¦ Especifico para Hpe Automotores By WM Cosultoria           ¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦Alteração ¦ Wilker Marçal                            ¦ Data ¦23/05/2025¦¦¦
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User  Function TransfereSada()

    Local aAuto := {}
    Local aItem := {}
    Local aLinha := {}
    Local nOpcAuto := 0
    Local cDocumen := ""
    Local lContinua := .T.
    Local cLocDest  := SuperGetMV("HP_XLOCDEST" , .F.,"D2")
    Local cEndDest  := SuperGetMV("HP_XENDEST" , .F.,"GERAL")
    Local cSBFLot   := GetNextAlias()

    lMsErroAuto := .F.

    BeginSql  Alias cSBFLot 
        SELECT BF_LOTECTL FROM %table:SBF% SBF
        WHERE BF_NUMSERI = %Exp:_atransp[09]%   //= %Exp:(cAliasTmp)->CHASSI%
        and BF_PRODUTO = %Exp:_atransp[01]%
        AND D_E_L_E_T_=''
    EndSql
    //Cabecalho a Incluir
    cDocumen := GetSxeNum("SD3","D3_DOC")
    aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

    //Itens a Incluir
    aItem := {}

    // for nX := 1 to len(aLista) step 2
        aLinha := {}
        //Origem
        SB1->(DbSeek(xFilial("SB1")+PadR(_atransp[01], tamsx3('D3_COD') [1])))
        aadd(aLinha,{"ITEM"     , "001"                 ,Nil})
        aadd(aLinha,{"D3_COD"   , _atransp[01]     , Nil}) //Cod Produto origem
        aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC          , Nil}) //descr produto origem
        aadd(aLinha,{"D3_UM"    , SB1->B1_UM            , Nil}) //unidade medida origem
        aadd(aLinha,{"D3_LOCAL" ,  _atransp[03]             , Nil}) //armazem origem
        aadd(aLinha,{"D3_LOCALIZ",ALLTRIM(_atransp[04]) ,Nil}) //Informar endereÃ§o origem
        
        //Destino
        aadd(aLinha,{"D3_COD"       , _atransp[01]      , Nil}) //cod produto destino
        aadd(aLinha,{"D3_DESCRI"    , SB1->B1_DESC          , Nil}) //descr produto destino
        aadd(aLinha,{"D3_UM"        , SB1->B1_UM            , Nil}) //unidade medida destino
        aadd(aLinha,{"D3_LOCAL"     , _atransp[06]              , Nil}) //armazem destino
        aadd(aLinha,{"D3_LOCALIZ"   , _atransp[07]              ,Nil}) //Informar endereÃ§o destino
        
        aadd(aLinha,{"D3_NUMSERI", Alltrim(_atransp[09])                 , Nil}) //Numero serie
        aadd(aLinha,{"D3_LOTECTL",(cSBFLot)->BF_LOTECTL                , Nil}) //Lote Origem - preciso pegar essa info 
        aadd(aLinha,{"D3_NUMLOTE", ""               , Nil}) //sublote origem
        // aadd(aLinha,{"D3_DTVALID", ''               , Nil}) //data validade
        aadd(aLinha,{"D3_POTENCI", 0                , Nil}) // Potencia
        aadd(aLinha,{"D3_QUANT"  , 1                , Nil}) //Quantidade
        aadd(aLinha,{"D3_QTSEGUM", 0                , Nil}) //Seg unidade medida
        aadd(aLinha,{"D3_ESTORNO", ""               , Nil}) //Estorno
        aadd(aLinha,{"D3_NUMSEQ", ""                , Nil}) // Numero sequencia D3_NUMSEQ
        
        aadd(aLinha,{"D3_LOTECTL", (cSBFLot)->BF_LOTECTL               , Nil}) //Lote destino
        aadd(aLinha,{"D3_NUMLOTE", ""               , Nil}) //sublote destino
        // aadd(aLinha,{"D3_DTVALID", ''               , Nil}) //validade lote destino
        aadd(aLinha,{"D3_ITEMGRD", ""               , Nil}) //Item Grade
        
        aadd(aLinha,{"D3_CODLAN", ""                , Nil}) //cat83 prod origem
        aadd(aLinha,{"D3_CODLAN", ""                , Nil}) //cat83 prod destino
        
        aAdd(aAuto,aLinha)
        (cSBFLot)->(DbCloseArea())
    // Next nX
    nOpcAuto := 3 // Inclusao
    MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

    if lMsErroAuto
        MostraErro()
        lContinua := .F.
    Else 
        lContinua := .T.
    EndIf

    conout("Finalizado a inclusão de movimentação multipla")

Return lContinua


