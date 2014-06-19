package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBufferUsage;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedRectTexture;

	import net.psykosoft.psykopaint2.core.drawing.config.FastBufferManager;
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;

	public class AbstractBrushMesh implements IBrushMesh
	{
		// at some point, it would be nice to have these managed somewhere else
		private static var _inProgressVertexBuffer : VertexBuffer3D;	// arrays because they're sparse
		private static var _inProgressIndexBuffer : IndexBuffer3D;
		private static var _colorPrograms : Array = [];
		private static var _normalSpecularPrograms : Array = [];
		private static var _currentNumElementsPerVertex : int = -1;
		private static var _currentTopology : int = -1;

		protected static var _context3d : Context3D;

		private var _vertexBuffer : VertexBuffer3D;
		private var _indexBuffer : IndexBuffer3D;

		protected static var _fastBuffer : FastBuffer;

		protected var _brushTexture : Texture;
		protected var _normalTexture : TextureBase;
		protected var _bakedTexture : TextureProxy;
		protected var _numVertices : int = 0;
		protected var _numIndices : int = 0;

		protected var _minX : Number = Number.POSITIVE_INFINITY;
		protected var _minY : Number = Number.POSITIVE_INFINITY;
		protected var _maxX : Number = Number.NEGATIVE_INFINITY;
		protected var _maxY : Number = Number.NEGATIVE_INFINITY;
		protected var _bounds : Rectangle;
		private var _boundsInvalid : Boolean = true;

		protected var _vIndex : uint;
		private var _lastvIndex : uint;
		private var _lastNumVertices : int = 0;
		private var _buffersInvalid : Boolean = true;
		private var _isFinal : Boolean;
		private var _programKey : String;
		protected var _pixelUVOffset:Number = 0;
		// only in eraser mode (if supported by brush)
		protected var _normalSpecularOriginal : TrackedRectTexture;

		public function AbstractBrushMesh()
		{
			_bounds = new Rectangle();
			_programKey = getQualifiedClassName(this);
			_fastBuffer = FastBufferManager.getFastBuffer(topologyIndexType, createIndices);
		}

		public function init(context3d : Context3D) : void
		{
			_currentNumElementsPerVertex = numElementsPerVertex;
			_currentTopology = topologyIndexType;
			initInProgressVertexBuffer(context3d);
			initInProgressIndexBuffer(context3d);

			assembleShaderPrograms(context3d);
		}



		public function finalize() : Boolean
		{
			//@Mario: I had a case in the Wet Paint brush were _numIndices was 0 and _numVertices was 2 - this should be looked at
			//for now I added a sanity check

			// create a smaller unique vbuffer
			_isFinal = true;
			if (_context3d && _numVertices > 0 && _numIndices > 0 ) {
				_vertexBuffer = _context3d.createVertexBuffer(_numVertices, 10);
				_fastBuffer.uploadVerticesToBuffer(_vertexBuffer, 0, 0, _numVertices);
				_indexBuffer = _context3d.createIndexBuffer(_numIndices);
				_fastBuffer.uploadIndicesToBuffer(_indexBuffer, _numIndices);
				return true;
			}
			return false;
		}

		public function get numTriangles() : int
		{
			return _numIndices / 3;
		}

		public function set pixelUVOffset( value:Number ) : void
		{
			_pixelUVOffset = value;
		}

		public function getBounds() : Rectangle
		{
			if (_boundsInvalid)
				updateBounds();

			return _bounds;
		}

		public function append( appendVO:StrokeAppendVO) : void
		{
		}

		public function get bakedTexture() : TextureProxy
		{
			return _bakedTexture;
		}

		public function set bakedTexture(value : TextureProxy) : void
		{
			_bakedTexture = value;
		}

		public function get brushTexture() : Texture
		{
			return _brushTexture;
		}

		public function set brushTexture(value : Texture) : void
		{
			_brushTexture = value;
		}

		public function get normalTexture() : TextureBase
		{
			return _normalTexture;
		}

		public function set normalTexture(value : TextureBase) : void
		{
			_normalTexture = value;
		}

		public function clear() : void
		{
			_numVertices = 0;
			_numIndices = 0;
			_vIndex = 0;
			_lastvIndex = 0;
			_lastNumVertices = 0;
			_minX = Number.POSITIVE_INFINITY;
			_minY = Number.POSITIVE_INFINITY;
			_maxX = Number.NEGATIVE_INFINITY;
			_maxY = Number.NEGATIVE_INFINITY;
			_boundsInvalid = true;
			_bounds.setEmpty();
		}

		public function dispose() : void
		{
			if (_bakedTexture) _bakedTexture.dispose();
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			_fastBuffer = null;
			_bakedTexture = null;
			_vertexBuffer = null;
			_indexBuffer = null;
			trace("test");
		}

		public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
		}

		public function customBlending() : Boolean
		{
			return false;
		}

		private function assembleShaderPrograms(context3d : Context3D) : void
		{
			if (!_normalSpecularPrograms[_programKey])
				updateNormalSpecularProgram(context3d);

			if (!_colorPrograms[_programKey])
				updateColorProgram(context3d);
		}

		protected function invalidateBounds() : void
		{
			_boundsInvalid = true;
		}

		protected function invalidateBuffers() : void
		{
			_buffersInvalid = true;
		}

		protected function get numElementsPerVertex() : int
		{
			throw new AbstractMethodError();
			return 0;
		}

		protected function get topologyIndexType() : int
		{
			throw new AbstractMethodError();
			return -1;
		}

		// if topologyIndexType == FastBuffer.INDEX_MODE_CUSTOM, overwrite this to provide index method
		// this method operates on fast memory using intrinsics
		protected function createIndices(offset : int):void
		{
			return;
		}


		protected function updateBuffers(context3d : Context3D) : void
		{
			if (_currentNumElementsPerVertex != numElementsPerVertex) {
				_currentNumElementsPerVertex = numElementsPerVertex;
				initInProgressVertexBuffer(context3d);
			}

			if (_currentTopology != topologyIndexType) {
				_currentTopology = topologyIndexType;
				initInProgressIndexBuffer(context3d);
			}

			//CHECK: There are cases where this lines gives "bad input size"
			_fastBuffer.uploadVerticesToBuffer(_inProgressVertexBuffer, _lastvIndex, _lastNumVertices, _numVertices - _lastNumVertices);

			_context3d = context3d;
			_lastvIndex = _vIndex;
			_lastNumVertices = _numVertices;
			_buffersInvalid = false;
		}

		private function initInProgressVertexBuffer(context3d : Context3D) : void
		{
			if (_inProgressVertexBuffer) _inProgressVertexBuffer.dispose();
			// if you ever get an error here it means that the reserved memory by the fast buffer is not big enough.
			// currently the maximum amount of elements per vertex assumed is 16.
			_inProgressVertexBuffer = context3d.createVertexBuffer(65535, numElementsPerVertex, Context3DBufferUsage.DYNAMIC_DRAW);
			// initialize with garbage
			_fastBuffer.uploadVerticesToBuffer(_inProgressVertexBuffer, 0, 0, 65535);
		}

		protected function initInProgressIndexBuffer(context3d : Context3D) : void
		{
			if (_inProgressIndexBuffer) _inProgressIndexBuffer.dispose();
			_inProgressIndexBuffer = context3d.createIndexBuffer(524286);
			_fastBuffer.uploadIndicesToBuffer(_inProgressIndexBuffer);
		}

		protected function getColorVertexCode() : String
		{
			throw new AbstractMethodError();
			return null;
		}

		protected function getColorFragmentCode() : String
		{
			throw new AbstractMethodError();
			return null;
		}

		protected function getNormalSpecularVertexCode() : String
		{
			return null;
		}

		protected function getNormalSpecularFragmentCode() : String
		{
			return null;
		}

		protected function updateColorProgram(context3d : Context3D) : void
		{
			var key : String = getQualifiedClassName(this);
			if (!_colorPrograms[key]) {
				var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, getColorVertexCode());
				var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, getColorFragmentCode());

				_colorPrograms[key] = context3d.createProgram();
				_colorPrograms[key].upload(vertexByteCode, fragmentByteCode);
			}
		}

		protected function updateNormalSpecularProgram(context3d : Context3D) : void
		{
			var key : String = getQualifiedClassName(this);
			if (!_normalSpecularPrograms[key]) {
				var vertexCode : String = getNormalSpecularVertexCode();
				var fragmentCode : String = getNormalSpecularFragmentCode();

				if (!vertexCode || !fragmentCode)
					return;

				var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
				var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);

				_normalSpecularPrograms[key] = context3d.createProgram();
				_normalSpecularPrograms[key].upload(vertexByteCode, fragmentByteCode);
			}
		}

		protected function getVertexBuffer(context3d : Context3D) : VertexBuffer3D
		{
			if (!_isFinal && !_inProgressVertexBuffer)
				initInProgressVertexBuffer(context3d);

			if (_buffersInvalid)
				updateBuffers(context3d);

			return _isFinal ? _vertexBuffer : _inProgressVertexBuffer;
		}

		protected function getIndexBuffer(context3d : Context3D) : IndexBuffer3D
		{
			if (!_isFinal && !_inProgressIndexBuffer)
				initInProgressIndexBuffer(context3d);

			if (_buffersInvalid)
				updateBuffers(context3d);

			return _isFinal ? _indexBuffer : _inProgressIndexBuffer;
		}

		protected function getColorProgram(context3d : Context3D) : Program3D
		{
			if (!_colorPrograms[_programKey])
				updateColorProgram(context3d);

			return _colorPrograms[_programKey];
		}

		protected function getNormalSpecularProgram(context3d : Context3D) : Program3D
		{
			if (!_normalSpecularPrograms[_programKey])
				updateNormalSpecularProgram(context3d);

			return _normalSpecularPrograms[_programKey];
		}

		private function updateBounds() : void
		{
			if (_minX < -1) _minX = -1;
			else if (_minX > 1) _minX = 1;
			if (_maxX < -1) _maxX = -1;
			else if (_maxX > 1) _maxX = 1;

			if (_minY < -1) _minY = -1;
			else if (_minY > 1) _minY = 1;
			if (_maxY < -1) _maxY = -1;
			else if (_maxY > 1) _maxY = 1;

			_bounds.x = _minX * .5 + .5;
			_bounds.y = -_maxY * .5 + .5;
			_bounds.width = (_maxX - _minX) * .5;
			_bounds.height = (_maxY - _minY) * .5;

			_boundsInvalid = false;
		}

		public static function freeExpendableStaticMemory() : void
		{
			if (_inProgressVertexBuffer)
				_inProgressVertexBuffer.dispose();

			if (_inProgressIndexBuffer)
				_inProgressIndexBuffer.dispose();

			for each(var program : Program3D in _colorPrograms)
				program.dispose();

			_inProgressVertexBuffer = null;
			_inProgressIndexBuffer = null;
			_colorPrograms = [];
		}

		// default height mapping expects default vertex layout: pos=0, brush uv=1, rotation vectors = 2
		public function drawNormalsAndSpecular(context3d : Context3D, canvas : CanvasModel, glossiness : Number, bumpiness : Number, influence : Number ) : void
		{

		}

		public function set normalSpecularOriginal(normalSpecularOriginal : TrackedRectTexture) : void
		{
			_normalSpecularOriginal = normalSpecularOriginal;
		}
	}
}
//