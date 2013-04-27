package net.psykosoft.psykopaint2.app.view.components.combobox
{
	
	import net.psykosoft.psykopaint2.app.managers.assets.Fonts;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	public class PaperListItemView extends Sprite
	{
		private var _bgView:Image;
		private var _txt:TextField;
		private var _data:PaperListItemVO;

		public function PaperListItemView(data:PaperListItemVO)
		{
			super();
			this._data = data; 
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture((_data.odd==true)?"comboboxListUpward":"comboboxListDownward"));
			this.addChild(_bgView); 
			
			
			_txt = new TextField(_bgView.width,_bgView.height,"0",Fonts.Warugaki,20,0);
			this.addChild(_txt); 
			_txt.text = data.label;

		}
		
		
		
		public function setData(value:PaperListItemVO):void{
			
			
			if(_bgView.parent){
				_bgView.parent.removeChild(_bgView);
				_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture((_data.odd==true)?"comboboxListUpward":"comboboxListDownward"));
				this.addChildAt(_bgView,0);
			}
			if(value.label!=_txt.text){
				_txt.text = value.label;
			}
			
			this._data = value; 
			
		}
		
		public function getData():PaperListItemVO{
			return _data ; 
			
		}
		
		
		
		/*
		override public function get height():Number{
			return _bgView.height
		}
		
		override public function set height(value:Number):void{
			 _bgView.height = value;
			 _txt.height = value;
		}*/
		
	}
}