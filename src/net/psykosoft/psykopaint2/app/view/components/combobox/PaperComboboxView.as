package net.psykosoft.psykopaint2.app.view.components.combobox
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.utils.decorator.DraggableDecorator;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class PaperComboboxView extends Sprite
	{
		
		private var _bgView:Image;
		private var _listView:PaperListView;
		private var _listViewContainer:Sprite;
		private var _dragDecorator:DraggableDecorator;
		
		
		public function PaperComboboxView()
		{
			super();
			
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxBg"));
			_listView = new PaperListView();
			_listViewContainer = new Sprite();
			
			_bgView.y = -15;
			_listViewContainer.x=25;
			_listViewContainer.y=12;
			 
			_listViewContainer.addChild(_listView); 
			this.addChild(_listViewContainer); 
			this.addChild(_bgView); 
			
			_dragDecorator = new DraggableDecorator(_listView,new Rectangle(0,0,_listView.width,_listView.height));
			//_listView.addEventListener(TouchEvent.TOUCH,onTouchEventHandle);
		}
		
		private function onTouchEventHandle(e:TouchEvent):void
		{
			
			var touch:Touch = e.touches[0];
			var position:Point = touch.getLocation(stage);
			if (touch.phase == TouchPhase.BEGAN){
				
			}else if (touch.phase == TouchPhase.MOVED){
				_listView.y = position.y - _listView.height/2;
				
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
		}		
		
		public function addItem(params:Object):void
		{
			
			_listView.addItem(params);
			
			
			//UPDATE DRAG DECORATOR
			_dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height));
		}
		
		
		private function update():void{
			
			
		}
	}
}