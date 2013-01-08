package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.data.ListCollection;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.events.Event;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _buttonGroup:ButtonGroup;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase() {
			super();
			buttonPressedSignal = new Signal();
		}

		protected function addButtons( definition:ButtonGroupDefinitionVO ):void {
			if( !_buttonGroup ) {
				_buttonGroup = new ButtonGroup();
				_buttonGroup.direction = ButtonGroup.DIRECTION_HORIZONTAL;
				_buttonGroup.buttonProperties = { width: 100, height: 100 };
				addChild( _buttonGroup );
			}
			_buttonGroup.dataProvider = new ListCollection( definition.buttonVOArray );
		}

		override protected function onLayout():void {

			_buttonGroup.validate();

			super.onLayout();
		}

		protected function onButtonTriggered( event:Event ):void {
			var button:Button = event.currentTarget as Button;
			Cc.log( this, "button pressed: " + button );
			buttonPressedSignal.dispatch( button.label );
		}

		override public function dispose():void {

			// TODO: disable button group, specially remove listeners

			super.disable();
		}
	}
}
