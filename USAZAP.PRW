#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#include 'Fileio.ch'

//   +----------------------------------------------------------------------------------------------------------------------+
//   |                       FUNÇÃO: FONTE DE FUNÇÕES GENERICAS PARA O WHATSAPP 	          		        	                  |
//   +----------------------------------------------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                                                    Data: 22/01/2020		                  |
//   +----------------------------------------------------------------------------------------------------------------------+
//   |  Descrição: Este fonte é um agrupamento de funções genericas para uso da API NETiZAP, a fim de       	              |
//   |	facilitar ainda mais o uso, sendo apenas necessario alguns parametros.              		        	                  |
//   |  Todas fazem uso dos parametros MV_CELZAP, MV_CHAVZAP e MV_HTTPZAP para determinar a conexão com     	              |
//   |  o WhatsApp.                                                                	                        	              |
//   |  Exemplo dos conteudos dos 3 parametros:                                                           	                |
//   |  MV_CELZAP : "5527981049976"                                                                                         |
//   |  MV_CHAVZAP: "A9CostEuLiQpiCC5IH7w"                                                                                  |
//   |  MV_HTTPZAP: 13005                                                                                        	          |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | USER FUNCTION |          DESCRIÇÃO                          |             PARAMETROS                 	              |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_ENVMGZAP    | ENVIA MENSAGEM NO WHATSAPP                  |    C - NUM.CELULAR ; C - MENSAGEM     ; C - REFERENCIA |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_ENVPGZAP    | ENVIA PERGUNTA NO WHATSAPP                  |    C - NUM.CELULAR ; C - MENSAGEM     ; C - REFERENCIA |
//   |               |                                             |    C - OPÇÕES                                    	    |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_ENVFLZAP    | ENVIA ARQUIVO NO WHATSAPP                   |    C - NUM.CELULAR ; C - MENSAGEM     ; C - REFERENCIA |
//   |               |                                             |    C - NOM.ARQUIVO ; C - TIPO.ARQUIVO ; C - CAMINHO    |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_RECMGZAP    | VERIF SE MENSAGEM FOI LIDA                  |    C - NUM.PROTOCOLO                  	                |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_RECPGZAP    | VERIF SE PERGUNTA FOI LIDA E/OU RESPONDIDA  |    C - NUM.PROTOCOLO      	        	                  |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | U_RECRSZAP    | VERIF SE HOUVE ALGUMA REQUISIÇÃO            |                                        	              |
//   +----------------------------------------------------------------------------------------------------------------------+
//   |               |                                             |                                        	              |
//   +----------------------------------------------------------------------------------------------------------------------+
//   | *OBS PARA UMA MELHOR VISUALIZAÇÃO DOS JSONs DE EXEMPLO RECOMENDO UTILIZAR O SITE https://codebeautify.org/jsonviewer |
//   +----------------------------------------------------------------------------------------------------------------------+

//   +------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   ENVFLZAP    			          			   	            |
//   +------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	  |
//   +------------------------------------------------------------------------------+
//   |  Descrição: Envia mensagem e um arquivo passados por parametro para o numero,|
//   |	tambem passado por parametro.								                                |
//   |  Para validar o envio utilize a U_RECMGZAP.                                  |
//   +------------------------------------------------------------------------------+
//   |  Retorna um protocolo, exemplo:                                              |
//   |  "5D0F246F-DF3A-418F-9E65-E1BA954329C0"                                     	|
//   +------------------------------------------------------------------------------+

USER FUNCTION ENVFLZAP(cNumCel,cMsg,cReference,cNomArq,cTpArquivo,cCaminho)
Local oNetIZap
Local cProtocolo
Local oJson	:= JsonObject():new()

Local cTexto := ""
Local nFSize

DEFAULT cReference  := " "

//Instancio a Classe que faz ligação com a API NETiZAP
oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))

// Define as propriedades minimas para envio de mensagem

//Define o numero destino
oNetIZap:SetDestiny(cNumCel)

