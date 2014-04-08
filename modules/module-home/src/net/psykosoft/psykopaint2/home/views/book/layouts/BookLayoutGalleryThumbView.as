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

	import flash.text.AntiAliasType;

	import flash.text.TextField;

	import flash.text.TextFieldAutoSize;

	import flash.text.TextFormat;

	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageThumbnailSize;
	import net.psykosoft.psykopaint2.home.views.book.BookGeometryProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;

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

		private var _likeMesh:Mesh;
		private var _onComplete:Function;

		private var _stage3DProxy:Stage3DProxy;
		private var _userNameMesh:Mesh;
		private var _userNameMaterial:FlatTextureMaterial;


		public function BookLayoutGalleryThumbView(stage3DProxy:Stage3DProxy)
		{
			_stage3DProxy = stage3DProxy;

			initThumbnail();
			initShadow();
			initUserName();
			initLike();
		}

		private function initLike():void
		{
			_likeMesh = new Mesh(BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY), BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.ICON_HEART));
			_likeMesh.scaleX = 5;
			_likeMesh.scaleZ = 5;
			_likeMesh.x = 28;
			_likeMesh.y = 3;
			_likeMesh.z = -25;
			addChild(_likeMesh);
		}

		private function initUserName():void
		{
			_userNameMaterial = new FlatTextureMaterial(null);
			_userNameMaterial.blendMode = BlendMode.LAYER;
			_userNameMesh = new Mesh(BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY), _userNameMaterial);
			_userNameMesh.y = 3;
			_userNameMesh.z = -25;
			addChild(_userNameMesh);
		}

		private function updateUserNameMaterial():void
		{
			var bitmapData:BitmapData = generateTextBitmapData(_imageProxy.userName);
			var texture:TrackedBitmapRectTexture = new TrackedBitmapRectTexture(bitmapData);
			texture.getTextureForStage3D(_stage3DProxy);
			_userNameMesh.scaleX = bitmapData.width/2.57;
			_userNameMesh.scaleZ = bitmapData.height/2.57;
			alignUserName();
			bitmapData.dispose();
			_userNameMaterial.texture = texture;
		}

		[Inline]
		private function alignUserName():void
		{
			// scale values contain actual dimensions due to normalized geometry
			_userNameMesh.x = (_userNameMesh.scaleX - _width) * .5;
		}

		private function generateTextBitmapData(text : String) : BitmapData
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

			var bitmapData:BitmapData = new BitmapData(textField.width, textField.height, true, 0x00000000);
			bitmapData.draw(textField, null, null, null, null, true);
			return bitmapData;
		}

		private function initShadow():void
		{
			_shadowMesh = new Mesh(BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY), BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW));
			_shadowMesh.scaleX = 64;
			_shadowMesh.scaleZ = 25;
			_shadowMesh.z = -18;
			addChild(_shadowMesh);
		}

		private function initThumbnail():void
		{
			_thumbMesh = new Mesh(BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY), BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
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
			updateUserNameMaterial();

			_onComplete = onComplete;

			_thumbMesh.material = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING)
			_imageProxy.loadThumbnail(onThumbnailLoaded, onThumbnailFail, ImageThumbnailSize.SMALL);
		}


		override public function dispose():void
		{
			_imageProxy.cancelLoading();
			_imageProxy = null;

			_likeMesh.dispose();
			_thumbMesh.dispose();
			_shadowMesh.dispose();
			_userNameMaterial.texture.dispose();
			_userNameMaterial.dispose();
			_userNameMesh.dispose();

			_thumbMaterial.dispose();
			_thumbTexture.dispose();

			_thumbMesh = null;
			_thumbTexture = null;
			_thumbMaterial = null;
			_shadowMesh = null;

			_userNameMesh=null;
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