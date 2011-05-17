package puremvc.service
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import puremvc.proxy.GReaderCommandProxy;
	
	public class GReaderClient
	{
		private static const SOURCE:String =  'Feederoso (0.1)';
		
		private static const GOOGLE_URL:String =  'http://www.google.com';
		private static const READER_URL:String =  GOOGLE_URL + '/reader';
		private static const LOGIN_URL:String =  'https://www.google.com/accounts/ClientLogin';
		private static const TOKEN_URL:String =  READER_URL + '/api/0/token';
		private static const USER_INFO_URL:String =  READER_URL + '/api/0/user-info';
		private static const SUBSCRIPTION_LIST_URL:String =  READER_URL + '/api/0/subscription/list';
		private static const READING_SUBS_URL:String =  READER_URL + '/atom/';
		private static const READING_URL:String =  READER_URL + '/atom/user/-/state/com.google/reading-list';
		private static const READ_ITEMS_URL:String =  READER_URL + '/atom/user/-/state/com.google/read';
		private static const SUBSCRIPTION_URL:String =  READER_URL + '/api/0/subscription/quickadd?client=' + SOURCE;
		private static const GET_FEED_URL:String =  READER_URL + '/atom/';
		private static const MARK_READ_URL:String =  READER_URL + '/api/0/edit-tag?client=' + SOURCE;
		private static const UNREAD_COUNT_URL:String =  READER_URL + '/api/0/unread-count?all=true&output=json';
		private static const MARK_ALL_READ_URL:String =  READER_URL + '/api/0/mark-all-as-read?client=' + SOURCE;
		
		private static const AUTH_BAD_CREDENTIALS_STATUS_CODE: Number = 403;
		
		private static const BAD_API_ERROR:String = "Feederoso has trouble talking to Google Reader. Please try later.";
		private static const FEED_ITEMS_COUNT:String = "20";
		
		private var _AUTH:String;
		private var _SID: String;
		private var _USERID: String;
		private var _MODTOKEN: String;
		public var connected:Boolean;
		private var requestQueue:Dictionary;
		private var commandMap:Dictionary;
		private var xmlDecoder:SimpleXMLDecoder;
		
		private static const errObject:Object = {result:{r: {err: "Invalid XML from Feederoso Google Reader API"}}};
		
		public function GReaderClient()
		{	
			requestQueue = new Dictionary();
			commandMap = new Dictionary();
			xmlDecoder = new SimpleXMLDecoder(true);
		}
		
		private function getErrObject(str:String=null):Object
		{
			var obj:Object = {result:{r: {err: str == null ? "Invalid XML from yourcustomapp Google Reader API" : str}}};
			
			return obj;
		}
		
		private function getResultObject():Object
		{
			var obj:Object = {result:{r: null}};
			
			return obj;
		}
		
		private function clearFromQueue(urlloader:Object):URLRequest
		{
			if ( urlloader )
			{
				var urlreq:URLRequest = requestQueue[urlloader] as URLRequest;
				if ( urlreq )
				{
					requestQueue[urlloader] = null;
					delete requestQueue[urlloader];
					return urlreq;
				}
			}
			
			return null;
		}
		
		private function addToQueue(request:Object, urlloader:URLLoader):void
		{
			if ( !(urlloader in requestQueue) )
			{
				requestQueue[urlloader] = request;				
			}
		}
		
		private function clearCommandFromQueue(urlrequest:URLRequest):GReaderCommandProxy
		{
			if ( urlrequest )
			{
				var command:GReaderCommandProxy = commandMap[urlrequest] as GReaderCommandProxy;
				if ( command )
				{
					commandMap[urlrequest] = null;
					delete commandMap[urlrequest];
					return command;
				}
			}
			
			return null;
		}
		
		private function addCommandToQueue(command:GReaderCommandProxy, urlreq:URLRequest):void
		{
			if ( !(urlreq in commandMap) )
			{
				commandMap[urlreq] = command;				
			}
		}
		
		public function authenticate(login: String, password: String): void 
		{
			var authRequest:URLRequest = new URLRequest();
			authRequest.url = LOGIN_URL;
			authRequest.method = "POST";
			var variables: URLVariables = new URLVariables();
			variables.service = "reader";
			variables.source = SOURCE;
			variables.Email = login;
			variables.Passwd = password;
			authRequest.data = variables;
			
			var authConnection: URLLoader = new URLLoader();
			authConnection.addEventListener(Event.COMPLETE,handleAuthResultEvent);
			authConnection.addEventListener(IOErrorEvent.IO_ERROR, handleAuthFaultEvent);
			authConnection.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleAuthStatusEvent);
			authConnection.load(authRequest);
			
			addToQueue(authRequest, authConnection);
			
		}
		
		private function handleAuthResultEvent(event: Event): void 
		{
			var result:String = String(event.target.data);
			//manually parsing out the Auth name/value pair
			var tokens:Array = result.split(/[\n=]/);
			var urlloader:URLLoader = event.target as URLLoader;
			urlloader.removeEventListener(Event.COMPLETE, handleAuthResultEvent);
			urlloader.removeEventListener(IOErrorEvent.IO_ERROR, handleAuthFaultEvent);
			for(var i:int = 0; i < tokens.length; i++) 
			{
				if((tokens[i] == "Auth") && (i+1 != tokens.length)) 
				{
					_AUTH = tokens[i+1];
					connected = true;
				}else if((tokens[i] == "SID") && (i+1 != tokens.length)) 
				{
					_SID = tokens[i+1];
				}
			}
			
			var req:URLRequest = clearFromQueue(urlloader);
			if ( !req )
				return;
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_LOGIN, req.data["Email"]);
			gCommand.result({result:{auth: _AUTH}});
		}
		
		private var authStatusMap:Dictionary = new Dictionary();
		
		private function handleAuthFaultEvent(event: IOErrorEvent): void 
		{
			connected = false;
			var urlloader:URLLoader = event.target as URLLoader;
			urlloader.removeEventListener(Event.COMPLETE, handleAuthResultEvent);
			urlloader.removeEventListener(IOErrorEvent.IO_ERROR, handleAuthFaultEvent);
			var req:URLRequest = clearFromQueue(urlloader);
			if ( !req )
				return;
			
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_LOGIN, req.data["Email"]);
			var resObj:Object = getErrObject();
			if ( urlloader in authStatusMap )
			{
				authStatusMap[urlloader] = null;
				delete authStatusMap[urlloader];
				
				var googleRespOrig:String = String(urlloader.data);
				var googleResp:String = googleRespOrig;
				var erridx:int = googleRespOrig.indexOf("Error=");
				if ( erridx > -1 )
				{
					googleResp = googleResp.substring(erridx + 6);
				}
				if ( googleResp == "CaptchaRequired" )
				{
					erridx = googleRespOrig.indexOf("Url=");
					if ( erridx > -1 )
					{						
						navigateToURL(new URLRequest(googleRespOrig.substring(erridx + 4)));
						googleResp = "Please authenticate in your browser against the captcha. This is for security reasons. (Tip: Make sure you are at google.com)";
					}
					
				}
				resObj.result.r.err = "Authentication failed: " + googleResp;
			}
			else
				resObj.result.r.err = "Unable to connect to Google Reader: " + String(urlloader.data);
			
			gCommand.result(resObj);
		}
		
		private function handleAuthStatusEvent(event: HTTPStatusEvent) : void 
		{
			connected = false;
			var urlloader:URLLoader = event.target as URLLoader;
			urlloader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, handleAuthStatusEvent);
			
			if(event.status == AUTH_BAD_CREDENTIALS_STATUS_CODE)
			{
				authStatusMap[urlloader] = event.status;
				return;
				
			}
		}
		
		private function getAuthenticationHeaders(): Array 
		{
			var headers:Array = new Array();
			headers.push(new URLRequestHeader("Authorization", "GoogleLogin auth="+_AUTH));
			headers.push(new URLRequestHeader("Cookie", 
				"Name=SID;SID=" + _SID + ";Domain=.google.com;Path=/;Expires=160000000000"));
			
			return headers;
		}
		
		private function checkLoggedIn():Boolean
		{
			if ( _AUTH == null )
				return false;
			return true;
		}
		
		private function getReaderRequest(url:String, gCommand:GReaderCommandProxy, post:Boolean=true, vars:URLVariables=null):void
		{
			trace("GReaderRequest: [",gCommand.action, "]", url);
			var readerRequest:URLRequest = new URLRequest();
			readerRequest.url = url;
			readerRequest.method = post ? "POST" :  "GET";			
			readerRequest.data = vars;
			readerRequest.requestHeaders = getAuthenticationHeaders();
			readerRequest.manageCookies = false;
			readerRequest.userAgent = SOURCE;
			
			var authConnection: URLLoader = new URLLoader();
			authConnection.addEventListener(Event.COMPLETE,handleReaderResultEvent);
			authConnection.addEventListener(IOErrorEvent.IO_ERROR, handleReaderFaultEvent);
			addCommandToQueue(gCommand, readerRequest);
			authConnection.load(readerRequest);
			
			addToQueue(readerRequest, authConnection);
		}
		
		private function handleReaderFaultEvent(event: IOErrorEvent): void 
		{						
			var urlloader:URLLoader = event.target as URLLoader;
			var req:URLRequest = clearFromQueue(urlloader);
			urlloader.removeEventListener(IOErrorEvent.IO_ERROR, handleReaderFaultEvent);
			urlloader.removeEventListener(Event.COMPLETE,handleReaderResultEvent);
			if ( !req )
				return;
			var gCommand:GReaderCommandProxy = clearCommandFromQueue(req);
			if ( gCommand )
			{
				var resObj:Object = getErrObject();
				resObj.result.r.err = "Unable to connect to Google Reader. Check your internet connection status: " + urlloader.data;
				
				gCommand.result(resObj);
			}
		}
		
		private function handleReaderResultEvent(event: Event): void 
		{						
			var urlloader:URLLoader = event.target as URLLoader;
			var req:URLRequest = clearFromQueue(urlloader);
			var result:String = String(urlloader.data);
			urlloader.removeEventListener(Event.COMPLETE, handleReaderResultEvent);
			urlloader.removeEventListener(IOErrorEvent.IO_ERROR, handleReaderFaultEvent);
			if ( !req )
				return;
			var gCommand:GReaderCommandProxy = clearCommandFromQueue(req);
			if ( gCommand )
			{
				marshallReaderResponse(gCommand, result);
			}
		}
		
		private function respondWithLoginError(gCommand:GReaderCommandProxy):void
		{
			var resObj:Object = getErrObject();
			resObj.result.r.err = "LOGIN";
			gCommand.result(resObj);
		}
		
		private function respondWithError(gCommand:GReaderCommandProxy, str:String):void
		{
			var resObj:Object = getErrObject();
			resObj.result.r.err = str;
			gCommand.result(resObj);
		}
		
		public function userInfoCheck(check:Boolean):void
		{
			var gCommand:GReaderCommandProxy;
			var resObj:Object;
			gCommand = new GReaderCommandProxy(check ? GReaderCommandProxy.GREADER_CHECK : GReaderCommandProxy.GREADER_USER);
			if ( checkLoggedIn() )
			{				
				getReaderRequest(USER_INFO_URL, gCommand, false);
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function getSubscriptions():void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_SUBS);
			var resObj:Object;
			
			if ( checkLoggedIn() )
			{				
				getReaderRequest(SUBSCRIPTION_LIST_URL, gCommand, false);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function getUnreadCount():void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_UNREAD);
			var resObj:Object;
			
			if ( checkLoggedIn() )
			{				
				getReaderRequest(UNREAD_COUNT_URL, gCommand, false);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function getArticles(params:Object):void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_GET);
			var resObj:Object;
			var actualParams:URLVariables = new URLVariables();
			if ( checkLoggedIn() )
			{				
				var cont:String = params['cont'] as String;
				var subfeed:String = params['sf'] as String;
				var ot:int = params['ot'] as int;
				var ar:int = params['ar'] as int;
				var feed:String = params['feed'] as String;
				
				var finalurl:String = READING_URL;
				if(params.hasOwnProperty("feed"))
					finalurl = READING_SUBS_URL + feed;
				var exclude_tag_param:String = 'user/' + _USERID +  '/state/com.google/read';
				actualParams["n"] = FEED_ITEMS_COUNT;
				actualParams["r"] = "n";
				actualParams["ck"] = new Date().time;
				if ( subfeed && subfeed.length > 0 )
				{
					finalurl = GET_FEED_URL + subfeed;										
				}
				if ( params.hasOwnProperty("ot") )
				{
					actualParams['ot'] = ot.toString();
				}
				if ( params.hasOwnProperty("ar") && ar == 1 )
				{
					exclude_tag_param = null;
				}
				if ( params.hasOwnProperty('cont') && cont && cont.length > 0 )
				{
					actualParams['c'] = cont;
				}
				//                if ( exclude_tag_param != null )
				//                    actualParams['xt'] = exclude_tag_param;
				
				getReaderRequest(finalurl, gCommand, false, actualParams);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		//sign out
		
		public function signOut():void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_LOGOUT);
			_AUTH = null;
			_MODTOKEN = null;
			_USERID = null;
			_SID = null;
			//            var gvo:GReaderVO = new GReaderVO();
			//            gvo.SID = null;
			//            gvo.USERID = null;
			//          writeSO(gvo);
			
			var dataResp:Object = getResultObject();						
			dataResp.result = new Object();
			dataResp.result["ok"] = null;
			gCommand.result(dataResp);			
		}
		
		// Destructive APIs begin
		
		public function getToken():void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_MOD_TOKEN);
			var resObj:Object;
			
			if ( checkLoggedIn() )
			{				
				getReaderRequest(TOKEN_URL, gCommand, false);			
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function tagArticle(params:Object, commandData:Object):void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_TAG, commandData);
			var resObj:Object;
			var actualParams:URLVariables = new URLVariables();
			if ( checkLoggedIn() )
			{				
				if ( _MODTOKEN == null || _MODTOKEN == "" )
				{
					respondWithError(gCommand, BAD_API_ERROR);
					return;
				}
				var subtag:int = params['t'] as int;
				var doRemove:int = params['r'] as int;
				var actRemove:Boolean;
				var readdata:String = 'user/' + _USERID + '/state/com.google/';
				
				if ( params.hasOwnProperty('r') &&  doRemove == 1 )
					actRemove = true;
				else
					actRemove = false;
				
				if ( !params.hasOwnProperty('t') || subtag < 0 )
				{
					subtag = 0;
				}
				
				switch ( subtag )
				{
					case 0:
						readdata +=  'read'; 
						break;
					case 1:
						readdata +=  'like'; 
						break;
					case 2:
						readdata +=  'starred'; 
						break;
					case 3:
						readdata +=  'kept-unread'; 
						break;
					case 4:
						readdata +=  'tracking-kept-unread'; 
						break;
					case 5:
						readdata +=  'broadcast'; 
						break;
					
				}
				actualParams['T'] = _MODTOKEN;
				actualParams['async'] = 'true';
				actualParams['s'] = params['f'];
				actualParams['i'] = params['i'];
				
				if ( actRemove )
					actualParams['r'] = readdata;
				else
					actualParams['a'] = readdata;
				
				getReaderRequest(MARK_READ_URL, gCommand, true, actualParams);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function markAllRead(params:Object, commandData:Object):void
		{
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_MARK_ALL_READ, commandData);
			var resObj:Object;
			var actualParams:URLVariables = new URLVariables();
			if ( checkLoggedIn() )
			{				
				if ( _MODTOKEN == null || _MODTOKEN == "" )
				{
					respondWithError(gCommand, BAD_API_ERROR);
					return;
				}
				var ts:Number = params['t'] as Number;
				var feedTitle:String = params['i'] as String;
				var feedid:String = params['f'] as String;
				
				if ( feedid == "com.google/reading-list" )
				{
					feedid = 'user/' + _USERID + '/state/com.google/reading-list';
					feedTitle = "All Items";
				}
				
				actualParams['T'] = _MODTOKEN;
				actualParams['t'] = feedTitle;
				actualParams['s'] = feedid;
				actualParams['ts'] = ts;
				
				getReaderRequest(MARK_ALL_READ_URL, gCommand, true, actualParams);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		public function addSub(query:String):void
		{			
			var gCommand:GReaderCommandProxy = new GReaderCommandProxy(GReaderCommandProxy.GREADER_ADD_SUB, query);
			if ( query == null || query == "" )
			{
				respondWithError(gCommand, "Invalid query to add subscription");
				return;
			}
			
			var resObj:Object;
			var actualParams:URLVariables = new URLVariables();
			if ( checkLoggedIn() )
			{		
				if ( _MODTOKEN == null || _MODTOKEN == "" )
				{
					respondWithError(gCommand, BAD_API_ERROR);
					return;
				}
				actualParams['T'] = _MODTOKEN;
				actualParams['quickadd'] = query;
				var finalurl:String = SUBSCRIPTION_URL;
				finalurl += "&ck=" + new Date().time;
				getReaderRequest(finalurl, gCommand, true, actualParams);				
			}
			else
			{
				respondWithLoginError(gCommand);
			}
		}
		
		
		/* Pre-process the response before GReaderCommand accesses
		* it */
		private function marshallReaderResponse(gCommand:GReaderCommandProxy, result:String):void
		{
			var userResp:Object;
			var dataResp:Object;
			var xmlResp:XML;
			var arrColl:ArrayCollection;
			var arr:Array;
			var xmlDoc:XMLDocument;
			switch ( gCommand.action )
			{
				case GReaderCommandProxy.GREADER_USER:
				case GReaderCommandProxy.GREADER_CHECK:
					userResp = JSON.decode(result);
					
					if ( userResp && userResp.hasOwnProperty('userId') )
					{					
						dataResp = getResultObject();						
						dataResp.result.r = new Object();
						dataResp.result.r["ok"] = null;
						dataResp.result.r["u"] = "#" + userResp['userId'];
						_USERID = userResp['userId'];						
						gCommand.result(dataResp);
					}
					else
					{
						gCommand.fault(getErrObject(BAD_API_ERROR));
					}	
					
					break;
				
				case GReaderCommandProxy.GREADER_SUBS:
					
					try
					{
						xmlResp = new XML(result);
					}
					catch (err:Error)
					{
						xmlResp = new XML('<r><err>'+BAD_API_ERROR+'</err></r>');
					}
					dataResp = getResultObject();
					dataResp.result = xmlResp;
					gCommand.result(dataResp);
					
					break;
				
				case GReaderCommandProxy.GREADER_UNREAD:
					userResp = JSON.decode(result);
					
					if ( userResp && userResp.hasOwnProperty('unreadcounts') )
					{					
						dataResp = getResultObject();						
						dataResp.result.r = new Object();
						
						
						var sum:int = 0;
						arrColl = new ArrayCollection();
						arr = new Array();
						for each ( var feedobj:Object in userResp['unreadcounts'])
						{
							if ( feedobj['id'] == ('user/' + _USERID + '/state/com.google/reading-list') )
							{
								sum = feedobj['count'];
							}
							else
							{
								arr.push({count: feedobj['count'], 'id': feedobj['id'], newestItemTimestampUsec: feedobj['newestItemTimestampUsec']});
							}
						}
						dataResp.result.r["count"] = sum;
						dataResp.result.r["feed"] = new ArrayCollection(arr);
						
						gCommand.result(dataResp);
					}
					else
					{
						gCommand.fault(getErrObject(BAD_API_ERROR));
					}	
					
					break;
				
				case GReaderCommandProxy.GREADER_GET:
					
					try
					{
						xmlDoc = new XMLDocument(result);
					}
					catch(err:Error)
					{
						xmlDoc = null;
					}
					if ( !xmlDoc )
						gCommand.fault(getErrObject(BAD_API_ERROR));
					else
					{
						
						//dataResp.result = new Object();
						try
						{
							dataResp = new ResultEvent(ResultEvent.RESULT, false, true, xmlDecoder.decodeXML(xmlDoc));
							gCommand.result(dataResp);
						}
						catch(err:Error)
						{
							gCommand.fault(getErrObject(BAD_API_ERROR));
						}
						
					}
					break;
				
				case GReaderCommandProxy.GREADER_MOD_TOKEN:
					
					if ( result.length > 0 )
					{
						_MODTOKEN = result;
						dataResp = getResultObject();						
						dataResp.result.r = new Object();
						dataResp.result.r["ok"] = null;
						gCommand.result(dataResp);
					}
					else
					{
						gCommand.fault(getErrObject(BAD_API_ERROR));
					}
					
					break;
				
				case GReaderCommandProxy.GREADER_TAG:
				case GReaderCommandProxy.GREADER_MARK_ALL_READ:
					
					if ( result == "OK" )
					{
						dataResp = getResultObject();						
						dataResp.result.r = new Object();
						dataResp.result.r["ok"] = null;
						gCommand.result(dataResp);
					}
					else
					{
						gCommand.fault(getErrObject(BAD_API_ERROR));
					}
					break;
				
				case GReaderCommandProxy.GREADER_ADD_SUB:
					
					userResp = JSON.decode(result);
					
					if ( userResp && userResp.hasOwnProperty('numResults') )
					{										
						if ( userResp['numResults'] == 1 )
						{
							dataResp = getResultObject();						
							dataResp.result.r = new Object();
							dataResp.result.r['f'] = userResp["streamId"];
							gCommand.result(dataResp);
						}
						else if ( userResp['numResults'] == 0 )
							respondWithError(gCommand, 'Matching feed could not be found, try another URL');
						else if ( userResp['numResults'] > 1 )
							respondWithError(gCommand, 'Feed query returned more than one URL, yourcustomapp only supports adding the exact Feed URL such as http://www.guardian.co.uk/rss');
						else
							respondWithError(gCommand, 'Unable to add sub, don\'t know why.')
						
					}
					break;
				//end of switch
			}
			// end of function
		}
		
	}
}