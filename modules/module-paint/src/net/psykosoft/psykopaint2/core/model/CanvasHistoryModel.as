package net.psykosoft.psykopaint2.core.model
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.actions.CanvasSnapShot;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;
	import net.psykosoft.psykopaint2.core.resources.texture_management;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;

	import net.psykosoft.psykopaint2.core.errors.ResourceError;

	use namespace texture_management;

	public class CanvasHistoryModel implements ITextureManager
	{
		public static var MAX_TEXTURE_MEMORY_USAGE : uint = 150*1024*1024;
		public static var MAX_HISTORY_LENGTH : int = 10;

		[Inject]
		public var notifyHistoryStackChanged : NotifyHistoryStackChangedSignal;

		[Inject]
		public var stage3d : Stage3D;

		[Inject]
		public var canvas : CanvasModel;

		private var _snapShots : Vector.<CanvasSnapShot>;
		private var _currentHistoryIndex : uint;

		private var _bytesAvailable : uint;

		private var _context : Context3D;

		public function CanvasHistoryModel()
		{
			_snapShots = new Vector.<CanvasSnapShot>();
		}

		[PostConstruct]
		public function init() : void
		{
			_bytesAvailable = MAX_TEXTURE_MEMORY_USAGE;
			trace ("CanvasHistoryModel.init: " + (MAX_TEXTURE_MEMORY_USAGE - _bytesAvailable)/(1024*1024) + "MB used");
			_context = stage3d.context3D;
		}

		public function addSnapShot(snapshot : CanvasSnapShot) : void
		{
			//PATCH to avoid adding of null strokes when active brush is changed. this probably needs proper fixing:
			if ( snapshot == null ) {
				throw("CanvasHistoryModel.addAction() - adding an empty stroke should not happen here");
				return;
			}
			
			cleanUpFuture();

			if (MAX_HISTORY_LENGTH != -1 && _currentHistoryIndex == MAX_HISTORY_LENGTH-1)
				cleanUpOldest();

			_snapShots[_currentHistoryIndex++] = snapshot;

			notifyStackChange();
		}

		private function cleanUpOldest() : Boolean
		{
			var snapshot : CanvasSnapShot = _snapShots.shift();
			//PATCH Mario: this check is only a temporary fix to avoid errors during the demo.
			// the real cause for this error must still be found:
			if ( snapshot != null )
			{
				--_currentHistoryIndex;
				snapshot.dispose();
			} else { 
				return false;
			}
			return true;
		}

		public function get history() : Vector.<CanvasSnapShot>
		{
			return _snapShots.slice(0, _currentHistoryIndex);
		}

		public function get future() : Vector.<CanvasSnapShot>
		{
			return _snapShots.slice(_currentHistoryIndex);
		}

		private function cleanUpFuture() : void
		{
			var len : uint = _snapShots.length;

			for (var i : int = _currentHistoryIndex; i < len; ++i)
				_snapShots[i].dispose();

			_snapShots.length = _currentHistoryIndex;
		}

		public function undo() : void
		{
			if (_currentHistoryIndex > 0) {
				--_currentHistoryIndex;
				swapSnapShots();
			}

			notifyStackChange();
		}

		public function redo() : void
		{
			if (_currentHistoryIndex < _snapShots.length) {
				swapSnapShots();
				++_currentHistoryIndex;
			}

			notifyStackChange();
		}

		private function swapSnapShots() : void
		{
			var oldSnap : CanvasSnapShot = _snapShots[_currentHistoryIndex];
			var newSnap : CanvasSnapShot = new CanvasSnapShot(_context, canvas, this, oldSnap.heightSpecularTexture != null, oldSnap.canvasBounds);

			_context.setRenderToTexture(canvas.fullSizeBackBuffer);
			_context.clear(0, 0, 0, 0);
			CopyTexture.copy(canvas.colorTexture, _context, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
			oldSnap.drawColor();
			_context.setRenderToBackBuffer();
			canvas.swapColorLayer();


			oldSnap.dispose();
			_snapShots[_currentHistoryIndex] = newSnap;
		}

		private function notifyStackChange() : void
		{
			notifyHistoryStackChanged.dispatch(_currentHistoryIndex, _snapShots.length - _currentHistoryIndex);
		}

		public function initTexture(textureProxy : TextureProxy) : void
		{
			assureFreeSpace(textureProxy.size);
			var texture : Texture = _context.createTexture(textureProxy.width, textureProxy.height, textureProxy.format, textureProxy.isRenderTarget);
			textureProxy.setTexture(texture);
			_bytesAvailable -= textureProxy.size;
			trace ("CanvasHistoryModel.initTexture: " + (MAX_TEXTURE_MEMORY_USAGE - _bytesAvailable)/(1024*1024) + "MB used");
		}

		private function assureFreeSpace(size : uint) : void
		{
			if (size > MAX_TEXTURE_MEMORY_USAGE)
				throw ResourceError("Stroke data larger than reserved space!");

			while (_bytesAvailable < size)
			{
				if (!cleanUpOldest()) break;
			}
		}

		public function freeTexture(textureProxy : TextureProxy) : void
		{
			_bytesAvailable += textureProxy.size;
			trace ("CanvasHistoryModel.freeTexture: " + (MAX_TEXTURE_MEMORY_USAGE - _bytesAvailable)/(1024*1024) + "MB used");
			textureProxy.texture.dispose();
			textureProxy.setTexture(null);
		}
	}
}
