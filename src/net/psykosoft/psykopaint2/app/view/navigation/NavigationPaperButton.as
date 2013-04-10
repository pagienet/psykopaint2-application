package net.psykosoft.psykopaint2.app.view.navigation
{
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class NavigationPaperButton extends Button
	{
		
		private var _paperImage : Image;
		
		
		public function NavigationPaperButton(upState:Texture, text:String="")
		{
			super(upState,text);
			scaleWhenDown = 0.98;
			
		}
		
		
		public function setData(label:String,iconID:String):void{
			
			
		}
	}
}