// Informa o texto da mensagem
oNetIZap:SetText(EncodeUTF8(cMsg))

// Define a Referencia, forma identificar a mensagem para uso posterior
oNetIZap:SetReference(cReference)

//Informo o nome escolhido do arquivo, o tipo e o caminho fisico onde ele se encontra.
//OBS. cCaminho deve estar no formato \NOME_REAL_ARQUIVO.EXTENÇÂO exemplo: \filetosend.pdf
//OBS².cCaminho segue a partir do ROOTPATH do appserver

nHandle := fopen(cCaminho , FO_READ + FO_SHARED )
If nHandle == -1 
	MSgStop("FOpen() Failed - FError("+cValToChar(ferror())+")",'FileSend() - Falha na abertura do arquivo')
  return ""
Endif      

// Pega o tamanho do arquivo 
nFSize := FSeek(nHandle,0,FS_END)
FSeek(nHandle,0)

If nFSize < 1 
	MSgStop("Invalid File Size",'FileSend() - ARquivo vazio')
  return ""
Endif      

// Le o arquivo 
cString := space(nFSize)
FRead( nHandle, @cString, nFSize ) //Carrega na variável cString, a string ASCII do arquivo.

FClose(nHandle)

cTexto := Encode64(cString) // Converte o arquivo para BASE64
oNetIZap:SetFile(cNomArq,cTpArquivo,cTexto)

// Realiza o envio da mensagem
If oNetIZap:FileSend()
	
	// Pega o JSON de retorno da requisiçao
	// Cada mensagem enviada retorna um identificador de protocolo
	// no formato "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX".
	cProtocolo := oNetIZap:GetResponse()
	
Else
	
	// Em caso de falha no envio, recupera o erro
	MSgStop(oNetIZap:GetLastError(),'FileSend() - Falha no envio da requisição')
	
Endif

//Coloco o JSON vindo da classe NETiZAP no objeto oJson desta função
cErro := oJson:fromJSON(cProtocolo)

//Verifico se ocorreu algum erro no metodo fromJSON
If Len(AllTrim(cErro)) == 0
	//Ja trato o JSON e retorno apenas o protocolo para facilitar no uso da USER FUNCTION
	cProtocolo:=oJson:GetJsonObject("result")
else
	MsgStop(oNetIZap:GetLastError(),'oJson:fromJSON(cProtocolo) - Falha na inserção de dados com a classe JsonObject()')
EndIf
RETURN cProtocolo

//   +------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   ENVMGZAP    			          			   	            |
//   +------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	  |
//   +------------------------------------------------------------------------------+
//   |  Descrição: 	Envia mensagem passada por parametro para o numero, tambem	  	|
//   |	passado por parametro								                                        |
//   +------------------------------------------------------------------------------+
//   |  Retorna um JSON com o protocolo, exemplo:                                   |
//   |  {"result":"5D0F246F-DF3A-418F-9E65-E1BA954329C0"}                       	  |
//   +------------------------------------------------------------------------------+

USER FUNCTION ENVMGZAP(cNumCel,cMsg,cReference)
Local oNetIZap
Local cProtocolo
Local oJson	:= JsonObject():new()
DEFAULT cReference  := " "

//Instancio a Classe que faz ligação com a API NETiZAP
oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))

// Define as propriedades minimas para envio de mensagem

//Define o numero destino
oNetIZap:SetDestiny(cNumCel)

// Informa o texto da mensagem
oNetIZap:SetText(EncodeUTF8(cMsg))

// Define a Referencia, forma identificar a mensagem para uso posterior
oNetIZap:SetReference(cReference)

// Realiza o envio da mensagem
If oNetIZap:MessageSend()
	
	// Pega o JSON de retorno da requisiçao
	// Cada mensagem enviada retorna um identificador de protocolo
	// no formato "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX".
	cProtocolo := oNetIZap:GetResponse()
	
Else
	
	// Em caso de falha no envio, recupera o erro
	MSgStop(oNetIZap:GetLastError(),'MessageSend() - Falha no envio da requisição')
	
