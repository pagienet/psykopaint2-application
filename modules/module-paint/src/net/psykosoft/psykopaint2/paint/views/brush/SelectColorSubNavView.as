package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.ColorSwatches;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	// TODO: remove minimalcomps dependency when done

	public class SelectColorSubNavView extends SubNavigationViewBase
	{
		private var _colorParameter:PsykoParameter;

		public static const ID_BACK:String = "Edit Brush";

		// TODO: complete navigation refactor
		static private var _lastSelectedBrush:String = "";
		static private var _lastSelectedParameter:Object = {};
		static public var lastScrollerPosition:Number = 372; //TODO: hardcode works, might want to do it cleaner.

		private const UI_ELEMENT_Y:uint = 560;

		private var colorMixer1:Colormixer;

		private var colorMixer2:Colormixer;
		private var colorSwatches:ColorSwatches;

		public function SelectColorSubNavView() {
			super();
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
			_colorParameter = null;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function connectColorParameter( parameterSetVO:ParameterSetVO ):void {
			var list:Vector.<PsykoParameter> = parameterSetVO.parameters;
			var numParameters:uint = list.length;
			for( var i:uint = 0; i < numParameters; ++i ) {
				var parameter:PsykoParameter = list[ i ];
				if( parameter.type == PsykoParameter.ColorParameter ) {
					_colorParameter = parameter;
				} 
			}
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		

		protected function onColorPicked( event:Event ):void {
			if( _colorParameter != null ) {
				_colorParameter.colorValue = Colormixer( event.target ).pickedColor;
				colorSwatches.setSelection( -1 );
			}

		}

		protected function onSwatchColorPicked( event:Event ):void {
			if( _colorParameter != null ) 
			{
				_colorParameter.colorValue = ColorSwatches( event.target ).pickedColor;
			}
		}
	}
}
