#include 'protheus.ch'

/* ======================================================================
Funcao		U_IzapClient
Autor		Júlio Wittwer
Data 		01/2020
Descrição 	Programa de demonstração e uso da API de Mensagens WhatsApp NETIZAP

Funcionalidades da API encapsuladas pela classe NETIZAP()

====================================================================== */

// --- Chaves de demonstração da API  ----
#define NETIZAP_DEMO_KEY    'A9CostEuLiQpiCC5IH7w'
#define NETIZAP_DEMO_LINE   '5527981049976'
#define NETIZAP_DEMO_PORT   13005

#define CALCSIZESAY( X )  (( X * 4 ) + 4)

User Function IzapClient()

Local oMainWnd
Local cTitle      := "AdvPL NETIZAP Client 1.0.0"
Local oFont
Local oNetIZap
Local nPort       := 0
Local cAccessKey  := space(30)
Local cLine       := space(15)
Local cDestiny    := space(60)
Local cText       := ''
Local cProtocol   := space(36) // Formato "@!"
Local cQuestion   := space(30)
Local cReference  := space(60)
Local cFileName   := space(20)
Local cFileType   := space(3)
Local cFile2Send  := space(60) 
Local cResponse   := ''

// Formato de Data 
SET DATE BRITISH
SET CENTURY ON 

// Usa uma fonte Fixed Size
oFont := TFont():New('Courier new',,-14,.T.,.T.)

// Cria a janela principal
DEFINE DIALOG oMainWnd FROM 0,0 to 768,1280 PIXEL ; 
  FONT oFont ;
	TITLE (cTitle) COLOR CLR_BLACK, CLR_WHITE  

// Cria o painel superior 
@ 0,0 MSPANEL oPanelSup OF oMainWnd SIZE 10,60 COLOR CLR_BLACK,CLR_HGRAY
oPanelSup:ALIGN := CONTROL_ALIGN_TOP

// Painel central ocupa o resto da tela
@ 0,0 MSPANEL oPanelDown OF oMainWnd SIZE 10,60 COLOR CLR_BLACK,CLR_WHITE
oPanelDown:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Objeto de uso da API Client
oNetIZap := NETIZAP():New()   

// Coloca os componentes comuns no painel superior 

@ 05,10 SAY "Line (Telefone de Origem)"   SIZE 120,12 OF oPanelSup PIXEL 

@ 05-2,140 GET oGet01 VAR cLine SIZE 80,12 OF oPanelSup PIXEL 
oGet01:SetEnable(.F.)

@ 20,10 SAY "AccessKey (Chave de Acesso)" SIZE 120,12 OF oPanelSup PIXEL 

@ 20-2,140 GET oGet02 VAR cAccessKey SIZE 140,12 OF oPanelSup PIXEL 
oGet02:SetEnable(.F.)

@ 35,10 SAY "Porta (Porta HTTP da API)"   SIZE 120,12 OF oPanelSup PIXEL 

@ 35-2,140 GET oGet03 VAR nPort SIZE 40,12 OF oPanelSup PIXEL 
oGet03:SetEnable(.F.)

@ 05,300 BUTTON oBtn PROMPT "Chaves de Demonstração" SIZE 120,12 ;
  ACTION ( oGet01:SetEnable(.F.),oGet02:SetEnable(.F.),oGet03:SetEnable(.F.),;
	  eval(oGet01:bSetGet,padr(NETIZAP_DEMO_LINE,15)),;
	  eval(oGet02:bSetGet,padr(NETIZAP_DEMO_KEY,30)),;
	  eval(oGet03:bSetGet,NETIZAP_DEMO_PORT) ) OF oPanelSup PIXEL 

@ 20,300 BUTTON oBtn PROMPT "Informar Chaves" SIZE 120,12 ;
  ACTION ( oGet01:SetEnable(.T.),oGet02:SetEnable(.T.),oGet03:SetEnable(.T.)) OF oPanelSup PIXEL 

// Cria um splitter no painel central

oSplitter := tSplitter():New( 01,01,oPanelDown,260,184 )
oSplitter:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Painel central dividido em opcoes e status
@ 0,0 MSPANEL oPanelOpt OF oSplitter SIZE 256,60 COLOR CLR_BLACK,CLR_WHITE 
oPanelOpt:ALIGN := CONTROL_ALIGN_ALLCLIENT

@ 0,0 MSPANEL oPanelStat OF oSplitter SIZE 256,60 COLOR CLR_BLACK,CLR_WHITE 
oPanelStat:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Folder com as opções
@ 0,0 FOLDER oFolders PROMPTS 	"MessageSend","QuestionSend","FileSend",;
								"MessageSearch","QuestionSearch","GroupSearch",;
								"BroadcastSearch","CheckCredits","RequestsStart" ;
								COLOR CLR_BLACK,CLR_WHITE OF oPanelOpt  PIXEL

