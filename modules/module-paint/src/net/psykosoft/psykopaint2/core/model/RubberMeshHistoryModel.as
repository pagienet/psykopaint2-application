package net.psykosoft.psykopaint2.core.model
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	
	import net.psykosoft.psykopaint2.core.drawing.actions.IRubberMeshAction;
	import net.psykosoft.psykopaint2.core.errors.ResourceError;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;
	import net.psykosoft.psykopaint2.core.resources.texture_management;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestRenderRubberMeshSignal;

	use namespace texture_management;

	public class RubberMeshHistoryModel implements ITextureManager
	{
		public static var MAX_TEXTURE_MEMORY_USAGE : uint = 192*1024*1024;
		public static var MAX_HISTORY_LENGTH : uint = 20;

		[Inject]
		public var requestRenderRubberMeshSignal : RequestRenderRubberMeshSignal;

		[Inject]
		public var notifyHistoryStackChanged : NotifyHistoryStackChangedSignal;

		[Inject]
		public var stage3d : Stage3D;

		private var _actions : Vector.<IRubberMeshAction>;
		private var _currentHistoryIndex : uint;

		private var _bytesAvailable : uint;

		private var _context : Context3D;

		public function RubberMeshHistoryModel()
		{
			_actions = new Vector.<IRubberMeshAction>();
		}

		[PostConstruct]
		public function init() : void
		{
			_bytesAvailable = MAX_TEXTURE_MEMORY_USAGE;
			_context = stage3d.context3D;
		}

		public function addAction(stroke : IRubberMeshAction) : void
		{
			cleanUpFuture();

			if (MAX_HISTORY_LENGTH != -1 && _currentHistoryIndex == MAX_HISTORY_LENGTH-1)
				cleanUpOldest();

			_actions[_currentHistoryIndex++] = stroke;

			requestRenderRubberMeshSignal.dispatch();
			notifyStackChange();
		}

		private function cleanUpOldest() : void
		{
			var action : IRubberMeshAction = _actions.shift();
			--_currentHistoryIndex;
			// do not dispose action here!
		}

		public function get history() : Vector.<IRubberMeshAction>
		{
			return _actions.slice(0, _currentHistoryIndex);
		}

		public function get future() : Vector.<IRubberMeshAction>
		{
			return _actions.slice(_currentHistoryIndex);
		}

		private function cleanUpFuture() : void
		{
			var len : uint = _actions.length;

			for (var i : int = _currentHistoryIndex; i < len; ++i)
				_actions[i].dispose();

			_actions.length = _currentHistoryIndex;
		}

		public function undo() : void
		{
			if (_currentHistoryIndex > 0)
				--_currentHistoryIndex;

			requestRenderRubberMeshSignal.dispatch();
			notifyStackChange();
		}

		public function redo() : void
		{
			if (_currentHistoryIndex < _actions.length)
				++_currentHistoryIndex;

			requestRenderRubberMeshSignal.dispatch();
			notifyStackChange();
		}

		private function notifyStackChange() : void
		{
			notifyHistoryStackChanged.dispatch(_currentHistoryIndex, _actions.length - _currentHistoryIndex);
		}

		public function initTexture(textureProxy : TextureProxy) : void
		{
			assureFreeSpace(textureProxy.size);
			var texture : Texture = _context.createTexture(textureProxy.width, textureProxy.height, textureProxy.format, textureProxy.isRenderTarget);
			textureProxy.setTexture(texture);
			_bytesAvailable -= textureProxy.size;
		}

		private function assureFreeSpace(size : uint) : void
		{
			if (size > MAX_TEXTURE_MEMORY_USAGE)
				throw ResourceError("Stroke data larger than reserved space!");

			while (_bytesAvailable < size)
				cleanUpOldest();
		}

		public function freeTexture(textureProxy : TextureProxy) : void
		{
			_bytesAvailable += textureProxy.size;
			textureProxy.texture.dispose();
			textureProxy.setTexture(null);
		}
	}
}
