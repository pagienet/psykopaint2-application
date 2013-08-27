package net.psykosoft.psykopaint2.book.views.book.data
{
	import net.psykosoft.psykopaint2.book.views.book.data.FileLoader;
	import net.psykosoft.psykopaint2.book.views.book.data.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.psykopaint2.book.views.book.data.BookPageSize;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	import away3d.textures.BitmapTexture;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.textures.BitmapCubeTexture;

	/* holds the minimum bitmaps data for a book  */
 	public class BlankBook
 	{
 		private const REQUIRED:uint = 11;

 		private var _requiredLoaded:uint;
 		private var _enviroRequiredLoaded:uint;
 		private var _paper:BitmapData ;
		private var _craftMap:BitmapData;
		private var _paperNormalMap:BitmapData;
		private var _paperInsertNormalMap:BitmapData;
		private var _shadowPictMap:BitmapData;
		private var _pageNumber_txt:TextField;
		private var _enviroSources:Vector.<BitmapData>;
		private var _fileLoader:FileLoader;
		private var _pageSprite:Sprite;
		private var _paperBM:Bitmap;
 		private var _layoutBase:LayoutBase;
 
		function BlankBook(layoutBase:LayoutBase){
			_layoutBase = layoutBase;
			init();
		}

		private function init():void
		{
			_requiredLoaded = 0;
			_enviroRequiredLoaded = 0;
			_fileLoader = new FileLoader();
			_pageSprite = new Sprite();

			_enviroSources = new Vector.<BitmapData>(6, true);

			//urls are hardcoded as they will never change. Could come from some app config file tho.

			//craft
			var url:String = "book-packaged/images/book/cover.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:0});
			//enviro sources (x6)
			url = "book-packaged/images/page/pageEnv0.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:1, index:0});

			url = "book-packaged/images/page/pageEnv1.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:2, index:1});

			url = "book-packaged/images/page/pageEnv2.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:3, index:2});

			url = "book-packaged/images/page/pageEnv3.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:4, index:3});

			url = "book-packaged/images/page/pageEnv4.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:5, index:4});

			url = "book-packaged/images/page/pageEnv5.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:6, index:5});

			//diffuse paper
			url = "book-packaged/images/page/paperbook512.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:7});

			//normalmap paper
			url = "book-packaged/images/page/paperbook512_NRM.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:8});

			//normalmap insert image
			url = "book-packaged/images/page/volume_pict_NRM_128.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:9});

			//shadow
			url = "book-packaged/images/page/pict_shadow.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:10});
		}

		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{	
			_requiredLoaded++;
			var type:uint = e.customData.type;

			switch(type){
				case 0:
					_craftMap = e.data;
					_layoutBase.dispatchCraftReady(_craftMap);
					break;
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
					_enviroSources[e.customData.index] = e.data;
					_enviroRequiredLoaded++;

					if(_enviroRequiredLoaded == 6)  _layoutBase.dispatchEnviromapsReady(_enviroSources);
					 
					break;
				case 7:
					_paper = e.data;
					prepareBasePage();
					break;
				case 8:
					_paperNormalMap = e.data;
					break;
				case 9:
					_paperInsertNormalMap = e.data;
					break;
				case 10:
					_shadowPictMap = e.data;
					break;
			}

			if(_requiredLoaded == REQUIRED){
				_fileLoader = null;
				_layoutBase.dispatchMinimumRequiredReady();
			} 
 
		}

		private function prepareBasePage():void
		{
			var g:Graphics = _pageSprite.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0,0, BookPageSize.WIDTH, BookPageSize.HEIGHT);
			g.endFill();
			_paperBM = new Bitmap(_paper);
			_pageSprite.addChild(_paperBM);

			initTextField();
		}

		private function initTextField():void
		{
			var textFormat:TextFormat = PsykoFonts.BookFontSmall;
			textFormat.color = 0x333333;
			textFormat.size = 10;
			textFormat.align = TextFieldAutoSize.LEFT;
 
		 	_pageNumber_txt = new TextField();
		  	_pageNumber_txt.embedFonts = true; //ask LI when the fonts will be available
			_pageNumber_txt.width = 20;
			_pageNumber_txt.height = 15;
			_pageNumber_txt.x = 10;
			_pageNumber_txt.y = _pageSprite.height - 20;
			 //_pageNumber_txt.scaleY --> to fix the distort if the texture would not be projected as a square
			 //_pageNumber_txt.border = true; to debug visually

			_pageNumber_txt.defaultTextFormat = textFormat;
			_pageNumber_txt.text = "00";

			_pageSprite.addChild(_pageNumber_txt);
		}

		public function getBasePageBitmapData(index:uint):BitmapData
		{
			_pageNumber_txt.text = ""+(index+1);

			if(index%2 != 0){
				_pageNumber_txt.x = 5;
				_paperBM.rotation = 180;
				_paperBM.x = BookPageSize.WIDTH;
				_paperBM.y = BookPageSize.HEIGHT;
				
			} else {
				_paperBM.rotation = 0;
				_paperBM.x = _paperBM.y = 0;
				_pageNumber_txt.x = _pageSprite.width -5 - _pageNumber_txt.width;
			}

			// new BitmapData(...) with new TrackedBitmapData(...)
			//var pageBitmapData:BitmapData = new BitmapData(BookPageSize.WIDTH, BookPageSize.HEIGHT, false);
			var pageBitmapData:TrackedBitmapData = new TrackedBitmapData(BookPageSize.WIDTH, BookPageSize.HEIGHT, false);
			pageBitmapData.draw(_pageSprite, null, null, "normal", null, true);

			return pageBitmapData;
		}

		public function getBasePageNormalmap(clone:Boolean):BitmapData
		{	
			if(clone) return _paperNormalMap.clone();

			return _paperNormalMap;
		}

		public function getBasePictShadowMap(clone:Boolean):BitmapData
		{	
			if(clone) return _shadowPictMap.clone();

			return _shadowPictMap;
		}

		public function getBasePageInsertNormalmap(clone:Boolean):BitmapData
		{	
			if(clone) return _paperInsertNormalMap.clone();

			return _paperInsertNormalMap;
		}

		public function dispose():void
		{
			if(_paper) _paper.dispose();
			if(_paperNormalMap) _paperNormalMap.dispose();
			if(_paperInsertNormalMap) _paperInsertNormalMap.dispose();
			if(_shadowPictMap) _shadowPictMap.dispose();

			_pageNumber_txt = null;
			_pageSprite = null;
			if(_enviroSources){
				for(var i:uint = 0;i<_enviroSources.length;++i){
					if(_enviroSources[i]) _enviroSources[i].dispose();
				}
				_enviroSources = null;
			}
		}

 	}
 }