oFolders:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Folder unico com Status
@ 0,0 FOLDER oFldStat PROMPTS 	"Retorno da Requisição" ;
								COLOR CLR_BLACK,CLR_WHITE OF oPanelStat  PIXEL

oFldStat:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Aba 1 -- MessageSend 

oAba1 := oFolders:aDialogs[1] 

@ 10,10 SAY "Destiny (Telefone de Destino)"   SIZE 180,12 OF oAba1 PIXEL 
@ 25-2,10 GET oGet04 VAR cDestiny SIZE 200,12 OF oAba1 PIXEL 

@ 40,10 SAY "Reference (Referência - opcional) " SIZE 180,12 OF oAba1 PIXEL 
@ 55-2,10 GET oGet05 VAR cReference SIZE 200,12 OF oAba1 PIXEL 

@ 70,10 SAY "Text (Mensagem a enviar) " SIZE 180,12 OF oAba1 PIXEL 
@ 85-2,10 GET oGet06 VAR cText MULTILINE SIZE 200,48 OF oAba1 PIXEL 

@ 140,10 BUTTON oBtn PROMPT "Enviar Mensagem" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												oNetIZap:SetDestiny(cDestiny),;
												oNetIZap:SetReference(cReference),;
												oNetIZap:SetText(EncodeUTF8(cText)),;
												MsgRun("Enviando Mensagem...","Aguarde",{||MsgSend(oNetIZap,oGetResponse)}) ) ;
												OF oAba1 PIXEL 

@ 155,10 SAY "Para enviar para um grupo ou lista de broadcast, utilize em 'destiny' o código de um grupo ou lista, "+;
			 "que podem ser obtidos nas abas GroupSearch e/ou BroadcastSearch." SIZE 200,120 OF oAba1 PIXEL 

// Folder 2 -- "QuestionSend"

oAba2 := oFolders:aDialogs[2]

@ 10,10 SAY "Destiny (Telefone de Destino)"   SIZE 180,12 OF oAba2 PIXEL 
@ 25-2,10 GET oGet07 VAR cDestiny SIZE 200,12 OF oAba2 PIXEL 

@ 40,10 SAY "Reference (Referência - opcional) " SIZE 180,12 OF oAba2 PIXEL 
@ 55-2,10 GET oGet08 VAR cReference SIZE 200,12 OF oAba2 PIXEL 

@ 70,10 SAY "Text (Mensagem a enviar) " SIZE 180,12 OF oAba2 PIXEL 
@ 85-2,10 GET oGet09 VAR cText MULTILINE SIZE 200,48 OF oAba2 PIXEL 

@ 140,10 SAY "Question (Respostas)" SIZE 180,12 OF oAba2 PIXEL 
@ 155-2,10 GET oGet10 VAR cQuestion SIZE 200,12 OF oAba2 PIXEL 

@ 175,10 BUTTON oBtn2 PROMPT "Enviar Pergunta" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												oNetIZap:SetDestiny(cDestiny),;
												oNetIZap:SetReference(cReference),;
												oNetIZap:SetText(EncodeUTF8(cText)),;
												oNetIZap:SetQuestion(EncodeUTF8(cQuestion)),;
												MsgRun("Enviando Questao...","Aguarde",{||QSend(oNetIZap,oGetResponse)}) ) ;
												OF oAba2 PIXEL 


@ 190,10 SAY "Uma questão aguarda uma resposta, onde as respostas que podem ser marcadas como válidas "+;
			 "deve ser especificadas entre colchetes e separadas por ponto e vírgula. A resposta da pergunta "+;
			 "pode ser consultada pelo protocolo gerado no envio, usando o método QuestionSearch()." SIZE 200,120 OF oAba2 PIXEL 



// Folder 3 -- "FileSend"

oAba3 := oFolders:aDialogs[3]

@ 10,10 SAY "Destiny (Telefone de Destino)"   SIZE 180,12 OF oAba3 PIXEL 
@ 25-2,10 GET oGet11 VAR cDestiny SIZE 200,12 OF oAba3 PIXEL 

@ 40,10 SAY "Reference (Referência - opcional) " SIZE 180,12 OF oAba3 PIXEL 
@ 55-2,10 GET oGet12 VAR cReference SIZE 200,12 OF oAba3 PIXEL 

@ 70,10 SAY "Text (Mensagem a enviar) " SIZE 180,12 OF oAba3 PIXEL 
@ 85-2,10 GET oGet13 VAR cText MULTILINE SIZE 200,48 OF oAba3 PIXEL 

