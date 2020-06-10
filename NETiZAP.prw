#include 'protheus.ch'

/* ======================================================================
Classe		NETIZAP
Autor		Júlio Wittwer
Data 		12/2019
Descrição 	Classe em AdvPL que encapsula o seviço de integracão 
			com o WhatsApp oferecido pela NETIZAP

Classe criada com base na Documentação da API NETIZAP
https://documenter.getpostman.com/view/2747664/SVSPnmoH?version=latest

*** Este fonte não depende do projeto ZLIB  ***
Pode ser compilado em qualquer TOTVS Application Server , Windows ou Linux, 
32 ou 64 bits, com build igual ou superior a 7.00.131227

====================================================================== */

#define NETIZAP_ADVPL_BUILD   'NetiZap AdvPL 1.0.0'
#define NETIZAP_DEFAULT_HOST  'http://api.meuaplicativo.vip'
#define NETIZAP_DEFAULT_PORT  13005

// --------------------------------------------------

CLASS NETIZAP FROM LONGNAMECLASS

	DATA cHostBase
	DATA nPortBase
	DATA cLastError
	DATA nLastStatus
	DATA cHeaderRet
	DATA cResponse
	DATA cLine
	DATA cDestiny
	DATA cReference
	DATA cText
	DATA cQuestion
	DATA cApp
	DATA cAccessKey
	DATA nTimeOutMS
	DATA cFileName
	DATA cFileType
	DATA cFileStream
	DATA cProtocol
	DATA aHeadOut
	DATA cAuthBasic
	DATA bLogBlock

	METHOD NEW()				// Cria um nova instância da classe
	METHOD SetLine()			// Informa o numero da linha de origem da chamada 
	METHOD SetAccessKey()       // Informa a chave de acesso associada a linha de origem
	METHOD SetPort()			// Informa a porta do provedor de seviços HTTP ( default = 12005 ) 
	METHOD Reset()				// Limpa as propriedades para uma nova requisiçao 
	METHOD SetLogger()			// Informa um Bloco de Codigo de Callback para registro de LOG

	// Parametros para uso dos serviços 
	METHOD SetDestiny() 		// Informa o numero do destinatario para operações *Send()
	METHOD SetReference()		// Informa um valor de referencia opcional para operações *Send()
	METHOD SetText()			// Informa um texto para operações *Send()
	METHOD SetQuestion()		// Informa as respostas válidas para a operação QuestioSend()
	METHOD SetFile()			// Informa um tipo, conteudo e nome de arquivo para a operação FileSend()
	METHOD SetProtocol()		// Informa um numero de protocolo de mensagems para MessageSearch e QuestionSearch
	METHOD SetTimeOutMS()		// Define o TimeOut em milissegundos para retorno de chamada de API 

	// Serviços oferecidos	
	METHOD MessageSend()		// Envio de mensagens para um destinatario ou grupo 
	METHOD QuestionSend()		// Envio de uma pergunta com respostas predefinidas
	METHOD FileSend()			// Envio de mensagem com arquivo anexo 
	METHOD MessageSearch()		// Confirma se uma mensagem foi lida e/ou recebida 
	METHOD QuestionSearch()		// Confirma se uma pergunta enviada foi lida e/ou respondida
	METHOD GroupSearch()		// Busca por grupos 
	METHOD BroadcastSearch()	// Busca por listas de trannsmissao
	METHOD CheckCredits()		// Consulta status de creditos da API 
	METHOD RequestsStart()		// Consulta requisições realizadas

	// Miscelânea
	METHOD GetResponse()		// Recupera o corpo da resposta da ultima requisição HTTP 
	METHOD GetHeaderResponse()  // Recupera o HEader HTTP de resposta da ultima requisição HTTP 
	METHOD GetStatus()          // Recupera o codigo HTTP de retorno  da ultima requisição HTTP 
	METHOD GetLastError()		// Recupera o últim erro da classe NETIZAP
	METHOD ValidBase()			// Valida os parametros minimos comuns que devem ser informados 
	
ENDCLASS

// --------------------------------------------------
// Cria a instancia da classe de integração com os valores default
// Permite receber 

METHOD NEW(cLine,cAccessKey,nPort) CLASS NETIZAP           

::cHostBase   := NETIZAP_DEFAULT_HOST
::nPortBase   := NETIZAP_DEFAULT_PORT
::cApp        := NETIZAP_ADVPL_BUILD
::cAuthBasic  := 'Authorization: Basic '+Encode64("user:api")
::nTimeOutMS  := (20*1000)
::bLogBlock   := NIL
::cLine       := ''
::cAccessKey  := ''

