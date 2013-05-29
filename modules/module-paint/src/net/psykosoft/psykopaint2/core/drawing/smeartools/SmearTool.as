package net.psykosoft.psykopaint2.core.drawing.smeartools
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.model.Pin;
	import net.psykosoft.psykopaint2.core.model.RubberMeshModel;

	// TODO: commented by li, we don't use starling anymore
	/*import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;*/

	public class SmearTool extends EventDispatcher
	{
		protected var _rubberMeshModel : RubberMeshModel;
		// TODO: commented by li, we don't use starling anymore
//		protected var _view : DisplayObject;
		
		//protected var _pathManager : PathManager;

		private var _vertexBuffer : VertexBuffer3D;
		private var _indexBuffer : IndexBuffer3D;
		private var _vertexData : Vector.<Number>;
		private var _buffersInvalid : Boolean = true;
		
		private static var _indexData : Vector.<uint>;
		private static var _program : Program3D;
		private static var _context3d : Context3D;
		
		
		private var _location:Point;
		private var _previousLocation:Point
		
		public function SmearTool()
		{
			/*
			_pathManager = new PathManager();
			_pathManager.radius = 1;
			_pathManager.minSamplesPerStep = 3;
			_pathManager.simplificationTime = 15;
			_pathManager.addCallbacks(this, onPathPoints);
			*/
			_vertexData = new <Number>[];
			_location = new Point();
			_previousLocation = new Point();
		}

		// TODO: commented by li, we don't use starling anymore
		/*public function activate(view:DisplayObject, rubberMeshModel:RubberMeshModel) : void
		{
			_view = view;
			_rubberMeshModel = rubberMeshModel;
			//_pathManager.activate(view);
			_view.addEventListener(TouchEvent.TOUCH, onTouch);
			
			//_view.addEventListener(  starling.events.Event.ENTER_FRAME, updateSimulation );
		}*/

		// TODO: commented by li, we don't use starling anymore
		/*private function updateSimulation( event:starling.events.Event ):void
		{
		//	_rubberMeshModel.updateMesh();
			//dispatchEvent(new flash.events.Event(flash.events.Event.RENDER));
		}*/
		
		
		public function draw(context3d : Context3D, ratio : Number = 1) : void
		{
			//_rubberMeshModel.updateVertexData( _vertexData );
			
			if (!_program)
				updateProgram(context3d);
			
			context3d.setProgram(_program);
			
			context3d.setTextureAt(0,  _rubberMeshModel.sourceTexture);
			
			drawMesh(context3d, ratio);
			
			context3d.setTextureAt(0, null);
			
		}
		
		private function drawMesh(context3d : Context3D, ratio : Number = 1) : void
		{
			if (_context3d != context3d) 
			{
				if (_program) _program.dispose();
				_program = null;
			}
			
			updateBuffers(context3d);
			
			context3d.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
			context3d.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
			context3d.drawTriangles(_indexBuffer );
			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			
		}
		
		private function updateBuffers(context3d : Context3D) : void
		{
			if (!_vertexBuffer) {
				_vertexBuffer = context3d.createVertexBuffer( _rubberMeshModel.numVertices, 4);
				_rubberMeshModel.initVertexData( _vertexData );
				
			}
			
			_vertexBuffer.uploadFromVector(_vertexData, 0, _rubberMeshModel.numVertices);
			
			if (!_indexBuffer)
				initIndexBuffer(context3d);
			
			_context3d = context3d;
		}
		
		private function initIndexBuffer(context3d : Context3D) : void
		{
			if (!_indexData) 
			{
				_indexData = _rubberMeshModel.indexData;
			}
			
			_indexBuffer = context3d.createIndexBuffer(_rubberMeshModel.numIndices);
			_indexBuffer.uploadFromVector(_indexData, 0, _rubberMeshModel.numIndices);
		}
		
		private function updateProgram(context3d : Context3D) : void
		{
			if (_program) _program.dispose();
			
			var vertexCode : String =
				"mov op, va0\n" +
				"mov v0, va1\n";
			
			
			var fragmentCode : String =
				"tex oc, v0, fs0 <2d,clamp,linear>\n";
				
				
			
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			
			_program = context3d.createProgram();
			_program.upload(vertexByteCode, fragmentByteCode);
		}
		
		public function deactivate() : void
		{
			//_pathManager.deactivate();

			// TODO: commented by li, we don't use starling anymore
//			_view.removeEventListener(TouchEvent.TOUCH, onTouch);
			
			//_view.removeEventListener(  starling.events.Event.ENTER_FRAME, updateSimulation );
			dispose();
		}
		
		public function dispose() : void
		{
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			_vertexBuffer = null;
			_indexBuffer = null;
		}

		// TODO: commented by li, we don't use starling anymore
		/*private function onTouch(event:TouchEvent):void
		{
			var touches:Vector.<Touch> = event.getTouches(_view, TouchPhase.MOVED);
			
			if (touches.length == 1)
			{
				_location = touches[0].getLocation(_view.parent, _location);
				_previousLocation = touches[0].getPreviousLocation(_view.parent, _previousLocation);
				
				addTouchChange(  (_location.x / _rubberMeshModel.textureWidth) * 2 - 1,
								-((_location.y / _rubberMeshModel.textureHeight) * 2 -1),
								(_location.x -_previousLocation.x) / _rubberMeshModel.textureWidth ,
								-(_location.y -_previousLocation.y) / _rubberMeshModel.textureHeight ,
								0.1,0,0,false);
				
				
				
			}            
			else if (touches.length == 2)
			{
				
				// two fingers touching -> rotate and scale
				var touchA:Touch = touches[0];
				var touchB:Touch = touches[1];
				
				var currentPosA:Point  = touchA.getLocation(_view.parent);
				var previousPosA:Point = touchA.getPreviousLocation(_view.parent);
				var currentPosB:Point  = touchB.getLocation(_view.parent);
				var previousPosB:Point = touchB.getPreviousLocation(_view.parent);
				
				var currentVector:Point  = currentPosA.subtract(currentPosB);
				var previousVector:Point = previousPosA.subtract(previousPosB);
				
				var currentAngle:Number  = Math.atan2(currentVector.y, currentVector.x);
				var previousAngle:Number = Math.atan2(previousVector.y, previousVector.x);
				var deltaAngle:Number = currentAngle - previousAngle;
				
				// update pivot point based on previous center
				var previousLocalA:Point  = touchA.getPreviousLocation(_view);
				var previousLocalB:Point  = touchB.getPreviousLocation(_view);
				_previousLocation.x = (previousLocalA.x + previousLocalB.x) * 0.5;
				_previousLocation.y = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				// update location based on the current center
				_location.x = (currentPosA.x + currentPosB.x) * 0.5;
				_location.y = (currentPosA.y + currentPosB.y) * 0.5;
				
				var radius:Number = currentPosA.subtract(currentPosB).length;
				// scale
				var sizeDiff:Number = currentVector.length - previousVector.length;
				//if ( Math.abs(deltaAngle) < 0.02 && Math.abs(sizeDiff) < 4 )
				//{
					addTouchChange(  (_location.x / _rubberMeshModel.textureWidth) * 2 - 1,
						-((_location.y / _rubberMeshModel.textureHeight) * 2 -1),
						(_location.x -_previousLocation.x) / _rubberMeshModel.textureWidth ,
						-(_location.y -_previousLocation.y) / _rubberMeshModel.textureHeight ,
						radius / _rubberMeshModel.textureWidth,sizeDiff / _rubberMeshModel.textureWidth,deltaAngle);
				
			//} else {
					*//*
					addTouchChange(  (_location.x / _rubberMeshModel.textureWidth) * 2 - 1,
						-((_location.y / _rubberMeshModel.textureHeight) * 2 -1),
						0 ,
						0 ,
						radius / _rubberMeshModel.textureWidth,sizeDiff / _rubberMeshModel.textureWidth,deltaAngle);
				}
					*//*
			}
			*//*
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if (touch && touch.tapCount == 2)
			{
			dispatchEvent( new Event(Event.TRIGGERED));
			}
			*//*
			// enable this code to see when you're hovering over the object
			// touch = event.getTouch(this, TouchPhase.HOVER);            
			// alpha = touch ? 0.8 : 1.0;
			_rubberMeshModel.updateMesh();
			dispatchEvent(new flash.events.Event(flash.events.Event.RENDER));
		}*/
		

		/*
		protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var canvasScaleW : Number = 2.0 / _rubberMeshModel.textureWidth;
			var canvasScaleH : Number = 2.0 / _rubberMeshModel.textureHeight;
			var baseBrushSize : Number = 100 * canvasScaleW; //_brushShape.actualSize * canvasScaleW;
			
			for (var i : int = 0; i < points.length; i++) 
			{
				points[i].x = points[i].x * canvasScaleW - 1.0;
				points[i].y = -(points[i].y * canvasScaleH - 1.0);
				addStrokePoint(points[i], baseBrushSize);
			}
			
			_rubberMeshModel.updateMesh();
			dispatchEvent(new flash.events.Event(flash.events.Event.RENDER));
		}
*/
	 	protected function addTouchChange( centerx:Number, centery:Number, deltax:Number, deltay:Number, radius:Number, scaleDelta:Number, rotation:Number, circular:Boolean = true ) : void
		{
			
			var mind:Number=radius*radius;
			var a:Number,dx:Number,dy:Number,d:Number;
			var x2:Number= centerx + deltax;
			var y2:Number= centery + deltay;
			radius = Math.max( Math.sqrt(deltax*deltax+deltay*deltay), radius);
			//var meshPoints:Vector.<Pin> = _rubberMeshModel.getPinsInRect( new Rectangle( centerx - radius, centery - radius, 2* radius, 2* radius ));
			var meshPoints:Vector.<Pin>;
			var meshCount:int;
			if ( circular )
			{
				meshPoints = _rubberMeshModel.getPinsInCircle( centerx, centery,radius);
				meshCount = meshPoints.length;
				
				for (var i:int=meshCount;--i>-1;)
				{
					var pin:Pin = meshPoints[i];
					if (!pin.fix )
					{
						dx = pin.x-centerx;
						dy = pin.y-centery;
						d=dx*dx+dy*dy;
						if (d<=mind)
						{	
							var falloff:Number = d / mind;
							
							d = Math.sqrt(d);
							dx /= d;
							dy /= d;
							//falloff*=falloff;
							falloff = 1- falloff;
							pin.tx += (deltax + dx * scaleDelta + dy * rotation * d) * falloff;
							pin.ty += (deltay + dy * scaleDelta - dx * rotation * d) * falloff;
							Pin.addActivePin(pin);
							
						}
					}
				}
			} else {
				meshPoints = _rubberMeshModel.getPinsAroundLine( centerx, centery, x2, y2, radius);
				meshCount = meshPoints.length;
				
				var l:Number = Math.sqrt(deltax * deltax + deltay * deltay);
				
				for ( i=meshCount;--i>-1;)
				{
					pin = meshPoints[i];
					if (!pin.fix )
					{
						d = 2 * Math.abs( 0.5 * ( centerx * y2 + x2 * pin.y + pin.x * centery - x2 * centery - pin.x * y2 - centerx * pin.y )) / l
						if (d<=radius)
						{
							falloff = d / radius;
							//falloff*=falloff;
							falloff = 1- falloff;
							pin.tx +=  deltax * falloff;
							pin.ty += deltay * falloff;
							Pin.addActivePin(pin);
							
						}
					}
				}
			}
			
		}

	}
}