@ 140,10 SAY "File (Arquivo da Mensagem)" SIZE 180,12 OF oAba3 PIXEL 
@ 155-2,10 GET oGet14 VAR cFileName SIZE 200,12 OF oAba3 PIXEL 

@ 170,10 SAY "Arquivo a Enviar" SIZE 180,12 OF oAba3 PIXEL 
@ 185-2,10 GET oGetF VAR cFile2Send SIZE 200,12 OF oAba3 PIXEL 

@ 200,10 SAY "Tipo do Arquivo" SIZE 180,12 OF oAba3 PIXEL 
@ 215-2,10 GET oGetF VAR cFileType PICTURE "@!" SIZE 30,12 OF oAba3 PIXEL 

@ 235,10 BUTTON oBtn3 PROMPT "Envia Arquivo" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												oNetIZap:SetDestiny(cDestiny),;
												oNetIZap:SetReference(cReference),;
												oNetIZap:SetText(EncodeUTF8(cText)),;
												MsgRun("Enviando Mensagem com Arquivo...","Aguarde",{||FileSend(oNetIZap,oGetResponse,cFileName,cFileType,cFile2Send)}) ) ;
												OF oAba3 PIXEL 


@ 250,10 SAY "Um arquivo pode ser escolhido e enviado junto da mensagem. O Conteudo do arquivo deve ser enviado  "+;
			 "codificado em BASE64. O nome do arquivo que enviamos é o nome que será usado para identificar o arquivo "+;
			 "dentro da mensagem." SIZE 200,120 OF oAba3 PIXEL 


// Folder 4 -- "MessageSearch"

oAba4 := oFolders:aDialogs[4]

@ 10,10 SAY "Protocolo da mensagem enviada"   SIZE 190,12 OF oAba4 PIXEL 
@ 25-2,10 GET oGet15 VAR cProtocol PICTURE "@!" ;
          SIZE 150,12 OF oAba4 PIXEL 

@ 45,10 BUTTON oBtn4 PROMPT "Procurar Mensagem" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												oNetIZap:SetProtocol(cProtocol),;
												MsgRun("Procurando Mensagem...","Aguarde",{||MsgSearch(oNetIZap,oGetResponse)}) ) ;
												OF oAba4 PIXEL 


@ 60,10 SAY "Para procurar o status de uma mensagem enviada usando o MessageSend(), devemos usar "+;
            "o numero de protocolo da mensagem, retornado no envio da mesma. " SIZE 200,120 OF oAba4 PIXEL 

// Folder 5 -- "QuesstionSearch"

oAba5 := oFolders:aDialogs[5]

@ 10,10 SAY "Protocolo da pergunta enviada"   SIZE 190,12 OF oAba5 PIXEL 
@ 25-2,10 GET oGet15 VAR cProtocol PICTURE "@!" ;
          SIZE 150,12 OF oAba5 PIXEL 

@ 45,10 BUTTON oBtn4 PROMPT "Procurar Pergunta" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												oNetIZap:SetProtocol(cProtocol),;
												MsgRun("Procurando Pergunta...","Aguarde",{||QSearch(oNetIZap,oGetResponse)}) ) ;
												OF oAba5 PIXEL 


@ 60,10 SAY "Para procurar o status e/ou resposta de uma pergunta enviada usando QuestionSend(), devemos usar "+;
            "o numero de protocolo da pergunta, retornado no envio da mesma. " SIZE 200,120 OF oAba5 PIXEL 

// Folder 6 -- "GroupSearch"

oAba6 := oFolders:aDialogs[6]

@ 10,10 BUTTON oBtn4 PROMPT "Pesquisar Grupos de Mensagem" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												MsgRun("Procurando por Grupos...","Aguarde",{||GSearch(oNetIZap,oGetResponse)}) ) ;
												OF oAba6 PIXEL 


// Folder 7 -- "BroadcastSearch"

oAba7 := oFolders:aDialogs[7]

@ 10,10 BUTTON oBtn4 PROMPT "Pesquisar Listas de Broadcast" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												MsgRun("Procurando por Listas de Broadcast ...","Aguarde",{||BSearch(oNetIZap,oGetResponse)}) ) ;
												OF oAba7 PIXEL 

// Folder 8 -- "CheckCredits"

oAba8 := oFolders:aDialogs[8]

@ 10,10 BUTTON oBtn4 PROMPT "Pesquisar Creditos" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												MsgRun("Pesquisando Creditos do Plano atual ...","Aguarde",{||ChkCredits(oNetIZap,oGetResponse)}) ) ;
												OF oAba8 PIXEL 

// Folder 9 -- "RequestStart"

oAba9 := oFolders:aDialogs[9]

