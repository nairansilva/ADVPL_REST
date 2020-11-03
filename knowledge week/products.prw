#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"


//-------------------------------------//
// Define os m�todos dispon�veis no WS //
//-------------------------------------//
WSRESTFUL products DESCRIPTION 'endpoint products API' FORMAT "application/json,text/html"
    WSDATA Page     AS INTEGER OPTIONAL
    WSDATA PageSize AS INTEGER OPTIONAL
    WSDATA aQueryString AS ARRAY OPTIONAL
    WSDATA Product AS CHARACTER OPTIONAL
    
 	WSMETHOD GET teste;
	    DESCRIPTION "Retorna uma lista de produtos";
	    WSSYNTAX "/api/v1/teste" ;
        PATH "/api/v1/teste" ;
	    PRODUCES APPLICATION_JSON

 	WSMETHOD GET ProdList;
	    DESCRIPTION "Retorna uma lista de produtos";
	    WSSYNTAX "/api/v1/products" ;
        PATH "/api/v1/products" ;
	    PRODUCES APPLICATION_JSON

 	WSMETHOD GET Product;
	    DESCRIPTION "Retorna um produto espec�fico";
	    WSSYNTAX "/api/v1/products/{Product}" ;
        PATH "/api/v1/products/{Product}" ;
	    PRODUCES APPLICATION_JSON

 	WSMETHOD POST Product;
	    DESCRIPTION "Inclui um Produto";
	    WSSYNTAX "/api/v1/products/" ;
        PATH "/api/v1/products/" ;
	    PRODUCES APPLICATION_JSON

 	WSMETHOD PUT Product;
	    DESCRIPTION "Altera um Produto";
	    WSSYNTAX "/api/v1/products/{Product}" ;
        PATH "/api/v1/products/{Product}" ;
	    PRODUCES APPLICATION_JSON

 	WSMETHOD DELETE Product;
	    DESCRIPTION "Exclui um Produto";
	    WSSYNTAX "/api/v1/products/{Product}" ;
        PATH "/api/v1/products/{Product}" ;
	    PRODUCES APPLICATION_JSON
 	
END WSRESTFUL

//-------------------------------------//
// M�todo Get TESTE                    //
//-------------------------------------//
WSMETHOD GET teste QUERYPARAM Page WSSERVICE products
Return teste(self)

//-------------------------------------//
// M�todo Get All dos Produtos         //
//-------------------------------------//
WSMETHOD GET ProdList QUERYPARAM Page WSSERVICE products
Return getPrdList(self)

//-------------------------------------//
// M�todo Get Produto espec�fico       //
//-------------------------------------//
WSMETHOD GET Product PATHPARAM Product  WSSERVICE products
Return getProduct(self, self:Product)

//-------------------------------------//
// M�todo POST Produtos                //
//-------------------------------------//
WSMETHOD POST Product QUERYPARAM Page WSSERVICE products
Return ManutProd(3, self)

//-------------------------------------//
// M�todo PUT Produtos                //
//-------------------------------------//
WSMETHOD PUT Product PATHPARAM Product WSSERVICE products
Return ManutProd(4, self, self:Product)

//-------------------------------------//
// M�todo delete Produtos                //
//-------------------------------------//
WSMETHOD DELETE Product PATHPARAM Product WSSERVICE products
Return ManutProd(5, self, self:Product)

