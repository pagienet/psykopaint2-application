package net.psykosoft.psykopaint2.app.managers.textures
{

	import flash.display.BitmapData;

	import starling.textures.Texture;

	public class SimpleTextureManager
	{
		public function SimpleTextureManager() {
			super();
		}

		private static var _transparentTexture:Texture;
		public static function get transparentTexture():Texture {
			if( !_transparentTexture ) {
				_transparentTexture = generateTextureOfColor( 0x000000, true );
			}
			return _transparentTexture;
		}

		private static var _solidGrayTexture:Texture;
		public static function get solidGrayTexture():Texture {
			if( !_solidGrayTexture ) {
				_solidGrayTexture = generateTextureOfColor( 0xCCCCCC, false );
			}
			return _solidGrayTexture;
		}

		private static var _solidWhiteTexture:Texture;
		public static function get solidWhiteTexture():Texture {
			if( !_solidWhiteTexture ) {
				_solidWhiteTexture = generateTextureOfColor( 0xFFFFFF, false );
			}
			return _solidWhiteTexture;
		}

		private static var _solidBlackTexture:Texture;
		public static function get solidBlackTexture():Texture {
			if( !_solidBlackTexture ) {
				_solidBlackTexture = generateTextureOfColor( 0x000000, false );
			}
			return _solidBlackTexture;
		}

		private static function generateTextureOfColor( color:uint, transparent:Boolean ):Texture {
			var bmd:BitmapData = new BitmapData( 16, 16, transparent, color );
			var tex:Texture = Texture.fromBitmapData( bmd, false );
			bmd.dispose();
			return tex;
		}
	}
}
