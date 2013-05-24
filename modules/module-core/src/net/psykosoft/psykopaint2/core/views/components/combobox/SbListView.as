package net.psykosoft.psykopaint2.core.views.components.combobox
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Elastic;

    import flash.display.Sprite;
    import flash.events.Event;

    public class SbListView extends Sprite{

        public static const CHANGE:String = "onChange";

        private var _itemViews:Vector.<SbListItemView>
        private var _itemViewContainer:Sprite;

        private var _selectedIndex:int;
        private var _tweenSpeed:Number = 0.35;
        private var _expandedHeight:Number;

        private var _opened:Boolean=false;

        //Declared in fla
        public var topImage:Sprite;
        public var bottomImage:Sprite;
        public var bottomImageUpward:Sprite;

        public function SbListView() {
            super();

			_itemViews = new Vector.<SbListItemView>();
			_itemViewContainer = new Sprite();

			topImage.y=0;
			topImage.x = 4;
			bottomImage.y = 0;
			bottomImage.x = 10;
			bottomImageUpward.x=3;
			bottomImageUpward.y=0;

			this.addChild(_itemViewContainer);
		}



		public function removeAll():void
		{
			for (var i:int = _itemViews.length-1; i > 0; i--)
			{
				_itemViews[i].parent.removeChild(_itemViews[i]);

			}
			_itemViews = new Vector.<SbListItemView>();
		}

		public function removeItemAt(index:int):void
		{
			_itemViews[index].parent.removeChild(_itemViews[index]);
			_itemViews.splice(index,1);

			caluclateExpandedHeight();

		}

		public function addItemAt(dataObject:Object, index:int):void
		{
			var listItemVO:SbListItemVO = new SbListItemVO(dataObject);

			listItemVO.odd = (index%2==1)?true:false;
			var newListItemView :SbListItemView = new SbListItemView();
            newListItemView.setData( listItemVO );
			_itemViews.splice(index,0,newListItemView);
			_itemViewContainer.addChild(newListItemView);

			caluclateExpandedHeight();
		}

		public function addItem(dataObject:Object):void{

			var listItemVO:SbListItemVO = new SbListItemVO(dataObject);

			listItemVO.odd = (_itemViews.length%2==1)?true:false;

            trace( this, "creating list item....", listItemVO.odd );
			var newListItemView :SbListItemView = new SbListItemView();
            newListItemView.setData( listItemVO );
			_itemViews.push(newListItemView);
			_itemViewContainer.addChild(newListItemView);

			caluclateExpandedHeight();
		}


		private function caluclateExpandedHeight():void{
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
					var currentItemView:SbListItemView = _itemViews[i];


                    TweenLite.killTweensOf(currentItemView);

					//ONLY REUPDATE ONCE
					if(i==0){

						if(speed==0){
							currentItemView.scaleY=1;
						}else
                        TweenLite.to(currentItemView, speed, { scaleY:1, ease:Elastic.easeOut, onStart:update, onUpdate:update, onComplete:update });
                        //TODO: make sure the update function is being called
					}else {
						if(speed==0){
							currentItemView.scaleY=1;
						}else
                        TweenLite.to(currentItemView, speed, { scaleY:1, ease:Elastic.easeOut });
					}
				}

                TweenLite.killTweensOf(topImage);
                TweenLite.killTweensOf(bottomImage);
                TweenLite.killTweensOf(bottomImageUpward);
                TweenLite.to(topImage, speed, { scaleY:1, ease:Elastic.easeOut });
                TweenLite.to(bottomImage, speed, { scaleY:1, ease:Elastic.easeOut });
                TweenLite.to(bottomImageUpward, speed, { scaleY:1, ease:Elastic.easeOut });

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
					var currentItemView:SbListItemView = _itemViews[i];

                    TweenLite.killTweensOf(currentItemView);

					if(i<positionIndex){
						//currentItemView.height -=5;
						if(speed==0){
							currentItemView.height = 1;
						}else
                        TweenLite.to(currentItemView, speed, { height:1, ease:Elastic.easeOut });

					}else if(i==positionIndex){

                        TweenLite.to(currentItemView, speed, { onStart:update, onUpdate:update, onComplete:update });

					}else {
						if(speed==0){
							currentItemView.height = 1;
						}else
                        TweenLite.to(currentItemView, speed, { height:1, ease:Elastic.easeOut });
					}

				}

                TweenLite.killTweensOf(topImage);
                TweenLite.killTweensOf(bottomImage);
                TweenLite.killTweensOf(bottomImageUpward);
                TweenLite.to(topImage, speed, { y:-1, height:1, ease:Elastic.easeOut });
                TweenLite.to(bottomImage, speed, { height:1, ease:Elastic.easeOut });
                TweenLite.to(bottomImageUpward, speed, { height:1, ease:Elastic.easeOut });


				if(speed==0){
					update();
				}

				dispatchEvent(new Event(SbListView.CHANGE));

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

			topImage.y=-topImage.height+1;

			if(_itemViews.length>=1){
				trace("SBListView:update");

				//REPOSITION ITEMS IN LINE
				for (var i:int = 0; i < _itemViews.length; i++)
				{
					var currentItemView:SbListItemView = _itemViews[i];

					currentItemView.getData().odd = (i%2==1)?false:true;
					currentItemView.setData(currentItemView.getData());


					if(i>0)
					currentItemView.y = _itemViews[i-1].y + _itemViews[i-1].height-1;

					if(currentItemView.height<2){
						currentItemView.visible=false;
					}else {
						currentItemView.visible=true;

					}

				}

				//IF LAST ITEM IS upward there is a different end
				var lastItemView:SbListItemView = _itemViews[_itemViews.length-1];
				bottomImage.visible = !lastItemView.getData().odd;
				bottomImageUpward.visible = !bottomImage.visible;

				bottomImage.y = _itemViews[_itemViews.length-1].y + _itemViews[_itemViews.length-1].height-1;
				bottomImageUpward.y = _itemViews[_itemViews.length-1].y + _itemViews[_itemViews.length-1].height-1;

			}

		}

		public function get expandedHeight():Number{
			return _expandedHeight;
		}


		 public function destroy():void{
			//TODO: make sure everything is disposed

		}

		public function get tweenSpeed():Number
		{
			return _tweenSpeed;
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function get selectedItem():SbListItemVO
		{

			return _itemViews[_selectedIndex].getData();
		}




	}
}