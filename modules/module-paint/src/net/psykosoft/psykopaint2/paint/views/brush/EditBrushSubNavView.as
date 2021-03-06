package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;
	import net.psykosoft.psykopaint2.core.views.components.combobox.ComboboxView;
	import net.psykosoft.psykopaint2.core.views.components.slider.SliderBase;
	import net.psykosoft.psykopaint2.core.views.components.slider.SliderButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	// TODO: remove minimalcomps dependency when done

	public class EditBrushSubNavView extends SubNavigationViewBase
	{
		private var _uiElements:Vector.<DisplayObject>;
		private var _parameterSetVO:ParameterSetVO;
		private var _parameter:PsykoParameter;

		public static const ID_BACK:String = "Pick a Brush";
		public static const ID_COLOR:String = "Pick a Color";
		public static const ID_ALPHA:String = "Change Opacity";

		public static const CUSTOM_COLOR_ID:String = "Custom Color";

		private const UI_ELEMENT_Y:uint = 560;

		public function EditBrushSubNavView() {
			super();
			toggleScrolling( false );
			_scroller.itemGap = 40;
		}

		override protected function onEnabled():void {
			
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );

			/*
			// Show color button?
			if( PaintModeModel.activeMode == PaintMode.COLOR_MODE ) {
				setRightButton( ID_COLOR, ID_COLOR, ButtonIconType.COLOR );
			}
			else {
				setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			}
			*/
			setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			setHeader( "" );
		}

		override protected function onDisposed():void {
			closeLastParameter();
		}

		public function setColorButtonHex( hex:uint ):void {
			var icon:Sprite = getButtonIconForRightButton();
			if( icon ) {
				var ct:ColorTransform = new ColorTransform();
				ct.color = hex;
				var overlay:Sprite = icon.getChildByName( "overlay" ) as Sprite;
				overlay.transform.colorTransform = ct;
			}
		}

		// ---------------------------------------------------------------------
		// Parameter listing.
		// ---------------------------------------------------------------------

		public function setParameters( parameterSetVO:ParameterSetVO ):void {

			_parameterSetVO = parameterSetVO;
			trace( this, "receiving parameters for brush " + parameterSetVO.brushName + ", with num parameters: " + parameterSetVO.parameters.length );

			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.

			invalidateCenterButtons();

			var list:Vector.<PsykoParameter> = _parameterSetVO.parameters;
			var numParameters:uint = list.length;

			for( var i:uint = 0; i < numParameters; ++i ) {

				var parameter:PsykoParameter = list[ i ];

				trace( this, "adding parameter with id: " + parameter.id + ", and label: " + parameter.label );

				if( parameter.type != PsykoParameter.ColorParameter ) {
					if( parameter.id != CUSTOM_COLOR_ID ) {

						//TODO: handling the custom color switch this way is not really ideal but it has to do for now

						var data:ButtonData = createCenterButton( parameter.id, parameter.label, ButtonIconType.DEFAULT, null, null, false, true, true, MouseEvent.MOUSE_DOWN );

						// Button slider?
						if( parameter.type == PsykoParameter.IntParameter
						 || parameter.type == PsykoParameter.NumberParameter
						 || parameter.type == PsykoParameter.AngleParameter ) {
							data.itemRendererType = SliderButton;
							data.minValue = parameter.minLimit;
							data.maxValue = parameter.maxLimit;
							data.value = parameter.type == PsykoParameter.AngleParameter ? parameter.degrees : parameter.numberValue;
							data.previewID = parameter.previewID;
							data.onItemRendererAssigned = onSliderButtonRendererAssigned;
							data.onItemRendererReleased = onSliderButtonRendererReleased;
						} else if ( parameter.type == PsykoParameter.IconListParameter )
						{
							data.itemRendererType = SliderButton;
							data.minValue = parameter.minLimit;
							data.maxValue = parameter.maxLimit;
							data.value = parameter.index;
							data.previewID = parameter.previewID;
							data.onItemRendererAssigned = onSliderButtonRendererAssigned;
							data.onItemRendererReleased = onSliderButtonRendererReleased;
							
						}
					}
				}
				//else {
				//	showRightButton( true );
				//}


			}

			validateCenterButtons();
		}

		private function onSliderButtonRendererAssigned( renderer:SliderButton ):void {
//			trace( this, "onSliderButtonRendererAssigned - id: " + renderer.id );
			renderer.addEventListener( Event.CHANGE, onSliderButtonChanged );
			renderer.addEventListener( MouseEvent.MOUSE_DOWN, onSliderButtonMouseDown );
		}

		private function onSliderButtonRendererReleased( renderer:SliderButton ):void {
//			trace( this, "onSliderButtonRendererReleased - id: " + renderer.id );
			renderer.removeEventListener( Event.CHANGE, onSliderButtonChanged );
			renderer.removeEventListener( MouseEvent.MOUSE_DOWN, onSliderButtonMouseDown );
		}

		private function onSliderButtonMouseDown( event:MouseEvent ):void {
			// Always on top.
			var slider:SliderButton = ClickUtil.getObjectOfClassInHierarchy( event.target as DisplayObject, SliderButton ) as SliderButton;
			slider.parent.swapChildren( slider, slider.parent.getChildAt( slider.parent.numChildren - 1 ) );
		}

		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}

		// ---------------------------------------------------------------------
		// Parameter components.
		// ---------------------------------------------------------------------

		private function focusOnParameterWithId( id:String ):void {
			_parameter = null;
			var numParameters:uint = _parameterSetVO.parameters.length;
			for( var i:uint = 0; i < numParameters; i++ ) {
				var parameter:PsykoParameter = _parameterSetVO.parameters[ i ];
				if( parameter.id == id ) {
					_parameter = parameter;
					break;
				}
			}
			trace( this, "focused on parameter: " + _parameter );
		}

		/* called by the mediator */
		public function openParameterWithId( id:String ):void {

			trace( this, "opening parameter for id: " + id );

			closeLastParameter();
			_uiElements = new Vector.<DisplayObject>();

			focusOnParameterWithId( id );
			if( _parameter == null ) return;

			var parameterType:int = _parameter.type;

			var i:uint;
			var slider:SliderBase;

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				// Replaced by slider buttons on setParameters().
				/*slider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.numberValue;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );*/
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {
				throw("Range Slider has been deprecated - use something else");
				/*
				var rangeSlider:RangedSlider = new RangedSlider();
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerRangeValue;
				rangeSlider.value2 = _parameter.upperRangeValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
				*/
			}
			

			else if( parameterType == PsykoParameter.AngleRangeParameter ) {
				throw("Range Slider has been deprecated - use something else");
				/*
				rangeSlider = new RangedSlider();
				rangeSlider.labelMode = RangedSlider.LABEL_DEGREES;
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerDegreesValue;
				rangeSlider.value2 = _parameter.upperDegreesValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
				*/
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

				// Replaced by slider buttons on setParameters().
				/*slider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.degrees;
				slider.labelMode = SbRangedSlider.LABEL_DEGREES;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );*/
			}

			// Combo box.
			else if( parameterType == PsykoParameter.StringListParameter) {
				// || parameterType == PsykoParameter.IconListParameter 
				var list:Vector.<String> = _parameter.stringList;
				var len:uint = list.length;
				var combobox:ComboboxView = new ComboboxView();
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
				var checkBox:CheckBox = new CheckBox();
				checkBox.selected = _parameter.booleanValue;
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox );
				addChild( checkBox );
				_uiElements.push( checkBox );
			}
			// No Ui component for this parameter.
			else if (parameterType == PsykoParameter.IconListParameter)
			{
				
			} else {
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
				if( uiElement is SliderBase ) uiElement.removeEventListener( Event.CHANGE, onSliderChanged );
				else if( uiElement is ComboBox ) {
					uiElement.removeEventListener( Event.SELECT, onComboBoxChanged );
				}
				else if( uiElement is CheckBox ) uiElement.removeEventListener( Event.CHANGE, onCheckBoxChanged );
				else if( uiElement is Knob ) uiElement.removeEventListener( Event.CHANGE, onKnobChanged );
				else {
					trace( this, "*** Warning *** - don't know how to clean up ui element: " + uiElement );
				}
				//else if( uiElement is RangedSlider ) uiElement.removeEventListener( Event.CHANGE, onRangeSliderChanged );
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
			var checkBox:CheckBox = event.target as CheckBox;
			_parameter.booleanValue = checkBox.selected;
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:ComboboxView = event.target as ComboboxView;
			_parameter.index = comboBox.selectedIndex;
		}

		private function onComboboxInteractionEnded():void {
			GestureManager.gesturesEnabled = true;
		}

		private function onComboboxInteractionStarted():void {
			GestureManager.gesturesEnabled = false;
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SliderBase = event.target as SliderBase;
			_parameter.value = slider.value;
		}

		private function onSliderButtonChanged( event:Event ):void {
			var slider:SliderButton = event.target as SliderButton;
//			trace( this, "onSliderButtonChanged: " + slider.labelText );
			if ( _parameter )
			{
				//focusOnParameterWithId( slider.id );
				if ( _parameter.type == PsykoParameter.IconListParameter )
				{
					_parameter.index = slider.value;
					slider.labelText = _parameter.stringValue;
				} else {
					_parameter.value = slider.value;
					slider.updateLabelFromValue();
				}
			} else {
				trace("ERRROR - something is not right with the parameter in EditBrushSubNavView");
			}
		}
/*
		private function onRangeSliderChanged( event:Event ):void {
			var slider:RangedSlider = event.target as RangedSlider;
			if( _parameter.type == PsykoParameter.AngleRangeParameter ) {
				_parameter.lowerDegreesValue = slider.value1;
				_parameter.upperDegreesValue = slider.value2;
			} else {
				_parameter.lowerRangeValue = slider.value1;
				_parameter.upperRangeValue = slider.value2;
			}
		}
		*/
	}
}
