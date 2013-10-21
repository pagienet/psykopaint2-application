package net.psykosoft.psykopaint2.home.views.home
{
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.hacks.NativeTexture;
	import away3d.lights.LightBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.materials.PaintingDiffuseMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingNormalMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingSpecularMethod;

	import org.osflash.signals.Signal;

	public class EaselView extends Sprite
	{
		public static const CANVAS_DEFAULT_POSITION : Vector3D = new Vector3D(271, -35, 73);
		private static const CANVAS_WIDTH : Number = 160;

		public var easelRectChanged : Signal = new Signal();
		public var easelTappedSignal : Signal = new Signal();

		private var _canvas : Mesh;
		private var _material : TextureMaterial;
		private var _diffuseTexture : NativeTexture;
		private var _normalSpecularTexture : NativeTexture;
		private var _context3D : Context3D;
		private var _textureWidth : int;
		private var _textureHeight : int;
		private var _lightPicker : LightPickerBase;
		private var _view : View3D;
		private var _pendingPaintingInfoVO : PaintingInfoVO;
		private var _pendingOnUploadComplete : Function;
		private var _paintingID : String;

		public function EaselView(view : View3D, light : LightBase, stage3dProxy : Stage3DProxy)
		{
			_view = view;
			_context3D = stage3dProxy.context3D;
			_lightPicker = new StaticLightPicker([light]);
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraTransformChanged);
			initMaterial();
			initCanvas();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event : MouseEvent) : void
		{
			if (easelRect.contains(event.stageX, event.stageY))
				easelTappedSignal.dispatch();
		}

		private function onCameraTransformChanged(event : Object3DEvent) : void
		{
			easelRectChanged.dispatch();
		}

		private function initCanvas() : void
		{
			var aspectRatio : Number = CoreSettings.STAGE_HEIGHT/CoreSettings.STAGE_WIDTH;
			// TODO: Figure out the proper size
			var geom : Geometry = new PlaneGeometry(CANVAS_WIDTH, CANVAS_WIDTH*aspectRatio, 1, 1, false);
			geom.scaleUV(1, aspectRatio);
			_canvas = new Mesh(geom);
			_canvas.material = _material;
			_canvas.rotationY = 180;
//			_canvas.rotationX = 8.5;
			_canvas.position = CANVAS_DEFAULT_POSITION;
			// start invisible until content is added
			_canvas.visible = false;
			_view.scene.addChild(_canvas);
		}

		public function get canvasPosition() : Vector3D
		{
			return _canvas.position;
		}

		private function initMaterial() : void
		{
			_material = new TextureMaterial(null, true, false, false);
			_material.diffuseMethod = new PaintingDiffuseMethod();
			_material.normalMethod = new PaintingNormalMethod();
			_material.specularMethod = new PaintingSpecularMethod();
			_material.lightPicker = _lightPicker;
			_material.ambientColor = 0xffffff;
			_material.ambient = 1;
			_material.specular = 1.5;
			_material.gloss = 200;
		}

		public function get easelRect() : Rectangle
		{
			var aspectRatio : Number = CoreSettings.STAGE_HEIGHT/CoreSettings.STAGE_WIDTH;
			var halfWidth : Number = CANVAS_WIDTH*.5;
			var halfHeight : Number = CANVAS_WIDTH*aspectRatio*.5;
			var vectorTopLeft : Vector3D = _canvas.scenePosition.clone();
			var vectorBottomRight : Vector3D = _canvas.scenePosition.clone();
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
			if (paintingVO && paintingVO.id == _paintingID)
				return;

			if (paintingVO && areTexturesInvalid(paintingVO)) {
				disposeTextures();
				initTextures(paintingVO);
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
				updateCanvas(paintingVO, onUploadComplete);
			}
		}

		private function updateCanvas(paintingVO : PaintingInfoVO, onUploadComplete : Function) : void
		{
			if (paintingVO) {
				_canvas.visible = true;
				updateTextures(paintingVO);
			}
			else
				_canvas.visible = false;

			if (onUploadComplete)
				onUploadComplete(paintingVO);
		}

		private function animateCanvasOut() : void
		{
			if (_canvas.visible)
				TweenLite.to(_canvas,.25, {x: CANVAS_DEFAULT_POSITION.x + 400, ease: Quad.easeIn, onComplete: animateCanvasIn});
			else {
				_canvas.x = -600;
				animateCanvasIn();
			}

		}

		private function animateCanvasIn() : void
		{
			updateCanvas(_pendingPaintingInfoVO, _pendingOnUploadComplete);

			_pendingOnUploadComplete = null;
			_pendingPaintingInfoVO = null;

			if (_canvas.visible) {
				_canvas.x = CANVAS_DEFAULT_POSITION.x - 400;
				TweenLite.to(_canvas, .25, {x: CANVAS_DEFAULT_POSITION.x , ease: Quad.easeOut});
			}
		}

		private function areTexturesInvalid(paintingVO : PaintingInfoVO) : Boolean
		{
			return !_diffuseTexture || _textureWidth != TextureUtil.getNextPowerOfTwo(paintingVO.width) || _textureHeight != TextureUtil.getNextPowerOfTwo(paintingVO.height);
		}

		private function updateTextures(paintingVO : PaintingInfoVO) : void
		{
			if (paintingVO.colorPreviewData)
				uploadByteArray(paintingVO.colorPreviewData, _diffuseTexture.texture);
			else
				_diffuseTexture.texture.uploadFromBitmapData(paintingVO.colorPreviewBitmap);

			uploadByteArray(paintingVO.normalSpecularPreviewData, _normalSpecularTexture.texture);
		}

		private function uploadByteArray(data : ByteArray, target : Texture) : void
		{
			var oldLen : int = data.length;
			data.length = _textureWidth * _textureHeight * 4;
			target.uploadFromByteArray(data, 0);
			data.length = oldLen;
		}

		private function initTextures(paintingVO : PaintingInfoVO) : void
		{
			_textureWidth = TextureUtil.getNextPowerOfTwo(paintingVO.width);
			_textureHeight = TextureUtil.getNextPowerOfTwo(paintingVO.height);

			var diffuse : Texture = _context3D.createTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);
			var normalSpecular : Texture = _context3D.createTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);

			_diffuseTexture = new NativeTexture(diffuse);
			_normalSpecularTexture = new NativeTexture(normalSpecular);
			_material.texture = _diffuseTexture;
			_material.normalMap = _normalSpecularTexture;
			_material.specularMap = _normalSpecularTexture;
		}

		public function dispose() : void
		{
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraTransformChanged);
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
	}
}
