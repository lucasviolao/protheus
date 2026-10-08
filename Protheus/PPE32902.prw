#include "totvs.ch"
#include "topconn.ch"
#include "protheus.ch"


/*/{Protheus.doc} PPE32902
Adiciona as informações da classificação de frete nos dados adicionais da NFe
@type function
@version  1
@author ls809225
@since 07/04/2025
@return caracter, Retorna Caractere
/*/
User Function PPE32902()
  Local aNota            := PARAMIXB[5]
  Local cCodClasseFrete  := ""
  Local cDescClasseFrete := ""
  Local cIDTransacao     := ""
  Local cNumPedidoVenda  := ""
  Local aAreas           := Lj7GetArea({"SC5","SC6","SD2","SF2","SF3","SFT","CD2","VV0","VVA","VRK", "GUB"})
  Local cNumNotaFiscal   := SD2->D2_DOC
  Local cSerieNotaFiscal := SD2->D2_SERIE
  Local cMsg             := ""


  DbSelectArea("VV0")
  VV0->( DbSetOrder(4) )
  If (MsSeek(AvKey(FWxFilial("VV0"), "VV0_FILIAL") + AvKey(cNumNotaFiscal, "VV0_NUMNFI") + AvKey(cSerieNotaFiscal, "VV0_SERNFI")))
    cIDTransacao := VV0->VV0_NUMTRA
  EndIf
  VV0->( DbCloseArea() )

  DbSelectArea("VVA")
  VVA->(DbSetOrder(1))
  If (MsSeek(AvKey(FWxFilial("VVA"), "VVA_FILIAL") + AvKey(cIDTransacao, "VVA_NUMTRA")))
    cNumPedidoVenda := VVA->VVA_VRKNUM
  EndIf
  VVA->(DbCloseArea())

  DbSelectArea("VRK")
  VRK->(DbSetOrder(1))
  If (MsSeek(AvKey(FWxFilial("VRK"), "VRK_FILIAL") + AvKey(cNumPedidoVenda, "VRK_PEDIDO")))
    cCodClasseFrete := VRK->VRK_XCDCFR
  EndIf
  VRK->(DbCloseArea())

  DbSelectArea("GUB")
  GUB->(DbSetOrder(1))
  If (MsSeek(AvKey(FWxFilial("GUB"), "GUB_FILIAL") + AvKey(cCodClasseFrete, "GUB_CDCLFR")))
    cDescClasseFrete := GUB->GUB_DSCLFR
  EndIf
  GUB->(DbCloseArea())

  If aNOTA[4] == "1" // NF de saida
    cMsg += " " + AllTrim(cCodClasseFrete) + " - " + AllTrim(cDescClasseFrete) + " "
  EndIf

  Lj7RestArea(aAreas)
Return cMsg

