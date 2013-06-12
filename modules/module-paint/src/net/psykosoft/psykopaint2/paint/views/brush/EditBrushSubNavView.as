package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.SbCheckBox;
import net.psykosoft.psykopaint2.core.views.components.combobox.SbComboboxView;
import net.psykosoft.psykopaint2.core.views.components.rangeslider.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.slider.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	
	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency when done

	public class EditBrushSubNavView extends SubNavigationViewBase
	{
		private var _uiElements:Vector.<DisplayObject>;
		private var _parametersXML:XML;
		private var _parameter:XML;

		public static const LBL_BACK:String = "Pick a Brush";

		private const UI_ELEMENT_Y:uint = 560;

		public var brushParameterChangedSignal:Signal;

		public function EditBrushSubNavView() {
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
			closeLastParameter();
		}

		// ---------------------------------------------------------------------
		// Parameter listing.
		// ---------------------------------------------------------------------

		public function setParameters( xml:XML ):void {

			_parametersXML = xml;
//			trace( this, "receiving parameters: " + _parametersXML );

			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.
			var list:XMLList = _parametersXML.descendants( "parameter" );
			var numParameters:uint = list.length();
			var firstParamId:String = "";
//			trace( this, "last selected: " + EditBrushCache.getLastSelectedParameter() );
			for( var i:uint; i < numParameters; ++i ) {
				var parameter:XML = list[ i ];
				if ( CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS || ( parameter.hasOwnProperty("@showInUI") && parameter.@showInUI == "1" ) )
				{
					//if( firstParamId == "" ) firstParamId = parameter.@id;
					var matchesLast:Boolean = EditBrushCache.getLastSelectedParameter().indexOf( parameter.@id ) != -1;
					if( matchesLast ) firstParamId = parameter.@id;
//					trace( ">>> " + parameter.toXMLString() );
					addCenterButton( parameter.@id, "param" + parameter.@type, "btnLabelCenter",null,false );
				}
			}
			invalidateContent();

		    // Select and <<< activate >>> the first parameter.
			if ( firstParamId != "" )
			{
				selectButtonWithLabel( firstParamId );
				openParameter( firstParamId );
			}
		}
		
		public function updateParameters( xml:XML ):void 
		{
			_parametersXML = xml;
			var currentParameterID:String = EditBrushCache.getLastSelectedParameter();
			if ( currentParameterID != "" )
			{
				openParameter( currentParameterID );
			}
		}

		// ---------------------------------------------------------------------
		// Parameter components.
		// ---------------------------------------------------------------------

		/* called by the mediator */
		public function openParameter( id:String ):void {
			closeLastParameter();

			var i:uint;
			_uiElements = new Vector.<DisplayObject>();

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
				slider.setWidth ( 276 );
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
				rangeSlider.setWidth ( 451 );
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
			else if( parameterType == PsykoParameter.StringListParameter || parameterType == PsykoParameter.IconListParameter ) {

				/*var comboBox:ComboBox = new ComboBox( this );
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
				trace("STRINGLIST PARAM");*/

				var shapeList:Array = String(_parameter.@list).split(",");
				var numShapes:uint = shapeList.length;
				var shapeComboBox:SbComboboxView = new SbComboboxView( );
				for( i = 0; i < numShapes; ++i ) {
					shapeComboBox.addItem( { label: shapeList[ i ] } );
				}
				addChild( shapeComboBox );
				shapeComboBox.addEventListener( Event.CHANGE, onComboBoxChanged );
				positionUiElement( shapeComboBox as DisplayObject );
				_uiElements.push( shapeComboBox );
			}

			// Check box
			else if( parameterType == PsykoParameter.BooleanParameter ) {
				var checkBox:SbCheckBox = new SbCheckBox();
				checkBox.selected = int( _parameter.@value ) == 1;
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

		private function notifyParameterChange():void {
			brushParameterChangedSignal.dispatch( _parameter );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onKnobChanged( event:Event ):void {
		    var knob:Knob = event.target as Knob;
			_parameter.@value = knob.value;
			notifyParameterChange();
		}

		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:SbCheckBox = event.target as SbCheckBox;
			_parameter.@value = checkBox.selected ? "1" : "0";
			notifyParameterChange();
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:SbComboboxView = event.target as SbComboboxView;
			// TODO: passed index seems to be inverted
			_parameter.@index = comboBox.selectedIndex;
			notifyParameterChange();
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			_parameter.@value = slider.value;
			notifyParameterChange();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			_parameter.@value1 = slider.value1;
			_parameter.@value2 = slider.value2;
			notifyParameterChange();
		}
	}
}
