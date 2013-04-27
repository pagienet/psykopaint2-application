package net.psykosoft.psykopaint2.app.view.components.combobox
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.utils.decorator.DraggableDecorator;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class PaperComboboxView extends Sprite
	{
		
		private var _bgView:Image;
		private var _listView:PaperListView;
		private var _listViewContainer:Sprite;
		private var _dragDecorator:DraggableDecorator;
		private var _selectedIndex:int;
		
		
		public function PaperComboboxView()
		{
			super();
			
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxBg"));
			_listView = new PaperListView();
			_listViewContainer = new Sprite();
			
			_bgView.y = -15;
			_listViewContainer.x=42;
			_listViewContainer.y=7;
			
			_bgView.touchable=false;
			 
			_listViewContainer.addChild(_listView); 
			this.addChild(_listViewContainer); 
			this.addChild(_bgView); 
			
			_dragDecorator = new DraggableDecorator(_listView,new Rectangle(0,0,_listView.width,_listView.height));
			_listView.addEventListener(TouchEvent.TOUCH,onTouchEventHandle);
			_listView.addEventListener(Event.CHANGE,onChangeList);
			
		}
		
		private function onChangeList(e:Event):void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onTouchEventHandle(e:TouchEvent):void
		{
			
			var touch:Touch = e.touches[0];
			var position:Point = touch.getLocation(_listView);
			if (touch.phase == TouchPhase.BEGAN){
				_listView.expand();
				Starling.juggler.tween(_listView,_listView.tweenSpeed,{y:-_listView.selectedIndex*_listView.height/_listView.length,transition:Transitions.EASE_OUT});
				
				_dragDecorator.shiftPosition.y+=_listView.selectedIndex*_listView.height/_listView.length;
				
			}else if (touch.phase == TouchPhase.MOVED){
				
			}else if (touch.phase == TouchPhase.ENDED){
				//SNAP VIEW TO CURRENT VIEW
				
				var positionIndex:int = getPositionIndex();
				Starling.juggler.tween(_listView,_listView.tweenSpeed,{y:0,transition:Transitions.EASE_OUT});
				_listView.collapse(positionIndex);
				_selectedIndex = positionIndex;
			}
		}	
		
		
		
		private function getPositionIndex():int{
			
			var positionRatio:Number = -_listView .y / _listView.height;
			 
			return Math.max(Math.min(Math.round(positionRatio*_listView.length),_listView.length-1),0);
		}
		
		public function addItem(params:Object):void
		{
			
			_listView.addItem(params);
			
			//UPDATE DRAG DECORATOR
			_dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
		}
		
		
		public function addItemAt(params:Object,index:int):void
		{
			
			_listView.addItemAt(params,index);
			
			//UPDATE DRAG DECORATOR
			_dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
		}
		
		
		public function removeItemAt(index:int):void
		{
			
			_listView.removeItemAt(index);
			
			//UPDATE DRAG DECORATOR
			_dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
		}
		
		public function removeAll():void
		{
			
			_listView.removeAll();
			
			//UPDATE DRAG DECORATOR
			_dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			_selectedIndex = value;
			
			Starling.juggler.tween(_listView,_listView.tweenSpeed,{y:0,transition:Transitions.EASE_OUT});
			_listView.collapse(_selectedIndex);
		}
		
		
		public function get selectedItem():PaperListItemVO
		{
			return _listView.selectedItem;
		}
		
	
		
	}
}