Endif

//Coloco o JSON vindo da classe NETiZAP no objeto oJson desta função
cErro := oJson:fromJSON(cProtocolo)

//Verifico se ocorreu algum erro no metodo fromJSON
If Len(AllTrim(cErro)) == 0
	//Ja trato o JSON e retorno apenas o protocolo para facilitar no uso da USER FUNCTION
	cProtocolo:=oJson:GetJsonObject("result")
else
	MsgStop(oNetIZap:GetLastError(),'oJson:fromJSON(cProtocolo) - Falha na inserção de dados com a classe JsonObject()')
EndIf
RETURN cProtocolo

//   +------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   ENVPGZAP    			          			   	            |
//   +------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	  |
//   +------------------------------------------------------------------------------+
//   |  Descrição: Envia uma mensagem com opções para o numero passado			  	    |
//   |	Parametro cOpcoes tem que ser no formato : "'[OPCAO1;OPCAO2;OPCAO3]'"       |
//   +------------------------------------------------------------------------------+
//   |  Retorna um JSON com o protocolo, exemplo:                                   |
//   |  {"result":"5A80CE9D-621C-4533-AE40-CFB4C45C307B"}                       	  |
//   +------------------------------------------------------------------------------+

USER FUNCTION ENVPGZAP(cNumCel, cMsg, cReference, cOpcoes)
Local oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))
Local cProtocolo
Local cErro
Local oJson	:= JsonObject():new()
DEFAULT cReference  := " "

//Define o numero destino
oNetIZap:SetDestiny(cNumCel)

// Informa o texto da mensagem
oNetIZap:SetText(EncodeUTF8(cMsg))

// Define a Referencia, forma identificar a mensagem para uso posterior
oNetIZap:SetReference(cReference)

//Determino as repostas validas
oNetIZap:SetQuestion(cOpcoes)

// Realiza o envio da mensagem
If oNetIZap:QuestionSend()
	
	// Pega o JSON de retorno da requisiçao
	// Cada mensagem enviada retorna um identificador de protocolo
	// no formato "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX".
	cProtocolo := oNetIZap:GetResponse()
	
Else
	
	// Em caso de falha no envio, recupera o erro
	MSgStop(oNetIZap:GetLastError(),'QuestionSend() - Falha no envio da requisição')
	
Endif
//Coloco o JSON vindo da classe NETiZAP no objeto oJson desta função
cErro := oJson:fromJSON(cProtocolo)

//Verifico se ocorreu algum erro no metodo fromJSON
If Len(AllTrim(cErro)) == 0
	//Ja trato o JSON e retorno apenas o protocolo para facilitar no uso da USER FUNCTION
	cProtocolo:=oJson:GetJsonObject("result")
else
	MsgStop(oNetIZap:GetLastError(),'oJson:fromJSON(cProtocolo) - Falha na inserção de dados com a classe JsonObject()')
EndIf
RETURN cProtocolo

//   +------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   RECMGZAP    			          			   	            |
//   +------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	  |
//   +------------------------------------------------------------------------------+
//   |  Descrição: Função para verificar se a mensagem do protocolo passado por  	  |
//   |	parametro foi lida/ e ou recebida.			                                    |
//   +------------------------------------------------------------------------------+
//   |  Retorna um JSON, exemplo:                                                   |
//   |  {"reference":"","sent":"true","sent_datehour":"2020-01-24T09:51:25",        |
//   |  "destiny":"5511xxxxxxxxx","error":"false"}                                  |
//   +------------------------------------------------------------------------------+

USER FUNCTION RECMGZAP(cProtocolo)
Local oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))
Local cResponse

// Informa o protococolo da mensagem a ser pesquisada
oNetIZap:SetProtocol(cProtocolo)

//Realizo a Procura da mensagem
If oNetIZap:MessageSearch()
	
	//Armazeno o JSON retornado em caso de sucesso
	cResponse := oNetIZap:GetResponse()
	
