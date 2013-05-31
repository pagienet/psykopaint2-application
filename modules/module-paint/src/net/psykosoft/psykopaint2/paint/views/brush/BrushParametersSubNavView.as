package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;

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

		private const UI_ELEMENT_Y:uint = 560;

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
			var list:XMLList = _parametersXML.descendants( "parameter" );
			var numParameters:uint = list.length();
			for( var i:uint; i < numParameters; ++i ) {
				var parameter:XML = list[ i ];
//				trace( ">>> " + parameter.toXMLString() );
				var btn:SbNavigationButton = addCenterButton( parameter.@id ) as SbNavigationButton;
				btn.addEventListener( MouseEvent.MOUSE_UP, onParameterClicked );
				_btns.push( btn );
			}
			invalidateContent();
			openParameter( list[ 0 ].@id );
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

			var parameter:XML = getParameterFromId( id );
			var parameterType:uint = uint( parameter.@type );

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {

				var slider:SbSlider = new SbSlider();
				slider.id = String( parameter.@id );
				slider.numDecimals = 2;
				slider.minValue = Number( parameter.@minValue );
				slider.maxValue = Number( parameter.@maxValue );
				slider.value = Number( parameter.@value );
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				positionUiElement( slider );
				addChild( slider );

				_uiElements.push( slider );
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {

				var rangeSlider:SbRangedSlider = new SbRangedSlider();
				rangeSlider.id = String( parameter.@id );
				rangeSlider.numDecimals = 2;
				rangeSlider.minValue = Number( parameter.@minValue );
				rangeSlider.maxValue = Number( parameter.@maxValue );
				rangeSlider.value1 = Number( parameter.@value1 );
				rangeSlider.value2 = Number( parameter.@value2 );
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );

				_uiElements.push( rangeSlider );
			}

			// TODO: support more parameter types...
			else {
				trace( this, "*** Warning *** - parameter type not supported: " + PsykoParameter.getTypeName( parameterType ) );
			}
		}

		private function closeLastParameter():void {
			if( !_uiElements ) return;
			// Remove all ui elements from display and clear listeners
			var len:uint = _uiElements.length;
			for( var i:uint; i < len; ++i ) {
				var uiElement:DisplayObject = _uiElements[ i ];
				if( uiElement is SbSlider ) uiElement.removeEventListener( Event.CHANGE, onSliderChanged );
				else if( uiElement is SbRangedSlider ) uiElement.removeEventListener( Event.CHANGE, onRangeSliderChanged );
				else {
					trace( this, "*** Warning *** - don't know how to clean up ui element: " + uiElement );
				}
				removeChild( uiElement );
			}
			_uiElements = null;
		}

		private function positionUiElement( element:Sprite ):void {
			// TODO: fix this scaling hack, not sure why its necessary on ipad.
			element.scaleX = element.scaleY = 1 / ViewCore.globalScaling;
			element.x = ( ViewCore.globalScaling == 2 ? -100 : 0 ) + ( 1024 / 2 - element.width / 2 ) / ViewCore.globalScaling;
			element.y = UI_ELEMENT_Y / ViewCore.globalScaling;
//			trace( this, ">>> positioning element at: " + element.x + ", " + element.y + ", scale: " + scaleX );
		}

		private function getParameterFromId( id:String ):XML {
			var parameter:XML = _parametersXML.descendants( "parameter" ).( @id == id )[ 0 ];
//			trace( this, "getting parameter from id: " + id + ", value: " + parameter.toXMLString() );
			return parameter;
		}

		private function updateParameter( parameter:XML ):void {
			var id:String = parameter.@id;
			_parametersXML.descendants( "parameter" ).( @id == id )[ 0 ] = parameter;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			var parameter:XML = getParameterFromId( slider.id );
			parameter.@value = slider.value;
			updateParameter( parameter );
			brushParameterChangedSignal.dispatch( parameter );
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			var parameter:XML = getParameterFromId( slider.id );
			parameter.@value1 = slider.value1;
			parameter.@value2 = slider.value2;
			updateParameter( parameter );
			brushParameterChangedSignal.dispatch( parameter );
		}
	}
}
