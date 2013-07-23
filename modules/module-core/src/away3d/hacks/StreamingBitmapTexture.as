package away3d.hacks
{

	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	public class StreamingBitmapTexture extends BitmapTexture
	{
		private const QUALITIES:uint = 2;

		private var _texture:TextureBase;
		private var _currentQuality:int = QUALITIES;
		private var _mipGenerator:BitmapData;
		private var _drawMatrix:Matrix;

		public function StreamingBitmapTexture( bitmapData:BitmapData ) {
			super( bitmapData, false );
		}

		/*override protected function uploadContent( texture:TextureBase ):void {
			while( _currentQuality >= QUALITIES ) {
				increaseQuality();
			}
		}

		public function increaseQuality():void {
			if( _currentQuality < 0 ) return;
			generateMipMapForLevel( _currentQuality );
			_currentQuality--;
		}

		private function generateMipMapForLevel( mipLevel:uint ):void {
			var size:uint = _width >> mipLevel;
			var scale:Number = size / _width;
			_drawMatrix.a = scale;
			_drawMatrix.d = scale;
			_mipGenerator.draw( _bitmapData, _drawMatrix );
			Texture( _texture ).uploadFromBitmapData( _mipGenerator );
		}

		override protected function createTexture( context:Context3D ):TextureBase {
			return _texture = context.createTexture( _width, _height, Context3DTextureFormat.BGRA, false, QUALITIES );
		}

		override protected function setSize( width:int, height:int ):void {
			super.setSize( width, height );
			_currentQuality = Math.log( _width ) / Math.log( 2 );
			_mipGenerator = new BitmapData( _width, _height );
			_drawMatrix = new Matrix();
		}*/
	}
}