// Pode receber a linha de origem e a chave de acesso no construtor
// Esses parametros sao necessários para qualquer requisição 
If !empty(cLine)
	::cLine       := cLine
Endif

If !empty(cAccessKey)
	::cAccessKey  := cAccessKey
Endif

IF !empty(nPort)
	::nPortBase := nPort
Endif

// Inicializa todas as demais propriedades relacionadas a API 
::cLastError   := ''
::cHeaderRet   := ''
::cResponse    := ''
::cDestiny     := ''
::cReference   := ''
::cText        := ''
::cQuestion    := ''
::cFileName    := ''
::cFileType    := ''
::cFileStream  := ''
::cProtocol    := ''

// Monta o header HTTP de saída, comum a todas as requisições
::aHeadOut := {}
aadd(::aHeadOut,'Content-Type: application/x-www-form-urlencoded')
aadd(::aHeadOut,::cAuthBasic)
aadd(::aHeadOut,'Accept-Charset: UTF-8')
aadd(::aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

Return self

// Seta um Bloco de Codigo para gravaçao de log de chamadas da API 
METHOD SetLogger(bLogBlock) CLASS NETIZAP
::bLogBlock := bLogBlock
REturn

// --------------------------------------------------
// Reseta as propriedades usadas para envio de requisições

METHOD RESET() CLASS NETIZAP
::cLastError   := ''
::cHeaderRet   := ''
::cResponse    := ''
::cDestiny     := ''
::cReference   := ''
::cText        := ''
::cQuestion    := ''
::cFileName    := ''
::cFileType    := ''
::cFileStream  := ''
::cProtocol    := ''
Return

// --------------------------------------------------
// Informa a chave de acesso para o serviço

METHOD SetAccessKey(cAccessKey) CLASS NETIZAP
::cAccessKey := alltrim(cAccessKey)
Return

// --------------------------------------------------
// Informa a porta HTTP do servidor da API 

METHOD SetPort(nPort) CLASS NETIZAP
::nPortBase := nPort
Return

// --------------------------------------------------
// Informa a linha de origem registrada para o serviço

METHOD SetLine(cLine) CLASS NETIZAP
::cLine := alltrim(cLine)
Return

// --------------------------------------------------
// Informa o numero de telefone de destino 

METHOD SetDestiny(cDestiny) CLASS NETIZAP
::cDestiny := alltrim(cDestiny)
Return

// --------------------------------------------------
// Informa um valor de referencia para uso posterior

METHOD SetReference(cReference) CLASS NETIZAP
::cReference := alltrim(cReference)
Return

// --------------------------------------------------
// Informa o texto da mensagem 
METHOD SetText(cText) CLASS NETIZAP
::cText := alltrim(cText)
Return

// --------------------------------------------------
// Informa resposta(s) para envio de uma questão 

METHOD SetQuestion(cQuestion) CLASS NETIZAP
::cQuestion := alltrim(cQuestion)
Return

// --------------------------------------------------
// Informa um arquivo a ser enviado 

METHOD SetFile(cFileName,cFileType,cFileStream) CLASS NETIZAP
::cFileName := alltrim(cFileName)
::cFileType := alltrim(Upper(cFileType))
::cFileStream := cFileStream
Return

// --------------------------------------------------
// Reconfigura o timeout de retorno de requisição 
// Default = 20000 ( 20 segundos ) 
METHOD SETTIMEOUTMS(nTimeOutMS)  CLASS NETIZAP
::nTimeOutMS := nTimeOutMS
Return

// --------------------------------------------------
// Informa um numero de protocolo de mensagem para uma operação 

METHOD SETPROTOCOL(cProtocol)  CLASS NETIZAP
::cProtocol := alltrim(cProtocol)
Return

// --------------------------------------------------
// Realiza o envio de uma mensagem 
// Requer o numero do telefone de destino e a mensagem 
// Permite setar um valor de referencia para uso posterior

METHOD MessageSend() CLASS NETIZAP
Local cUrlPost
Local cUrlParms
Local cPostParms
Local nTimer

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('MessageSend()')
	Return .F.
Endif         

If empty(::cDestiny)
	::cLastError := 'MessageSend() ERROR - Destiny is missing'
	Return .F.
Endif

If empty(::cText)
	::cLastError := 'MessageSend() ERROR - Text is missing'
	Return .F.
Endif

// Monta url/host para a requisição
cUrlPost := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/message_send"

// Monta o Corpo do Post / Formulario 
cPostParms := 'App='+UrlEncode(::cApp)
cPostParms += '&AccessKey='+UrlEncode(::cAccessKey)

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&destiny=' + UrlEncode(::cDestiny)
cUrlParms += '&reference=' + UrlEncode(::cReference)
cUrlParms += '&text=' + UrlEncode(::cText)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPPOST(cUrlPost,cUrlParms,cPostParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlPost,cUrlParms,cPostParms,::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	::cLastError := 'HTTP ERROR ('+cValToChar(::nLastStatus)+') : '+ ::cLastError
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Envio de uma pergunta ao destinatario 
// Requer a linha de destino, a mensagem, a(s) resposta(s) válidas

METHOD QuestionSend() CLASS NETIZAP
Local cUrlPost
Local cUrlParms
Local cPostParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('QuestionSend()')
	Return .F.
Endif         

If empty(::cDestiny)
	::cLastError := 'QuestionSend() ERROR - Destiny is missing'
	Return .F.
Endif

If empty(::cText)
	::cLastError := 'QuestionSend() ERROR - Text is missing'
	Return .F.
Endif

If empty(::cQuestion)
	::cLastError := 'QuestionSend() ERROR - Question is missing'
	Return .F.
Endif

// Monta url/host para a requisição
cUrlPost := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/question_send"

// Monta o Corpo do Post / Formulario 
cPostParms := 'App='+UrlEncode(::cApp)
cPostParms += '&AccessKey='+UrlEncode(::cAccessKey)

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + ::cLine
cUrlParms += '&destiny=' + ::cDestiny
cUrlParms += '&reference=' + ::cReference
cUrlParms += '&text=' + UrlEncode(::cText)
cUrlParms += '&question=' + UrlEncode(::cQuestion)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPPOST(cUrlPost,cUrlParms,cPostParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlPost,cUrlParms,cPostParms,::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Envio de mensagem com arquivo anexo 
// Requer a linha de destino, a mensagem, o tipo do arquivo, 
// o conteudo (binário) e o nome do arquivo a ser informado na memsagem 

METHOD FileSend() CLASS NETIZAP
Local cUrlPost
Local cUrlParms
Local cPostParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('FileSend()')
	Return .F.
Endif         

If empty(::cDestiny)
	::cLastError := 'FileSend() ERROR - Destiny is missing'
	Return .F.
Endif

If empty(::cText)
	::cLastError := 'FileSend() ERROR - Text is missing'
	Return .F.
Endif

If empty(::cFileType)
	::cLastError := 'FileSend() ERROR - File Type is missing'
	Return .F.
Endif

If empty(::cFileStream)
	::cLastError := 'FileSend() ERROR - File Stream is missing'
	Return .F.
Endif

// Monta url/host para a requisição
cUrlPost := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/file_send"

// Monta o Corpo do Post / Formulario 
cPostParms := 'app='+URLEncode(::cApp)
cPostParms += '&key='+URLEncode(::cAccessKey)
cPostParms += '&text='+UrlEncode(::cText)
cPostParms += '&type='+URLEncode(::cFileType)
cPostParms += '&stream='+UrlEncode(::cFileStream)
cPostParms += '&filename='+UrlEncode(::cFileName)

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + ::cLine
cUrlParms += '&destiny=' + ::cDestiny
cUrlParms += '&reference=' + ::cReference

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPPOST(cUrlPost,cUrlParms,cPostParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlPost,cUrlParms,cPostParms,::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif


Return .T.

// --------------------------------------------------
// Busca pelo status de uma determinada mensagem enviada
// Requer o numero do protocolo da mensagem, retornado pelo MEssageSend()

METHOD MessageSearch() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('MessageSearch()')
	Return .F.
Endif         

If empty(::cProtocol)
	::cLastError := 'MessageSearch() ERROR - Protocol is missing'
	Return .F.
Endif

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/message_search"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&AccessKey='+UrlEncode(::cAccessKey)
cUrlParms += '&protocol=' + UrlEncode(::cProtocol)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Busca pelo status de uma determinada pergunta enviada
// Requer o numero do protocolo da pergunta , retornado pelo QuestionSend()

METHOD QuestionSearch() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('QuestionSearch()')
	Return .F.
Endif         

If empty(::cProtocol)
	::cLastError := 'QuestionSearch() ERROR - Protocol is missing'
	Return .F.
Endif

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/question_search"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&AccessKey='+UrlEncode(::cAccessKey)
cUrlParms += '&protocol=' + UrlEncode(::cProtocol)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Verifica quais os grupos de envio de mensagens estão registrados 
// para a linha de origem definida. Nao requer parametros

METHOD GroupSearch() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('GroupSearch()')
	Return .F.
Endif         

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/group_search"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&AccessKey='+UrlEncode(::cAccessKey)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Consulta as listas de transmissão que estão registrados 
// para a linha de origem definida. Nao requer parametros

METHOD BroadcastSearch() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('BroadcastSearch()')
	Return .F.
Endif         

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/broadcast_search"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&AccessKey='+UrlEncode(::cAccessKey)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Verifica o estado do plano atual junto a NetIZap
// Nao requer parametros adicionais

METHOD CheckCredits() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 
IF !::ValidBase('CheckCredits()')
	Return .F.
Endif         

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/services/check_credits"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&key='+UrlEncode(::cAccessKey)

// Submete a requisiçao 
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.

// --------------------------------------------------
// Consulta o envio de requisições já realizado pela API 
// Nao requer parametros adicionais

METHOD RequestsStart() CLASS NETIZAP
Local cUrlGet
Local cUrlParms

::cLastError := ''

// Validação das propriedades necessárias 

IF !::ValidBase('RequestsStart()')
	Return .F.
Endif         

// Monta url/host para a requisição
cUrlGet := ::cHostBase + ":" + cValToChar(::nPortBase) + "/reports/requests_start"

// Monta os parametros para URL / GET 
cUrlParms := 'line=' + UrlEncode(::cLine)
cUrlParms += '&AccessKey='+UrlEncode(::cAccessKey)

// Submete a requisiçao GET
::cHeaderRet := ''
nTimer := seconds()
::cResponse := HTTPGET(cUrlGet,cUrlParms,::nTimeOutMS,::aHeadOut,@::cHeaderRet)
nTimer := seconds()-nTimer

IF valtype(::bLogBlock)=='B'
	Eval(::bLogBlock,cUrlGet,cUrlParms,"",::cHeaderRet,::cResponse,nTimer) 
Endif

// Recupera o status da requisição 
::nLastStatus := HttpGetStatus(@::cLastError)

// Avalia se a requisição foi submetida e se o retorno é válido
If ::nLastStatus != 200         
	IF empty(::cLastError)
		::cLastError := 'Unknow Error on HTTPPOST'
	Endif
	Return .F.
Endif

Return .T.


// --------------------------------------------------
// Obtem a string com a resposta da ultima chamada de API realizada

METHOD GetResponse() CLASS NETIZAP
Return ::cResponse

// --------------------------------------------------
// Obtem o Header HTTP de retorno da ultima chamada de API realizada 

METHOD GetHeaderResponse() CLASS NETIZAP
Return ::cHeaderRet

// --------------------------------------------------
// Obtem a descrição do último erro da API 
// Observação : Um erro é definido quando não foi possível 
// o envio de uma requisição, ou houve um retorno inesperado. 
// Cada chamada possui o seu formato de retorno, com um JSON
// informando se a operação foi realizada com sucesso ou não 

METHOD GetLastError() CLASS NETIZAP
Return ::cLastError


// --------------------------------------------------
// Retorna o ultimo status HTTP de uma chamada de API 

METHOD GetStatus() CLASS NETIZAP
Return ::nLastStatus


// --------------------------------------------------
// Valida os argumentos básicos para envio de qualquer mensagem 
// Precisa pelo menos da linha de origem e da access key 

METHOD ValidBase(cMethod) CLASS NETIZAP

If empty(::cLine)
	::cLastError := cMethod+' ERROR - Line is missing.'
	Return .F.
Endif

IF empty(::cAccessKey)
	::cLastError := cMethod+' ERROR - AccessKey is missing.'
	Return .F.
Endif

Return .T. 

// --------------------------------------------------
// Realiza a codificação de dados para URL e/ou POST 

STATIC Function URLEncode(cValue)
Local nI , cRet := '', cChar
For nI := 1 to len(cValue)
	cChar := substr(cValue,nI,1)
	IF asc(cChar) < 32 
		IF asc(cChar) == 13 // ( CR - Ignora ) 
			LOOP		
		ElseIF asc(cChar) == 10 // ( LF - TRoca para "\n" ) 
			cRet += '\n' 
		Else
			// Converte para hexadecimal, formato %HH
			cRet += '%'+PADL(Upper(__DecToHex(asc(cChar))),2,'0')
	    Endif
	ElseIf cChar >= ' ' .and. cChar <= '/'
		// Converte para hexadecimal, formato %HH
		cRet += '%'+PADL(Upper(__DecToHex(asc(cChar))),2,'0')
	ElseIf cChar >= '0' .and. cChar <= '9'
		cRet += cChar
	ElseIf cChar >= 'A' .and. cChar <= 'Z'
		cRet += cChar
	ElseIf cChar >= 'a' .and. cChar <= 'z'
		cRet += cChar
	Else
		// Converte para hexadecimal, formato %HH
		cRet += '%'+PADL(Upper(__DecToHex(asc(cChar))),2,'0')
	Endif
Next
Return cRet

