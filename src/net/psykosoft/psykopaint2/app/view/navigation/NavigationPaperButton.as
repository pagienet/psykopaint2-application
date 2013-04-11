package net.psykosoft.psykopaint2.app.view.navigation
{
	import starling.display.Button;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class NavigationPaperButton extends Button
	{
		
		private var _paperImage : Image;
		
		
		public function NavigationPaperButton(upState:Texture, text:String="")
		{
			super(upState,text);
			scaleWhenDown = 1;
			
		}
		
		
		public function setData(label:String,iconID:String):void{
			
			
		}
	}
}