Else
	
	MsgStop(oNetIZap:GetLastError(),'MessageSearch() - Falha no envio da requisição')
	
Endif

RETURN cResponse

//   +--------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   RECPGZAP    			          			   	              |
//   +--------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	    |
//   +--------------------------------------------------------------------------------+
//   |  Descrição: Função para verificar se houve a resposta da pergunta enviada.  	  |
//   |	 											                                                        |
//   +--------------------------------------------------------------------------------+
//   |  Retorna um JSON, exemplo de um caso onde eu respondi a pergunta com um "Sim": |
//   |  {"reference":"","sent":"true","sent_datehour":"2020-01-24T10:02:28",          |
//   |   "destiny":"5511xxxxxxxxx","error":"false","question_answer":"true",    	    |
//   |  "question_answer_correct":"true","question_response":"Sim",                   |
//   |  "question_expired":"false"}                                                   |
//   +--------------------------------------------------------------------------------+

USER FUNCTION RECPGZAP(cProtocolo)
Local oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))
Local cResponse

// Informa o protococolo da mensagem a ser pesquisada
oNetIZap:SetProtocol(cProtocolo)

//Procuro pela pergunta
If oNetIZap:QuestionSearch()
	
	//Armazeno o JSON retornado em caso de sucesso
	cResponse := oNetIZap:GetResponse()
	
Else
	
	MsgStop(oNetIZap:GetLastError(),'QuestionSearch() - Falha no envio da requisição')
	
Endif
RETURN cResponse

//   +----------------------------------------------------------------------------------------+
//   |             		  FUNÇÃO:   RECRSZAP    			          			   	                      |
//   +----------------------------------------------------------------------------------------+
//   |  Autor: Patrick Zerbinatti	                               Data: 22/01/2020	            |
//   +----------------------------------------------------------------------------------------+
//   |  Descrição: 	Função para verificar se alguem requisitou um inicio de conversa          |
//   |	Retornará um ARRAY com X objetos JSON onde cada um virá no seguinte formato:          |
//   |  {"message_datehour_first":"2020-01-08T14:24:21","phone":"5511xxxxxxxxx",  	          |
//   |  "messages_count":1,"messages":[{"datehour":"2020-01-08T14:24:21",       	            |
//   |  ,"message":"TESTE","id":"10609"}],"message_datehour_last":"2020-01-08T14:24:21"}.     |
//   |                                                                             	          |
//   |  X == NUMERO DE REQUISIÇÕES EM ABERTO(MENSAGENS ENVIADAS POR USUARIOS PARA O NUMERO    |
//   |  DO CHAT BOT QUE AINDA NÃO FORAM RESPONDIDAS POR ELE)                       	          |
//   +----------------------------------------------------------------------------------------+
//   |                                                                             	          |
//   +----------------------------------------------------------------------------------------+

USER FUNCTION RECRSZAP()
Local oNetIZap  := NETIZAP():New(SuperGetMv("MV_CELZAP"),SuperGetMv("MV_CHAVZAP"),SuperGetMv("MV_HTTPZAP"))
Local cResponse
Local cErro
Local oJson	:= JsonObject():new()
Local aArray:={}

//Realizo o Request
If oNetIZap:RequestsStart()
	
	//Armazeno o JSON retornado em caso de sucesso
	cResponse := oNetIZap:GetResponse()
Else
	MsgStop(oNetIZap:GetLastError(),'RequestsStart() - Falha no envio da requisição')
ENDIF

//Coloco o JSON vindo da classe NETiZAP no objeto oJson desta função
cErro := oJson:fromJSON(cResponse)

//Verifico se ocorreu algum erro no metodo fromJSON
If Len(AllTrim(cErro)) == 0
	aArray:=oJson:GetJsonObject("root")
else
	MsgStop(oNetIZap:GetLastError(),'oJson:fromJSON(cResponse) - Falha na inserção de dados com a classe JsonObject()')
EndIf
RETURN aArray

