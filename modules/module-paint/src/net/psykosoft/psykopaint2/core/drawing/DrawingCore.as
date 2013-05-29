package net.psykosoft.psykopaint2.core.drawing
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.psykosoft.notifications.NotificationsExtension;
	import net.psykosoft.notifications.events.NotificationExtensionEvent;

	import net.psykosoft.psykopaint2.core.drawing.config.DrawingCoreConfig;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	import org.swiftsuspenders.Injector;

	// TODO:
	/*
	* This class is no longer a proxy. It will simply setup the core in a RL fashion.
	* All interface methods and its nature as a singleton should be removed.
	* */

	public class DrawingCore extends flash.display.Sprite
	{
//		static private const STATE_IDLE:String 		 = "IDLE";
//		static private const STATE_CROP:String 		 = "CROP";
//		static private const STATE_COLORSTYLE:String = "COLORSTYLE";
//		static private const STATE_PAINT:String 	 = "PAINT";
		
//		private var _cropModule:CropModule;
//		private var _paintModule:PaintModule;
//		private var _colorStyleModule:ColorStyleModule;
		
		
//		private var _originalSourceImage:BitmapData;
//		private var _currentState:String;

		private var _config:DrawingCoreConfig;
		private var _notificationsExtension:NotificationsExtension;
		private var _memoryWarningNotification:NotifyMemoryWarningSignal;
		private var _useDebugKeys:Boolean;

		private static var _instance:DrawingCore;

		public static var stageWidth : Number;
		public static var stageHeight : Number;

		public function DrawingCore( injector:Injector, debug:Boolean = false ) {

			trace( this );

			super();

			_useDebugKeys = debug;

			// Init RL.
			_config = new DrawingCoreConfig( this, injector );

			// Init iOS memory warning notifications.
			_memoryWarningNotification = _config.injector.getInstance( NotifyMemoryWarningSignal );
			_notificationsExtension = new NotificationsExtension();
			_notificationsExtension.addEventListener( NotificationExtensionEvent.RECEIVED_MEMORY_WARNING, onMemoryWarning );
			_notificationsExtension.initialize();

			// TODO: remove
			// Init Display tree.
//			addChild( new DummyView() );
//			addChild( new DummyView1() );

			_instance = this; // TODO: remove

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			if( _useDebugKeys ) {
				stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			}
		}

		private function onKeyDown( event:KeyboardEvent ):void {
			trace( this, "key down for debugging: " + event.keyCode );
			switch( event.keyCode ) {
				case Keyboard.M : {
					trace( this, "simulating memory warning." );
					_notificationsExtension.simulateMemoryWarning();
				} break;
			}
		}

		private function onMemoryWarning( event:NotificationExtensionEvent ):void {
			trace( this, "AS3 knows of an iOS memory warning." );
			_memoryWarningNotification.dispatch();
		}
	}
}
