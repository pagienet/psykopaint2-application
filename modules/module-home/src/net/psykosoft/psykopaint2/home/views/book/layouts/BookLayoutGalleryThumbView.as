package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;

	import away3d.containers.ObjectContainer3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.hacks.FlatTextureMaterial;
	import away3d.hacks.TrackedBitmapRectTexture;

	import flash.geom.Matrix;
	import flash.text.AntiAliasType;

	import flash.text.TextField;

	import flash.text.TextFieldAutoSize;

	import flash.text.TextFormat;

	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageThumbnailSize;
	import net.psykosoft.psykopaint2.home.views.book.HomeGeometryCache;
	import net.psykosoft.psykopaint2.home.views.book.HomeMaterialsCache;

	public class BookLayoutGalleryThumbView extends ObjectContainer3D
	{
		public static const EVENT_LOADED:String = "EVENT_LOADED";

		private var _width:Number = 60;
		private var _height:Number = 40;

		private var _imageProxy:GalleryImageProxy;

		//THUMBNAIL
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:FlatTextureMaterial;

		//SHADOW
		private var _shadowMesh:Mesh;

		//LOADING IMAGE
		private var _thumbTexture:TrackedBitmapRectTexture;

		private var _onComplete:Function;

		private var _stage3DProxy:Stage3DProxy;
		private var _infoMesh:Mesh;
		private var _userNameMaterial:FlatTextureMaterial;

		public function BookLayoutGalleryThumbView(stage3DProxy:Stage3DProxy)
		{
			_stage3DProxy = stage3DProxy;

			initThumbnail();
			initShadow();
			initInfo();
		}

		private function initInfo():void
		{
			_userNameMaterial = new FlatTextureMaterial(null);
			_userNameMaterial.blendMode = BlendMode.LAYER;
			_infoMesh = new Mesh(HomeGeometryCache.getGeometryById(HomeGeometryCache.CARD_GEOMETRY), _userNameMaterial);
			_infoMesh.y = 3;
			_infoMesh.z = -25;
			_infoMesh.scaleX = 60;
			addChild(_infoMesh);
		}

		private function updateInfoMaterial():void
		{
			var bitmapData:BitmapData = createInfoBitmapData();
			var texture:TrackedBitmapRectTexture = new TrackedBitmapRectTexture(bitmapData);
			texture.getTextureForStage3D(_stage3DProxy);
			_infoMesh.scaleX = bitmapData.width/2.57;
			_infoMesh.scaleZ = bitmapData.height/2.57;
			_infoMesh.x = 0;
			bitmapData.dispose();
			_userNameMaterial.texture = texture;
		}

		private function createInfoBitmapData():BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(154, 20, true, 0x00000000);

			var textField:TextField = generateTextField(_imageProxy.userName);
			bitmapData.draw(textField);

			var heartBitmapData : BitmapData = HomeMaterialsCache.getBitmapDataById(HomeMaterialsCache.ICON_HEART);
			var matrix : Matrix = new Matrix(1, 0, 0, 1, bitmapData.width - heartBitmapData.width, 0);
			bitmapData.draw(heartBitmapData, matrix);

			textField = generateTextField(_imageProxy.numLikes.toString());
			matrix.tx -= textField.width + 3;
			bitmapData.draw(textField, matrix);

			return bitmapData;
		}

		private function generateTextField(text : String) : TextField
		{
			var textFormat:TextFormat = PsykoFonts.BookFontSmall;
			textFormat.color = 0x333333;
			textFormat.size = 9;
			textFormat.align = TextFieldAutoSize.LEFT;

			var textField:TextField = new TextField();
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.embedFonts = true;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = textFormat;
			textField.text = text;
			textField.width = textField.textWidth + 5;
			textField.height = textField.textHeight + 3;

			return textField;
		}

		private function initShadow():void
		{
			_shadowMesh = new Mesh(HomeGeometryCache.getGeometryById(HomeGeometryCache.CARD_GEOMETRY), HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.THUMBNAIL_SHADOW));
			_shadowMesh.scaleX = 64;
			_shadowMesh.scaleZ = 25;
			_shadowMesh.z = -18;
			addChild(_shadowMesh);
		}

		private function initThumbnail():void
		{
			_thumbMesh = new Mesh(HomeGeometryCache.getGeometryById(HomeGeometryCache.CARD_GEOMETRY), HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.THUMBNAIL_LOADING));
			_thumbMesh.scaleX = _width;
			_thumbMesh.scaleZ = _height;
			_thumbMesh.y = 1;
			_thumbMesh.mouseEnabled = true;
			addChild(_thumbMesh);

			_thumbTexture = new TrackedBitmapRectTexture(null);
			_thumbMaterial = new FlatTextureMaterial(_thumbTexture);
		}

		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		public function get imageProxy():GalleryImageProxy
		{
			return _imageProxy;
		}

		public function set imageProxy(value:GalleryImageProxy):void
		{
			_imageProxy = value;
		}

		public function load(onComplete:Function = null):void
		{
			updateInfoMaterial();

			_onComplete = onComplete;

			_thumbMesh.material = HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.THUMBNAIL_LOADING)
			_imageProxy.loadThumbnail(onThumbnailLoaded, onThumbnailFail, ImageThumbnailSize.SMALL);
		}


		override public function dispose():void
		{
			_imageProxy.cancelLoading();
			_imageProxy = null;

			_thumbMesh.dispose();
			_shadowMesh.dispose();
			_userNameMaterial.texture.dispose();
			_userNameMaterial.dispose();
			_infoMesh.dispose();

			_thumbMaterial.dispose();
			_thumbTexture.dispose();

			_thumbMesh = null;
			_thumbTexture = null;
			_thumbMaterial = null;
			_shadowMesh = null;

			_infoMesh=null;
			_onComplete = null;

			//WE DON'T DISPOSE OF THE SHADOW MATERIAL. TO DISPOSE IN BookMaterialsProxy

			super.dispose();
		}

		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD " + _imageProxy);
		}

		private function onThumbnailLoaded(file:Object):void
		{
			var bitmapData:BitmapData = BitmapData(file);

			_thumbTexture.bitmapData = bitmapData;
			_thumbTexture.getTextureForStage3D(_stage3DProxy);
			_thumbMesh.material = _thumbMaterial;
			bitmapData.dispose();

			dispatchEvent(new Event(EVENT_LOADED));

			if (_onComplete)
				_onComplete.call();
		}
	}
}