package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class BrushStylePreview extends MovieClip
	{
		public var txt:TextField;
		
		private static var styleToFrame:Array = [
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
		];
		
		
		
		public function BrushStylePreview()
		{
			super();
		}
		
		public function showIcon( id:String ):void
		{
			txt.text = "";
			var idx:int = styleToFrame.indexOf(id);
			if ( idx!=-1)
				gotoAndStop(idx+1);
			else
			{
				gotoAndStop(1);
				txt.text = id.toUpperCase();
			}
				//throw("no icon for style '"+id+"'");
		}
	}
}