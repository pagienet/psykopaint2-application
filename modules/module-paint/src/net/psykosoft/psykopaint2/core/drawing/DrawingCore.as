package net.psykosoft.psykopaint2.core.drawing
{

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.drawing.config.DrawingCoreConfig;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.framework.api.IInjector;

	// TODO:
	/*
	* This class is no longer a proxy. It will simply setup the core in a RL fashion.
	* All interface methods and its nature as a singleton should be removed.
	* */

	public class DrawingCore extends Sprite
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

		private static var _instance:DrawingCore;

		public function DrawingCore( injector:IInjector ) {

			trace( this );

			super();

			// Init RL.
			_config = new DrawingCoreConfig( this, injector );

			_instance = this; // TODO: remove

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
	}
}
