package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.base.ui.components.PsykoLabel;
	
	public class BrushStylePreview extends MovieClip
	{
		//public var txt:TextField;
		public var label:PsykoLabel;
		
		
		/*private static var styleToFrame:Array = [
			"paint1","basic","splat","line","sumi",
			"Small","Medium","Large",
			"splotch","basic smooth","noisy",
			"eraser1","eraser2","eraser3","eraser4",
			"No Style","Magritte 1","Ryden 1","Ryden 2",
			"Picasso 1","Picasso 2","Anatomie",
			"Revolution","Lady in a Boat","Beheading",
			"Turner 1","Turner 2","Turner 3","Turner 4",
			"Cezanne 1","Cezanne 2","Starry Night",
			"mona lisa","Grey 1","Grey 2","Black and White","Franz Marc","Goya",
			"Munch","Le Guitarriste",
			"pencilSketch","wet","render","sketch",
			"bubbles","cern","curly"
		];*/
		
		
		
		public function BrushStylePreview()
		{
			super();
		}
		
		public function showIcon( id:String ):void
		{
			if ( label ) label.text = "";
			//var idx:int = styleToFrame.indexOf(id);
			gotoAndStop(1);
			if ( movieClipHasLabel(this,id))
				gotoAndStop(id);
				if ( label ) label.text = id.toUpperCase();
			else
			{
				gotoAndStop(1);
				if ( label ) label.text = id.toUpperCase();
			}
				//throw("no icon for style '"+id+"'");
		}
		
		private function movieClipHasLabel(movieClip:MovieClip, labelName:String):Boolean {
			 var i:int;
			 var k:int = movieClip.currentLabels.length;
			 for (i; i < k; ++i) {
				 var label:FrameLabel = movieClip.currentLabels[i];
				 if (label.name == labelName)
					 return true; 
				}
			 return false;
			}
	}
}