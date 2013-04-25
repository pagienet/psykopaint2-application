package net.psykosoft.psykopaint2.utils.decorator
{
				
	
		
		import flash.geom.Point;
		import flash.geom.Rectangle;
		
		import starling.display.DisplayObject;
		import starling.display.Sprite;
		import starling.events.Event;
		import starling.events.EventDispatcher;
		import starling.events.Touch;
		import starling.events.TouchEvent;
		import starling.events.TouchPhase;
		
		/**
		 * @author mathieu
		 */
		public class DraggableDecorator  extends starling.events.EventDispatcher
		{
			public static const DRAG : String = "onDrag";
			
			private var _decorated : DisplayObject;
			private var _bounds : Rectangle;
			private var _target : DisplayObject;
			private var _followers : Array;
			private var _initialPosition:Point;
			private var _shiftPosition:Point;
			
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
				_decorated.addEventListener(TouchEvent.TOUCH,onTouchEventHandle);
			}
			
			
			public function disable() : void
			{
				//_decorated.useHandCursor = false;
				_decorated.removeEventListener(TouchEvent.TOUCH,onTouchEventHandle);
				
			}
			
			private function onTouchEventHandle(e:TouchEvent):void
			{
				
				var touch:Touch = e.touches[0];
				var position:Point = touch.getLocation(_decorated.parent);
				var shiftPosition:Point = touch.getLocation(_decorated);
				if (touch.phase == TouchPhase.BEGAN){
					_initialPosition = position;
					_shiftPosition = new Point(shiftPosition.x-position.x,shiftPosition.y-position.y) ;
					trace("begin _initialPosition = "+_initialPosition);
					trace("begin _shiftPosition = "+_shiftPosition);
				}else if (touch.phase == TouchPhase.MOVED){
					
					_decorated.x= -_initialPosition.x + position.x-_shiftPosition.x;
					_decorated.y= -_initialPosition.y + position.y-_shiftPosition.y;
					
					_decorated.x = Math.max(_bounds.x,_decorated.x);
					_decorated.x = Math.min(_bounds.x+_bounds.width,_decorated.x);
					_decorated.y = Math.max(_bounds.y,_decorated.y);
					_decorated.y = Math.min(_bounds.y+_bounds.height,_decorated.y);
					
					trace("TouchPhase.MOVED position = "+_decorated.x+","+_decorated.y);
				}else if (touch.phase == TouchPhase.ENDED){
					
				}
			}		
			
			private function onDragMove(event : starling.events.Event) : void
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
		}
	}
