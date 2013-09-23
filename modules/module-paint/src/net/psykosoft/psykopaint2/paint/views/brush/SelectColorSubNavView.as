package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.ColorSwatches;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	
	import org.osflash.signals.Signal;

	public class SelectColorSubNavView extends SubNavigationViewBase
	{
		
		public static const ID_BACK:String = "Edit Brush";

		// TODO: complete navigation refactor
		static private var _lastSelectedBrush:String = "";
		static private var _lastSelectedParameter:Object = {};
		static public var lastScrollerPosition:Number = 372; //TODO: hardcode works, might want to do it cleaner.

		
		public var colorChangedSignal:Signal;
		
		
		private const UI_ELEMENT_Y:uint = 560;

		private var colorMixer1:Colormixer;
		private var colorMixer2:Colormixer;
		private var colorSwatches:ColorSwatches;

		public var currentColor:int = 0;
		
		public function SelectColorSubNavView() {
			super();
			colorChangedSignal = new Signal();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
		}

		override protected function onSetup():void {

			colorSwatches = new ColorSwatches();
			colorSwatches.y = UI_ELEMENT_Y - 10;
			colorSwatches.x = 330;
			colorSwatches.addEventListener( Event.CHANGE, onSwatchColorPicked );

			colorMixer1 = new Colormixer( colorSwatches.palettes );
			colorMixer1.y = UI_ELEMENT_Y;
			colorMixer1.x = 140;
			//colorMixer1.blendMode = "multiply";
			colorMixer1.addEventListener( Event.CHANGE, onColorPicked );

			colorMixer2 = new Colormixer( colorSwatches.palettes );
			colorMixer2.y = UI_ELEMENT_Y;
			colorMixer2.x = 1024 - 200;
			//colorMixer2.blendMode = "multiply";
			colorMixer2.addEventListener( Event.CHANGE, onColorPicked );

			
			addChild( colorMixer1 );
			addChild( colorMixer2 );
			addChild( colorSwatches );
			
		}

		override protected function onDisposed():void {
			colorMixer1.removeEventListener( Event.CHANGE, onColorPicked );
			colorMixer2.removeEventListener( Event.CHANGE, onColorPicked );
			removeChild( colorMixer1 );
			removeChild( colorMixer2 );
			removeChild( colorSwatches );
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------
		

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		

		protected function onColorPicked( event:Event ):void {
			
			currentColor = Colormixer( event.target ).pickedColor;
			colorSwatches.setSelection( -1 );
			colorChangedSignal.dispatch();
		}

		protected function onSwatchColorPicked( event:Event ):void {
			currentColor = ColorSwatches( event.target ).pickedColor;
			colorChangedSignal.dispatch();
		}
	}
}
