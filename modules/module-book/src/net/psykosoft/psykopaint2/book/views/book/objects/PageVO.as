package net.psykosoft.psykopaint2.book.views.book.objects
{

	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import flash.display.Sprite;

	public class PageVO
	{
		private var _frontTexture:BitmapTexture;
		private var _backTexture:BitmapTexture;

		private var _frontContent:Sprite;
		private var _backContent:Sprite;

		public function PageVO() {
			super();
		}

		public function set frontContent( value:Sprite ):void {
			_frontContent = value;
			_frontTexture = produceSnapshotFromContent( _frontContent );
		}

		public function set backContent( value:Sprite ):void {
			_backContent = value;
			_backTexture = produceSnapshotFromContent( _backContent );
		}

		private function produceSnapshotFromContent( content:Sprite ):BitmapTexture {
			var bmd:BitmapData = new BitmapData( content.width, content.height, false, 0 );
			bmd.draw( content );
			return new BitmapTexture( bmd );
		}

		public function get backTexture():BitmapTexture {
			return _backTexture;
		}

		public function get frontTexture():BitmapTexture {
			return _frontTexture;
		}
	}
}
