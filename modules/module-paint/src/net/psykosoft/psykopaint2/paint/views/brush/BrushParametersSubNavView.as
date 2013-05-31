package net.psykosoft.psykopaint2.paint.views.brush
{

	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.SbNavigationButton;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	// TODO: remove minimalcomps dependency when done

	public class BrushParametersSubNavView extends SubNavigationViewBase
	{
		private var _btns:Vector.<SbNavigationButton>;
		private var _uiElements:Vector.<DisplayObject>;
		private var _parametersXML:XML;
		private var _activeParameter:XML;

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

		// ---------------------------------------------------------------------
		// Parameter listing.
		// ---------------------------------------------------------------------

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
				var btn:SbNavigationButton = addCenterButton( parameter.@id, "param" + parameter.@type ) as SbNavigationButton;
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

			_activeParameter = _parametersXML.descendants( "parameter" ).( @id == id )[ 0 ]
			var parameterType:uint = uint( _activeParameter.@type );

			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				var slider:SbSlider = new SbSlider();
				slider.numDecimals = 2;
				slider.minValue = Number( _activeParameter.@minValue );
				slider.maxValue = Number( _activeParameter.@maxValue );
				slider.value = Number( _activeParameter.@value );
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );
			}

			// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {
				var rangeSlider:SbRangedSlider = new SbRangedSlider();
				rangeSlider.numDecimals = 2;
				rangeSlider.minValue = Number( _activeParameter.@minValue );
				rangeSlider.maxValue = Number( _activeParameter.@maxValue );
				rangeSlider.value1 = Number( _activeParameter.@value1 );
				rangeSlider.value2 = Number( _activeParameter.@value2 );
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
			}

			// Combo box. // TODO: implement real combobox, design is ready
			else if( parameterType == PsykoParameter.StringListParameter ) {
				var comboBox:ComboBox = new ComboBox( this );
				comboBox.alternateRows = true;
				comboBox.openPosition = ComboBox.TOP;
				var list:Array = String( _activeParameter.@list ).split( "," );
				var len:uint = list.length;
				for( var i:uint; i < len; ++i ) {
					var option:String = list[ i ];
					comboBox.addItem( option );
				}
				comboBox.defaultLabel = list[ uint( _activeParameter.@index ) ];
				comboBox.numVisibleItems = Math.min( 6, len );
				comboBox.addEventListener( Event.SELECT, onComboBoxChanged );
				positionUiElement( comboBox as DisplayObject );
				_uiElements.push( comboBox );
			}

			// Check box
			else if( parameterType == PsykoParameter.BooleanParameter ) {
				trace( ">>>>> BOOLEAN: " + _activeParameter.toXMLString() );
				var checkBox:SbCheckBox = new SbCheckBox();
				checkBox.selected = Boolean( _activeParameter.@value );
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox as DisplayObject );
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
				// TODO: dispose combo boxes...
				// TODO: dispose check boxes...
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

		private function positionUiElement( element:DisplayObject ):void {
			// TODO: fix this scaling hack, not sure why its necessary on ipad.
			element.scaleX = element.scaleY = 1 / ViewCore.globalScaling;
			element.x = ( ViewCore.globalScaling == 2 ? -100 : 0 ) + ( 1024 / 2 - element.width / 2 ) / ViewCore.globalScaling;
			element.y = UI_ELEMENT_Y / ViewCore.globalScaling;
//			trace( this, ">>> positioning element at: " + element.x + ", " + element.y + ", scale: " + scaleX );
		}

		private function updateActiveParameter():void {
			var id:String = _activeParameter.@id;
			_parametersXML.descendants( "parameter" ).( @id == id )[ 0 ] = _activeParameter;
		}

		private function notifyParameterChange():void {
			brushParameterChangedSignal.dispatch( _activeParameter );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:SbCheckBox = event.target as SbCheckBox;
			_activeParameter.@value = checkBox.selected;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onComboBoxChanged( event:Event ):void {
			var comboBox:ComboBox = event.target as ComboBox;
			var list:Array = String( _activeParameter.@list ).split( "," );
			_activeParameter.@index = list.indexOf( comboBox.selectedItem );
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onSliderChanged( event:Event ):void {
			var slider:SbSlider = event.target as SbSlider;
			_activeParameter.@value = slider.value;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onRangeSliderChanged( event:Event ):void {
			var slider:SbRangedSlider = event.target as SbRangedSlider;
			_activeParameter.@value1 = slider.value1;
			_activeParameter.@value2 = slider.value2;
			updateActiveParameter();
			notifyParameterChange();
		}

		private function onParameterClicked( event:MouseEvent ):void {
			var button:SbNavigationButton = event.target as SbNavigationButton;
			if( !button ) button = event.target.parent as SbNavigationButton;
			var label:String = button.labelText;
			openParameter( label );
		}
	}
}
