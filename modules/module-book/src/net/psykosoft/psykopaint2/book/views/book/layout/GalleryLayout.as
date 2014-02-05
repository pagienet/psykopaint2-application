package net.psykosoft.psykopaint2.book.views.book.layout
{
	import away3d.core.managers.Stage3DProxy;

	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.book.views.models.BookData;
	import net.psykosoft.psykopaint2.book.views.models.BookGalleryData;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;

	import flash.geom.Rectangle;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
 
	public class GalleryLayout extends LayoutBase
	{
		public static const INSERTS_COUNT:uint = 6;

		private const INSERT_WIDTH:uint = 204;
		private const INSERT_HEIGHT:uint = 149;	
		private const SPACE:Number = 5;
		private const DEDICATED_ASSETS:uint = 7;

		private var _insertNRMRect:Rectangle;
		private var _insertPaintingRect:Rectangle;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _assetsLoaded:uint;
 		private var _fileLoader:QueuedFileLoader;
		private var _nameTextField:TextField;
		private var _hartCountTextField:TextField;
		private var _commentsCountTextField:TextField;
		private var _infoSprite:Sprite;
		private var _commentNMap:BitmapData;
		private var _commentMap:BitmapData;
		private var _heartNMap:BitmapData;
		private var _heartMap:BitmapData;
		private var _paintingMap:BitmapData;
		private var _baseMask:BitmapData;

		private var _bmComment:Bitmap;
		private var _bmHeart:Bitmap;
		private var _bmCommentMask:BitmapData;
		private var _bmHeartMask:BitmapData;
		 
		public function GalleryLayout(stage:Stage, stage3dProxy : Stage3DProxy, previousLayout:LayoutBase = null)
		{
			super(ImageCollectionSource.GALLERY_IMAGES, stage, stage3dProxy, previousLayout);
		}

		override protected function initDefaultAssets():void
		{
			_assetsLoaded = 0;
			_fileLoader = new QueuedFileLoader();

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

			url = "book-packaged/images/layouts/comment_mask.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:5});

			url = "book-packaged/images/layouts/heart_mask.jpg";
			_fileLoader.loadImage(url, onImageLoadedComplete, null, {type:6});
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
			if(_baseMask)_baseMask.dispose();
			if(_bmCommentMask)_bmCommentMask.dispose();
			if(_bmHeartMask)_bmHeartMask.dispose();

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
				case 5:
					_bmCommentMask = e.data;
					break;
				case 6:
					_bmHeartMask = e.data;
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
			var hasPower:Boolean = PlatformUtil.hasRequiredPerformanceRating(2);
				
			if(isRecto){

				if(inPageIndex %2 == 0){
					insertRect.x = 35;
				} else {
					insertRect.x = 269;
				}

			} else {

				if(inPageIndex %2 == 0){
					insertRect.x = 40;
				} else {
					insertRect.x = 274;
				}

			}

			var col:uint = Math.floor(inPageIndex/2);

			switch(col){
				case 0:
					insertRect.y = 5;
					break;
				case 1:
					insertRect.y = 172;
					break;
				case 2:
					insertRect.y = 342;
					break;
			}

			//random variations
			insertRect.x += -3+(Math.random()*6);
			insertRect.y += -3+(Math.random()*6);

			var rotation:Number = -1.5+(Math.random()*3);
  
			//the page material
			pageIndex = uint( Math.floor(pageIndex) );
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();

			//Not sure what this does, but since there is no painting mode anymore I just
			//assume that this should always get applied:
			//if(BookGalleryData(data).imageVO.paintingMode != ""){

				if(!_insertPaintingRect) _insertPaintingRect = new Rectangle(0, 0, 1, 1);

				_insertPaintingRect.x = -10;
				_insertPaintingRect.width = insertSource.width/4;
				_insertPaintingRect.height = insertSource.height/4;

				insert(_paintingMap, insertSource, _insertPaintingRect, rotation, false, true);
			//}
 
			if(hasPower){
				//insert brighter reflection
				var btMask:BitmapTexture = getEnviroMaskTexture(pageIndex);
				var maskBMD:BitmapData = btMask.bitmapData;

				if(_baseMask && (_baseMask.width != insertSource.width || _baseMask.height != insertSource.height) ){
					_baseMask.dispose();
					_baseMask = new TrackedBitmapData(insertSource.width, insertSource.height, false, 0xBBBBBB);

				} else if(!_baseMask){
					_baseMask = new TrackedBitmapData(insertSource.width, insertSource.height, false, 0xBBBBBB);
				}
				//insert the image loaded into diffuse map. no need to dispose map, its being reused and finally destroyed when all is constructed
				insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
				insert(_baseMask, maskBMD, insertRect, rotation, false, true);
				
			} else {
				insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
			}
 
			var offset:Number = (lastHeight*.5);

			updateAndInsertTextInformation(BookGalleryData(data).imageVO, insertRect, diffuseSourceBitmapdata);

			diffuseSourceBitmapdata.unlock();
 			
 			// because remote, we refresh each time an image is loaded...
			//_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			//var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			
			if(!_insertNRMRect) _insertNRMRect = new Rectangle();
 
			_insertNRMRect.x = insertRect.x+((insertRect.width - lastWidth)*.5);
			_insertNRMRect.y = insertRect.y+((insertRect.height - lastHeight)*.5);
			_insertNRMRect.width = lastWidth;
			_insertNRMRect.height = lastHeight;
 
			// no need to update the normalmap if no shader uses it
			if(hasPower){
				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;
 
				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();
				 
				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, _insertNRMRect, rotation, false, false);

				//insert the bits of normalmaps asset heart and comment bubble
				var destX:Number = insertRect.x + _bmComment.x;
				var destY:Number = insertRect.y+insertRect.height+2;
				if(_commentNMap){
					insertObjectAt(_commentNMap, normalSourceBitmapdata, destX, destY+_bmComment.y, _bmComment.width/_commentNMap.width, _bmComment.height/_commentNMap.height);
					if(_bmCommentMask) insertObjectAt(_bmCommentMask, maskBMD, destX, destY+_bmComment.y, _bmComment.width/_commentNMap.width, _bmComment.height/_commentNMap.height);
				}
				destX = insertRect.x + _bmHeart.x;

				if(_heartNMap){
					insertObjectAt(_heartNMap, normalSourceBitmapdata, destX, destY+_bmHeart.y, _bmHeart.width/_heartNMap.width, _bmHeart.height/_heartNMap.height);
					if(_bmHeartMask) insertObjectAt(_bmHeartMask, maskBMD, destX, destY+_bmHeart.y, _bmHeart.width/_heartNMap.width, _bmHeart.height/_heartNMap.height);
				}
				 
				normalSourceBitmapdata.unlock();
				
			//	if(invalidateContent) {
					normalTextureSource.invalidateContent();
					normalTextureSource.bitmapData = normalSourceBitmapdata;
				//}

	 			btMask.invalidateContent();
	 			btMask.bitmapData = maskBMD;
			}

			//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
			data.inPageIndex = inPageIndex;
			data.pageIndex = pageIndex;
 			dispatchRegion(insertRect, data);

			//insert the shadow map
			if(!_shadow)  _shadow = getShadow();

			insert(_shadow, diffuseSourceBitmapdata, _insertNRMRect, rotation, false, true, 0,0,-5, offset);

 			//update after inserts every time a picture is loaded as its remote and time between loading may differ
 			//if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;//normalSourceBitmapdata
 			//}
		}

		private function updateAndInsertTextInformation(vo: GalleryImageProxy, rect:Rectangle, destSource:BitmapData):void
		{
			var likes:String = ""+ ( (vo.numLikes>1000)? Math.round(vo.numLikes/1000)+" k" : vo.numLikes );
			_hartCountTextField.text = likes;

			var comments:String = ""+ ( (vo.numComments>1000)? Math.round(vo.numComments/1000)+" k" : vo.numComments);
			_commentsCountTextField.text = comments;
			_nameTextField.text = ""+vo.userName;

			_bmComment.x = INSERT_WIDTH - _bmComment.width;
			_hartCountTextField.x = _bmComment.x - SPACE - _hartCountTextField.textWidth;
			_bmHeart.x = _hartCountTextField.x - _bmHeart.width - SPACE;
			_commentsCountTextField.x = _bmHeart.x - SPACE - _commentsCountTextField.textWidth;

			insertObjectAt(_infoSprite, destSource, rect.x, rect.y+rect.height);//+2);
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