package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.combobox.SbComboboxView;
	import net.psykosoft.psykopaint2.core.views.components.rangeslider.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.slider.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	// TODO: remove minimalcomps dependency when done

	public class EditBrushSubNavView extends SubNavigationViewBase
	{
		private var _uiElements:Vector.<DisplayObject>;
		private var _parameterSetVO:ParameterSetVO;
		private var _parameter:PsykoParameter;

		public static const LBL_BACK:String = "Pick a Brush";
		public static const LBL_COLOR:String = "Pick a Color";

		public static const CUSTOM_COLOR_ID:String = "Custom Color";

		private const UI_ELEMENT_Y:uint = 560;

		public function EditBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setLeftButton( LBL_BACK, ButtonIconType.BACK );
			setRightButton( LBL_COLOR, ButtonIconType.CONTINUE );
			showRightButton( false );
		}

		override protected function onDisposed():void {
			closeLastParameter();
		}

		// ---------------------------------------------------------------------
		// Parameter listing.
		// ---------------------------------------------------------------------

		public function setParameters( parameterSetVO:ParameterSetVO ):void {

			_parameterSetVO = parameterSetVO;
//			trace( this, "receiving parameters: " + parameterSetVO.length );

			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.

			var list:Vector.<PsykoParameter> = _parameterSetVO.parameters;
			var numParameters:uint = list.length;
			showRightButton( false );
			for( var i:uint = 0; i < numParameters; ++i ) {

				var parameter:PsykoParameter = list[ i ];
//				trace( ">>> " + parameter.toXMLString() );

				if( parameter.type != PsykoParameter.ColorParameter ) {
					if( parameter.id != CUSTOM_COLOR_ID ) {
						//TODO: handling the custom color switch this way is not really ideal but it has to do for now
						createCenterButton( parameter.label );
					}
				} else {
					showRightButton( true );
				}
			}

			validateCenterButtons();
		}

		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}

		// ---------------------------------------------------------------------
		// Parameter components.
		// ---------------------------------------------------------------------

		/* called by the mediator */
		public function openParameter( id:String ):void {
			closeLastParameter();

			var i:uint;
			_uiElements = new Vector.<DisplayObject>();
			for( i = 0; i < _parameterSetVO.parameters.length; i++ ) {
				//this is a hack to work around the weird "select by label" thing -
				//parameters can have an id AND a diffferent label
				if( _parameterSetVO.parameters[i].id == id || _parameterSetVO.parameters[i].label == id ) {
					_parameter = _parameterSetVO.parameters[i];
					break;
				}
			}
			if( _parameter == null ) return;

			var parameterType:int = _parameter.type;

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				var slider:SbSlider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.numberValue;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {
				var rangeSlider:SbRangedSlider = new SbRangedSlider();
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerRangeValue;
				rangeSlider.value2 = _parameter.upperRangeValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
			}

			else if( parameterType == PsykoParameter.AngleRangeParameter ) {
				rangeSlider = new SbRangedSlider();
				rangeSlider.labelMode = SbRangedSlider.LABEL_DEGREES;
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerDegreesValue;
				rangeSlider.value2 = _parameter.upperDegreesValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
			}

			// Angle.
			else if( parameterType == PsykoParameter.AngleParameter ) {
				//sorry, but unfortunately knob is pretty unusable right now, replaced it with regular slider
				/*
				 var knob:Knob = new Knob( this );
				 knob.value = _parameter.degrees;
				 knob.minimum = _parameter.minLimit;
				 knob.maximum = _parameter.maxLimit;
				 knob.addEventListener( Event.CHANGE, onKnobChanged );
				 knob.draw();
				 positionUiElement( knob as DisplayObject, 0, -20 );
				 _uiElements.push( knob );
				 */
				slider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.degrees;
				slider.labelMode = SbRangedSlider.LABEL_DEGREES;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );
			}

			// Combo box.
			else if( parameterType == PsykoParameter.StringListParameter || parameterType == PsykoParameter.IconListParameter ) {
				var list:Vector.<String> = _parameter.stringList;
				var len:uint = list.length;
				var combobox:SbComboboxView = new SbComboboxView();
				combobox.interactionStartedSignal.add( onComboboxInteractionStarted );
				combobox.interactionEndedSignal.add( onComboboxInteractionEnded );
				for( i = 0; i < len; ++i ) {
					combobox.addItem( { label: list[ i ] } );
				}
				combobox.selectedIndex = _parameter.index;
				addChild( combobox );
				combobox.addEventListener( Event.CHANGE, onComboBoxChanged );
				positionUiElement( combobox as DisplayObject, 40, 10 );
				_uiElements.push( combobox );
			}

			// Check box
			else if( parameterType == PsykoParameter.BooleanParameter ) {
				var checkBox:SbCheckBox = new SbCheckBox();
				checkBox.selected = _parameter.booleanValue;
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox );
				addChild( checkBox );
				_uiElements.push( checkBox );
			}
			// No Ui component for this parameter.
			else {
				trace( this, "*** Warning *** - parameter type not supported: " + PsykoParameter.getTypeName( parameterType ) );
				var tf:TextField = new TextField();
				tf.selectable = tf.mouseEnabled = false;
				tf.text = "parameter type not supported: " + PsykoParameter.getTypeName( parameterType );
				tf.width = tf.textWidth * 1.2;
				tf.height = tf.textHeight * 1.2;
				positionUiElement( tf );
				addChild( tf );
				_uiElements.push( tf );
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
				else if( uiElement is ComboBox ) {
					uiElement.removeEventListener( Event.SELECT, onComboBoxChanged );
				}
				else if( uiElement is SbCheckBox ) uiElement.removeEventListener( Event.CHANGE, onCheckBoxChanged );
				else if( uiElement is Knob ) uiElement.removeEventListener( Event.CHANGE, onKnobChanged );
				else {
					trace( this, "*** Warning *** - don't know how to clean up ui element: " + uiElement );
				}
				removeChild( uiElement );
			}
			_uiElements = null;
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function positionUiElement( element:DisplayObject, offsetX:Number = 0, offsetY:Number = 0 ):void {
			element.x = 1024 / 2 - element.width / 2 + offsetX;
			element.y = UI_ELEMENT_Y + offsetY;
		}


		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onKnobChanged( event:Event ):void {
			var knob:Knob = event.target as Knob;
			_parameter.degrees = knob.value;
		}

		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:SbCheckBox = event.target as SbCheckBox;
			_parameter.booleanValue = checkBox.selected;
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:SbComboboxView = event.target as SbComboboxView;
			_parameter.index = comboBox.selectedIndex;
		}

		private function onComboboxInteractionEnded():void {
			GestureManager.gesturesEnabled = true;
		}

		private function onComboboxInteractionStarted():void {
			GestureManager.gesturesEnabled = false;
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			_parameter.value = slider.value;
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			if( _parameter.type == PsykoParameter.AngleRangeParameter ) {
				_parameter.lowerDegreesValue = slider.value1;
				_parameter.upperDegreesValue = slider.value2;
			} else {
				_parameter.lowerRangeValue = slider.value1;
				_parameter.upperRangeValue = slider.value2;
			}
		}
	}
}
