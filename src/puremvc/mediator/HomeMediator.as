package puremvc.mediator
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.GReaderProxy;
	import puremvc.service.GReaderClient;
	
	import qnx.dialog.AlertDialog;
	import qnx.dialog.DialogSize;
	import qnx.dialog.LoginDialog;
	import qnx.display.IowWindow;
	
	import utils.ObjectUtil;
	
	import views.FeederosoHome;
	
	public class HomeMediator extends Mediator
	{
		private var sharedObject:SharedObject;
		
		public function HomeMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			this.sharedObject = SharedObject.getLocal("feederoso-auth");
			//this.sharedObject.clear();
			
			if(this.sharedObject.data.password)
			{
				//Using SharedObject to authenticate
				this.authenticate();
			}
			else
			{
				//Ask to authenticate
				showLoginDialog();
			}
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( HomeMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationNames.GREADER_LOGIN_SUCCESS,
				NotificationNames.GREADER_LOGIN_FAIL
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var notificationName:String = notification.getName();
			var notificationBody:Object = notification.getBody();
			
			switch(notificationName)
			{
				case NotificationNames.GREADER_LOGIN_SUCCESS:
					this.saveSharedObject();
					break;
				
				case NotificationNames.GREADER_LOGIN_FAIL:
					sharedObject.clear();
					
					showErrorDialog(notificationBody as String);
					break;
			}
		}
		
		/**
		 * View Logic
		 **/
		
		private function showLoginDialog():void
		{
			var loginDialog:LoginDialog = new LoginDialog();
			loginDialog.title = "Google Reader Login";
			loginDialog.addButton("Login");
			loginDialog.usernameLabel = "Email";
			loginDialog.passwordPrompt = "Password";
			loginDialog.rememberMeLabel = "Remember Me"
			loginDialog.rememberMe = true;
			loginDialog.dialogSize = DialogSize.SIZE_SMALL;
			loginDialog.addEventListener(Event.SELECT, onLoginDialogSelect);
			loginDialog.show( IowWindow.getAirWindow().group);
		}
		
		private function showErrorDialog(message:String):void
		{
			var errorDialog:AlertDialog = new AlertDialog();
			errorDialog.title = "Login Error";
			errorDialog.message = message;
			errorDialog.addButton("Retry");
			errorDialog.dialogSize= DialogSize.SIZE_SMALL;
			errorDialog.addEventListener(Event.SELECT, onErrorDialogSelect);
			errorDialog.show( IowWindow.getAirWindow().group);
		}
		
		private function onLoginDialogSelect(event:Event):void
		{
			var loginDialog:LoginDialog = event.target as LoginDialog;
			
			if(loginDialog.rememberMe)
			{
				sharedObject.data.username = loginDialog.username;
				sharedObject.data.password = loginDialog.password;
			}
			
			this.authenticate(loginDialog.username, loginDialog.password);
		}
		
		private function authenticate(username:String=null, password:String=null):void
		{
			if(username == null && password == null)
			{
				username = this.sharedObject.data.username;
				password = this.sharedObject.data.password;
			}
			
			if(!readerClient.connected)
				readerClient.authenticate(username, password);
		}
		
		private function onErrorDialogSelect(event:Event):void
		{
			this.showLoginDialog();
		}
		
		/**
		 * Shared Object Logic
		 **/
		
		private function saveSharedObject():void
		{
			var flushStatus:String = null;
			try {
				flushStatus = sharedObject.flush(10000);
			} catch (error:Error) {
				trace("Error...Could not write SharedObject to disk\n");
			}
			if (flushStatus != null) {
				switch (flushStatus) {
					case SharedObjectFlushStatus.PENDING:
						sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
						break;
					case SharedObjectFlushStatus.FLUSHED:
						//Saved
						break;
				}
			}
		}
		
		private function onFlushStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "SharedObject.Flush.Success":
					trace("User granted permission -- value saved.\n");
					break;
				case "SharedObject.Flush.Failed":
					trace("User denied permission -- value not saved.\n");
					break;
			}
			
			sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}
		
		/**
		 * Getters and Setters
		 **/
		
		public function get view():FeederosoHome
		{
			return this.getViewComponent() as FeederosoHome;
		}
		
		private function get readerClient():GReaderClient
		{
			return facade.retrieveProxy( GReaderProxy.NAME ).getData() as GReaderClient;
		}
	}
}