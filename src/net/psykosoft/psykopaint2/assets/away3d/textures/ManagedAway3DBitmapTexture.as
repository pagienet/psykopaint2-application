package net.psykosoft.psykopaint2.assets.away3d.textures
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.textures.Texture2DBase;
	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.resources.FreeTextureManager;

	import net.psykosoft.psykopaint2.resources.TextureProxy;

	// this is all a bit dirty, but it basically bypasses away3d's textures to feed it our own
	public class ManagedAway3DBitmapTexture extends Texture2DBase
	{
		private static var _mipMaps : Array = [];
		private static var _mipMapUses : Array = [];

		private var _bitmapData : BitmapData;
		private var _mipMapHolder : BitmapData;

		private var _texture : TextureProxy;

		private var _useMipMapping:Boolean = false;

		public function ManagedAway3DBitmapTexture(bitmapData : BitmapData, useMipMapping:Boolean = false)
		{
			super();

			_useMipMapping = useMipMapping;
			this.bitmapData = bitmapData;
		}

		override public function getTextureForStage3D(stage3DProxy : Stage3DProxy) : TextureBase
		{
			var contextIndex : uint = stage3DProxy.stage3DIndex;
			var context : Context3D = stage3DProxy.context3D;

			if (!_texture || _dirty[contextIndex] != context) {
				createTexture(context);
				_dirty[contextIndex] = context;
				uploadContent(null);
			}

			return _texture.texture;
		}

		public function get bitmapData() : BitmapData
		{
			return _bitmapData;
		}

		override protected function createTexture(context : Context3D) : TextureBase
		{
			_texture = new TextureProxy(_bitmapData.width, _bitmapData.height, Context3DTextureFormat.BGRA, false, FreeTextureManager.getInstance());
			return null;
		}

		public function set bitmapData(value : BitmapData) : void
		{
			if (value == _bitmapData) return;

			if (!TextureUtils.isBitmapDataValid(value))
				throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");

			invalidateContent();
			setSize(value.width, value.height);

			_bitmapData = value;

			if( _useMipMapping ) {
				setMipMap();
			}
		}

		override protected function uploadContent(texture : TextureBase) : void
		{
			// TODO: do not create mipmaps if we're not uploading them ( comment out setMipMap ).

			if( _useMipMapping ) {
				var sourceWidth:uint = _bitmapData.width, sourceHeight:uint = _bitmapData.height;
				var w:uint = sourceWidth, h:uint = sourceHeight;
				var i:uint;
				var rect:Rectangle = new Rectangle( 0, 0, w, h );
				var matrix:Matrix = new Matrix();

				while( w >= 1 || h >= 1 ) {

					trace( this, "uploading mip map: " + i );

					_mipMapHolder.fillRect( rect, 0 );

					matrix.a = rect.width / sourceWidth;
					matrix.d = rect.height / sourceHeight;

					_mipMapHolder.draw( _bitmapData, matrix, null, null, null, true );

					_texture.uploadFromBitmapData( _mipMapHolder, i++ );

					w >>= 1;
					h >>= 1;

					rect.width = w > 1 ? w : 1;
					rect.height = h > 1 ? h : 1;
				}
			}
			else {
				_texture.uploadFromBitmapData(_bitmapData, 0);
			}
		}

		private function setMipMap() : void
		{
			var oldW : uint, oldH : uint;
			var newW : uint, newH : uint;

			newW = _bitmapData.width;
			newH = _bitmapData.height;

			if (_mipMapHolder) {
				oldW = _mipMapHolder.width;
				oldH = _mipMapHolder.height;
				if (oldW == _bitmapData.width && oldH == _bitmapData.height) return;

				if (--_mipMapUses[oldW][_mipMapHolder.height] == 0) {
					_mipMaps[oldW][oldH].dispose();
					_mipMaps[oldW][oldH] = null;
				}
			}

			if (!_mipMaps[newW]) {
				_mipMaps[newW] = [];
				_mipMapUses[newW] = [];
			}
			if (!_mipMaps[newW][newH]) {
				_mipMapHolder = _mipMaps[newW][newH] = new BitmapData(newW, newH, true);
				_mipMapUses[newW][newH] = 1;
			}
			else {
				++_mipMapUses[newW][newH];
				_mipMapHolder = _mipMaps[newW][newH];
			}
		}

		override protected function invalidateSize() : void
		{
			super.invalidateSize();
			if (_texture) {
				_texture.dispose();
				_texture = null;
			}
		}


		override public function dispose() : void
		{
			super.dispose();
			_texture.dispose();
		}
	}
}
