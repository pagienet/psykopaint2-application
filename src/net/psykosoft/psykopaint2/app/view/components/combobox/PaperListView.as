package net.psykosoft.psykopaint2.app.view.components.combobox
{
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class PaperListView extends Sprite
	{
		
		private var _itemViews:Vector.<PaperListItemView>
		
		private var _topImage:Image;
		private var _bottomImage:Image;
		private var _bottomImageUpward:Image;
		public function PaperListView()
		{
			super();
			
			_itemViews = new Vector.<PaperListItemView>();
			
			
			_topImage = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListTop"));		
			_bottomImage = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListBottom"));	
			_bottomImageUpward = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("comboboxListBottomUpward"));	
			
			_topImage.y=-_topImage.height;
			_topImage.x = 4;
			_bottomImage.y = 0;
			_bottomImage.x = 10;
			_bottomImageUpward.x=3;
			_bottomImageUpward.y=0;
			
			this.addChild(_topImage);
			this.addChild(_bottomImage);
			this.addChild(_bottomImageUpward);
		}		
		public function addItem(dataObject:Object):void{
			
			var paperlistItemVO:PaperListItemVO = new PaperListItemVO(dataObject);
			
			paperlistItemVO.odd = !(_itemViews.length%2);
			
			var newPaperListItemView :PaperListItemView = new PaperListItemView(paperlistItemVO);
			_itemViews.push(newPaperListItemView);
			
			if(_itemViews.length>1)
			newPaperListItemView.y = _itemViews[_itemViews.length-2].y+_itemViews[_itemViews.length-2].height;
			 
			update();
			
			this.addChild(newPaperListItemView);
		}
		
		
		private function update():void{
			_topImage.y=-_topImage.height;
			
			if(_itemViews.length>=1){
			
				var lastItemView:PaperListItemView = _itemViews[_itemViews.length-1];
				
				//IF LAST ITEM IS upward there is a different end
				_bottomImage.visible = !lastItemView.getData().odd;
				_bottomImageUpward.visible = !_bottomImage.visible;
				
				_bottomImage.y = lastItemView.y+lastItemView.height-1;
				_bottomImageUpward.y = lastItemView.y+lastItemView.height-1;
			
			}
			
		}
		
		
		 public function destroy():void{
			_topImage.dispose();
			_bottomImage.dispose();
			_topImage.dispose();
			
		}
	}
}