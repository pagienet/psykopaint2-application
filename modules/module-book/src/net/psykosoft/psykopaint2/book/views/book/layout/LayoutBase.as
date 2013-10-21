package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.views.book.data.PageMaterialsManager;
	import net.psykosoft.psykopaint2.book.views.book.data.BlankBook;
	import net.psykosoft.psykopaint2.book.views.book.layout.CompositeHelper;
	import net.psykosoft.psykopaint2.book.model.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.book.views.models.BookThumbnailData;
	import net.psykosoft.psykopaint2.book.views.models.BookGalleryData;
	import net.psykosoft.psykopaint2.book.views.models.BookData;
	import net.psykosoft.psykopaint2.book.model.SourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.model.FileSourceImageProxy;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.IBitmapDrawable;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import org.osflash.signals.Signal;

	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

 	public class LayoutBase
 	{
 		protected var _layoutType:String;
 		protected var _inserts:Dictionary;
		protected var _collection:SourceImageCollection;
		protected var _galleryCollection:GalleryImageCollection;
		protected var _pagesFilled:Dictionary;

 		private var _pageMaterialsManager:PageMaterialsManager;
 		private var _blankBook:BlankBook;
 		private var _compositeHelper:CompositeHelper;
 		private var _pageCount:uint = 0;
 		private var _currentQuality:String;
 		private var _stage:Stage;
 		private var _loadIndex:uint = 0;
		private var _resourcesCount:uint;
		private var _content:Vector.<BookData>;
		private var _loadQueue : Vector.<BookData>;
		private var _queueID : String;
 		
 		public var requiredAssetsReadySignal:Signal;
 		public var requiredCraftSignal:Signal;
 		public var regionSignal:Signal;
 		
     		public function LayoutBase(type:String, stage:Stage, previousLayout:LayoutBase = null)
 		{
 			_layoutType = type;
 			_stage = stage;
 			_inserts = new Dictionary();
 			_pagesFilled = new Dictionary();

 			requiredAssetsReadySignal = new Signal();
 			requiredCraftSignal = new Signal();
 			regionSignal = new Signal();

 			if(previousLayout){
 				_pageMaterialsManager = previousLayout.pageMaterialsManager;
	 			_blankBook = previousLayout.blankBook;
	 			_compositeHelper = previousLayout.compositeHelper;
 			} else {
	 			_pageMaterialsManager = new PageMaterialsManager();
	 			_blankBook = new BlankBook(this);
	 			_pageMaterialsManager.blankBook = _blankBook;
	 			_compositeHelper = new CompositeHelper();
 			}

 			initDefaultAssets();
 		}
 
 		protected function insert(insertSource:BitmapData, destSource:BitmapData, insertRect:Rectangle, rotation:Number = 0, disposeInsert:Boolean = false, keepRatio:Boolean = false, offsetRotationX:Number = 0, offsetRotationY:Number = 0, offsetX:Number = 0, offsetY:Number = 0):BitmapData
 		{
 			return _compositeHelper.insert(insertSource, destSource, insertRect, rotation, disposeInsert, keepRatio, offsetRotationX, offsetRotationY, offsetX, offsetY);
 		}

 		protected function copyAt(insertSource:BitmapData, destSource:BitmapData, x:Number, y:Number):BitmapData
 		{
 			return _compositeHelper.copyAt(insertSource, destSource, x, y);
 		}

 		protected function insertObjectAt(insertSource:IBitmapDrawable, destSource:BitmapData, x:Number, y:Number, sclX:Number = 1, sclY:Number = 1):BitmapData
 		{
 			return _compositeHelper.insertObjectAt(insertSource, destSource, x, y, sclX, sclY);
 		}

 		protected function get lastWidth():Number
 		{
 			return _compositeHelper.lastWidth;
 		}

 		protected function get lastHeight():Number
 		{
 			return _compositeHelper.lastHeight;
 		}
 
 		//the count of pages (2 sides per page)
 		protected function set pageCount(val:uint):void
		{
			_pageCount = val;
		}

		protected function getPageMaterial(index:uint):TextureMaterial
		{
			return _pageMaterialsManager.getPageContentMaterial(index);
		}

		protected function getEnviroMaskTexture(index:uint):BitmapTexture
		{
			return _pageMaterialsManager.getEnviroMask(index);
		}

		public function get pageMaterialsManager():PageMaterialsManager
 		{
 			return _pageMaterialsManager;
 		}
 		public function get compositeHelper():CompositeHelper
 		{
 			return _compositeHelper;
 		}
 		public function get blankBook():BlankBook
 		{
 			return _blankBook;
 		}

		public function set collection(collection : SourceImageCollection):void
 		{
 			_collection = collection;
 		}

 		public function set galleryCollection(collection : GalleryImageCollection):void
 		{
 			_galleryCollection = collection;
 		}

		public function getPageCount():uint
		{
			return _pageCount;
		}

 		protected function getInsertNormalMap():BitmapData
		{
			return _blankBook.getBasePageInsertNormalmap(false);
		}

		protected function getShadow():BitmapData
		{
			return _blankBook.getBasePictShadowMap(false);
		}

		protected function prepareBookContent(onContentLoaded:Function, insertsPerPage:uint):void
		{
			_content = new Vector.<BookData>();

			if(_galleryCollection){
				prepareGalleryData(insertsPerPage);
			} else {
				prepareImageData(insertsPerPage);
			}

			onContentLoaded();
		}
 
		public function loadContent():void
		{
			switchToHighDrawQuality();

			if(_loadQueue) clearLoadingQueue();
			 
			_loadQueue = new Vector.<BookData>();
			_loadIndex = 0;
			var bookData:BookData;

			for(var i:uint = 0; i < _content.length;++i){
				bookData = _content[i];
				bookData.queueID = _queueID;
				_loadQueue.push(bookData);
			}

			loadCurrentThumbnail();

			_content = null;
		}
 
 		public function generateNumberedPageMaterial(index:uint):TextureMaterial
		{
			var bmdPage:BitmapData = _blankBook.getNumberedBasePageBitmapData(index);
			var numberedPageMaterial:TextureMaterial  = _pageMaterialsManager.registerMarginPageMaterial(index, bmdPage);
			 
			return numberedPageMaterial;
		}

		public function generateEmptyPageMaterial(index:uint):TextureMaterial
		{
			var bmdPage:BitmapData = _blankBook.getEmptyPageBitmapData(index);
			var emptyPageMaterial:TextureMaterial  = _pageMaterialsManager.registerContentPageMaterial(index, bmdPage);
			
			return emptyPageMaterial;
		}

		private function clearLoadingQueue():void
 		{
			if(_loadQueue){

				for(var i:uint = 0; i < _loadQueue.length;++i){
					_loadQueue[i] = null;
				}
				_loadQueue = null;
			}
		}

		public function clearData():void
 		{
 			for(var key:String in _inserts){
 				_inserts[key] = null;
 			}
 			_inserts = null;
			
			for( key in _pagesFilled){
				_pagesFilled[key] = null;
			}
			_pagesFilled = null;

 			clearLoadingQueue();

 			disposeLayoutElements();
 		}

 		public function dispose():void
 		{
 			clearData();

 			_pageMaterialsManager.dispose();
 			_pageMaterialsManager = null;

 			_blankBook.dispose();
 			_blankBook = null;

 			_compositeHelper.dispose();
 			_compositeHelper = null;
			
			
			_collection = null;
			_galleryCollection = null;
 		}

 		//draw quality
 		protected function switchToHighDrawQuality():void
		{
			_currentQuality = _stage.quality;
			_stage.quality = StageQuality.BEST;//should be better than StageQuality.HIGH
		}
		protected function restoreQuality():void
		{
			_stage.quality = _currentQuality;
		}
 
 		//when all basic elements for a the book are ready
 		public function dispatchMinimumRequiredReady():void
 		{
 			requiredAssetsReadySignal.dispatch();
 		}
 		//when craft is there, book can be displayed, the anim will already cover a part of waiting time while loading the pages assets
 		public function dispatchCraftReady(bmd:BitmapData, bmd2:BitmapData):void
 		{
 			_pageMaterialsManager.generateCraftMaterial(bmd);
 			_pageMaterialsManager.generateRingsMaterial(bmd2);
 			requiredCraftSignal.dispatch(bmd);
 		}

 		//register regions
 		public function dispatchRegion(rect:Rectangle, data:BookData):void
 		{
 			regionSignal.dispatch(rect, data);
 		}

 		//when the enviro elements are all loaded, we can build the enviromethod. no need for a signal, only pageMaterialsManager needs it
 		public function dispatchEnviromapsReady(enviroMaps:Vector.<BitmapData>):void
 		{
 			_pageMaterialsManager.generateEnviroMapMethod(enviroMaps);
 		}

 		//to be overrided per type layout if any dedicated content is required
 		protected function initDefaultAssets():void{}

 		protected function disposeLayoutElements():void{}
  
 		/* loaded image insert/compositing in page*/
 		protected function composite(image:BitmapData, data:BookData):void{throw new Error(this+":composite function: must be overrided");}

 		/* triggers the specific data parsing per layout to be able to generate the receiving pages*/
 		public function loadBookContent(onContentLoaded:Function):void {}

 		private function prepareImageData(insertsPerPage:uint):void
		{
			generateQueueID();

			var images : Vector.<SourceImageProxy> = _collection.images;
			 
			var imageVO:SourceImageProxy;

 			_resourcesCount = images.length;
 
			var data:BookThumbnailData;
			var url:String;

			_pagesFilled = new Dictionary();
			var pageIndex:uint;
			var inPageIndex:uint;

			for(var i:uint = 0; i < _resourcesCount;++i){

				imageVO = images[i];
				
				pageIndex = uint(i/insertsPerPage);
				inPageIndex = uint( i - (pageIndex*insertsPerPage) );
				 
				data = new BookThumbnailData(imageVO, i, pageIndex, inPageIndex);

				_content.push(data);
 
				if(!_pagesFilled["pageIndex"+pageIndex]){
					_pagesFilled["pageIndex"+pageIndex] = {max:0, inserted:0};
				}

				_pagesFilled["pageIndex"+pageIndex].max++;
				 
			}

			var sides:uint = Math.ceil(_resourcesCount/insertsPerPage);

		//	if(sides%2 != 0) sides+=1;  because we start verso left
			pageCount = sides*.5;
		}

		private function prepareGalleryData(insertsPerPage:uint):void
		{
			generateQueueID();
			var images : Vector.<GalleryImageProxy> = _galleryCollection.images;
			 
			var imageVO:GalleryImageProxy;

 			_resourcesCount = images.length;
 
			var data:BookGalleryData;
			var url:String;

			_pagesFilled = new Dictionary();
			var pageIndex:uint;
			var inPageIndex:uint;

			for(var i:uint = 0; i < _resourcesCount;++i){

				imageVO = images[i];
				
				pageIndex = uint(i/insertsPerPage);
				inPageIndex = uint( i - (pageIndex*insertsPerPage) );
				 
				data = new BookGalleryData(imageVO, i, pageIndex, inPageIndex);

				_content.push(data);
 
				if(!_pagesFilled["pageIndex"+pageIndex]){
					_pagesFilled["pageIndex"+pageIndex] = {max:0, inserted:0};
				}

				_pagesFilled["pageIndex"+pageIndex].max++;
				 
			}

			var sides:uint = Math.ceil(_resourcesCount/insertsPerPage);

		//	if(sides%2 != 0) sides+=1;  because we start verso left
			pageCount = sides*.5;
		}
		

		private function loadCurrentThumbnail() : void
		{
			if( _loadQueue && _loadQueue[_loadIndex] && _loadQueue[_loadIndex].queueID == _queueID){
				if(_loadQueue[_loadIndex] is BookThumbnailData){
					var btd:BookThumbnailData = BookThumbnailData(_loadQueue[_loadIndex]);
					SourceImageProxy(btd.imageVO).loadThumbnail(onThumbnailLoadedComplete, onThumbnailLoadedError);
					_loadQueue[_loadIndex].originalFilename = FileSourceImageProxy(btd.imageVO).debugFilename;
				} else {
					var bgd:BookGalleryData = BookGalleryData(_loadQueue[_loadIndex]);
					GalleryImageProxy(bgd.imageVO).loadThumbnail(onThumbnailLoadedComplete, onThumbnailLoadedError);
				}
			}
			//debug
			//var bmd:BitmapData = new BitmapData(300, 200, false, 0xFF0000);
			//composite(bmd, BookData( _loadQueue[_loadIndex]) );
			//continueLoading();
		}

		private function continueLoading() : void
		{
			++_loadIndex;
			if (_loadIndex == _resourcesCount) {
				_loadQueue = null;
				restoreQuality();
			}
			else
				loadCurrentThumbnail();
		}

		private function onThumbnailLoadedComplete(bitmapData : BitmapData):void
		{
			if( _loadQueue && _loadQueue[_loadIndex] && _loadQueue[_loadIndex].queueID == _queueID){
				composite(bitmapData, BookData( _loadQueue[_loadIndex]) );
			}
			continueLoading();
		}

		private function onThumbnailLoadedError() : void
		{
			continueLoading();
		}

		private function generateQueueID():void
		{
			_queueID = "q"+getTimer();
		}

 	}
 } 