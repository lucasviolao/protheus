#include "totvs.ch"
#include "topconn.ch"
#include "protheus.ch"

/**************************************************************************************************
{Protheus.doc} M460FIM
@description	Ponto de entrada para processamento após a inclusão do documento de saída
@type   		User Function
@author			Ruann Carlos
@version   		1.00
@since     		17/09/2025
**************************************************************************************************/
user function M460FIM()

   Local aArea            := FwGetArea()
   Local aAreaSD2         := SD2->(FwGetArea())
   Local aAreaSF2         := SF2->(FwGetArea())

   If ExistBlock("PPE90513")
      U_PPE90513()
   Endif

   If ExistBlock("PPE58801")
      U_PPE58801()
   Endif

   If ExistBlock("PPE87602")
      U_PPE87602()
   Endif

   If (ExistBlock("PPE03702"))
	   ExecBlock("PPE03702", .F., .F., PARAMIXB)
	EndIf

   If ExistBlock("PPE81511")
      U_PPE81511()
   Endif

   IF ExistBlock("PPE1021A")
      U_PPE1021A()
   EndIf

   //Gap 816 - Rubens Guilardi Jr. - Gerar CDL para nota faturarada.
   If ExistBlock("PPE81611")
      U_PPE81611()
   Endif

   FwRestArea(aArea)
   FwRestArea(aAreaSD2)
   FwRestArea(aAreaSF2)

return

