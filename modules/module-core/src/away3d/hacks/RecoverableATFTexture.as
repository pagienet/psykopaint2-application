package away3d.hacks {
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	
	import away3d.textures.ATFData;
	import away3d.textures.Texture2DBase;
	
	public class RecoverableATFTexture extends Texture2DBase
	{
		private var _atfData : ATFData;
		private var _textureClass:Class;
		
		public function RecoverableATFTexture(textureClass:Class)
		{
			super();
			_textureClass = textureClass;
			atfData = new ATFData(new textureClass() as ByteArray);
			_format = atfData.format;
			_hasMipmaps = _atfData.numTextures > 1;
		}
		
		
		public function get atfData() : ATFData
		{
			return _atfData;
		}
		
		public function set atfData(value : ATFData) : void
		{
			_atfData = value;
			
			invalidateContent();
			
			setSize(value.width, value.height);
		}	
		
		
		override protected function uploadContent(texture : TextureBase) : void
		{
			if ( _atfData.data.bytesAvailable == 0 )
			{
				atfData = new ATFData(new _textureClass() as ByteArray);
			}
			Texture(texture).uploadCompressedTextureFromByteArray(_atfData.data, 0, false);
		}
		
		override protected function createTexture(context : Context3D) : TextureBase
		{
			return context.createTexture(_width, _height, atfData.format, false);
		}
	}
}


