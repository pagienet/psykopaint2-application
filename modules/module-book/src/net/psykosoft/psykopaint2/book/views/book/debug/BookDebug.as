package net.psykosoft.psykopaint2.book.views.book.debug
{
	import net.psykosoft.psykopaint2.book.views.book.layout.Region;
	import net.psykosoft.psykopaint2.book.views.book.data.RegionManager;
	import net.psykosoft.psykopaint2.book.views.models.BookData;
	import net.psykosoft.psykopaint2.book.views.book.debug.DEBUG;
	 
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.utils.setTimeout;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import away3d.containers.View3D;
	 
	public class BookDebug extends Sprite
 	{
 		private const _extremeX:Number = 970;
 		private const _extremeZ:Number = 512;
 
 		private var _regionManager:RegionManager;
 		private var _view:View3D;

 		private var _pageBounds:Sprite;
 		private var _regions:Sprite;
 		private var _pickedImage:Sprite;

 		private var _rectoRect:Rectangle;
 		private var _versoRect:Rectangle;

 		private var _lastRegion:Region;
 
     		public function BookDebug(view:View3D, regionManager:RegionManager)
 		{
 			super();

 			_regionManager = regionManager;
 			_view = view;
 			
 			this.mouseEnabled = false;
 			drawPageBounds();
 		}

 		public function drawPageBounds():void
 		{
 			var _pageBounds:Sprite = new Sprite();
 			addChild(_pageBounds);
 			_pageBounds.mouseEnabled = false;

 			var bookcraftZ:Number = 100;

 			var pt1:Vector3D = _view.project( new Vector3D(-_extremeX, 0, _extremeZ + bookcraftZ ) );
 			var pt2:Vector3D = _view.project( new Vector3D(_extremeX, 0, -_extremeZ + bookcraftZ ) );

 			var gr:Graphics = _pageBounds.graphics;

			gr.lineStyle(1, 0x00FF00);
			gr.moveTo(pt1.x,pt1.y);
			gr.lineTo(pt2.x,pt1.y);
			gr.lineTo(pt2.x,pt2.y);
			gr.lineTo(pt1.x,pt2.y);
			gr.lineTo(pt1.x,pt1.y);

			var middleX:int = pt1.x + ((pt2.x-pt1.x)*.5);

			gr.moveTo(middleX, pt1.y);
			gr.lineTo(middleX, pt2.y);
			gr.endFill();

			_rectoRect = new Rectangle(middleX, pt1.y, middleX-pt1.x, pt1.y-pt2.y);
 			_versoRect = new Rectangle(pt1.x, pt1.y, middleX-pt1.x, pt1.y-pt2.y);

			_regions = new Sprite();
			_regions.mouseEnabled = false;
 			addChild(_regions);

 			DEBUG.init(this, 2,2, 300, 300);
 		}

 		private function drawRegion(region:Region, isRecto:Boolean):void
 		{
 			var nx:Number = region.UVRect.x * 512;
 		 	var ny:Number = region.UVRect.y * 512;

 		 	var nw:Number = region.UVRect.width * 512;
 		 	var nh:Number = region.UVRect.height * 512;

 			if(_lastRegion != region){
				 
 				_lastRegion = region;
 				
	 			var gr:Graphics = _regions.graphics;
	 			gr.clear();
	 			gr.beginFill(0xFFD715, .4);

	 		 	if(isRecto){
	 		 		nx += _rectoRect.x;
	 		 		ny += _rectoRect.y;
	 		 	} else {
	 		 		nx += _versoRect.x;
	 		 		ny += _versoRect.y;
	 		 	}
	 
	 			gr.drawRect(nx, ny, nw, nh);
	 			 
	 			gr.endFill();

	 			DEBUG.updateFieldPosition(nx+2, ny+2);
 			}
 		}
 
 		public function debugMouse(x:int, y:int, currPageIndex:uint, currPageSideIndex:uint):void
 		{
 		 	var bookData:BookData = _regionManager.hitTestRegions(x, y, currPageIndex, currPageSideIndex);

 			DEBUG.TRACE("x: "+x+", y: "+y+", PageIndex: "+currPageIndex+", PageSideIndex: "+currPageSideIndex, true);
 			DEBUG.TRACE("found a page? :"+ ((_regionManager.debugPage != null)? true : false) );

 			if(bookData){

 				var region:Region = _regionManager.debugRegion;

 				DEBUG.TRACE("inPageIndex: "+bookData.inPageIndex);
 				//doesn't handle the gallery urls
 				if(region.data.originalFilename && region.data.originalFilename != ""){
 					DEBUG.TRACE("hit: "+region.data.originalFilename);
 				}
 				 
 				drawRegion(region, currPageSideIndex %2 == 0 ? false : true);
 				
 			} else {

 				if(_lastRegion){
 					_lastRegion = null;
 					var gr:Graphics = _regions.graphics;
	 				gr.clear();
	 				DEBUG.updateFieldPosition(_versoRect.x+2, _versoRect.y+2);	
 				}
 				
 			}
 		}

 		public function debugPickedURL():void
 		{
 		 	 _pickedImage = new Sprite();
 		 	 addChild(_pickedImage);

 		 	var region:Region = _regionManager.debugRegion;

			DEBUG.TRACE(">>>> atempt load image");
			
			var filename:String = "NOTHING TO LOAD";
			if(region && region.data.originalFilename && region.data.originalFilename != ""){
				filename = region.data.originalFilename;
			} 
 
 		 	var gr:Graphics = _pickedImage.graphics;
 			 
 			gr.beginFill(0x0000FF, 1);
 			
 			var nx:Number = _rectoRect.x+(_versoRect.x -_rectoRect.x);
 			var ny:Number = _rectoRect.y+(_rectoRect.height * 5);
 			gr.drawRect(nx, ny, _rectoRect.width, 100);
 			gr.endFill();

 		 	var urlLog:TextField = new TextField();
			urlLog.width =_rectoRect.width;
			urlLog.height = 100;
			urlLog.x = nx;
			urlLog.y = ny+5;
			 

			var tf:TextFormat = new TextFormat();
			tf.font = "Verdana";
			tf.color = 0x333333;
			tf.align = "center";
			tf.bold = true;
			tf.size = 20;
			 
			urlLog.defaultTextFormat = tf;
			urlLog.mouseEnabled = false;

			urlLog.text = filename;

			_pickedImage.addChild(urlLog);

			setTimeout(clearPickedImage, 2500);
 		}

 		public function clearPickedImage():void
 		{
 			if(_pickedImage) removeChild(_pickedImage);
 			_pickedImage = null;
 		}

 		public function dispose():void
 		{
			removeChild(_pageBounds);
			removeChild(_regions);
			if(_pickedImage) removeChild(_pickedImage);
 			 
 		}

 	}
 } 