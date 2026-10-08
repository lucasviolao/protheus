#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} PMN25601
Consulta de inspeções utilizando FWMarkBrowse e Query.
Mimetiza a estrutura visual do exemplo MarkBrowse com busca e botões.

@author Especialista ADVPL
@since 20/05/2024
/*/

User Function PMN25601()
    Local aArea := FWGetArea()
    
    // Chamada da função que monta a interface
    fMontaTela()
    
    FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Configura a tabela temporária, popula os dados e cria a interface visual.
/*/
Static Function fMontaTela()
    Local aCampos    := {}
    Local aColunas   := {}
    Local aSeek      := {}
    Local oTempTable
    //Local cFontPad   := 'Tahoma'
    //Local oFontGrid  := TFont():New(cFontPad,,-14)
    
    // Variáveis Private para serem acessadas pelas funções de apoio (fPopula, MenuDef, etc)
    Private oDlgMark
    Private oPanGrid
    Private oMarkBrowse
    Private cAliasTmp := GetNextAlias()
    Private aRotina   := MenuDef()
    
    // Tamanho da janela (Padrão Protheus)
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6]

    // 1. Definição da Estrutura da Tabela Temporária (Igual ao seu original + campo OK)
    //aAdd(aCampos, {"OK",         "C", 2,                      0}) // Campo de marcação
    aAdd(aCampos, {"T_IDPROD",    "C", TamSX3("QPR_OP")[1],     0}) 
    aAdd(aCampos, {"T_COMP",      "C", TamSX3("QP1_ENSAIO")[1], 0}) 
    aAdd(aCampos, {"T_DSCCOMP",   "C", TamSX3("QP1_DESCPO")[1], 0}) 
    aAdd(aCampos, {"T_GNT",       "C", TamSX3("QPU_XGNT")[1],   0}) 
    aAdd(aCampos, {"T_GMF",       "C", TamSX3("QPU_XGMF")[1],   0}) 
    aAdd(aCampos, {"T_POS",       "C", TamSX3("QPU_XPOSIC")[1], 0}) 
    aAdd(aCampos, {"T_CDFALHA",   "C", 60,                      0}) 
    aAdd(aCampos, {"T_PONTUAC",   "C", TamSX3("QPU_XSEVER")[1], 0}) 
    aAdd(aCampos, {"T_DSCINSP",   "C", TamSX3("QPQ_MEDICA")[1], 0}) 
    aAdd(aCampos, {"T_DTINSP",    "C", 20,                      0}) 
    aAdd(aCampos, {"T_STREPAR",   "C", TamSX3("QPU_XSTATU")[1], 0}) 
    aAdd(aCampos, {"T_REPARINI",  "C", 20,                      0}) 
    aAdd(aCampos, {"T_REPARFIM",  "C", 20,                      0}) 
    aAdd(aCampos, {"T_DSCREPAR",  "C", TamSX3("QPU_XCOREP")[1], 0})
    aAdd(aCampos, {"T_RECQPU",    "N", 15,                      0}) 
    aAdd(aCampos, {"T_RECQPR",    "N", 15,                      0}) 
    aAdd(aCampos, {"T_RECQP1",    "N", 15,                      0}) 
    aAdd(aCampos, {"T_RECQPQ",    "N", 15,                      0}) 
    aAdd(aCampos, {"T_QPUCHV",    "C", 50,                      0}) 
    aAdd(aCampos, {"T_TPREPAR",   "C", TamSX3("QPU_XTIPRE")[1], 0}) 
    aAdd(aCampos, {"T_CDESTAPO",  "C", TamSX3("QPR_LABOR")[1],  0}) 
    aAdd(aCampos, {"T_DSESTAPO",  "C", TamSX3("Z07_DESC")[1],   0}) 
    aAdd(aCampos, {"T_QPUCHAVE",  "C", TamSX3("QPU_CHAVE")[1],  0}) 
    aAdd(aCampos, {"T_QPUCODMD",  "C", TamSX3("QPU_CODMED")[1], 0}) 
    aAdd(aCampos, {"T_CHASSI",    "C", 17,                      0}) 

    // Criação da Tabela Temporária
    oTempTable := FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields(aCampos)
    oTempTable:AddIndex("01", {"T_IDPROD", "T_COMP"})
    oTempTable:AddIndex("02", {"T_QPUCHV"})
    oTempTable:Create()

    // 2. Popula a tabela temporária via Query
    Processa({|| fPopula()}, "Buscando dados SQL...")

    // 3. Configuração das Colunas do Browse
    aColunas := fCriaCols()

    // 4. Configuração da Busca (Search/Seek)
    // Definimos que a busca será pelo ID do Produto
    aAdd(aSeek, {"Ord. Prod", {{"", "C", TamSX3("QPR_OP")[1], 0, "Ord. Prod", ""}}})

    // 5. Criação da Janela MSDIALOG
    DEFINE MSDIALOG oDlgMark TITLE 'Manutenção de Inspeções' FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, (nJanAltu/2 - 1))
        
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:SetDescription("Inspeções Realizadas")
        //oMarkBrowse:SetFieldMark('OK')
        
        // Configurações de funcionalidades
        oMarkBrowse:oBrowse:SetDBFFilter(.T.)
        oMarkBrowse:oBrowse:SetUseFilter(.T.)
        oMarkBrowse:oBrowse:SetSeek(.T., aSeek) // Habilita a busca no topo
        oMarkBrowse:SetTemporary(.T.)
        
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:SetColumns(aColunas)
        
        oMarkBrowse:Activate()
        
    ACTIVATE MsDialog oDlgMark CENTERED

    oTempTable:Delete()
    oMarkBrowse:DeActivate()
Return

/*/{Protheus.doc} MenuDef
Define os botões da rotina. Substituímos o Continuar por Visualizar.
/*/
Static Function MenuDef()
    Local aRotina := {}
    // Usamos Operation 2 (Visualizar). A função ZVISUAL receberá o registro posicionado no browse.
    ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'u_PMN256Vis'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'          ACTION 'u_PMN256Alt'  OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Manut. Via Carga' ACTION 'u_PMN256Cga'  OPERATION 4 ACCESS 0
