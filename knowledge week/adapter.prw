#include 'totvs.ch'
#include 'parmtype.ch'


//--------------------------------//
// Adapter para o serviço         //
//--------------------------------//
CLASS adapter FROM FWAdapterBaseV2
	METHOD New()
	METHOD GetListProd()
	METHOD GetProduct()
	METHOD CRUD()
EndClass

//--------------------------------//
// Método Construto               //
//--------------------------------//
Method New( cVerb, lList ) CLASS adapter
	_Super:New( cVerb, lList )
return

//---------------------------------------//
// Retorna o Json da lista de Produtos  //
//--------------------------------------//
Method GetListProd( ) CLASS adapter
	Local aArea 	AS ARRAY
	Local cWhere	AS CHAR
	aArea   := FwGetArea()
	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self )
	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery() )
	//Informa a clausula Where da Query
	cWhere := " B1_FILIAL = '"+ FWxFilial('SB1') +"' AND SB1.D_E_L_E_T_ = ' '"
	::SetWhere( cWhere )
	//Informa a ordenação a ser Utilizada pela Query
	::SetOrder( "B1_COD" )
	//Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::Execute()
		// Gera o arquivo Json com o retorno da Query
		// Pode ser reescrita, iremos ver em outro artigo de como fazer
		::FillGetResponse()
	EndIf
	FwrestArea(aArea)
RETURN

//---------------------------------------//
// Retorna o Json da lista de Produtos  //
//--------------------------------------//
Method GetProduct( cId ) CLASS adapter
	Local aArea 	AS ARRAY
	Local cWhere	AS CHAR
	aArea   := FwGetArea()
	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self )
	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery() )
	//Informa a clausula Where da Query
	cWhere := " B1_FILIAL = '"+ FWxFilial('SB1') +"' AND SB1.D_E_L_E_T_ = ' '"

	::SetWhere( "B1_FILIAL = '"+xFilial("SB1")+"' AND  B1_COD = '" + cId + "'" )
	//Informa a ordenação a ser Utilizada pela Query
	::SetOrder( "B1_COD" )
	//Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::Execute()
		// Gera o arquivo Json com o retorno da Query
		// Pode ser reescrita, iremos ver em outro artigo de como fazer
		::FillGetResponse()
	EndIf
	FwrestArea(aArea)
RETURN

Method CRUD(nOpc, cBody, cId,) CLASS adapter

    Local aVetor 	:= {}
	Local aErroAuto	:= {}
	Local nI 		:= 0
	Local oJson     := JsonObject():new()
	Local cErro		:= ""

    private lMsErroAuto := .F.
	Private lAutoErrNoFile	:= .T.

	If nOpc == 3
		oJson:fromJson(cBody)
		
		//--- Exemplo: Inclusao --- //
		aVetor:= { {"B1_COD" ,oJson['codigo'] ,NIL},;
		{"B1_DESC" ,oJson['desc'] ,NIL},;
		{"B1_TIPO" ,oJson['tipo'] ,Nil},;
		{"B1_LOCPAD" ,oJson['armazem'] ,Nil},;
		{"B1_UM" ,oJson['um'] ,Nil}}
		
		MSExecAuto({|x,y| Mata010(x,y)},aVetor,nOpc)
		
		If lMsErroAuto
			lRet := .F.
		Else
			lRet := .T.
		Endif
	Else
		oJson:fromJson(cBody)

		conout('-----------------------------------------------------------------------')
		conout('entrei na alteração com o id ' + cId + ' - ' + oJson['desc'] + ' - ' + cValToChar(nOpc))
		conout('-----------------------------------------------------------------------')


		//--- Exemplo: Alteração --- //
		aVetor:= { {"B1_COD" , cId ,NIL},;
		{"B1_DESC" ,oJson['desc'] ,NIL},;
		{"B1_TIPO" ,oJson['tipo'] ,Nil},;
		{"B1_LOCPAD" ,oJson['armazem'] ,Nil},;
		{"B1_UM" ,oJson['um'] ,Nil}}
		
		SB1->(DbSeek(xFilial("SB1") + cId))

		MSExecAuto({|x,y| Mata010(x,y)},aVetor,nOpc)

	EndIf
	
	If lMsErroAuto
		lRet := .F.
		aErroAuto := GetAutoGRLog()
		For nI := 1 To Len(aErroAuto)
			cErro += aErroAuto[nI]
		Next nI
	Else
		lRet := .T.
	Endif	

Return {lRet, cErro}

//---------------------------------------//
// Realiza o De/Para dos campos do Json  //
//--------------------------------------//
Static Function AddMapFields( oSelf )
	Local nTamField := TamSx3("B1_FILIAL")[1] + TamSx3("B1_COD")[1]

	oSelf:AddMapFields( 'INTERNALID'        , 'INTERNALID'  , .T., .T., { 'INTERNALID', 'C', nTamField, 0 }, "B1_FILIAL + B1_COD" )
	oSelf:AddMapFields( 'CODE'              , 'B1_COD'      , .T., .T., { 'B1_COD', 'C', TamSX3( 'B1_COD' )[1], 0 } )
	oSelf:AddMapFields( 'DESCRIPTION'	    , 'B1_DESC'     , .T., .F., { 'B1_DESC', 'C', TamSX3( 'B1_DESC' )[1], 0 } )
	oSelf:AddMapFields( 'GROUP'		        , 'B1_GRUPO'    , .T., .F., { 'B1_GRUPO', 'C', TamSX3( 'B1_GRUPO' )[1], 0 } )
	oSelf:AddMapFields( 'GROUPDESCRIPTION'	, 'BM_DESC'     , .T., .F., { 'BM_DESC', 'C', TamSX3( 'BM_DESC' )[1], 0 } )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Retorna a query usada no serviço
@param oSelf, object, Objeto da prórpia classe
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetQuery()
	Local cQuery AS CHARACTER

	//Obtem a ordem informada na requisição, a query exterior SEMPRE deve ter o id #QueryFields# ao invés dos campos fixos
	//necessáriamente não precisa ser uma subquery, desde que não contenha agregadores no retorno ( SUM, MAX... )
	//o id #QueryWhere# é onde será inserido o clausula Where informado no método SetWhere()
	cQuery := " SELECT #QueryFields#"
	cQuery +=   " FROM " + RetSqlName( 'SB1' ) + " SB1 "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'SBM' ) + " SBM"
	cQuery +=       " ON B1_GRUPO = BM_GRUPO"
	cQuery +=           " AND BM_FILIAL = '"+ FWxFilial( 'SBM' ) +"'"
	cQuery +=           " AND SBM.D_E_L_E_T_ = ' '"
	cQuery += " WHERE #QueryWhere#"

Return cQuery