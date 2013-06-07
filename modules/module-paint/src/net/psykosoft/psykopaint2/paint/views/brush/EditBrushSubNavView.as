package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.rangeslider.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.slider.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency when done

	public class EditBrushSubNavView extends SubNavigationViewBase
	{
//		private var _btns:Vector.<SbButton>;
		private var _uiElements:Vector.<DisplayObject>;
		private var _parametersXML:XML;
		private var _parameter:XML;

		public static const LBL_BACK:String = "Pick a Brush";
		//public static const LBL_SHAPE:String = "Shapes";

		private const UI_ELEMENT_Y:uint = 560;

		public var brushParameterChangedSignal:Signal;
		public var shapeChangedSignal:Signal;

		public function EditBrushSubNavView() {
			super();
			brushParameterChangedSignal = new Signal();
			shapeChangedSignal = new Signal();
		}

		override protected function onEnabled():void {
			setLabel( "" );
			areButtonsSelectable( true );
			setLeftButton( LBL_BACK );
			invalidateContent();
		}

		override protected function onDisposed():void {
			// Dispose local button listeners ( the rest is disposed in SbNavigationView ).
			/*var len:uint = _btns.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = _btns[ i ];
				btn.removeEventListener( MouseEvent.CLICK, onParameterClicked );
			}
			_btns = null;*/
			// Dispose other components.
			closeLastParameter();
		}

		// ---------------------------------------------------------------------
		// TODO: change now, the info is in the parameter xml already
		// Shapes. ( this is temporary, it will be treated as a parameter )
		// ---------------------------------------------------------------------

		public function setAvailableShapes( shapes:XML ):void {
			var types:XMLList = shapes[ 0 ].shape;
			var len:uint = types.length();
			for( var i:uint; i < len; ++i ) {
				addCenterButton( types[ i ].@type );
			}
			invalidateContent();
		}

		public function setSelectedShape( activeBrushKitShape:String ):void {
			selectButtonWithLabel( activeBrushKitShape );
		}

		// ---------------------------------------------------------------------
		// Parameter listing.
		// ---------------------------------------------------------------------

		public function setParameters( xml:XML ):void {

			_parametersXML = xml;
			trace( this, "receiving parameters: " + _parametersXML );

			// Shapes button is always present. - @Mario: not anymore, should be automatically done by the regular parameter list
			//addCenterButton( LBL_SHAPE );

			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.
			var openIndex:uint;
//			_btns = new Vector.<SbButton>();
			var list:XMLList = _parametersXML.descendants( "parameter" );
			var numParameters:uint = list.length();
			for( var i:uint; i < numParameters; ++i ) {
				var parameter:XML = list[ i ];
//				if ( parameter.hasOwnProperty("@showInUI") && parameter.@showInUI == "1" )
//				{
					var matchesLast:Boolean = EditBrushCache.getLastSelectedParameter().indexOf( parameter.@id ) != -1;
					if( matchesLast ) openIndex = i;
	//				trace( ">>> " + parameter.toXMLString() );
					addCenterButton( parameter.@id, "param" + parameter.@type );
	//				btn.addEventListener( MouseEvent.CLICK, onParameterClicked );
	//				_btns.push( btn );
//				}
			}
			invalidateContent();
			
			/*
			//TODO: the shapes do not have to be handled separately anymore
			// there is a new parameter type "IconListParameter" which should create the required component
			openParameter( LBL_SHAPE );
			selectButtonWithLabel( LBL_SHAPE );
			*/
		}

		// ---------------------------------------------------------------------
		// Parameter components.
		// ---------------------------------------------------------------------

		/* called by the mediator */
		public function openParameter( id:String ):void {
			closeLastParameter();

			var i:uint;
			_uiElements = new Vector.<DisplayObject>();

			// Special treatment for the shapes "parameter".
			/*
			_tempIsShapeCombo = id == LBL_SHAPE;
			if( id == LBL_SHAPE ) {
				var shapeList:XMLList = _parametersXML.descendants( "shape" );
				var numShapes:uint = shapeList.length();
				if( numShapes == 0 ) return;
				var shapeComboBox:ComboBox = new ComboBox( this );
				shapeComboBox.alternateRows = true;
				shapeComboBox.openPosition = ComboBox.TOP;
				for( i = 0; i < numShapes; ++i ) {
					var shape:XML = shapeList[ i ];
					shapeComboBox.addItem( shape.@type );
				}
				shapeComboBox.defaultLabel = shapeList[ 0 ].@type;
				shapeComboBox.numVisibleItems = Math.min( 6, numShapes );
				shapeComboBox.addEventListener( Event.SELECT, onShapeComboBoxChanged );
				shapeComboBox.draw();
				positionUiElement( shapeComboBox as DisplayObject );
				_uiElements.push( shapeComboBox );
				return;
			}
			*/
			// Regular parameters...

			_parameter = _parametersXML.descendants( "parameter" ).( @id == id )[ 0 ];
			var parameterType:uint = uint( _parameter.@type );
			EditBrushCache.setLastSelectedParameter( _parameter.@id );

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				var slider:SbSlider = new SbSlider();
				slider.minValue = Number( _parameter.@minValue );
				slider.maxValue = Number( _parameter.@maxValue );
				slider.value = Number( _parameter.@value );
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter || parameterType == PsykoParameter.AngleRangeParameter ) {
				var rangeSlider:SbRangedSlider = new SbRangedSlider();
				rangeSlider.minValue = Number( _parameter.@minValue );
				rangeSlider.maxValue = Number( _parameter.@maxValue );
				rangeSlider.value1 = Number( _parameter.@value1 );
				rangeSlider.value2 = Number( _parameter.@value2 );
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
			}

			// Angle.
			else if( parameterType == PsykoParameter.AngleParameter ) {
				var knob:Knob = new Knob( this );
				knob.value = Number( _parameter.@value );
				knob.minimum = Number( _parameter.@minValue );
				knob.maximum = Number( _parameter.@maxValue );
				knob.addEventListener( Event.CHANGE, onKnobChanged );
				knob.draw();
				positionUiElement( knob as DisplayObject, 0, -20 );
				_uiElements.push( knob );
			}

			// Combo box. // TODO: implement real combobox, design is ready
			else if( parameterType == PsykoParameter.StringListParameter ) {
				var comboBox:ComboBox = new ComboBox( this );
				comboBox.alternateRows = true;
				comboBox.openPosition = ComboBox.TOP;
				var list:Array = String( _parameter.@list ).split( "," );
				var len:uint = list.length;
				for( i = 0; i < len; ++i ) {
					var option:String = list[ i ];
					comboBox.addItem( option );
				}
				comboBox.defaultLabel = list[ uint( _parameter.@index ) ];
				comboBox.numVisibleItems = Math.min( 6, len );
				comboBox.addEventListener( Event.SELECT, onComboBoxChanged );
				comboBox.draw();
				positionUiElement( comboBox as DisplayObject );
				_uiElements.push( comboBox );
			}

			// Check box
			else if( parameterType == PsykoParameter.BooleanParameter ) {
				var checkBox:SbCheckBox = new SbCheckBox();
				checkBox.selected = int( _parameter.@value ) == 1;
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox );
				addChild( checkBox );
				_uiElements.push( checkBox );
			} else if (parameterType == PsykoParameter.IconListParameter)
			{
				var shapeList:Array = String(_parameter.@list).split(",");
				var numShapes:uint = shapeList.length;
				if( numShapes == 0 ) return;
				var shapeComboBox:ComboBox = new ComboBox( this );
				shapeComboBox.alternateRows = true;
				shapeComboBox.openPosition = ComboBox.TOP;
				for( i = 0; i < numShapes; ++i ) {
					shapeComboBox.addItem(  shapeList[ i ] );
				}
				shapeComboBox.defaultLabel = shapeList[ 0 ];
				shapeComboBox.numVisibleItems = Math.min( 6, numShapes );
				shapeComboBox.addEventListener( Event.SELECT, onComboBoxChanged );
				shapeComboBox.draw();
				positionUiElement( shapeComboBox as DisplayObject );
				_uiElements.push( shapeComboBox );
			}

			// No Ui component for this parameter.
			// TODO: display a textfield or something when there is no component
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
				else if( uiElement is SbCheckBox ) uiElement.addEventListener( Event.CHANGE, onCheckBoxChanged );
				else if( uiElement is Knob ) uiElement.addEventListener( Event.CHANGE, onKnobChanged );
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

		//Mario: this method is not really required since when a parameter xml is changed the main xml object automatically updates anyway
		/*
		private function updateActiveParameter():void {
			var id:String = _parameter.@id;
			_parametersXML.descendants( "parameter" ).( @id == id )[ 0 ] = _parameter;
		}
		*/
		private function notifyParameterChange():void {
			brushParameterChangedSignal.dispatch( _parameter );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onKnobChanged( event:Event ):void {
		    var knob:Knob = event.target as Knob;
			_parameter.@value = knob.value;
			//updateActiveParameter();
			notifyParameterChange();
		}

		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:SbCheckBox = event.target as SbCheckBox;
			_parameter.@value = checkBox.selected ? "1" : "0";
		//	updateActiveParameter();
			notifyParameterChange();
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:ComboBox = event.target as ComboBox;
			/*
			var list:Array = String( _parameter.@list ).split( "," );
			_parameter.@index = list.indexOf( comboBox.selectedItem );
			*/
			//Mario: not sure there was some special intention to handle it the way above
			// but since the combob ox items is originally created from the
			// list parameter we can use the selected index directly
			_parameter.@index = comboBox.selectedIndex;
			//updateActiveParameter();
			notifyParameterChange();
		}

		private function onShapeComboBoxChanged( event:Event ):void {
			var comboBox:ComboBox = event.target as ComboBox;
			trace( this, "shape combo box changed: " + comboBox.selectedItem );
			shapeChangedSignal.dispatch( comboBox.selectedItem );
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			_parameter.@value = slider.value;
			//updateActiveParameter();
			notifyParameterChange();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			_parameter.@value1 = slider.value1;
			_parameter.@value2 = slider.value2;
			//updateActiveParameter();
			notifyParameterChange();
		}
	}
}
