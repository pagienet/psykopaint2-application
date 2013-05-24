package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency if not used

	public class BrushParametersSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const UI_ELEMENT_SCALING:Number = 0.75;

		private var _uiElementToParameter:Dictionary;
		private var _elements:Vector.<Sprite>;

		public var brushParameterChangedSignal:Signal;

		public function BrushParametersSubNavView() {
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
				if( element is SbSlider ) {
					element.removeEventListener( Event.CHANGE, onSliderChanged );
					SbSlider( element ).dispose();
				}
				else if( element is SbRangedSlider ) {
					element.removeEventListener( Event.CHANGE, onRangeSliderChanged );
					SbRangedSlider( element ).dispose();
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

					var slider:SbSlider = new SbSlider();
					slider.scaleX = slider.scaleY = UI_ELEMENT_SCALING;
					slider.numDecimals = 3;
					slider.minimum = Number( parameter.@minVlaue );
					slider.maximum = Number( parameter.@maxValue );
					slider.setValue( Number( parameter.@value ) );
					slider.setIdLabel( String( parameter.@id ) );
					slider.addEventListener( SbSlider.CHANGE, onSliderChanged );

					_uiElementToParameter[ slider ] = parameter;
					_elements.push( slider );
					addCenterElement( slider );
				}

				// Range slider.
				if( type == PsykoParameter.IntRangeParameter || type == PsykoParameter.NumberRangeParameter ) {

					var rangeSlider:SbRangedSlider = new SbRangedSlider();
					rangeSlider.scaleX = rangeSlider.scaleY = UI_ELEMENT_SCALING;
					rangeSlider.numDecimals = 2;
					rangeSlider.minValue = Number( parameter.@minVlaue );//TODO: typo
					rangeSlider.maxValue = Number( parameter.@maxValue );
					rangeSlider.setValue( Number( parameter.@value ) );
					rangeSlider.minValue = Number( parameter.@value1 ); //TODO: pass position and value
					rangeSlider.maxValue = Number( parameter.@value2 );
					rangeSlider.setIdLabel( String( parameter.@id ) );
					rangeSlider.addEventListener( SbRangedSlider.CHANGE, onRangeSliderChanged );


//            trace("SLIDER CREATED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parameter.@id);
//            trace("minvalue passed is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parameter.@value1);
//            trace("maxvalue passed is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parameter.@value2);
//            trace("minPOS? passed is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parameter.@minVlaue);
//            trace("maxPOS? passed is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parameter.@maxValue);

					_uiElementToParameter[ rangeSlider ] = parameter;
					_elements.push( rangeSlider );
					addCenterElement( rangeSlider );

				}
			}

			invalidateContent();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			var parameter:XML = _uiElementToParameter[ slider ];
			parameter.@value1 = slider.minValue;
			parameter.@value2 = slider.maxValue;
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onRangeSliderChanged: " + slider.lowValue + ", " + slider.highValue );
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			var parameter:XML = _uiElementToParameter[ slider ];
			parameter.@value = slider.getValue();
			brushParameterChangedSignal.dispatch( parameter );
//			trace( this, "onSliderChanged: " + slider.value );
		}
	}
}
