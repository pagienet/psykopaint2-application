package net.psykosoft.psykopaint2.base.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;


	/**
	 * @author mathieu
	 */
	public class DraggableDecorator extends EventDispatcher
	{
		public static const DRAG : String = "onDrag";

		private var _decorated : DisplayObject;
		private var _bounds : Rectangle;
		private var _target : DisplayObject;
		private var _followers : Array;
		private var _shiftPosition:Number;
		private var _clickOffset:Number;

		public function DraggableDecorator(decorated : DisplayObject,bounds : Rectangle = null,para_target : Sprite = null,followers:Array=null)
		{
			_followers = followers;
			_decorated = decorated;
			_target = (para_target == null) ? decorated : para_target;
			_bounds = bounds;

			enable();
		}


		public function enable() : void
		{
			//_decorated.useHandCursor = true;
			_decorated.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			//_decorated.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function disable() : void
		{
			//_decorated.useHandCursor = false;
			_decorated.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			
			//just in case:
			if ( _decorated.stage )
			{
				_decorated.stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				_decorated.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			}
		}

		private function onDragMove(event:Event) : void
		{
			if(_followers!=null)
				for (var i : int = 0; i < _followers.length; i++) {

					_followers[i].x = _decorated.x;
					_followers[i].y = _decorated.y;
				}

			dispatchEvent(new Event(DRAG));
		}


		public function get decorated() : DisplayObject
		{
			return _decorated;
		}

		public function setBounds(value : Rectangle) : void
		{
			_bounds = value;
		}

		public function get target() : DisplayObject
		{
			return _target;
		}

		public function set target(target : DisplayObject) : void
		{
			_target = target;
		}

		public function get shiftPosition():Number
		{
			return _shiftPosition;
		}

		public function set shiftPosition(value:Number):void
		{
			_shiftPosition = value;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onStageMouseUp(event:MouseEvent):void 
		{
			_decorated.stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_decorated.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		private function onMouseDown(event:MouseEvent):void 
		{
			_decorated.stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_decorated.stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );

			_shiftPosition = _decorated.mouseY - _decorated.parent.mouseY;
			_clickOffset = _decorated.y - _decorated.parent.mouseY;
		}

		private function onStageMouseMove(event:MouseEvent):void 
		{
			_decorated.y = _decorated.parent.mouseY - _shiftPosition + _clickOffset;
			if ( _decorated.y < _bounds.y ) _decorated.y = _bounds.y;
			else if ( _decorated.y > _bounds.y+_bounds.height ) _decorated.y = _bounds.y+_bounds.height;
		}
	}
}
