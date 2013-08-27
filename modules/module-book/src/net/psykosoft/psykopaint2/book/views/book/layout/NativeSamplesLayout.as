package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;

	import net.psykosoft.psykopaint2.book.views.book.data.FileLoader;
	import net.psykosoft.psykopaint2.book.views.book.data.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.book.model.SourceImageVO;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;

	import flash.utils.Dictionary;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.Stage;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;

	import net.psykosoft.psykopaint2.book.views.models.BookThumbnailData;

	public class NativeSamplesLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 200;
		private const INSERT_HEIGHT:uint = 130;

		private const INSERTS_COUNT:uint = 6;

		private var _loadedResources:uint = 0;
		private var _resourcesCount:uint;
		private var _fileLoader:FileLoader;
		private var _content:Vector.<BookThumbnailData>;
		private var _shadowRect:Rectangle;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _imageLoader:BitmapLoader;
		private var _pagesFilled:Dictionary;
		private var _cb:Function;

		public function NativeSamplesLayout(stage:Stage)
		{
			_fileLoader = new FileLoader();

			super(BookImageSource.SAMPLE_IMAGES, stage);
		}

		override public function loadBookContent(onContentLoaded:Function):void
 		{	
 			_content = new Vector.<BookThumbnailData>();
			
			var images : Vector.<SourceImageVO> = _collection.images;
			 
			var imageVO:SourceImageVO;

 			_resourcesCount = images.length;
 
			var data:BookThumbnailData;
			var url:String;

			_pagesFilled = new Dictionary();
			var pageIndex:uint;
			var inPageIndex:uint;

			for(var i:uint = 0; i < _resourcesCount;++i){

				imageVO = images[i];
				
				pageIndex = uint(i/INSERTS_COUNT);
				inPageIndex = uint( i - (pageIndex*INSERTS_COUNT) );
				 
				data = new BookThumbnailData(imageVO, i, pageIndex, inPageIndex);

				_content.push(data);
 
				if(!_pagesFilled["pageIndex"+pageIndex]){
					_pagesFilled["pageIndex"+pageIndex] = {max:0, inserted:0};
				}

				_pagesFilled["pageIndex"+pageIndex].max++;
				 
			}
 
			//we have 6 images for this layout, 2 sides;
			var sides:uint = Math.ceil(_resourcesCount/INSERTS_COUNT);

			if(sides%2 != 0) sides+=1;
			pageCount = sides*.5;

			onContentLoaded();
 		}
 
		override public function loadContent():void
		{
			switchToHighDrawQuality();

			for(var i:uint = 0; i < _content.length;++i){
				loadImage(_content[i]);
			}
			_content = null;
		}

		private function loadImage( object:BookThumbnailData):void
		{
			_fileLoader.loadImage(object.imageVO.highResThumbnailFilename, onImageLoadedComplete, onImageLoadError, object);
		}
 
		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{
			composite(e.data, e.customData);
			clearFileloader();
		}

		private function onImageLoadError(e:AssetLoadedEvent):void
		{
			clearFileloader();
		}

		private function clearFileloader():void
		{
			_loadedResources++;
			
			if(_resourcesCount == _loadedResources){
				_fileLoader = null;
				restoreQuality();
			}
		}

		//Custom compositing variation per layout and region registration for mouse detection
		override protected function composite(insertSource:BitmapData, object:Object):void
		{
			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(object.pageIndex);
			var inPageIndex:uint = uint(object.inPageIndex);
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
					insertRect.y = 31;
					break;
				case 1:
					insertRect.y = 192;
					break;
				case 2:
					insertRect.y = 353;
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
			//insert the image loaded into diffuse map
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true);
			diffuseSourceBitmapdata.unlock();
 
			_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			 
			// no need to update the normalmap if no shader uses it
			if(PlatformUtil.hasRequiredPerformanceRating(2) ) {
				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;
 
				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();
 
				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, insertRect, rotation);
				normalSourceBitmapdata.unlock();
				
				if(invalidateContent) {
					normalTextureSource.invalidateContent();
					normalTextureSource.bitmapData = normalSourceBitmapdata;
				}
			}

			//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
			object.inPageIndex = inPageIndex;
			object.pageIndex = pageIndex;
 			dispatchRegion(insertRect, object);

			//insert the shadow map
			if(!_shadow)  _shadow = getShadow();

			// because shadow is partly covering the image, update the insertRect, we keep the insertRect intact for regions
			if(!_shadowRect)  _shadowRect = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			 
			_shadowRect.x = insertRect.x - 10;
 			_shadowRect.y = insertRect.y + 40;
 			_shadowRect.width = INSERT_WIDTH+15;
 			_shadowRect.height = 105;
			insert(_shadow, diffuseSourceBitmapdata, _shadowRect, rotation, false, false, insertRect.x-_shadowRect.x, insertRect.y-_shadowRect.y);

 			//update after inserts
 			if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;
 			}
 			
		}

		// if VO is consistant, this could be moved to base as we do not need variations for the highres lookups.
		override public function loadFullImage( fileName:String, cb:Function ):void
 		{
			_imageLoader = new BitmapLoader();
			_cb = cb;
			_imageLoader.loadAsset( fileName, onFullSizeImageLoaded );
		}

		private function onFullSizeImageLoaded( bmd:BitmapData ):void
		{
			_cb( bmd );
			_imageLoader.dispose();
			_imageLoader = null;
		}

	}
}