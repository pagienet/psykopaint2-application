package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.CrSbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.CrSbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.CrSubNavigationViewBase;

	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency if not used

	public class PtBrushParametersSubNavView extends CrSubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";

		private var _uiElementToParameter:Dictionary;
		private var _elements:Vector.<Sprite>;

		public var brushParameterChangedSignal:Signal;

		public function PtBrushParametersSubNavView() {
			super();
			brushParameterChangedSignal = new Signal();
			_uiElementToParameter = new Dictionary();
			_elements = new Vector.<Sprite>();
		}

		override protected function onEnabled():void {

			setLabel( "Edit Brush" );

			areButtonsSelectable( false );

			setLeftButton( LBL_BACK );

			invalidateContent();
		}

		override protected function onDisposed():void {

			trace( ">>>>>>> DISPOSED!" );

			var len:uint = _elements.length;
			for( var i:uint; i < len; ++i ) {
				var element:Sprite = _elements[ i ];
				if( element is CrSbSlider ) {
					element.removeEventListener( Event.CHANGE, onSliderChanged );
					CrSbSlider( element ).dispose();
				}
				else if( element is CrSbRangedSlider ) {
					element.removeEventListener( Event.CHANGE, onRangeSliderChanged );
					CrSbRangedSlider( element ).dispose();
				}
			}

			_uiElementToParameter = new Dictionary();
			_elements = new Vector.<Sprite>();
		}

		public function setParameters( parameters:XML ):void {

//			trace( this, "setParameters ------------------------------------" );

			var parameterList:XMLList = parameters.parameter;

			var len:uint = parameterList.length();
			for( var i:uint; i < len; ++i ) {
				var parameter:XML = parameterList[ i ];
				var type:uint = uint( parameter.@type );
//				trace( this, "parameter type: " + type );

				// Simple slider.
				if( type == PsykoParameter.IntParameter || type == PsykoParameter.NumberParameter ) {

					var slider:CrSbSlider = new CrSbSlider();
					slider.numDecimals = 3;
					slider.minimum = Number( parameter.@minVlaue );
					slider.maximum = Number( parameter.@maxValue );
					slider.setValue( Number( parameter.@value ) );
					slider.setIdLabel( String( parameter.@id ) );
					slider.addEventListener( CrSbSlider.CHANGE, onSliderChanged );

					_uiElementToParameter[ slider ] = parameter;
					_elements.push( slider );
					addCenterElement( slider );
				}

				// Range slider.
				if( type == PsykoParameter.IntRangeParameter || type == PsykoParameter.NumberRangeParameter ) {

					var rangeSlider:CrSbRangedSlider = new CrSbRangedSlider();
					rangeSlider.numDecimals = 2;
					rangeSlider.minValue = Number( parameter.@minVlaue );
					rangeSlider.maxValue = Number( parameter.@maxValue );
					rangeSlider.setValue( Number( parameter.@value ) );
					rangeSlider.minValue = Number( parameter.@value1 );
					rangeSlider.maxValue = Number( parameter.@value2 );
					rangeSlider.setIdLabel( String( parameter.@id ) );
					rangeSlider.addEventListener( CrSbRangedSlider.CHANGE, onRangeSliderChanged );

					_uiElementToParameter[ rangeSlider ] = parameter;
					_elements.push( rangeSlider );
					addCenterElement( rangeSlider );

				}
			}

			invalidateContent();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:CrSbRangedSlider = event.target as CrSbRangedSlider;
			var parameter:XML = _uiElementToParameter[ slider ];
			parameter.@value1 = slider.minValue;
			parameter.@value2 = slider.maxValue;
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onRangeSliderChanged: " + slider.lowValue + ", " + slider.highValue );
		}

		private function onSliderChanged( event:Event ):void {
			var slider:CrSbSlider = event.target as CrSbSlider;
			var parameter:XML = _uiElementToParameter[ slider ];
			parameter.@value = slider.getValue();
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onSliderChanged: " + slider.value );
		}
	}
}
