package net.psykosoft.psykopaint2.ui.extensions.general
{

	import starling.display.Image;
	import starling.textures.Texture;

	/*
	* Feathers auto sizes components. This king of Image will not react to such auto-sizing.
	* */
	public class FixedSizeImage extends Image
	{
		public function FixedSizeImage( texture:Texture ) {
			super( texture );
		}

		override public function set width( value:Number ):void {
			// Do nothing.
		}

		override public function set height( value:Number ):void {
			// Do nothing.
		}
	}
}
