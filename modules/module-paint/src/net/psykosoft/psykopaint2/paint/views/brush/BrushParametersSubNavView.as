package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.rangeslider.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.slider.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency when done

	public class BrushParametersSubNavView extends SubNavigationViewBase
	{
		private var _btns:Vector.<SbButton>;
		private var _uiElements:Vector.<DisplayObject>;
		private var _parametersXML:XML;
		private var _parameter:XML;

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
				var btn:SbButton = _btns[ i ];
				btn.removeEventListener( MouseEvent.MOUSE_UP, onParameterClicked );
			}
			_btns = null;
			// Dispose other components.
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
			_btns = new Vector.<SbButton>();
			var list:XMLList = _parametersXML.descendants( "parameter" );
			var numParameters:uint = list.length();
			for( var i:uint; i < numParameters; ++i ) {
				var parameter:XML = list[ i ];
//				trace( ">>> " + parameter.toXMLString() );
				var btn:SbButton = addCenterButton( parameter.@id, "param" + parameter.@type ) as SbButton;
				btn.addEventListener( MouseEvent.MOUSE_UP, onParameterClicked );
				_btns.push( btn );
			}
			invalidateContent();
			openParameter( list[ 0 ].@id );
		}

		// ---------------------------------------------------------------------
		// Parameter components.
		// ---------------------------------------------------------------------

		private function openParameter( id:String ):void {
			closeLastParameter();

			_uiElements = new Vector.<DisplayObject>();

			_parameter = _parametersXML.descendants( "parameter" ).( @id == id )[ 0 ]
			var parameterType:uint = uint( _parameter.@type );

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				var slider:SbSlider = new SbSlider();
				slider.numDecimals = 2;
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
				rangeSlider.numDecimals = 2;
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
				for( var i:uint; i < len; ++i ) {
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
				checkBox.selected = Boolean( _parameter.@value );
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox );
				addChild( checkBox );
				_uiElements.push( checkBox );
			}

			// No Ui component for this parameter.
			else trace( this, "*** Warning *** - parameter type not supported: " + PsykoParameter.getTypeName( parameterType ) );
		}

		private function closeLastParameter():void {
			if( !_uiElements ) return;
			// Remove all ui elements from display and clear listeners
			var len:uint = _uiElements.length;
			for( var i:uint; i < len; ++i ) {
				var uiElement:DisplayObject = _uiElements[ i ];
				if( uiElement is SbSlider ) uiElement.removeEventListener( Event.CHANGE, onSliderChanged );
				else if( uiElement is SbRangedSlider ) uiElement.removeEventListener( Event.CHANGE, onRangeSliderChanged );
				else if( uiElement is ComboBox ) uiElement.removeEventListener( Event.SELECT, onComboBoxChanged );
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
			// TODO: fix this scaling hack, not sure why its necessary on ipad.
			var invSc:Number = 1 / ViewCore.globalScaling;
			element.scaleX = element.scaleY = invSc;
			element.x = ( ViewCore.globalScaling == 2 ? -100 + offsetX * invSc : offsetX ) + ( 1024 / 2 - element.width / 2 ) * invSc;
			element.y = ( ViewCore.globalScaling == 2 ? offsetY * invSc : offsetY ) + UI_ELEMENT_Y * invSc;
//			trace( this, ">>> positioning element at: " + element.x + ", " + element.y + ", scale: " + scaleX );
		}

		private function updateActiveParameter():void {
			var id:String = _parameter.@id;
			_parametersXML.descendants( "parameter" ).( @id == id )[ 0 ] = _parameter;
		}

		private function notifyParameterChange():void {
			brushParameterChangedSignal.dispatch( _parameter );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onKnobChanged( event:Event ):void {
		    var knob:Knob = event.target as Knob;
			trace( knob.value );
			_parameter.@value = knob.value;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:SbCheckBox = event.target as SbCheckBox;
			_parameter.@value = checkBox.selected;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:ComboBox = event.target as ComboBox;
			var list:Array = String( _parameter.@list ).split( "," );
			_parameter.@index = list.indexOf( comboBox.selectedItem );
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			_parameter.@value = slider.value;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			_parameter.@value1 = slider.value1;
			_parameter.@value2 = slider.value2;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onParameterClicked( event:MouseEvent ):void {
			var button:SbButton = event.target as SbButton;
			if( !button ) button = event.target.parent as SbButton;
			var label:String = button.labelText;
			openParameter( label );
		}
	}
}
