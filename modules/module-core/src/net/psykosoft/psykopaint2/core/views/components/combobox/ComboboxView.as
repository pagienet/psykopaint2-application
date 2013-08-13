package net.psykosoft.psykopaint2.core.views.components.combobox
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.osflash.signals.Signal;

public class ComboboxView extends Sprite
	{
		private var _clickOffsetY:Number = 0;
		private var _listView:ListView;
		private var _mouseIsDown:Boolean;

		public var interactionStartedSignal:Signal;
		public var interactionEndedSignal:Signal;

		public function ComboboxView() {
			super();

			interactionStartedSignal = new Signal();
			interactionEndedSignal = new Signal();

			_listView = new ListView();
			addChildAt( _listView, 0 );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onListChange( e:Event ):void {
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		public function addItem( params:Object ):void {
			_listView.addItem( params );
		}

		public function addItemAt( params:Object, index:int ):void {
			_listView.addItemAt( params, index );
		}

		public function removeItemAt( index:int ):void {
			_listView.removeItemAt( index );
		}

		public function removeAll():void {
			_listView.removeAll();
		}

		public function get selectedIndex():int {
			return _listView.selectedIndex;
		}

		public function set selectedIndex( value:int ):void {
			_listView.selectedIndex = value;
		}

		public function get selectedItem():ListItemVO {
			return _listView.selectedItem;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onListMouseDown( e:MouseEvent ):void {
			interactionStartedSignal.dispatch();

			if( _mouseIsDown ) return;
			_mouseIsDown = true;
			_listView.expand();
			_clickOffsetY = _listView.y - stage.mouseY;
			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			interactionEndedSignal.dispatch();

			if( !_mouseIsDown ) return;
			_mouseIsDown = false;
			// Update list selected index from Y.
			if( !_listView.animating ) {
				var offset:Number = _listView.selectedIndex * _listView.itemHeight;
				var resY:Number = _listView.y - offset;
				var ratio:Number = -resY / _listView.itemHeight;
				var selectedIndex:uint = Math.round( ratio );
				if( _listView.selectedIndex != selectedIndex ) {
					_listView.selectedIndex = selectedIndex;
				}
			}
			_listView.y = 0;
			_listView.collapse();
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		private function onEnterFrame( event:Event ):void {
			// Drag Y.
			var targetY:Number = _clickOffsetY + stage.mouseY;
			var offset:Number = _listView.selectedIndex * _listView.itemHeight;
			var topLimit:Number = -_listView.expandedHeight + _listView.itemHeight + offset;
			if( targetY < topLimit ) targetY = topLimit;
			else if( targetY > offset ) targetY = offset;
			_listView.y = targetY;
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			_listView.addEventListener( MouseEvent.MOUSE_DOWN, onListMouseDown );
			_listView.addEventListener( ListView.CHANGE, onListChange );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp )
		}
	}
}
