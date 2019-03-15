#include "protheus.ch"
#include "Birtdataset.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ dsdatavl  ³Nahim Terrazas º Data ³  21/05/18        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ dataset 									      			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ USA								                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User_Dataset ddatSD1
title "dddatSD1"
description "dddatSD1"
PERGUNTE "CIABOLRP"

columns
define column DDATT type character size 10 label "DATA"
define column NRFO type character size 13 label "NFORI"
define column FNRON type character size 30 label "FORNECE"
define column QANTT type numeric size 11 label "QUANTITE"
define column VNT type numeric size 14 label "VALUNIT"

define query "SELECT * FROM %WTable:1% "

process dataset
Local cWTabAlias
Local cTemp	:= getNextAlias()

Private dFecha1
Private dFecha2
Private nCont:= 0


if ::isPreview()
endif

	cWTabAlias := ::createWorkTable()
	dFecha1 := self:execParamValue( "MV_PAR01" )
	dFecha2 := self:execParamValue( "MV_PAR02" )
	cProducto := self:execParamValue( "MV_PAR04" )

cursorwait()

BeginSql alias cTemp

	SELECT D1_EMISSAO, D1_DOC, A2_NOME, D1_QUANT, D1_VUNIT
	FROM %table:SD1% SD1
	left join %table:SA2% SA2 on D1_FORNECE = A2_COD AND SA2.%notDel%
	WHERE D1_EMISSAO BETWEEN %Exp:DTOS(dFecha1)% and %Exp:DTOS(dFecha2)%
	and D1_COD LIKE %exp:cProducto%
	AND SD1.%notDel%
	order by D1_EMISSAO , D1_DOC desc
EndSql

cursorarrow()

dbSelectArea( cTemp )
(cTemp)->(dbGotop())

While (cTemp)->(!EOF())

	nCont++

	RecLock(cWTabAlias, .T.)
	cEmissao := alltrim((cTemp)->D1_EMISSAO)
	cAnho := SubStr(cEmissao, 1,4 )
	cDia  := SubStr(cEmissao, 5,2 )
	cMes  := SubStr(cEmissao, 7,2 )
	cEmissao := cMes + "/" + cDia + "/" + cAnho


 
	(cWTabAlias)->DDATT    := cEmissao
	(cWTabAlias)->NRFO 	   := (cTemp)->D1_DOC
	(cWTabAlias)->FNRON    := (cTemp)->A2_NOME
	(cWTabAlias)->QANTT    := (cTemp)->D1_QUANT
	(cWTabAlias)->VNT 	   := (cTemp)->D1_VUNIT

	(cWTabAlias)->(MsUnlock())
	(cTemp)->(dbSkip())

EndDo

Return .T.