//-------------------------------------//
// Retorna todos os Produtos           //
//-------------------------------------//
Static Function getPrdList( oWS )
   Local lRet  as logical
   Local oProd as object
   DEFAULT oWS:Page      := 1 
   DEFAULT oWS:PageSize := 10 
   lRet        := .T.
   
   //PrdAdapter ser� nossa classe que implementa fornecer os dados para o WS
   // O primeiro parametro indica que iremos tratar o m�todo GET
   oProd := adapter():new( 'GET', .T. )
  
   //o m�todo setPage indica qual p�gina deveremos retornar
   //ex.: nossa consulta tem como resultado 100 produtos, e retornamos sempre uma listagem de 10 itens por p�gina.
   // a p�gina 1 retorna os itens de 1 a 10
   // a p�gina 2 retorna os itens de 11 a 20
   // e assim at� chegar ao final de nossa listagem de 100 produtos 
   oProd:setPage(oWS:Page)
   // setPageSize indica que nossa p�gina ter� no m�ximo 10 itens
   oProd:setPageSize(oWS:PageSize)
   // Esse m�todo ir� processar as informa��es

   //Ir� transferir as informa��es de filtros da url para o objeto
   oProd:SetUrlFilter( oWS:aQueryString )

   oProd:GetListProd()
   //Se tudo ocorreu bem, retorna os dados via Json
   If oProd:lOk
       oWS:SetResponse(oProd:getJSONResponse())
   Else
   //Ou retorna o erro encontrado durante o processamento
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   EndIf
   //faz a desaloca��o de objetos e arrays utilizados
   oProd:DeActivate()
   oProd := nil
   
Return lRet

//-------------------------------------//
// Retorna um Produto Espec�fico       //
//-------------------------------------//
Static Function getProduct( oWS, cId )
   Local lRet  as logical
   Local oProd as object
   DEFAULT oWS:Page      := 1 
   DEFAULT oWS:PageSize := 10 
   lRet        := .T.
   
   //PrdAdapter ser� nossa classe que implementa fornecer os dados para o WS
   // O primeiro parametro indica que iremos tratar o m�todo GET
   oProd := adapter():new( 'GET', .F. )
  
   //o m�todo setPage indica qual p�gina deveremos retornar
   //ex.: nossa consulta tem como resultado 100 produtos, e retornamos sempre uma listagem de 10 itens por p�gina.
   // a p�gina 1 retorna os itens de 1 a 10
   // a p�gina 2 retorna os itens de 11 a 20
   // e assim at� chegar ao final de nossa listagem de 100 produtos 
   oProd:setPage(oWS:Page)
   // setPageSize indica que nossa p�gina ter� no m�ximo 10 itens
   oProd:setPageSize(oWS:PageSize)
   // Esse m�todo ir� processar as informa��es

   //Ir� transferir as informa��es de filtros da url para o objeto
   oProd:SetUrlFilter( oWS:aQueryString )

    conout(cId)
   oProd:GetProduct(cId)
   //Se tudo ocorreu bem, retorna os dados via Json
   If oProd:lOk
       oWS:SetResponse(oProd:getJSONResponse())
   Else
   //Ou retorna o erro encontrado durante o processamento
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   EndIf
   //faz a desaloca��o de objetos e arrays utilizados
   oProd:DeActivate()
   oProd := nil
   
Return lRet

Static Function ManutProd(nOpc, oWs, cProduct)
    Local cBody 	  		:= oWs:GetContent()
    Local oProd as object
    Local aRet := {.T.,''}

    Default cProduct := ''

    oProd := adapter():new( 'POST')

    aRet := oProd:CRUD(nOpc, cBody, cProduct)

	If aRet[1]
		oWs:SetResponse( 'Sucesso' )
	Else
		SetRestFault( 500, aRet[2] )
	EndIf

Return aRet[1]

static function teste(oWs)

    Local oJson     := JsonObject():new()
    Local cTextJson := '{"itens":[{"joao":"maria","jos�":"joana","joaquim":"joaquina","juscelino":"joice"},{"limao":"verde","banana":"amarelo","ma�a":"vermelho","amora":"roxo"}], hasNext:false}'
    Local cRet := oJson:FromJson(cTextJson)
  if ValType(cRet) == "C"
    conout("Falha ao transformar texto em objeto json. Erro: " + ret)
    return
  endif

    oWs:SetResponse( oJson:toJSON() )
return .T.