package net.psykosoft.psykopaint2.home.views.home
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.ISubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.events.Stage3DEvent;
	import away3d.hacks.NativeRectTexture;
	import away3d.hacks.PaintingMaterial;
	import away3d.lights.LightBase;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.CopyMeshToBitmapDataUtil;
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;

	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	import org.osflash.signals.Signal;

	public class EaselView extends Sprite
	{
		public static const CAMERA_POSITION:Vector3D = new Vector3D(271, -40, 250);
		public static const CANVAS_DEFAULT_POSITION : Vector3D = new Vector3D(278, -28, -5);
		private static const CANVAS_WIDTH : Number = 158;

		public var easelRectChanged : Signal = new Signal();
		public var easelTappedSignal : Signal = new Signal();

		private var _canvas : Mesh;
		private var _material : PaintingMaterial;
		private var _diffuseTexture : NativeRectTexture;
		private var _normalSpecularTexture : NativeRectTexture;
		private var _context3D : Context3D;
		private var _textureWidth : int;
		private var _textureHeight : int;
		private var _lightPicker : LightPickerBase;
		private var _view : View3D;
		private var _pendingPaintingInfoVO : PaintingInfoVO;
		private var _pendingOnUploadComplete : Function;
		private var _paintingID : String;
		private var _stage : Stage;
		private var _mouseDownX : Number;
		private var _mouseDownY : Number;
		private var _tmpMatrix:Matrix;
		
		private var _texturesInvalid:Boolean;

		private var aspectRatio:Number;
		public var cropModeIsActive:Boolean;

		private var cropTransformAccepted:Boolean;
		private var stage3dProxy:Stage3DProxy;
		
		public function EaselView(view : View3D, light : LightBase, stage3dProxy : Stage3DProxy)
		{
			_view = view;
			this.stage3dProxy = stage3dProxy;
			_context3D = stage3dProxy.context3D;
			stage3dProxy.addEventListener(Stage3DEvent.CONTEXT3D_RECREATED, onContextRecreated );
			
			_lightPicker = new StaticLightPicker([light]);
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraTransformChanged);
			initMaterial();
			initCanvas();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onContextRecreated(event:Stage3DEvent):void
		{
			_context3D = stage3dProxy.context3D;
		}
		
		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			_mouseDownX = event.stageX;
			_mouseDownY = event.stageY;
			
			if (_canvas.visible && easelRect.contains(_mouseDownX, event.stageY)) {
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			if ( cropModeIsActive  )
			{
				var r:Rectangle = easelRect;
				
				
				var x1:Number = _mouseDownX - r.x;
				var y1:Number = _mouseDownY - r.y;
				var x2:Number =  event.stageX  - r.x;
				var y2:Number =  event.stageY  - r.y;
				
				var f:Number = 1 / (r.width*r.height);
				var f1:Number = (r.width - x1)*(r.height-y1) - (r.width - x2)*(r.height-y2);
				var f2:Number =  x1*(r.height-y1) - x2*(r.height-y2);
				var f3:Number = (r.width - x1)*y1 - (r.width - x2)*y2;
				var f4:Number = x1*y1 - x2*y2;
				
				var sg:ISubGeometry = _canvas.geometry.subGeometries[0];
				var uvData:Vector.<Number> = sg.UVData;
				var uvOffset:int = sg.UVOffset;
				var uvStride:int = sg.UVStride;
				
				//lower left
				var du:Number = f3 * uvData[uvOffset];
				var dv:Number = f3 * uvData[uvOffset+1];
				
				//lower right
				uvOffset += uvStride;
				du += f4 * uvData[uvOffset];
				dv += f4 * uvData[uvOffset+1];
				
				//upper left
				uvOffset += uvStride;
				du += f1 * uvData[uvOffset];
				dv += f1 * uvData[uvOffset+1];
				
				//upper right
				uvOffset += uvStride;
				du += f2 * uvData[uvOffset];
				dv += f2 * uvData[uvOffset+1];
				
				du *= f;
				dv *= f;
				
				_tmpMatrix.identity();
				_tmpMatrix.translate(du,dv);
				_canvas.geometry.transformUV(_tmpMatrix );
				
				_mouseDownX = event.stageX;
				_mouseDownY = event.stageY;
			} else if (Math.abs(event.stageX - _mouseDownX) > 20) {
				// cancel with swiping
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			if (!cropModeIsActive && mouseEnabled && easelRect.contains(event.stageX, event.stageY))
				easelTappedSignal.dispatch();
		}

		private function onCameraTransformChanged(event : Object3DEvent) : void
		{
			easelRectChanged.dispatch();
		}

		private function initCanvas() : void
		{
			if ( _canvas )
			{
				_view.scene.removeChild(_canvas);
				_canvas.dispose();
			}
			aspectRatio = CoreSettings.STAGE_HEIGHT/CoreSettings.STAGE_WIDTH;
			var geom : Geometry = new PlaneGeometry(CANVAS_WIDTH, CANVAS_WIDTH*aspectRatio, 1, 1, false);
			_canvas = new Mesh(geom);
			_canvas.material = _material;
			_canvas.rotationY = 180;
//			_canvas.rotationX = 8.5;
			_canvas.position = CANVAS_DEFAULT_POSITION;
			// start invisible until content is added
			_canvas.visible = false;
			_canvas.mouseEnabled = false;
			_view.scene.addChild(_canvas);
		}

		public function get canvasPosition() : Vector3D
		{
			return _canvas.position;
		}

		private function initMaterial() : void
		{
			_material = new PaintingMaterial();
			_material.lightPicker = _lightPicker;
			_material.ambientColor = 0xffffff;
			_material.specular = 1.5;
			_material.gloss = 200;
		}

		public function get easelRect() : Rectangle
		{
			var aspectRatio : Number = CoreSettings.STAGE_HEIGHT/CoreSettings.STAGE_WIDTH;
			var halfWidth : Number = CANVAS_WIDTH*.5;
			var halfHeight : Number = CANVAS_WIDTH*aspectRatio*.5;
			var vectorTopLeft : Vector3D = CANVAS_DEFAULT_POSITION.clone();
			var vectorBottomRight : Vector3D = CANVAS_DEFAULT_POSITION.clone();
			vectorTopLeft.x += halfWidth;
			vectorTopLeft.y += halfHeight;
			vectorBottomRight.x -= halfWidth;
			vectorBottomRight.y -= halfHeight;
			var projTopLeft : Vector3D = _view.project(vectorTopLeft);
			var projBottomRight : Vector3D = _view.project(vectorBottomRight);

			return new Rectangle(projTopLeft.x, projTopLeft.y, projBottomRight.x - projTopLeft.x, projBottomRight.y - projTopLeft.y);
		}

		public function setContent(paintingVO : PaintingInfoVO, animateIn : Boolean = false, onUploadComplete : Function = null) : void
		{
			if (cropModeIsActive) {
				// uv coords need to be reset
				_canvas.geometry.dispose();
				_canvas.geometry = new PlaneGeometry(CANVAS_WIDTH, CANVAS_WIDTH*aspectRatio, 1, 1, false);
			}

			cropModeIsActive = false;
			
			if (paintingVO && paintingVO.id == _paintingID && paintingVO.id != PaintingInfoVO.DEFAULT_VO_ID)
				return;

			//GestureManager.gesturesEnabled = false;
			//GrabThrowController.gesturesEnabled = false;
			if (paintingVO && areTexturesInvalid(paintingVO)) {
				_texturesInvalid = true;
			}

			_paintingID = paintingVO? paintingVO.id : null;

			// previous PaintingVO not necessary anymore at all, so notify callback
			if (_pendingOnUploadComplete)
				_pendingOnUploadComplete(_pendingPaintingInfoVO);

			TweenLite.killTweensOf(_canvas);

			if (animateIn) {
				_pendingPaintingInfoVO = paintingVO;
				_pendingOnUploadComplete = onUploadComplete;
				animateCanvasOut();
			}
			else {
				_pendingOnUploadComplete = null;
				_pendingPaintingInfoVO = null;
				updateCanvas(paintingVO, onUploadComplete, true);
			}
		}

		private function updateCanvas(paintingVO : PaintingInfoVO, onUploadComplete : Function, reenableGestures:Boolean = false) : void
		{
			if (_texturesInvalid) {
				disposeTextures();
				initTextures(paintingVO);
				_texturesInvalid = false;
			}

			if (paintingVO) {
				_canvas.visible = true;
				updateTextures(paintingVO);
			}
			else
				_canvas.visible = false;

			if (onUploadComplete)
				onUploadComplete(paintingVO);
			
			/*if ( reenableGestures )
			{
				GestureManager.gesturesEnabled = true;
				GrabThrowController.gesturesEnabled = true;
			}*/
				
		}
		
		

		private function animateCanvasOut() : void
		{
			trace(this,animateCanvasOut);
			if (_canvas.visible)
				TweenLite.to(_canvas,.50, {x: CANVAS_DEFAULT_POSITION.x + 400, ease: Expo.easeOut, onUpdate:function(){
					GestureManager.gesturesEnabled=false;
				},onComplete: animateCanvasIn});
			else {
				_canvas.x = -600;
				animateCanvasIn();
			}

		}

		private function animateCanvasIn() : void
		{
			trace(this,animateCanvasIn);
			updateCanvas(_pendingPaintingInfoVO, _pendingOnUploadComplete);

			_pendingOnUploadComplete = null;
			_pendingPaintingInfoVO = null;

			if (_canvas.visible) {
				_canvas.x = CANVAS_DEFAULT_POSITION.x + 400;

				//TweenLite.to(_canvas, .50, {x: CANVAS_DEFAULT_POSITION.x , ease: Expo.easeOut, onComplete: function():void{GestureManager.gesturesEnabled = true;GrabThrowController.gesturesEnabled = true;}});
				TweenLite.to(_canvas, .50, {x: CANVAS_DEFAULT_POSITION.x , ease: Expo.easeOut});
				
			}
		}

		private function areTexturesInvalid(paintingVO : PaintingInfoVO) : Boolean
		{
			return !_diffuseTexture || _textureWidth != paintingVO.width || _textureHeight != paintingVO.height;
		}

		private function updateTextures(paintingVO : PaintingInfoVO) : void
		{
			if (paintingVO.colorPreviewData)
				uploadByteArray(paintingVO.colorPreviewData, _diffuseTexture.texture);
			else
				_diffuseTexture.texture.uploadFromBitmapData(paintingVO.colorPreviewBitmap);

			uploadByteArray(paintingVO.normalSpecularPreviewData, _normalSpecularTexture.texture);
		}

		private function uploadByteArray(data : ByteArray, target : RectangleTexture) : void
		{
			var oldLen : int = data.length;
			data.length = _textureWidth * _textureHeight * 4;
			target.uploadFromByteArray(data, 0);
			data.length = oldLen;
		}

		private function initTextures(paintingVO : PaintingInfoVO) : void
		{
			_textureWidth = paintingVO.width;
			_textureHeight = paintingVO.height;
			var diffuse : RectangleTexture = _context3D.createRectangleTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);
			var normalSpecular : RectangleTexture = _context3D.createRectangleTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);

			_diffuseTexture = new NativeRectTexture(diffuse);
			_normalSpecularTexture = new NativeRectTexture(normalSpecular);
			_material.albedoTexture = _diffuseTexture;
			_material.normalSpecularTexture = _normalSpecularTexture;
		}

		public function dispose() : void
		{
			stage3dProxy.removeEventListener(Stage3DEvent.CONTEXT3D_RECREATED, onContextRecreated );
			
			_view.camera.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraTransformChanged);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel );
			_view.scene.removeChild(_canvas);
			_canvas.geometry.dispose();
			_canvas.dispose();
			_material.dispose();
			disposeTextures();

			_canvas = null;
			_diffuseTexture = null;
			_normalSpecularTexture = null;
			_material = null;
		}

		public function get paintingID() : String
		{
			return _paintingID;
		}

		private function disposeTextures() : void
		{
			if (_diffuseTexture) _diffuseTexture.dispose();
			if (_normalSpecularTexture) _normalSpecularTexture.dispose();

			_diffuseTexture = null;
			_normalSpecularTexture = null;
		}
		
		public function setCropContent(bitmapData:BitmapData, orientation:int):void
		{
			if ( _context3D.driverInfo == "Disposed" )
			{
				trace("ERROR in EaselView.setCropContent: context has been disposed");
				return;
			}
			initCanvas();
			//pad outer edges with white
			bitmapData.fillRect(new Rectangle(0,0,bitmapData.width,1),0xffffff);
			bitmapData.fillRect(new Rectangle(0,0,1,bitmapData.height),0xffffff);
			bitmapData.fillRect(new Rectangle(0,bitmapData.height-1,bitmapData.width,1),0xffffff);
			bitmapData.fillRect(new Rectangle(bitmapData.width-1,0,1,bitmapData.height),0xffffff);
			
			initTexturesFromBitmapData(bitmapData);
			updateTexturesFromBitmapData(bitmapData);
			
			var sg:ISubGeometry = _canvas.geometry.subGeometries[0];
			var uvData:Vector.<Number> = sg.UVData;
			var uvOffset:int = sg.UVOffset;
			var uvStride:int = sg.UVStride;
			var r:Rectangle = easelRect;
			_tmpMatrix = new Matrix();
			
			//vertically center source image on canvas:
			var scaleX:Number = (bitmapData.width-2) / _textureWidth;
			var scaleY:Number = scaleX * ( _textureWidth / _textureHeight );
			var missing:Number = (bitmapData.height * r.width / bitmapData.width - r.height) * 0.5 ;
			if ( missing >= 0 )
			{
				var offsetV:Number =  missing * uvData[uvOffset+1] * scaleY / r.height;
				
				_tmpMatrix.scale(1.0, aspectRatio);
				_tmpMatrix.scale(scaleX,scaleY);
				_tmpMatrix.translate(0,offsetV);
			} else {
				scaleY = (bitmapData.height-2) / _textureHeight / aspectRatio;
				scaleX = scaleY * ( _textureHeight / _textureWidth );
				missing = (bitmapData.width * r.height / bitmapData.height - r.width) * 0.5 ;
				
				var offsetU:Number =  missing * uvData[uvOffset] * scaleX / r.width;
				
				_tmpMatrix.scale(1.0, aspectRatio);
				_tmpMatrix.scale(scaleX,scaleY);
				_tmpMatrix.translate(offsetU,0);
			}
			_canvas.geometry.transformUV(_tmpMatrix);
			
			
			
		
			
			//orientation = CameraRollImageOrientation.ROTATION_270;
			
			if ( orientation == CameraRollImageOrientation.ROTATION_90 ||
				orientation ==  CameraRollImageOrientation.ROTATION_90_HFLIP ||
				orientation ==  CameraRollImageOrientation.ROTATION_270 ||
				orientation ==  CameraRollImageOrientation.ROTATION_270_HFLIP )
			{
			
				var x:Number =  r.width *0.5;
				var y:Number =  r.height*0.5;
				
				var f:Number = 1 / (r.width*r.height);
				var f1:Number = (r.width - x)*(r.height-y);
				var f2:Number =  x*(r.height-y);
				var f3:Number = (r.width - x)*y ;
				var f4:Number = x*y;
				
				
				//lower left
				var du:Number = f3 * uvData[uvOffset];
				var dv:Number = f3 * uvData[uvOffset+1];
				
				//lower right
				uvOffset += uvStride;
				du += f4 * uvData[uvOffset];
				dv += f4 * uvData[uvOffset+1];
				
				//upper left
				uvOffset += uvStride;
				du += f1 * uvData[uvOffset];
				dv += f1 * uvData[uvOffset+1];
				
				//upper right
				uvOffset += uvStride;
				du += f2 * uvData[uvOffset];
				dv += f2 * uvData[uvOffset+1];
				
				du *= f;
				dv *= f;
				
				var rotation:Number = (orientation == CameraRollImageOrientation.ROTATION_90  || orientation == CameraRollImageOrientation.ROTATION_90_HFLIP ? -Math.PI*0.5 : Math.PI*0.5);
				_tmpMatrix.identity();
				_tmpMatrix.translate(-du,-dv);
				var squeeze:Number = ((bitmapData.height-2) / _textureWidth) / scaleX;
				_tmpMatrix.scale(1 * squeeze,_textureHeight / _textureWidth * squeeze);
				_tmpMatrix.rotate(-rotation);
				_tmpMatrix.scale(1,_textureWidth / _textureHeight);
				_tmpMatrix.translate(du,dv);
				_canvas.geometry.transformUV(_tmpMatrix);
				
			}
			
			
			
			
			_canvas.visible = true;
			
			/*
			
			//fit source image width to canvas width:
			switch ( orientation )
			{
			case CameraRollImageOrientation.ROTATION_0:
			case CameraRollImageOrientation.ROTATION_0_HFLIP:
			case CameraRollImageOrientation.ROTATION_180:
			case CameraRollImageOrientation.ROTATION_180_HFLIP:
			
			break;
			case CameraRollImageOrientation.ROTATION_90:
			case CameraRollImageOrientation.ROTATION_90_HFLIP:
			case CameraRollImageOrientation.ROTATION_270:
			case CameraRollImageOrientation.ROTATION_270_HFLIP:
			scaleX = bitmapData.height / _textureWidth;
			scaleY = scaleX * ( _textureWidth / _textureHeight );
			
			break;
			}
			*/
			
			//cropModeIsActive = true;
			//temporary to test on desktop
			if ( !CoreSettings.RUNNING_ON_iPAD )
			{
				_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel );
			}
			
		}
		
		protected function onMouseWheel(event:MouseEvent):void
		{
			var r:Rectangle = easelRect;
			if ( r.contains(event.stageX, event.stageY) )
			{
				
				var x:Number =  event.stageX  - r.x;
				var y:Number =  event.stageY  - r.y;
				
				var f:Number = 1 / (r.width*r.height);
				var f1:Number = (r.width - x)*(r.height-y);
				var f2:Number =  x*(r.height-y);
				var f3:Number = (r.width - x)*y ;
				var f4:Number = x*y;
				
				var sg:ISubGeometry = _canvas.geometry.subGeometries[0];
				var uvData:Vector.<Number> = sg.UVData;
				var uvOffset:int = sg.UVOffset;
				var uvStride:int = sg.UVStride;
				
				//lower left
				var du:Number = f3 * uvData[uvOffset];
				var dv:Number = f3 * uvData[uvOffset+1];
				
				//lower right
				uvOffset += uvStride;
				du += f4 * uvData[uvOffset];
				dv += f4 * uvData[uvOffset+1];
				
				//upper left
				uvOffset += uvStride;
				du += f1 * uvData[uvOffset];
				dv += f1 * uvData[uvOffset+1];
				
				//upper right
				uvOffset += uvStride;
				du += f2 * uvData[uvOffset];
				dv += f2 * uvData[uvOffset+1];
				
				du *= f;
				dv *= f;
				
				var scale:Number = 1 - event.delta / 50;
				_tmpMatrix.identity();
				_tmpMatrix.translate(-du,-dv);
				_tmpMatrix.scale(scale,scale);
				_tmpMatrix.translate(du,dv);
				_canvas.geometry.transformUV( _tmpMatrix );
			}
		}
		
		private function initTexturesFromBitmapData(bitmapData:BitmapData) : void
		{
			_textureWidth = bitmapData.width;
			_textureHeight = bitmapData.height;
			var diffuse : RectangleTexture = _context3D.createRectangleTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);
			var normalSpecular : RectangleTexture = _context3D.createRectangleTexture(1, 1, Context3DTextureFormat.BGRA, false);
			
			_diffuseTexture = new NativeRectTexture(diffuse);
			_normalSpecularTexture = new NativeRectTexture(normalSpecular);
			_material.albedoTexture = _diffuseTexture;
			_material.normalSpecularTexture = _normalSpecularTexture;
		}
		
		private function updateTexturesFromBitmapData(bitmapData:BitmapData) : void
		{
			_diffuseTexture.texture.uploadFromBitmapData(bitmapData);
			var temp : BitmapData = new TrackedBitmapData(1,1,false,0x808080);
			_normalSpecularTexture.texture.uploadFromBitmapData(temp);
			temp.dispose();
		}
		
		public function onTransformGesture(event:GestureEvent):void
		{
			if ( cropModeIsActive && cropTransformAccepted )
			{
				var gesture:TransformGesture = (event.target as TransformGesture);
				var r:Rectangle = easelRect;
				if ( r.containsPoint(gesture.location ))
				{
					var x:Number =  gesture.location.x - r.x;
					var y:Number =  gesture.location.y  - r.y;
					
					var f:Number = 1 / (r.width*r.height);
					var f1:Number = (r.width - x)*(r.height-y);
					var f2:Number =  x*(r.height-y);
					var f3:Number = (r.width - x)*y ;
					var f4:Number = x*y;
					
					var sg:ISubGeometry = _canvas.geometry.subGeometries[0];
					var uvData:Vector.<Number> = sg.UVData;
					var uvOffset:int = sg.UVOffset;
					var uvStride:int = sg.UVStride;
					
					//lower left
					var du:Number = f3 * uvData[uvOffset];
					var dv:Number = f3 * uvData[uvOffset+1];
					
					//lower right
					uvOffset += uvStride;
					du += f4 * uvData[uvOffset];
					dv += f4 * uvData[uvOffset+1];
					
					//upper left
					uvOffset += uvStride;
					du += f1 * uvData[uvOffset];
					dv += f1 * uvData[uvOffset+1];
					
					//upper right
					uvOffset += uvStride;
					du += f2 * uvData[uvOffset];
					dv += f2 * uvData[uvOffset+1];
					
					du *= f;
					dv *= f;
					
					var scale:Number = 1 / gesture.scale;
					_tmpMatrix.identity();
					_tmpMatrix.translate(-du,-dv);
					_tmpMatrix.scale(scale,scale);
					_tmpMatrix.scale(1,_textureHeight / _textureWidth);
					_tmpMatrix.rotate(-gesture.rotation);
					_tmpMatrix.scale(1,_textureWidth / _textureHeight);
					_tmpMatrix.translate(du,dv);
					
					
					var x2:Number =  x + gesture.offsetX;
					var y2:Number =  y + gesture.offsetY;
					
					f1 = (r.width - x)*(r.height-y) - (r.width - x2)*(r.height-y2);
					f2 =  x*(r.height-y) - x2*(r.height-y2);
					f3 = (r.width - x)*y - (r.width - x2)*y2;
					f4 = x*y - x2*y2;
					
					uvOffset = sg.UVOffset;
				
					//lower left
					du = f3 * uvData[uvOffset];
					dv = f3 * uvData[uvOffset+1];
					
					//lower right
					uvOffset += uvStride;
					du += f4 * uvData[uvOffset];
					dv += f4 * uvData[uvOffset+1];
					
					//upper left
					uvOffset += uvStride;
					du += f1 * uvData[uvOffset];
					dv += f1 * uvData[uvOffset+1];
					
					//upper right
					uvOffset += uvStride;
					du += f2 * uvData[uvOffset];
					dv += f2 * uvData[uvOffset+1];
					
					du *= f;
					dv *= f;
					
					_tmpMatrix.translate(du,dv);
					
					_canvas.geometry.transformUV( _tmpMatrix );
				}
			}
		
			
		}
		
		public function onTransformGestureBegan(event:GestureEvent):void
		{
			if ( cropModeIsActive )
			{
				var gesture:TransformGesture = (event.target as TransformGesture);
				var r:Rectangle = easelRect;
				if ( r.containsPoint(gesture.location ))
				{
					_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					cropTransformAccepted = true;
				} else {
					cropTransformAccepted = false;
				}
			}
		}
		
		public function onTransformGestureEnded(event:GestureEvent):void
		{
			if ( cropModeIsActive )
			{
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		public function getCroppedImage():BitmapData
		{
			var util:CopyMeshToBitmapDataUtil = new CopyMeshToBitmapDataUtil();
			var result:BitmapData = new BitmapData( CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT,false );
			
			result = util.execute( _canvas, _diffuseTexture.texture, result, _context3D );
			return result;
		}
	}
}
