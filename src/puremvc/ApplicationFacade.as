package puremvc
{
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.observer.Notification;
	
	import puremvc.command.StartupCommand;
	import puremvc.proxy.GReaderProxy;
	
	public class ApplicationFacade extends Facade
	{
		public static const NAME:String = "ApplicationFacade";
		
		public static function getInstance():ApplicationFacade
		{
			return (instance ? instance : new ApplicationFacade()) as ApplicationFacade;
		}
		
		public function startup(stage:Object):void
		{
			sendNotification( NotificationNames.STARTUP,  stage );
		}
		
		/**
		 * 
		 *  Initialize Models Views and Controllers 
		 * 
		 **/
		
		override protected function initializeController():void
		{
			super.initializeController();
			
			registerCommand(NotificationNames.STARTUP, StartupCommand);
		}
		
		override protected function initializeModel():void
		{
			super.initializeModel();
		}
		
		/**
		 * 
		 *  Track Notifications
		 * 
		 **/
		
		override public function sendNotification(notificationName:String, body:Object=null, type:String=null):void
		{
			trace( 'Sent: ' + notificationName );
			
			notifyObservers( new Notification( notificationName, body, type ) );
		}
	}
}