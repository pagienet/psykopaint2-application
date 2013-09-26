package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.book.views.models.BookData;
	import net.psykosoft.psykopaint2.book.views.models.BookGalleryData;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;
	import net.psykosoft.psykopaint2.book.views.book.data.FileLoader;
	import net.psykosoft.psykopaint2.book.views.book.data.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;

	import flash.geom.Rectangle;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
 
	public class GalleryLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 200;
		private const INSERT_HEIGHT:uint = 130;
		private const INSERTS_COUNT:uint = 6;
		private const SPACE:Number = 5;
		private const DEDICATED_ASSETS:uint = 5;

		private var _insertNRMRect:Rectangle;
		private var _insertPaintingRect:Rectangle;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _assetsLoaded:uint;
 		private var _fileLoader:FileLoader;
		private var _nameTextField:TextField;
		private var _hartCountTextField:TextField;
		private var _commentsCountTextField:TextField;
		private var _infoSprite:Sprite;
		private var _commentNMap:BitmapData;
		private var _commentMap:BitmapData;
		private var _heartNMap:BitmapData;
		private var _heartMap:BitmapData;
		private var _paintingMap:BitmapData;

		private var _bmComment:Bitmap;
		private var _bmHeart:Bitmap;
		 
		public function GalleryLayout(stage:Stage)
		{
			super(BookImageSource.GALLERY_IMAGES, stage);
		}

		override protected function initDefaultAssets():void
		{
			_assetsLoaded = 0;
			_fileLoader = new FileLoader();

			var url:String = "book-packaged/images/layouts/comment_NRM.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:0});

			url = "book-packaged/images/layouts/comment.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:1});

			url = "book-packaged/images/layouts/heart_NRM.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:2});

			url = "book-packaged/images/layouts/heart.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:3});

			url = "book-packaged/images/layouts/painting.png";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:4});

		}

		override protected function disposeLayoutElements():void
		{
			_insertNRMRect = _insertPaintingRect = null;
			_nameTextField = _hartCountTextField = _commentsCountTextField = null;
			_infoSprite = null;

			if(_commentNMap) _commentNMap.dispose();
			if(_commentMap) _commentMap.dispose();
			if(_heartNMap) _heartNMap.dispose();
			if(_heartMap) _heartMap.dispose();
			if(_paintingMap) _paintingMap.dispose();

			if(_bmComment)_bmComment = null;
			if(_bmHeart)_bmHeart = null;
		}
 
		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{	
			_assetsLoaded++;
			var type:uint = e.customData.type;

			switch(type){
				case 0:
					_commentNMap = e.data;
					break;
				case 1:
					_commentMap = e.data;
					break;
				case 2:
					_heartNMap = e.data;
					break;
				case 3:
					_heartMap = e.data;
					break;
				case 4:
					_paintingMap = e.data;
					break;
			}

			if(_assetsLoaded == DEDICATED_ASSETS){
				_fileLoader = null;
				initTextField();
			} 
 
		}

		override public function loadBookContent(onContentLoaded:Function):void
 		{	
 			prepareBookContent(onContentLoaded, INSERTS_COUNT);
 		}

 		override protected function composite(insertSource:BitmapData, data:BookData):void
		{
			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(data.pageIndex);
			var inPageIndex:uint = uint(data.inPageIndex);
			var isRecto:Boolean = (pageIndex %2 == 0)? true : false;
				
			if(isRecto){

				if(inPageIndex %2 == 0){
					insertRect.x = 50;
				} else {
					insertRect.x = 281;
				}

			} else {

				if(inPageIndex %2 == 0){
					insertRect.x = 31;
				} else {
					insertRect.x = 262;
				}

			}

			//col layout recto: 31+130+31+130+31+130
			var col:uint = Math.floor(inPageIndex/2);

			switch(col){
				case 0:
					insertRect.y = 20;//31
					break;
				case 1:
					insertRect.y = 181;//192;
					break;
				case 2:
					insertRect.y = 342;//353;
					break;
			}

			//random variations
			insertRect.x += -3+(Math.random()*6);
			insertRect.y += -3+(Math.random()*6);

			var rotation:Number = -1.5+(Math.random()*3);
 
			//row layout recto: 50+200+31+200+31
			//the page material
			pageIndex = Math.floor(pageIndex);
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();

			if(BookGalleryData(data).imageVO.paintingMode != ""){

				if(!_insertPaintingRect) _insertPaintingRect = new Rectangle(0,0,01,1);

				_insertPaintingRect.x = -10;
				_insertPaintingRect.width = insertSource.width/4;
				_insertPaintingRect.height = insertSource.height/4;

				insert(_paintingMap, insertSource, _insertPaintingRect, rotation, false, true);
			}

			//insert the image loaded into diffuse map
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
			var offset:Number = (lastHeight*.5);

			updateAndInsertTextInformation(BookGalleryData(data).imageVO, insertRect, diffuseSourceBitmapdata);

			diffuseSourceBitmapdata.unlock();
 
			_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			
			if(!_insertNRMRect) _insertNRMRect = new Rectangle();
 
			_insertNRMRect.x = insertRect.x+((insertRect.width - lastWidth)*.5);
			_insertNRMRect.y = insertRect.y+((insertRect.height - lastHeight)*.5);
			_insertNRMRect.width = lastWidth;
			_insertNRMRect.height = lastHeight;
 
			// no need to update the normalmap if no shader uses it
			if(PlatformUtil.hasRequiredPerformanceRating(2) ) {
				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;
 
				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();
				 
				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, _insertNRMRect, rotation, false, false);

				//insert the bits of normalmaps asset heart and comment bubble
				var destX:Number = insertRect.x + _bmComment.x;
				var destY:Number = insertRect.y+insertRect.height+2;
				if(_commentNMap) insertObjectAt(_commentNMap, normalSourceBitmapdata, destX, destY+_bmComment.y, _bmComment.width/_commentNMap.width, _bmComment.height/_commentNMap.height);
				destX = insertRect.x + _bmHeart.x;
				if(_heartNMap) insertObjectAt(_heartNMap, normalSourceBitmapdata, destX, destY+_bmHeart.y, _bmHeart.width/_heartNMap.width, _bmHeart.height/_heartNMap.height);
				
				normalSourceBitmapdata.unlock();
				
				if(invalidateContent) {
					normalTextureSource.invalidateContent();
					normalTextureSource.bitmapData = normalSourceBitmapdata;
				}
			}

			//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
			data.inPageIndex = inPageIndex;
			data.pageIndex = pageIndex;
 			dispatchRegion(insertRect, data);

			//insert the shadow map
			if(!_shadow)  _shadow = getShadow();

			insert(_shadow, diffuseSourceBitmapdata, _insertNRMRect, rotation, false, true, 0,0,-5, offset);

 			//update after inserts
 			if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;//normalSourceBitmapdata
 			}
 			
		}

		private function updateAndInsertTextInformation(vo: GalleryImageProxy, rect:Rectangle, destSource:BitmapData):void
		{
			_hartCountTextField.text = ""+vo.numLikes;
			_commentsCountTextField.text = ""+vo.numComments;
			_nameTextField.text = ""+vo.userName;

			_bmComment.x = INSERT_WIDTH - _bmComment.width;
			_hartCountTextField.x = _bmComment.x - SPACE - _hartCountTextField.textWidth;
			_bmHeart.x = _hartCountTextField.x - _bmHeart.width - SPACE;
			_commentsCountTextField.x = _bmHeart.x - SPACE - _commentsCountTextField.textWidth;

			insertObjectAt(_infoSprite, destSource, rect.x, rect.y+rect.height+2);
		}

		private function initTextField():void
		{
			_infoSprite = new Sprite();

			var textFormatName:TextFormat = PsykoFonts.BookFontSmall;
			textFormatName.color = 0x333333;
			textFormatName.size = 10;
			textFormatName.align = TextFieldAutoSize.LEFT;

			var textFormatCount:TextFormat = PsykoFonts.BookFontSmall;
			textFormatCount.color = 0x333333;
			textFormatCount.size = 10;
			textFormatCount.align = TextFieldAutoSize.RIGHT;

			var fieldsHeight:Number = 20;
			var numericFieldsWidth:Number = 30;
 
		 	_nameTextField = new TextField();
		 	_nameTextField.antiAliasType = AntiAliasType.ADVANCED;
		  	_nameTextField.embedFonts = true;
			_nameTextField.width = 150;
			_nameTextField.height = fieldsHeight;
			_nameTextField.x = 0;
			_nameTextField.y = 1;
			//_nameTextField.border = true;
			_nameTextField.defaultTextFormat = textFormatName;
			_nameTextField.text = "Cool Name";
			_infoSprite.addChild(_nameTextField);
 
		 	_hartCountTextField = new TextField();
		 	_hartCountTextField.autoSize = TextFieldAutoSize.RIGHT;
		 	_hartCountTextField.antiAliasType = AntiAliasType.ADVANCED;
		  	_hartCountTextField.embedFonts = true;
			_hartCountTextField.width = numericFieldsWidth;
			_hartCountTextField.height = fieldsHeight;
			_hartCountTextField.y = 1;
			_hartCountTextField.defaultTextFormat = textFormatCount;
			_hartCountTextField.text = "000";
			_infoSprite.addChild(_hartCountTextField);

			_commentsCountTextField = new TextField();
			_commentsCountTextField.autoSize = TextFieldAutoSize.RIGHT;
		 	_commentsCountTextField.antiAliasType = AntiAliasType.ADVANCED;
		  	_commentsCountTextField.embedFonts = true;
			_commentsCountTextField.width = numericFieldsWidth;
			_commentsCountTextField.height = fieldsHeight;
			_commentsCountTextField.y = 1;
			_commentsCountTextField.defaultTextFormat = textFormatCount;
			_commentsCountTextField.text = "000";
			_infoSprite.addChild(_commentsCountTextField);
 
			_bmComment = new Bitmap(_commentMap);
			_bmComment.width = _bmComment.height = 19;
			_bmComment.y = 2;
			
			_bmHeart = new Bitmap(_heartMap);
			_bmHeart.width = _bmHeart.height = 19;
			_bmHeart.y = 2;
 
			_infoSprite.addChild(_bmComment);
			_infoSprite.addChild(_bmHeart);
		}
	}
}