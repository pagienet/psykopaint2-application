package net.psykosoft.psykopaint2.core.resources
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.errors.ResourceError;

	use namespace texture_management;

	public class FreeTextureManager implements ITextureManager
	{
		private var _maxSize : uint;
		private var _textureCache : Vector.<TextureProxy>;
		private var _bytesAvailable : uint;
		private var _context : Context3D;

		private static var _instance : FreeTextureManager;

		public function FreeTextureManager()
		{
		}

		public static function getInstance() : FreeTextureManager
		{
		    _instance ||= new FreeTextureManager();
			return _instance;
		}

		public function init(maxSize : uint, context : Context3D) : void
		{
			_maxSize = maxSize;
			_bytesAvailable = maxSize;
			trace ("FreeTextureManager: " + (_maxSize - _bytesAvailable)/(1024*1024) + "MB used");
			_context = context;
			_textureCache = new Vector.<TextureProxy>();
		}

		public function initTexture(textureProxy : TextureProxy) : void
		{
			if (_maxSize == 0) throw ResourceError("init must be called before textures are used!");
			assureFreeSpace(textureProxy.size);
			if (textureProxy.width > 2048 || textureProxy.height > 2048)
				throw new Error("some random message");
			var texture : Texture = _context.createTexture(textureProxy.width, textureProxy.height, textureProxy.format, textureProxy.isRenderTarget);
			textureProxy.setTexture(texture);
			_textureCache.push(textureProxy);
			_bytesAvailable -= textureProxy.size;
			trace ("FreeTextureManager: " + (_maxSize - _bytesAvailable)/(1024*1024) + "MB used");
		}

		public function freeTexture(textureProxy : TextureProxy) : void
		{
			var index : int = _textureCache.indexOf(textureProxy);
			if (index >= 0) {
				_textureCache.splice(index, 1);
				disposeTexture(textureProxy);
			}
		}

		public function get maxSize() : uint
		{
			return _maxSize;
		}

		public function get bytesAvailable() : uint
		{
			return _bytesAvailable;
		}

		private function disposeTexture(textureProxy : TextureProxy) : void
		{
			_bytesAvailable += textureProxy.size;
			trace ("FreeTextureManager: " + (_maxSize - _bytesAvailable)/(1024*1024) + "MB used");
			textureProxy.texture.dispose();
			textureProxy.setTexture(null);
		}

		private function assureFreeSpace(size : uint) : void
		{
			if (size > _maxSize)
				throw new ResourceError("Texture larger than reserved size!");

			if (_bytesAvailable < size) {
				trace(this, "Ran out of free texture memory, freeing up space");
				_textureCache.sort(sortOnUsage)
			}

			var lastIndex : uint = _textureCache.length-1;
			while (_bytesAvailable < size) {
				if (_textureCache[lastIndex--].persistent)
					throw new ResourceError("Could not free up enough memory!");
				disposeTexture(_textureCache.pop());
			}
		}

		private function sortOnUsage(a : TextureProxy, b : TextureProxy) : int
		{
			var usageA : uint = a.usageMark;
			var usageB : uint = b.usageMark;
			var persistencyA : Boolean = a.persistent;
			var persistencyB : Boolean = b.persistent;

			// first sort on persistency (those not allowed to be disposed should be the last popped)
			return 	persistencyA && !persistencyB? -1 :
					!persistencyA && persistencyB? 1 :
					usageA < usageB? 1 :
					usageA > usageB? -1 :
									 0;
		}
	}
}