@ 10,10 BUTTON oBtn4 PROMPT "Pesquisar Registro de Requisições" ACTION (	oNetIZap:Reset(),;
												oNetIZap:SetLine(cLine),;
												oNetIZap:SetAccessKey(cAccessKey),;
												oNetIZap:SetPort(nPort),;
												MsgRun("Pesquisando Registro de Requisiçoes ...","Aguarde",{||ReqStart(oNetIZap,oGetResponse)}) ) ;
												OF oAba9 PIXEL 


// Folder "Retorno da Requisição"

@ 20-2,05 GET oGetResponse VAR cResponse MULTILINE SIZE 200,200 OF oFldStat:aDialogs[1] PIXEL 
oGetResponse:LREADONLY := .T.
oGetResponse:ALIGN := CONTROL_ALIGN_ALLCLIENT

// Ativa a janela principal 
ACTIVATE DIALOG oMainWnd CENTER 

Return

/* -----------------------------------------------------------
Ação de envio de mensagem 
----------------------------------------------------------- */

STATIC Function MsgSend(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:MessageSend()

	cMsg := oNetIZap:GetResponse()

	// Formato de retorno  ( sucesso ) 
	// [{"result":"8F0B0A99-1F9F-4AF1-83EE-FFA0C7B6D615"}]

	// Retorno em caso de erro 
	// [{"errors": [{"code": "400.002", "type": "APIException", "message": "Erro na autentica+º+úo.", "link": "" }]}]

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

/* -----------------------------------------------------------
Ação de envio de uma mensagem com pergunta e respostas esperadas
----------------------------------------------------------- */

STATIC Function QSend(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:QuestionSend()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

/* -----------------------------------------------------------
Ação de envio de uma mensagem com arquivo anexo
----------------------------------------------------------- */

STATIC Function FileSend(oNetIZap,oGetResponse,cFileName,cFileType,cFile2Send)
Local cMsg := ''

cFileName := alltrim(cFileName)
cFile2Send := alltrim(cFile2Send)

if empty(cFileName)
	MsgStop("Nome do Arquivo para a mensagem nao informado.")
	return
Endif

if empty(cFileType)
	MsgStop("Tipo do Arquivo para enviar nao informado.")
	return
Endif

IF !file(cFile2Send)
	MsgStop("Arquivo para enviar ["+cFile2Send+"] nao encontrado.")
	return
Endif

// Carrega o arquivo e seta os dados de envio para a mensagem
oNetIZap:SetFile(cFileName,cFileType,LoadFile64(cFile2Send))

// Envia a mensagem com o arquivo 
If oNetIZap:FileSend()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

/* -----------------------------------------------------------
Consulta de uma mensagem enviada com MEssageSend() pelo numero do protocolo
----------------------------------------------------------- */

STATIC Function MsgSearch(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:MessageSearch()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return


/* -----------------------------------------------------------
Consulta de uma pergunta enviada com QuestionSend() pelo numero do protocolo
----------------------------------------------------------- */

STATIC Function QSearch(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:QuestionSearch()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return


/* -----------------------------------------------------------
Consulta os grupos de envios de mensagem associados a esta conta 
----------------------------------------------------------- */

STATIC Function GSearch(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:GroupSearch()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

/* -----------------------------------------------------------
Consulta as listas de broadcast associados a esta conta 
----------------------------------------------------------- */

STATIC Function BSearch(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:BroadcastSearch()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return


/* -----------------------------------------------------------
Consulta os cretidos do plano atual 
----------------------------------------------------------- */

STATIC Function ChkCredits(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:CheckCredits()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

/* -----------------------------------------------------------
Consulta o log de requisicoes e uso da API 
----------------------------------------------------------- */

STATIC Function ReqStart(oNetIZap,oGetResponse)
Local cMsg := ''

If oNetIZap:RequestsStart()

	cMsg := oNetIZap:GetResponse()

Else 

	cMsg += oNetIZap:GetHeaderResponse()
	cMsg += CRLF + CRLF 
	cMsg += oNetIZap:GetLastError()

Endif

// Atualiza resposta na interface
eval(oGetResponse:bSetGet,cMsg)
oGetResponse:Refresh()

Return

STATIC Function LoadFile64(cFile)
Local nH, nSize, cBuffer := ""
nH := fopen(cFile)
If nH < 0 
	USerException("LoadFile64 error - File ["+cfile+"] - Open Error "+cValToChar(ferror()))
Endif
nSize := fSeek(nH,0,2)
If nSize <= 0 
	USerException("LoadFile64 error - File ["+cfile+"] - Invalid Empty File ")
Endif
fseek(nh,0)
fRead(nH,@cBuffer,nSize)
fClose(nH)

Return Encode64(cBuffer)

