package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.SbNavigationButton;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	public class BrushParametersSubNavView extends SubNavigationViewBase
	{
		private var _btns:Vector.<SbNavigationButton>;
		private var _uiElements:Vector.<DisplayObject>;
		private var _parametersXML:XML;

		public static const LBL_BACK:String = "Back";

		private const UI_ELEMENT_Y:uint = /*100*/560;

		public var brushParameterChangedSignal:Signal;

		public function BrushParametersSubNavView() {
			super();
			brushParameterChangedSignal = new Signal();
		}

		override protected function onEnabled():void {
			setLabel( "" );
			areButtonsSelectable( true );
			setLeftButton( LBL_BACK );
			invalidateContent();
		}

		override protected function onDisposed():void {
			// Dispose local button listeners ( the rest is disposed in SbNavigationView ).
			var len:uint = _btns.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbNavigationButton = _btns[ i ];
				btn.removeEventListener( MouseEvent.MOUSE_UP, onParameterClicked );
			}
			_btns = null;
			// Dispose other components.
			closeLastParameter();
		}

		public function setParameters( xml:XML ):void {
			_parametersXML = xml;
//			trace( this, "receiving parameters: " + _parametersXML );
			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.
			_btns = new Vector.<SbNavigationButton>();
			var numParameters:uint = _parametersXML.parameter.length();
			for( var i:uint; i < numParameters; ++i ) {
				var parameter:XML = _parametersXML.parameter[ i ];
				var btn:SbNavigationButton = addCenterButton( parameter.@id ) as SbNavigationButton;
				btn.addEventListener( MouseEvent.MOUSE_UP, onParameterClicked );
				_btns.push( btn );
			}
			invalidateContent();
			openParameter( _parametersXML.parameter[ 0 ].@id );
		}

		private function onParameterClicked( event:MouseEvent ):void {
			var button:SbNavigationButton = event.target as SbNavigationButton;
			if( !button ) button = event.target.parent as SbNavigationButton;
			var label:String = button.labelText;
			openParameter( label );
		}

		private function openParameter( id:String ):void {
			closeLastParameter();

			_uiElements = new Vector.<DisplayObject>();

//			trace( this, "opening parameter: " + id );
			var parameter:XMLList = getParameterFromId( id );
			var parameterType:uint = uint( parameter.@type );

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {

				var slider:SbSlider = new SbSlider();
				slider.numDecimals = 3;
				slider.minimum = Number( parameter.@minValue );
				slider.maximum = Number( parameter.@maxValue );
				slider.setValue( Number( parameter.@value ) );
				slider.setIdLabel( String( parameter.@id ) );
				slider.addEventListener( SbSlider.CHANGE, onSliderChanged );
				positionUiElement( slider );
				addChild( slider );

				_uiElements.push( slider );
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {

				var rangeSlider:SbRangedSlider = new SbRangedSlider();
				rangeSlider.numDecimals = 1;
				rangeSlider.minValue = Number( parameter.@minValue );
				rangeSlider.maxValue = Number( parameter.@maxValue );
				rangeSlider.setValue( Number( parameter.@value ) );
				rangeSlider.setIdLabel( String( parameter.@id ) );
				rangeSlider.addEventListener( SbRangedSlider.CHANGE, onRangeSliderChanged );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );

				_uiElements.push( rangeSlider );
			}

			// TODO: support more parameter types...
			else {
				trace( this, "*** Warning *** - parameter type not supported: " + parameterType );
			}
		}

		private function closeLastParameter():void {
			if( !_uiElements ) return;
			// Remove all ui elements from display and clear listeners
			var len:uint = _uiElements.length;
			for( var i:uint; i < len; ++i ) {
				var uiElement:DisplayObject = _uiElements[ i ];
				if( uiElement is SbSlider ) uiElement.removeEventListener( SbSlider.CHANGE, onSliderChanged );
				else if( uiElement is SbRangedSlider ) uiElement.removeEventListener( SbRangedSlider.CHANGE, onRangeSliderChanged );
				else {
					trace( this, "*** Warning *** - don't know how to clean up ui element: " + uiElement );
				}
				removeChild( uiElement );
			}
			_uiElements = null;
		}

		private function positionUiElement( element:DisplayObject ):void {
			element.scaleX = element.scaleY = 1 / ViewCore.globalScaling; // TODO: fix this scaling hack, not sure why its necessary on ipad
			element.x = ( 1024 / 2 - element.width / 2 ) / ViewCore.globalScaling;
			element.y = UI_ELEMENT_Y / ViewCore.globalScaling;
			trace( this, ">>> positioning element at: " + element.x + ", " + element.y );
		}

		private function getParameterFromId( id:String ):XMLList {
//			trace( this, "getting parameter from id: " + id );
			var parameter:XMLList = _parametersXML.parameter.( @id == id );
			return parameter;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			var parameter:XMLList = getParameterFromId( slider.getIdLabel() );
			parameter.@value = slider.getValue();
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onSliderChanged: " + slider.value );
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			var parameter:XMLList = getParameterFromId( slider.getIdLabel() );
			parameter.@value1 = slider.minValue;
			parameter.@value2 = slider.maxValue;
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onRangeSliderChanged: " + slider.lowValue + ", " + slider.highValue );
		}
	}
}