Return aRotina

/*/{Protheus.doc} fPopula
Executa a sua query original e insere os dados na Temporária.
/*/
Static Function fPopula()
    Local cQry := ""
    Local cAliasQry := GetNextAlias()
    Local nTotal := 0
    Local nAtual := 0

    // Sua Query Original
    cQry := " SELECT"
    cQry += "   qp1.qp1_ensaio                                             AS componente,"
    cQry += "   qp1.qp1_descpo                                             AS desc_componente,"
    cQry += "   qpu.qpu_xposic                                             AS pos,"
    cQry += "   qpu.qpu_xtipre                                             AS tipo_reparo,"
    cQry += "   qpr.qpr_op                                                 AS id_prod,"
    cQry += "   qpu.qpu_xsever                                             AS pontuacao,"
    cQry += "   MAX(CASE WHEN SUBSTR(TRIM(sc2.c2_op), -2) = '01' THEN sc2.c2_xchassi END) OVER (PARTITION BY SUBSTR(TRIM(sc2.c2_op), 1, LENGTH(TRIM(sc2.c2_op)) - 2)) AS chassi,"
    cQry += "   qpu.qpu_xgnt                                               AS gnt,"
    cQry += "   sc2.c2_xmodve                                              AS model_code,"
    cQry += "   RTRIM(sag.ag_naocon) || ' - ' || RTRIM(sag.ag_descpo)      AS cod_falha,"
    cQry += "   sc2.c2_xplataf                                             AS plataforma,"
    cQry += "   qpu.qpu_xgmf                                               AS gmf,"
    cQry += "   qpr.qpr_labor                                              AS cod_est_apon,"
    cQry += "   z07.z07_desc                                               AS dsc_est_apon,"
    cQry += "   TO_CHAR(TO_TIMESTAMP(qpr.qpr_dtmedi || ' ' || qpr.qpr_hrmedi, 'YYYYMMDD HH24:MI'), 'DD/MM/YYYY HH24:MI') AS dt_inspec,"
    cQry += "   NVL(TRIM(qpq.qpq_medica), '')                              AS coment_inspec,"
    cQry += "   CASE WHEN TRIM(qpu.qpu_xdtini) IS NOT NULL THEN TO_CHAR(TO_TIMESTAMP(qpu.qpu_xdtini || ' ' || qpu.qpu_xhrini, 'YYYYMMDD HH24:MI'), 'DD/MM/YYYY HH24:MI') ELSE '' END AS dt_reparoini,"
    cQry += "   CASE WHEN TRIM(qpu.qpu_xdtfim) IS NOT NULL THEN TO_CHAR(TO_TIMESTAMP(qpu.qpu_xdtfim || ' ' || qpu.qpu_xhrfim, 'YYYYMMDD HH24:MI'), 'DD/MM/YYYY HH24:MI') ELSE '' END AS dt_reparofim,"
    cQry += "   NVL(TRIM(qpu.qpu_xcorep), '')                              AS coment_reparo,"
    cQry += "   upper(qpu.qpu_xstatu)                                      AS status_reparo,"
    cQry += "   qpu.qpu_chave                                              AS qpu_chave,"
    cQry += "   qpu.qpu_codmed                                             AS qpu_codmed,"
    cQry += "   qpu.r_e_c_n_o_                                             AS rec_qpu,"
    cQry += "   qpr.r_e_c_n_o_                                             AS rec_qpr,"
    cQry += "   qp1.r_e_c_n_o_                                             AS rec_qp1,"
    cQry += "   qpq.r_e_c_n_o_                                             AS rec_qpq"
    cQry += " FROM " + RetSqlName("QPU010") + " qpu"
    cQry += " INNER JOIN " + RetSqlName("SAG010") + " sag ON sag.ag_naocon = qpu.qpu_naocon AND sag.ag_classe = qpu.qpu_classe AND SUBSTR(qpu.qpu_filial, 1, 4) = TRIM(sag.ag_filial) AND sag.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("QPR010") + " qpr ON qpr.qpr_chave = qpu.qpu_codmed AND qpu.qpu_filial = qpr.qpr_filial AND qpr.d_e_l_e_t_ <> '*'"
    cQry += " LEFT JOIN " + RetSqlName("Z17010") + " z17 ON z17.z17_id = qpu.qpu_xgnt AND z17.z17_filial = qpu.qpu_filial AND z17.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("CTT010") + " ctt ON ctt.ctt_custo = z17.z17_ccusto AND SUBSTR(z17.z17_filial, 1, 2) = TRIM(ctt.ctt_filial) AND ctt.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("SC2010") + " sc2 ON sc2.c2_op = qpr.qpr_op AND qpr.qpr_filial = sc2.c2_filial AND sc2.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("Z07010") + " z07 ON z07.z07_idest = qpr.qpr_labor AND qpr.qpr_filial = z07.z07_filial AND z07.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("PQ1010") + " pq1 ON pq1.pq1_codigo = upper(qpu.qpu_xstatu) AND pq1.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("QP1010") + " qp1 ON qp1.qp1_ensaio = qpr.qpr_ensaio AND qp1.d_e_l_e_t_ <> '*'"
    cQry += " INNER JOIN " + RetSqlName("QPQ010") + " qpq ON qpq.qpq_codmed = qpu.qpu_codmed AND qpq.qpq_filial = qpu.qpu_filial AND qpq.d_e_l_e_t_ <> '*'"
    cQry += " WHERE qpu.d_e_l_e_t_ <> '*'"

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasQry, .T., .T.)
    
    Count to nTotal
    ProcRegua(nTotal)
    (cAliasQry)->(DbGoTop())

    While !(cAliasQry)->(Eof())
        nAtual++
        IncProc("Carregando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal))

        RecLock(cAliasTmp, .T.)
            //(cAliasTmp)->OK         := ""
            (cAliasTmp)->T_IDPROD   := (cAliasQry)->id_prod
            (cAliasTmp)->T_COMP     := (cAliasQry)->componente
            (cAliasTmp)->T_DSCCOMP  := (cAliasQry)->desc_componente
            (cAliasTmp)->T_GNT      := (cAliasQry)->gnt
            (cAliasTmp)->T_GMF      := (cAliasQry)->gmf
            (cAliasTmp)->T_POS      := (cAliasQry)->pos
            (cAliasTmp)->T_CDFALHA  := (cAliasQry)->cod_falha
            (cAliasTmp)->T_PONTUAC  := (cAliasQry)->pontuacao
            (cAliasTmp)->T_DSCINSP  := (cAliasQry)->coment_inspec
            (cAliasTmp)->T_DTINSP   := (cAliasQry)->dt_inspec
            (cAliasTmp)->T_STREPAR  := (cAliasQry)->status_reparo
            (cAliasTmp)->T_REPARINI := (cAliasQry)->dt_reparoini
            (cAliasTmp)->T_REPARFIM := (cAliasQry)->dt_reparofim
            (cAliasTmp)->T_QPUCHV   := (cAliasQry)->qpu_chave
            (cAliasTmp)->T_RECQPU   := (cAliasQry)->rec_qpu
            (cAliasTmp)->T_RECQPR   := (cAliasQry)->rec_qpr
            (cAliasTmp)->T_RECQP1   := (cAliasQry)->rec_qp1
            (cAliasTmp)->T_RECQPQ   := (cAliasQry)->rec_qpq
            (cAliasTmp)->T_DSCREPAR := (cAliasQry)->coment_reparo
            (cAliasTmp)->T_TPREPAR  := (cAliasQry)->tipo_reparo
            (cAliasTmp)->T_CDESTAPO := (cAliasQry)->cod_est_apon
            (cAliasTmp)->T_DSESTAPO := (cAliasQry)->dsc_est_apon
            (cAliasTmp)->T_QPUCHAVE := (cAliasQry)->qpu_chave
            (cAliasTmp)->T_QPUCODMD := (cAliasQry)->qpu_codmed
            (cAliasTmp)->T_CHASSI   := (cAliasQry)->chassi
        (cAliasTmp)->(MsUnlock())

        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} fCriaCols
