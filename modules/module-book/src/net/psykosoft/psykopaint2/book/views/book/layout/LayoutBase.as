package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.views.book.data.PageMaterialsManager;
	import net.psykosoft.psykopaint2.book.views.book.data.BlankBook;
	import net.psykosoft.psykopaint2.book.views.book.layout.CompositeHelper;
	import net.psykosoft.psykopaint2.book.model.SourceImageCollectionVO;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.utils.Dictionary;
 
	import org.osflash.signals.Signal;

	import away3d.materials.TextureMaterial;

 	public class LayoutBase
 	{
 		protected var _layoutType:String;
 		protected var _inserts:Dictionary;

 		//to be removed
	 	//	protected var _thumbsLowResPath:String;
			//protected var _thumbsHighResPath:String;
			//protected var _originalsPath:String;
		//end to be removed

		protected var _collection:SourceImageCollectionVO;

 		private var _pageMaterialsManager:PageMaterialsManager;
 		private var _blankBook:BlankBook;
 		private var _compositeHelper:CompositeHelper;
 		private var _pageCount:uint = 0;
 		private var _currentQuality:String;
 		private var _stage:Stage;
 		
 		public var requiredAssetsReadySignal:Signal;
 		public var requiredCraftSignal:Signal;
 		public var regionSignal:Signal;
 		
     		public function LayoutBase(type:String, stage:Stage)
 		{
 			_layoutType = type;
 			_stage = stage;
 			_inserts = new Dictionary();

 			requiredAssetsReadySignal = new Signal();
 			requiredCraftSignal = new Signal();
 			regionSignal = new Signal();

 			_pageMaterialsManager = new PageMaterialsManager();
 			_blankBook = new BlankBook(this);
 			_pageMaterialsManager.blankBook = _blankBook;
 			_compositeHelper = new CompositeHelper();

 			initDefaultAssets();
 		}
 
 		protected function insert(insertSource:BitmapData, destSource:BitmapData, insertRect:Rectangle, rotation:Number = 0, disposeInsert:Boolean = false, keepRatio:Boolean = false, offsetRotationX:Number = 0, offsetRotationY:Number = 0, offsetX:Number = 0, offsetY:Number = 0):BitmapData
 		{
 			return _compositeHelper.insert(insertSource, destSource, insertRect, rotation, disposeInsert, keepRatio, offsetRotationX, offsetRotationY, offsetX, offsetY);
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
			return _pageMaterialsManager.getPageMaterial(index);
		}

//these will be removed at some point as the collection vo makes them obsolete
//public function get thumbsLowResPath():String
//{
//	return _thumbsLowResPath;
//}
//public function get thumbsHighResPath():String
//{
//	return _thumbsHighResPath;
//}
//public function get originalsPath():String
//{
//	return _originalsPath;
//}
//end to be removed

		public function set collection(collection : SourceImageCollectionVO):void
 		{
 			_collection = collection;
 		}

		public function getPageCount():uint
		{
			return _pageCount;
		}

		public function get pageMaterialsManager():PageMaterialsManager
 		{
 			return _pageMaterialsManager;
 		}

 		public function get blankBook():BlankBook
 		{
 			return _blankBook;
 		}

 		protected function getInsertNormalMap():BitmapData
		{
			return _blankBook.getBasePageInsertNormalmap(false);
		}

		protected function getShadow():BitmapData
		{
			return _blankBook.getBasePictShadowMap(false);
		}

 		public function generateDefaultPageMaterial(index:uint):TextureMaterial
		{
			var bmdPage:BitmapData = _blankBook.getBasePageBitmapData(index);
			var pageMaterial:TextureMaterial  = _pageMaterialsManager.registerPageMaterial(index, bmdPage);

			return pageMaterial;
		}

 		public function dispose():void
 		{
 			_pageMaterialsManager.dispose();
 			_pageMaterialsManager = null;

 			_blankBook.dispose();
 			_blankBook = null;

 			_compositeHelper = null;

 			for(var key:String in _inserts){
 				_inserts[key] = null;
 			}
 			_inserts = null;
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
 		public function dispatchCraftReady(bmd:BitmapData):void
 		{
 			_pageMaterialsManager.generateCraftMaterial(bmd);
 			requiredCraftSignal.dispatch(bmd);
 		}

 		//register regions
 		public function dispatchRegion(rect:Rectangle, object:Object):void
 		{
 			regionSignal.dispatch(rect, object);
 		}

 		//when the enviro elements are all loaded, we can build the enviromethod. no need for a signal, only pageMaterialsManager needs it
 		public function dispatchEnviromapsReady(enviroMaps:Vector.<BitmapData>):void
 		{
 			_pageMaterialsManager.generateEnviroMapMethod(enviroMaps);
 		}

 		//to be overrided per type layout if any dedicated content is required
 		protected function initDefaultAssets():void{}
 
 		/* data parsing/collecting*/
 		//public function parseXml( xml:XML ):void{} to be removed

 		/* loading the collected content once default receivers pages are generated*/
 		public function loadContent():void{throw new Error(this+":loadContent function: must be overrided");}

 		/* loaded image insert/compositing in page*/
 		protected function composite(image:BitmapData, object:Object):void{throw new Error(this+":composite function: must be overrided");}

 		/* loads high res version of an image*/
 		public function loadFullImage( fileName:String, cb:Function ):void {}

 		/* triggers the specific data parsing per layout to be able to generate the receiving pages*/
 		public function loadBookContent(cb:Function):void {}

 	}
 } 