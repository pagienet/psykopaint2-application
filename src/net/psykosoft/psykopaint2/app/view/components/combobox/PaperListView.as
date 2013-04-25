package net.psykosoft.psykopaint2.app.view.components.combobox
{
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class PaperListView extends Sprite
	{
		
		private var _itemViews:Vector.<PaperListItemView>
		private var _itemViewContainer:Sprite;
		
		private var _topImage:Image;
		private var _bottomImage:Image;
		private var _bottomImageUpward:Image;
		private var _selectedIndex:int;
		
		private var _tweenSpeed:Number = 0.35
		
		private var _expandedHeight:Number;
		
		private var _opened:Boolean=false;
		
		public function PaperListView()
		{
			super();
			
			_itemViews = new Vector.<PaperListItemView>();
			_itemViewContainer = new Sprite();
			
			
			_topImage = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListTop"));		
			_bottomImage = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListBottom"));	
			_bottomImageUpward = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListBottomUpward"));	
			
			_topImage.y=0;
			_topImage.x = 4;
			_bottomImage.y = 0;
			_bottomImage.x = 10;
			_bottomImageUpward.x=3;
			_bottomImageUpward.y=0;
			
			this.addChild(_itemViewContainer);
			this.addChild(_topImage);
			this.addChild(_bottomImage);
			this.addChild(_bottomImageUpward);
		}		
		public function addItem(dataObject:Object):void{
			
			var paperlistItemVO:PaperListItemVO = new PaperListItemVO(dataObject);
			
			paperlistItemVO.odd = !(_itemViews.length%2);
			
			var newPaperListItemView :PaperListItemView = new PaperListItemView(paperlistItemVO);
			_itemViews.push(newPaperListItemView);
			_itemViewContainer.addChild(newPaperListItemView);
			
			
			
			//WHEN ADD AN ITEM WE SET IT TO COLLAPSE
			//
			
			
			expand(0);
			update();
			
			//WHEN EVERYTHING IS EXPANDED WE STORE THE EXPANDED HEIGHT
			if(_itemViews.length>0)
			_expandedHeight = _itemViews[_itemViews.length-1].y+_itemViews[_itemViews.length-1].height
			
				
			collapse(0,0);
			update();
		}
		
		
		public function expand(speed:Number = -1):void
		{
			if(speed==-1){
				speed = _tweenSpeed;
			}
			
				_opened= true;
				for (var i:int = 0; i < _itemViews.length; i++) 
				{
					var currentItemView:PaperListItemView = _itemViews[i];
					
					
					Starling.juggler.removeTweens(currentItemView);

					//ONLY REUPDATE ONCE
					if(i==0){
						
						if(speed==0){
							currentItemView.scaleY=1;
						}else 
						Starling.juggler.tween(currentItemView,speed,{scaleY:1,transition:Transitions.EASE_OUT_BACK,onStart:update,onUpdate:update,onComplete:update});
					}else {
						if(speed==0){
							currentItemView.scaleY=1;
						}else 
						Starling.juggler.tween(currentItemView,speed,{scaleY:1,transition:Transitions.EASE_OUT_BACK});
					}
				}
				
				Starling.juggler.removeTweens(_topImage);
				Starling.juggler.removeTweens(_bottomImage);
				Starling.juggler.removeTweens(_bottomImageUpward);
				Starling.juggler.tween(_topImage,speed,{scaleY:1,transition:Transitions.EASE_OUT});
				Starling.juggler.tween(_bottomImage,speed,{scaleY:1,transition:Transitions.EASE_OUT});
				Starling.juggler.tween(_bottomImageUpward,speed,{scaleY:1,transition:Transitions.EASE_OUT});
				
				if(speed==0){
					update();
				}
		}
		
		public function collapse(positionIndex:int,speed:Number=-1):void
		{
				_opened= false;
				_selectedIndex = positionIndex;
				
				if(speed==-1){
					speed = _tweenSpeed;
				}
				
				for (var i:int = 0; i < _itemViews.length; i++) 
				{
					var currentItemView:PaperListItemView = _itemViews[i];
					
					Starling.juggler.removeTweens(currentItemView);
					
					if(i<positionIndex){
						//currentItemView.height -=5;
						if(speed==0){
							currentItemView.height = 1;
						}else 
						Starling.juggler.tween(currentItemView,speed,{height:1,transition:Transitions.EASE_OUT});
					}else if(i==positionIndex){
						
						Starling.juggler.tween(currentItemView,speed,{onStart:update,onUpdate:update,onComplete:update});

					}else {
						if(speed==0){
							currentItemView.height = 1;
						}else 
						Starling.juggler.tween(currentItemView,speed,{height:1,transition:Transitions.EASE_OUT});

					}
					
				}
				
				
				Starling.juggler.removeTweens(_topImage);
				Starling.juggler.removeTweens(_bottomImage);
				Starling.juggler.removeTweens(_bottomImageUpward);
				Starling.juggler.tween(_topImage,speed,{y:-1,height:1,transition:Transitions.EASE_OUT});
				Starling.juggler.tween(_bottomImage,speed,{height:1,transition:Transitions.EASE_OUT});
				Starling.juggler.tween(_bottomImageUpward,speed,{height:1,transition:Transitions.EASE_OUT});
				
				if(speed==0){
					update();
				}
			
		}
		
		/* OVERRIDE HEIGHT, ONLY TAKE INTO ACCOUNT THE LISTITEMVIEWS WITHOUT TOP AND BOTTOM */
		override public function get height():Number{
			
			return _expandedHeight;
			//return _itemViewContainer.height;
		
		}
		
		override public function set height(value:Number):void{
			_itemViewContainer.height = value;
			update();
		}
		
		 public function  get length():uint{
			return _itemViews.length;
			
		}
		
		
		private function update():void{
			
			_topImage.y=-_topImage.height+1;
			
			if(_itemViews.length>=1){
				trace("PaperListView:update");
				
				//REPOSITION ITEMS IN LINE
				for (var i:int = 0; i < _itemViews.length; i++) 
				{
					var currentItemView:PaperListItemView = _itemViews[i];
					
					if(i>0)
					currentItemView.y = _itemViews[i-1].y + _itemViews[i-1].height-1;
					
					if(currentItemView.height<2){
						currentItemView.visible=false;
					}else {
						currentItemView.visible=true;

					}
					
				}
				
				//IF LAST ITEM IS upward there is a different end
				var lastItemView:PaperListItemView = _itemViews[_itemViews.length-1];
				_bottomImage.visible = !lastItemView.getData().odd;
				_bottomImageUpward.visible = !_bottomImage.visible;
				
				_bottomImage.y = _itemViews[_itemViews.length-1].y + _itemViews[_itemViews.length-1].height-1;
				_bottomImageUpward.y = _itemViews[_itemViews.length-1].y + _itemViews[_itemViews.length-1].height-1;
			
			}
			
		}
		
		public function get expandedHeight():Number{
			return _expandedHeight;
		}
		
		
		 public function destroy():void{
			_topImage.dispose();
			_bottomImage.dispose();
			_topImage.dispose();
			
		}

		public function get topImage():Image
		{
			return _topImage;
		}

		public function get bottomImage():Image
		{
			return _bottomImage;
		}

		public function get tweenSpeed():Number
		{
			return _tweenSpeed;
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}


	}
}