Gera as colunas para o MarkBrowse.
/*/
Static Function fCriaCols()
    Local aColunas := {}
    Local aEstrut  := {}
    Local nI
    
    // Definição visual das colunas
    aAdd(aEstrut, { 'T_IDPROD',   'Ord. Prod',         'C', 14, 0, ''})
    aAdd(aEstrut, { 'T_QPUCHAVE', 'Chave',             'C', 8, 0, ''})
    aAdd(aEstrut, { 'T_QPUCODMD', 'Cod. Med.',         'C', 8, 0, ''})
    aAdd(aEstrut, { 'T_COMP',     'Componente',        'C', 8, 0, ''})
    aAdd(aEstrut, { 'T_DSCCOMP',  'Desc.Comp',         'C', 30, 0, ''})
    aAdd(aEstrut, { 'T_GNT',      'GNT',               'C', 7, 0, ''})
    aAdd(aEstrut, { 'T_GMF',      'GMF',               'C', 7, 0, ''})
    aAdd(aEstrut, { 'T_POS',      'Posicao',           'C', 8, 0, ''})
    aAdd(aEstrut, { 'T_CDFALHA',  'Falha',             'C', 8, 0, ''})
    aAdd(aEstrut, { 'T_PONTUAC',  'Pontuacao',         'C', 3, 0, ''})
    aAdd(aEstrut, { 'T_CDESTAPO', 'Est. Apontamento',  'C', 6, 0, ''})
    aAdd(aEstrut, { 'T_STREPAR',  'Status Reparo',     'C', 2, 0, ''})

    For nI := 1 To Len(aEstrut)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nI][1] +'}'))
        oColumn:SetTitle(aEstrut[nI][2])
        oColumn:SetType(aEstrut[nI][3])
        oColumn:SetSize(aEstrut[nI][4])
        aAdd(aColunas, oColumn)
    Next
Return aColunas

/*/{Protheus.doc} PMN256Vis
Função de gatilho para o botão Visualizar.
/*/
User Function PMN256Vis()
    // Chama a sua função de visualização original passando o Alias
    //ZVISUAL(cAliasTmp)
    fExibeTela(cAliasTmp, .F.)
Return

/*/{Protheus.doc} PMN256Alt
Função disparada pelo botão Alterar
/*/
User Function PMN256Alt()
    // O registro já está posicionado no alias (cAliasTmp)
    // Aqui você chama uma tela parecida com a ZVISUAL, mas sem o READONLY nos campos
    //MsgInfo("Iniciando a alteração do registro: " + (cAliasTmp)->T_IDPROD)
    fExibeTela(cAliasTmp, .T.)
Return

/*/{Protheus.doc} PMN256Cga
Função disparada pelo botão Manut. Via Carga
/*/
User Function PMN256Cga()
    // Aqui você coloca a lógica para processamento em lote ou carga de arquivo
    //MsgAlert("Iniciando rotina de Manutenção via Carga...")
    Local cFile := cGetFile("Arquivo CSV|*.csv", "Seleção de arquivo para carga", 0, "C:\", .T., GETF_LOCALHARD + GETF_NETWORKDRIVE, .T.)
    
    If !Empty(cFile)
        // Chamamos a função de processamento dentro da régua de acompanhamento
        Processa({|| fImportCSV(cFile)}, "Processando Carga...")
    EndIf
Return



/*/{Protheus.doc} fExibeTela
Interface unificada para Visualização e Alteração.
@param cAlias Alias da tabela temporária posicionado.
@param lAlter .T. se for modo de edição, .F. se for apenas visualização.
/*/
Static Function fExibeTela(cAlias, lAlter)
    Local aArea         := FWGetArea()
    Local nJanAltura    := 620 
    Local nJanLargur    := 750 
    Local cJanTitulo    := Iif(lAlter, "Alteração - ", "Visualização - ") + (cAlias)->T_IDPROD
    Local lDimPixels    := .T.
    Local aItemsXP      := fGetXP()
    Local oGetComp      := Nil
    Local oGetDscComp   := Nil // Adicione esta linha
    Local cCodFalha      //AllTrim(SubStr(cCdFalha, 1, At(" - ", cCdFalha) - 1))
    Local cDscFalha      //AllTrim(SubStr(cCdFalha, At(" - ", cCdFalha) + 3))
    Local oGetDscFal // Objeto para dar refresh na descrição
    Local nTamCod       := TamSX3("QPU_NAOCON")[1] // Tamanho do código da falha no Protheus
    Local nTamDsc       := TamSX3("AG_DESCPO")[1] // Tamanho da descrição da falha
    Local dDtAp  // Pega os 10 primeiros caracteres "DD/MM/YYYY"
    Local cHrAp // Pega do caractere 12 em diante "HH:MM"
    Local dDtIni  //CToD(SubStr((cAlias)->T_REPARINI, 1, 10))
    Local cHrIni  //SubStr((cAlias)->T_REPARINI, 12, 5)
    Local dDtFim  //CToD(SubStr((cAlias)->T_REPARFIM, 1, 10))
    Local cHrFim  //SubStr((cAlias)->T_REPARFIM, 12, 5)
    Local oGetDscEst
      
    
    Local nObjLinha     := 0
    Local nObjColun     := 0
    Local oDlg
    Local oFolder
    Local oGetTmp       
    Local aAbas         := {"Produto", "Inspeção", "Reparo"}
    
    // Variáveis locais carregadas com os dados do Alias (Serão usadas nos GETs)
    Local cIdProd     := (cAlias)->T_IDPROD
    Local cComp       := (cAlias)->T_COMP
    Local cDscComp    := (cAlias)->T_DSCCOMP
    Local cGnt        := (cAlias)->T_GNT
    Local cGmf        := (cAlias)->T_GMF
    Local cPos        := (cAlias)->T_POS
    Local cCdFalha    := (cAlias)->T_CDFALHA
    Local cPont       := (cAlias)->T_PONTUAC
    Local cDtApIns    := (cAlias)->T_DTINSP
    Local cStatus     := (cAlias)->T_STREPAR
    Local cDtInRp     := (cAlias)->T_REPARINI
    Local cDtFmRp     := (cAlias)->T_REPARFIM
    Local cComentInsp := (cAlias)->T_DSCINSP
    Local cComentRep  := (cAlias)->T_DSCREPAR
    Local cTpReparo   := (cAlias)->T_TPREPAR
    Local cEstAp      := (cAlias)->T_CDESTAPO
    Local cDscEst     := (cAlias)->T_DSESTAPO
    Local cChassi     := (cAlias)->T_CHASSI

    //cCodFalha     := AllTrim(SubStr(cCdFalha, 1, At(" - ", cCdFalha) - 1))
    //cDscFalha     := AllTrim(SubStr(cCdFalha, At(" - ", cCdFalha) + 3))
    cCodFalha := PadR(AllTrim(SubStr(cCdFalha, 1, At(" - ", cCdFalha) - 1)), nTamCod)
    cDscFalha := PadR(AllTrim(SubStr(cCdFalha, At(" - ", cCdFalha) + 3)), nTamDsc)
    dDtAp     := CToD(SubStr(cDtApIns, 1, 10))
    cHrAp     := SubStr(cDtApIns, 12, 5)
    dDtIni    := CToD(SubStr(cDtInRp, 1, 10))
    cHrIni    := SubStr(cDtInRp, 12, 5)
    dDtFim    := CToD(SubStr(cDtFmRp, 1, 10))
    cHrFim    := SubStr(cDtFmRp, 12, 5)      
    

    Local aDados := {;
        cStatus,;      // [1]
        cComentInsp,;  // [2]
        cComentRep,;   // [3]
        cGnt,;         // [4]
        cGmf,;         // [5]
        cPos,;         // [6]
        cPont,;        // [7]
        cComp,;        // [8]
        cDscComp,;     // [9]
        cCodFalha,;    // [10]
        cDscFalha,;    // [11]
        dDtAp,;        // [12]
        cHrAp,;        // [13]
        cTpReparo,;    // [14]
        dDtIni,;       // [15]
        cHrIni,;       // [16]
        dDtFim,;       // [17]
        cHrFim,;       // [18]
        cEstAp,;       // [19]
        cDscEst;       // [20]
    }

    Private oFontPadrao := TFont():New('Tahoma', , -12)

    cPont := AllTrim(cPont)

    If Empty(cPont)
        cPont := " "
    EndIf
    If AScan(aItemsXP, cPont) == 0
        aAdd(aItemsXP, cPont) // Se o valor atual não existe na SX5, adiciona temporariamente à lista
    EndIf
    
    DEFINE MSDIALOG oDlg TITLE cJanTitulo FROM 000, 000 TO nJanAltura, nJanLargur PIXEL

    oFolder := TFolder():New(005, 005, aAbas, , oDlg, , , , lDimPixels, , (nJanLargur/2)-10, (nJanAltura/2)-45)

    /* --- ABA 1: PRODUTO (Sempre ReadOnly) --- */
    nObjLinha := 10; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "ID Produto:"}, oFolder:aDialogs[1], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    oGetTmp := TGet():New(nObjLinha+10, nObjColun, {|u| cIdProd}, oFolder:aDialogs[1], 150, 10, , , , , oFontPadrao, , , lDimPixels)
    oGetTmp:lReadOnly := .T.

    nObjLinha := 40
    TSay():New(nObjLinha, nObjColun, {|| "Chassi:"}, oFolder:aDialogs[1], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    oGetTmp := TGet():New(nObjLinha+10, nObjColun, {|u| cChassi}, oFolder:aDialogs[1], 150, 10, , , , , oFontPadrao, , , lDimPixels)
    oGetTmp:lReadOnly := .T.

    nObjLinha := 70
    TSay():New(nObjLinha, nObjColun, {|| "Componente:"}, oFolder:aDialogs[1], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET oGetComp VAR cComp ;
        SIZE 80, 10 ;
        OF oFolder:aDialogs[1] ;
        F3 "QP1" ; // Habilita a lupa de consulta na tabela QP1
        PIXEL ;
        FONT oFontPadrao ;
        WHEN lAlter ;
        VALID fValQP1(@cComp, @cDscComp, oGetDscComp) // Chama a validação/gatilho


    nObjLinha := 100
    TSay():New(nObjLinha, nObjColun, {|| "Descrição do Componente:"}, oFolder:aDialogs[1], , oFontPadrao, , , , lDimPixels, , , 200, 08)
    @ nObjLinha+10, nObjColun MSGET oGetDscComp VAR cDscComp ;
        SIZE 320, 10 ;
        OF oFolder:aDialogs[1] ;
        PIXEL ;
        FONT oFontPadrao ;
        WHEN .F.


    /* --- ABA 2: INSPEÇÃO (Campos de status e comentário editáveis se lAlter) --- */
    nObjLinha := 10; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "GNT:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cGnt ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "Z17" ;
        PIXEL ;
        FONT oFontPadrao ;
        VALID ExistCpo("Z17", cGnt) ;
        WHEN lAlter
    //oGetTmp := TGet():New(nObjLinha+10, nObjColun, {|u| iif(u==nil, cGnt, cGnt := u)}, oFolder:aDialogs[2], 120, 10, "@!", {|| ExistCpo("Z17", cGnt)}, , , oFontPadrao, .T., , lDimPixels)
    //oGetTmp:SetF3("Z17")
    //oGetTmp:lReadOnly := !lAlter

    nObjColun := 160 
    TSay():New(nObjLinha, nObjColun, {|| "GMF:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cGmf ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "Z18" ;
        PIXEL ;
        FONT oFontPadrao ;
        VALID ExistCpo("Z18", cGmf) ;
        WHEN lAlter
    //oGetTmp := TGet():New(nObjLinha+10, nObjColun, {|u| cGmf}, oFolder:aDialogs[2], 120, 10, , , , , oFontPadrao, , , lDimPixels)
    //oGetTmp:lReadOnly := !lAlter

    /*nObjLinha := 40; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Posição:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cPos ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "Z16" ;
        PIXEL ;
        FONT oFontPadrao ;
        VALID ExistCpo("Z16", cPos) ;
        WHEN lAlter*/

    nObjLinha := 40; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Posição:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cPos ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "Z16" ;
        PIXEL ;
        FONT oFontPadrao ;
        VALID (Empty(cPos) .Or. ExistCpo("Z16", cPos)) ; // Alterado aqui
        WHEN lAlter

    nObjColun := 160
    TSay():New(nObjLinha, nObjColun, {|| "Pontuação:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSCOMBOBOX oCmbXP VAR cPont ;
        ITEMS aItemsXP ;
        SIZE 60, 50 ; // Altura 50 para comportar a lista aberta
        OF oFolder:aDialogs[2] ;
        PIXEL ;
        FONT oFontPadrao ;
        WHEN lAlter

    nObjLinha := 65; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Estação:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET oGetEst VAR cEstAp ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "Z07" ; // Consulta padrão de Estações
        PIXEL ;
        FONT oFontPadrao ;
        WHEN lAlter ;
        VALID fValEst(@cEstAp, @cDscEst, oGetDscEst)

    nObjColun := 80
    TSay():New(nObjLinha, nObjColun, {|| "Descrição Estação:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 200, 08)
    @ nObjLinha+10, nObjColun MSGET oGetDscEst VAR cDscEst ;
        SIZE 250, 10 ;
        OF oFolder:aDialogs[2] ;
        PIXEL ;
        FONT oFontPadrao ;
        WHEN .F. // Apenas visualização, preenchido pelo gatilho

    nObjLinha := 95; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Cód. Falha:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 60, 08)
    @ nObjLinha+10, nObjColun MSGET oGetCodFal VAR cCodFalha ;
        SIZE 60, 10 ;
        OF oFolder:aDialogs[2] ;
        F3 "SAG" ; // Consulta padrão de falhas
        PIXEL ;
        FONT oFontPadrao ;
        WHEN lAlter ;
        VALID fValSAG(@cCodFalha, @cDscFalha, oGetDscFal)

    // Campo 2: Descrição da Falha (Lado Direito - Mesma Linha)
    nObjColun := 80 // Deslocamos a coluna para a direita
    TSay():New(nObjLinha, nObjColun, {|| "Descrição da Falha:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 200, 08)
    @ nObjLinha+10, nObjColun MSGET oGetDscFal VAR cDscFalha ;
        SIZE 250, 10 ;
        OF oFolder:aDialogs[2] ;
        PIXEL ;
        FONT oFontPadrao ;
        WHEN .F.



    nObjLinha := 125; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Data Apontamento:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 80, 08)
    @ nObjLinha+10, nObjColun MSGET dDtAp ;
        SIZE 50, 10 ;
        OF oFolder:aDialogs[2] ;
        PIXEL ;
        FONT oFontPadrao ;
        WHEN lAlter

    // CAMPO HORA (Posicionado um pouco mais à direita)
    nObjColun := 100 
    TSay():New(nObjLinha, nObjColun, {|| "Hora:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 50, 08)
    @ nObjLinha+10, nObjColun MSGET cHrAp ;
        SIZE 40, 10 ;
        OF oFolder:aDialogs[2] ;
        PIXEL ;
        FONT oFontPadrao ;
        PICTURE "99:99" ; // Máscara de hora
        WHEN lAlter


    nObjLinha := 160; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Comentário da Inspeção:"}, oFolder:aDialogs[2], , oFontPadrao, , , , lDimPixels, , , 200, 08)
            
    @ nObjLinha+10, nObjColun GET oMemo1 VAR cComentInsp MEMO SIZE 320, 60 OF oFolder:aDialogs[2] PIXEL FONT oFontPadrao
    oMemo1:lReadOnly := !lAlter


    /* --- ABA 3: REPARO --- */
    nObjLinha := 10; nObjColun := 10
    
    // LINHA 1: STATUS E TIPO
    TSay():New(nObjLinha, nObjColun, {|| "Status do Reparo:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cStatus SIZE 60, 10 OF oFolder:aDialogs[3] PIXEL FONT oFontPadrao WHEN lAlter

    nObjColun := 100
    TSay():New(nObjLinha, nObjColun, {|| "Tipo do Reparo:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET cTpReparo SIZE 120, 10 OF oFolder:aDialogs[3] PIXEL FONT oFontPadrao WHEN lAlter

    // LINHA 2: INÍCIO REPARO (DATA E HORA)
    nObjLinha := 40; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Data Início Reparo:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET dDtIni SIZE 60, 10 OF oFolder:aDialogs[3] PIXEL FONT oFontPadrao WHEN lAlter

    nObjColun := 100
    TSay():New(nObjLinha, nObjColun, {|| "Hora Início:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 60, 08)
    @ nObjLinha+10, nObjColun MSGET cHrIni SIZE 40, 10 OF oFolder:aDialogs[3] PICTURE "@R 99:99" PIXEL FONT oFontPadrao WHEN lAlter

    // LINHA 3: FIM REPARO (DATA E HORA)
    nObjLinha := 70; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Data Fim Reparo:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 100, 08)
    @ nObjLinha+10, nObjColun MSGET dDtFim SIZE 60, 10 OF oFolder:aDialogs[3] PIXEL FONT oFontPadrao WHEN lAlter

    nObjColun := 100
    TSay():New(nObjLinha, nObjColun, {|| "Hora Fim:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 60, 08)
    @ nObjLinha+10, nObjColun MSGET cHrFim SIZE 40, 10 OF oFolder:aDialogs[3] PICTURE "@R 99:99" PIXEL FONT oFontPadrao WHEN lAlter

    // LINHA 4: COMENTÁRIO DO REPARO (MEMO)
    nObjLinha := 100; nObjColun := 10
    TSay():New(nObjLinha, nObjColun, {|| "Comentário do Reparo:"}, oFolder:aDialogs[3], , oFontPadrao, , , , lDimPixels, , , 200, 08)
    @ nObjLinha+10, nObjColun GET oMemo2 VAR cComentRep MEMO SIZE 320, 60 OF oFolder:aDialogs[3] PIXEL FONT oFontPadrao
    oMemo2:lReadOnly := !lAlter // Agora ele fica editável se for modo Alteração


    // Botões de Rodapé
    If lAlter
        //TButton():New((nJanAltura/2)-35, (nJanLargur/2)-130, "Confirmar", oDlg, {|| fGrava(cAlias, aDados), oDlg:End()}, 55, 15, , oFontPadrao, , lDimPixels)
        TButton():New((nJanAltura/2)-35, (nJanLargur/2)-130, "Confirmar", oDlg, {|| ;
            aDados := {cStatus, cComentInsp, cComentRep, cGnt, cGmf, cPos, cPont, cComp, cDscComp, cCodFalha, cDscFalha, dDtAp, cHrAp, cTpReparo, dDtIni, cHrIni, dDtFim, cHrFim, cEstAp, cDscEst}, ; // Atualiza o array com o que foi digitado
            fGrava(cAlias, aDados), ; 
            oDlg:End() ;
        }, 55, 15, , oFontPadrao, , lDimPixels)
        
        TButton():New((nJanAltura/2)-35, (nJanLargur/2)-70, "Cancelar", oDlg, {|| oDlg:End()}, 55, 15, , oFontPadrao, , lDimPixels)
    Else
        TButton():New((nJanAltura/2)-35, (nJanLargur/2)-60, "Fechar", oDlg, {|| oDlg:End()}, 50, 15, , oFontPadrao, , lDimPixels)
    EndIf

    ACTIVATE MSDIALOG oDlg CENTERED

    FWRestArea(aArea)
Return

/*/{Protheus.doc} fGrava
Persiste os dados na Tabela Temporária e na Tabela Física (QPU e QPQ).
/*/
Static Function fGrava(cAlias, aDados)
    Local nRecQPU := (cAlias)->T_RECQPU
    Local nRecQPR := (cAlias)->T_RECQPR
    Local nRecQPQ := (cAlias)->T_RECQPQ

    Local cStatus     := aDados[1]
    Local cComInsp    := aDados[2]
    Local cComRep     := aDados[3]
    Local cGnt        := aDados[4]
    Local cGmf        := aDados[5]
    Local cPos        := aDados[6]
    Local cPont       := aDados[7]
    Local cComp       := aDados[8]
    Local cDscComp    := aDados[9]
    Local cCodFalha   := aDados[10]
    Local cDscFalha   := aDados[11]
    Local dDtAp       := aDados[12]
    Local cHrAp       := aDados[13]
    Local cTpReparo   := aDados[14]
    Local dDtIni      := aDados[15]
    Local cHrIni      := aDados[16]
    Local dDtFim      := aDados[17]
    Local cHrFim      := aDados[18]
    Local cEstAp      := aDados[19]
    Local cDscEst     := aDados[20]
    
    // 1. Atualiza Tabela Temporária (para o Browse atualizar visualmente)
    //RecLock(cAlias, .F.)
    If (cAlias)->(RecLock(cAlias, .F.))
        (cAlias)->T_STREPAR  := cStatus
        (cAlias)->T_DSCINSP  := cComInsp
        (cAlias)->T_DSCREPAR := cComRep
        (cAlias)->T_GNT      := cGnt
        (cAlias)->T_GMF      := cGmf
        (cAlias)->T_POS      := cPos
        (cAlias)->T_COMP     := cComp
        (cAlias)->T_DSCCOMP  := cDscComp
        (cAlias)->T_PONTUAC  := cPont
        (cAlias)->T_TPREPAR  := cTpReparo
        (cAlias)->T_CDFALHA  := cCodFalha + ' - ' + cDscFalha
        (cAlias)->T_DTINSP   := DToC(dDtAp) + ' ' + cHrAp
        (cAlias)->T_REPARINI := DToC(dDtIni) + ' ' + cHrIni
        (cAlias)->T_REPARFIM := DToC(dDtFim) + ' ' + cHrFim
        (cAlias)->T_CDESTAPO := cEstAp
        (cAlias)->T_DSESTAPO := cDscEst
        (cAlias)->(MsUnlock())
    EndIf

    // 2. Persistência no Banco de Dados (QPU - Inspeções)
    DbSelectArea("QPU")
    QPU->(DbGoTo(nRecQPU))
    If QPU->(RecLock("QPU", .F.))
        QPU->QPU_XSTATU := cStatus
        QPU->QPU_XCOREP := cComRep
        QPU->QPU_XGNT   := cGnt
        QPU->QPU_XGMF   := cGmf
        QPU->QPU_XPOSIC := cPos
        QPU->QPU_XSEVER := cPont
        QPU->QPU_NAOCON := cCodFalha
        QPU->QPU_XTIPRE := cTpReparo
        QPU->QPU_XDTINI := dDtIni
        QPU->QPU_XHRINI := cHrIni
        QPU->QPU_XDTFIM := dDtFim
        QPU->QPU_XHRFIM := cHrFim
        QPU->(MsUnlock())
    EndIf


    DbSelectArea("QPR")
    QPR->(DbGoTo(nRecQPR))
    If QPR->(RecLock("QPR", .F.))
        QPR->QPR_ENSAIO := cComp
        QPR->QPR_DTMEDI := dDtAp
        QPR->QPR_HRMEDI := cHrAp
        QPR->QPR_LABOR  := cEstAp
        QPR->(MsUnlock())
    EndIf

    DbSelectArea("QPQ")
    QPQ->(DbGoTo(nRecQPQ))
    If QPQ->(RecLock("QPQ", .F.))
        QPQ->QPQ_MEDICA := cComInsp
        QPQ->(MsUnlock())
    EndIf

    // 3. Persistência no Banco de Dados (QPQ - Comentário da Inspeção)
    // Nota: Como sua query original usa o recno da QPU, você precisaria do RECNO da QPQ para ser preciso.
    // Se o RECNO da QPQ estiver no campo T_RECQPR (ou similar), faça o mesmo DbGoTo nela.
    
    MsgInfo("Dados gravados com sucesso!", "Sucesso")
Return

Static Function fImportCSV(cFile)
    Local nHdl
    Local cLine     := ""
    Local aLine     := {}
    Local nLidos    := 0
    Local nAtu      := 0
    Local cChave    := ""
    Local cCodMed   := ""
    Local cCompon   := ""
    Local cStatus   := ""
    Local cComRep   := ""
    Local cGNT      := ""
    Local cGMF      := ""
    Local cPos      := ""
    Local cPont     := ""
    Local cCodFalha := ""
    Local cEstApon  := ""
    Local cTpReparo := ""
    Local dDtIni
    Local cHrIni    := ""
    Local dDtFim
    Local cHrFim    := ""
    Local nTotalLin := 0

    nHdl := FT_FUse(cFile)
    If nHdl < 0
        MsgStop("Não foi possível abrir o arquivo: " + cFile)
        Return
    EndIf

    // Conta total de linhas para a régua (opcional)
    FT_FGoTop()
    While !FT_FEof()
        nTotalLin++
        FT_FSkip()
    EndDo
    
    ProcRegua(nTotalLin)
    FT_FGoTop()
    FT_FSkip()

    DbSelectArea("QPU")
    QPU->(DbSetOrder(3)) // Verifique se a ordem 3 é QPU_CHAVE

    DbSelectArea("QPR")
    QPR->(DbSetOrder(4))

    While !FT_FEof()
        cLine := FT_FReadLn()
        //aLine := StrTokArr(cLine, ";") 
        aLine := fSplitCSV(cLine, ";") 
        
        nLidos++
        IncProc("Processando linha " + cValToChar(nLidos) + " de " + cValToChar(nTotalLin))

        // Valida se a linha tem as 3 colunas (Chave;GNT;GMF)
        If Len(aLine) >= 13
            cChave    := AllTrim(aLine[1])
            cCodMed   := AllTrim(aLine[2])
            cCompon   := AllTrim(aLine[3])
            cGNT      := AllTrim(aLine[4])
            cGMF      := AllTrim(aLine[5])
            cPos      := AllTrim(aLine[6])
            cCodFalha := AllTrim(aLine[7])
            cPont     := AllTrim(aLine[8])
            cEstApon  := AllTrim(aLine[9])
            cStatus   := AllTrim(aLine[10])
            cComRep   := AllTrim(aLine[11])
            cTpReparo := AllTrim(aLine[12])
            cDataIni  := AllTrim(aLine[13])
            dDtIni    := iif("/" $ cDataIni, CToD(cDataIni), SToD(cDataIni))
            cHrIni    := AllTrim(aLine[14])
            cDataFim  := AllTrim(aLine[15])
            dDtFim    := iif("/" $ cDataFim, CToD(cDataFim), SToD(cDataFim))
            cHrFim    := AllTrim(aLine[16])

            // 1. Atualiza Banco de Dados (QPU)
            If QPU->(DbSeek(xFilial("QPU") + cChave))
                If QPU->(RecLock("QPU", .F.))
                    QPU->QPU_XSTATU := cStatus
                    QPU->QPU_XCOREP := cComRep
                    QPU->QPU_XGNT   := cGnt
                    QPU->QPU_XGMF   := cGmf
                    QPU->QPU_XPOSIC := cPos
                    QPU->QPU_XSEVER := cPont
                    QPU->QPU_NAOCON := cCodFalha
                    QPU->QPU_XTIPRE := cTpReparo
                    QPU->QPU_XDTINI := dDtIni
                    QPU->QPU_XHRINI := cHrIni
                    QPU->QPU_XDTFIM := dDtFim
                    QPU->QPU_XHRFIM := cHrFim
                    QPU->(MsUnlock())
                    nAtu++
                EndIf
            EndIf

            If QPR->(DbSeek(xFilial("QPR") + cCodMed))
                If QPR->(RecLock("QPR", .F.))
                    QPR->QPR_ENSAIO := cCompon
                    QPR->QPR_LABOR  := cEstApon
                    QPR->(MsUnlock())
                EndIf
            EndIf

            // 2. Atualiza a Tabela Temporária (Interface)
            (cAliasTmp)->(DbSetOrder(2)) // Índice por T_CHAVE
            If (cAliasTmp)->(DbSeek(cChave))
                RecLock(cAliasTmp, .F.)
                (cAliasTmp)->T_STREPAR  := cStatus
                (cAliasTmp)->T_DSCREPAR := cComRep
                (cAliasTmp)->T_GNT      := cGNT
                (cAliasTmp)->T_GMF      := cGMF
                (cAliasTmp)->T_POS      := cPos
                (cAliasTmp)->T_PONTUAC  := cPont
                (cAliasTmp)->T_TPREPAR  := cTpReparo
                (cAliasTmp)->T_REPARINI := DToC(dDtIni) + " " + cHrIni
                (cAliasTmp)->T_REPARFIM := DToC(dDtFim) + " " + cHrFim
                //(cAliasTmp)->T_CDFALHA  := cCodFalha 
                (cAliasTmp)->(MsUnlock())
            EndIf
        EndIf
        
        FT_FSkip()
    EndDo
    
    FT_FUse()

    MsgInfo("Carga finalizada!" + CRLF + ;
            "Linhas processadas: " + cValToChar(nLidos) + CRLF + ;
            "Registros atualizados: " + cValToChar(nAtu), "Sucesso")
            
    // Atualiza o browse visualmente
    oMarkBrowse:Refresh()
Return

Static Function fGetXP()
    Local aOpcoes := {" "}
    Local cQuery  := ""
    Local cAliasQ := GetNextAlias()

    cQuery := " SELECT X5_CHAVE FROM " + RetSqlName("SX5")
    cQuery += " WHERE X5_TABELA = 'XP' AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY X5_CHAVE "

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQ, .T., .T.)

    While !(cAliasQ)->(Eof())
        aAdd(aOpcoes, AllTrim((cAliasQ)->X5_CHAVE))
        (cAliasQ)->(DbSkip())
    EndDo
    (cAliasQ)->(DbCloseArea())

    // Caso a tabela esteja vazia, adiciona o valor atual para não quebrar a tela
    /*If Len(aOpcoes) == 0
        aAdd(aOpcoes, "M")
        aAdd(aOpcoes, "V1")
        aAdd(aOpcoes, "V1+")
        aAdd(aOpcoes, "V2")
        aAdd(aOpcoes, "V3")
    EndIf*/

Return aOpcoes


Static Function fValQP1(cCodigo, cDescricao, oObjDsc)
    Local lRet      := .T.
    Local aAreaQP1  := QP1->(GetArea())

    // Se o campo estiver vazio, não faz nada
    If Empty(cCodigo)
        Return .T.
    EndIf

    DbSelectArea("QP1")
    QP1->(DbSetOrder(1)) // Ordem 1: Ensaio/Componente

    If QP1->(DbSeek(xFilial("QP1") + cCodigo))
        // Se encontrou na QP1, alimenta a variável da descrição
        cDescricao := QP1->QP1_DESCPO
        
        // Atualiza o componente visual na tela (Refresh)
        If oObjDsc <> Nil
            oObjDsc:Refresh()
        EndIf
    Else
        // Se não encontrou, avisa o usuário, mas permite continuar (já que você quer alteração livre)
        Help("", 1, "FORA_QP1",, "O componente digitado não existe na tabela QP1. Verifique o código ou preencha a descrição manualmente.", 1, 0)
    EndIf

    RestArea(aAreaQP1)
Return lRet

Static Function fValSAG(cCodigo, cDescricao, oObjDsc)
    Local lRet := .T.
    
    DbSelectArea("SAG")
    SAG->(DbSetOrder(1)) // AG_NAOCON
    
    // No SAG a chave costuma ser Filial + Codigo. 
    // Ajuste conforme seu dicionário (pode ser ag_naocon + ag_classe)
    If SAG->(DbSeek(xFilial("SAG") + cCodigo))
        cDescricao := SAG->AG_DESCPO
        If oObjDsc <> Nil
            oObjDsc:Refresh()
        EndIf
    EndIf
Return lRet

Static Function fSplitCSV(cLinha, cDelim)
    Local aRet      := {}
    Local nPos      := 0
    Local cConteudo := cLinha

    While (nPos := At(cDelim, cConteudo)) > 0
        aAdd(aRet, SubStr(cConteudo, 1, nPos - 1))
        cConteudo := SubStr(cConteudo, nPos + 1)
    EndDo
    aAdd(aRet, cConteudo) // Adiciona o último elemento
Return aRet

Static Function fValEst(cCodigo, cDescricao, oObjDsc)
    Local lRet      := .T.
    Local aAreaZ07  := Z07->(GetArea())

    If Empty(cCodigo)
        Return .T.
    EndIf

    DbSelectArea("Z07")
    Z07->(DbSetOrder(2)) // Filial + Estação

    If Z07->(DbSeek(xFilial("Z07") + cCodigo))
        cDescricao := Z07->Z07_DESC
        If oObjDsc <> Nil
            oObjDsc:Refresh()
        EndIf
    Else
        Help("", 1, "EST_NAO_EXISTE",, "Estação de apontamento não cadastrada na tabela Z07.", 1, 0)
        lRet := .F.
    EndIf

    RestArea(aAreaZ07)
Return lRet
