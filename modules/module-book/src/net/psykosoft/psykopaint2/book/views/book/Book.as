package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.entities.Mesh;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.materials.TextureMaterial;
  
	import net.psykosoft.psykopaint2.book.views.models.BookCraft;
	import net.psykosoft.psykopaint2.book.views.book.layout.*;
	import net.psykosoft.psykopaint2.book.views.book.data.RegionManager;
	import net.psykosoft.psykopaint2.book.views.book.data.PagesManager;
	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	import org.osflash.signals.Signal;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

 	public class Book
 	{
 		public var _percent:Number;
 		public var bookReadySignal:Signal;
 		public var imagePickedSignal:Signal;
 		public var bookClearedSignal:Signal;

 		private var _bookCraft:BookCraft;
 		private var _view:View3D;
 		private var _layout:LayoutBase;
 		private var _dummyCam:Object3D;
 		private var _pagesManager:PagesManager;
 		private var _xmlLoader:XMLLoader;
 		private var _bookReady:Boolean;
 		private var _pagesCount:uint;
 		private var _stage:Stage;
 		private var _nearestTime:Number;
		private var _step:Number;
		private var _currentPage:uint;
		private var _regionManager:RegionManager;
 		private var _imageLoader:BitmapLoader;
 		private var _isLoadingImage:Boolean;

     		public function Book(view:View3D, stage:Stage)
 		{
 			_view = view;
 			_stage = stage;
 			_percent = _nearestTime = _currentPage = 0;

 			bookReadySignal = new Signal();
 			imagePickedSignal = new Signal();
 			bookClearedSignal = new Signal();
 		}

 		public function set layoutType(type:String):void
 		{
 			switch(type){

 				case LayoutType.SAMPLE_IMAGES:
 					_layout = new NativeSamplesLayout(_stage);
 					break;

 				case LayoutType.CAMERA_IMAGES:
 					//break;

 				case LayoutType.USER_IMAGES:
 					//break;

 				case LayoutType.FRIENDS_IMAGES:
 					//break;

 				case LayoutType.COMMUNITY_IMAGES:
 					//break;

 				default:
 					_layout = new NativeSamplesLayout(_stage);

 			}

 			_layout.requiredCraftSignal.add(initOpenAnimation);
 			_layout.requiredAssetsReadySignal.add(loadBookContent);
 		}

 		/* XXXXXXXXXX scene animations XXXXXXXXX*/

 		public function initOpenAnimation(bitmapdata:BitmapData):void
 		{
 			buildBookCraft();
 			_view.scene.addChild(_bookCraft);

 			setTimeout(animateIn, 1000);
 		}

 		//Animation opening book closed
 		private function animateIn():void
 		{	
 			_bookCraft.visible = true;
 			_dummyCam = new Object3D();
 			_dummyCam.z = 2000;

			TweenLite.to( _view.camera, 2, { 	y: 1300, z:-50,
								ease: Strong.easeOut,
								onUpdate:lookAtDummy,
								onComplete: onAnimateInComplete } );

			TweenLite.to( _dummyCam, 2, { 	z:1, 
								ease: Strong.easeOut} );
		}
		public function lookAtDummy():void
		{
			_view.camera.lookAt(_dummyCam.position);
		}
		public function onAnimateInComplete():void
		{
			onOpenBook();
		}

		public function onOpenBook():void
		{
			TweenLite.to( _bookCraft, 1, { 	x: 0, 
							ease: Strong.easeOut,
							onComplete: onAnimateOpenComplete} );
			var desty:Number = -25;
			TweenLite.to( _bookCraft.coverRight, 1, { y: desty, x:0, rotationZ:2,
								ease: Strong.easeOut} );

			TweenLite.to( _bookCraft.coverLeft, 1, { y: desty, x:0, rotationZ:-2,
								ease: Strong.easeOut} );

			TweenLite.to( _bookCraft.coverCenter, 1, { y: desty, rotationZ:0,
								ease: Strong.easeOut} );
		}

		public function onAnimateOpenComplete():void
		{
			_bookReady = true;
			bookReadySignal.dispatch();
		}
		  
		//Animation closing book
		public function closePages():void
		{
			if(_percent == 0){
				animateOut();
			} else {
				TweenLite.killTweensOf(this);
				TweenLite.to( this, 0.5, { _percent: 0, ease: Strong.easeIn, onUpdate: updateCurrentTime, onComplete: animateOut } );
			}
		}

		public function updateCurrentTime():void
		{
			updatePages(_percent);
		}

		public function animateOut():void
		{
		
			TweenLite.to( _bookCraft.coverRight, 1, { y: -23, x:-13, rotationZ:-180,
								ease: Strong.easeOut} );

			TweenLite.to( _bookCraft.coverLeft, 1, { y: 0, x:0, rotationZ:0,
								ease: Strong.easeOut} );

			TweenLite.to( _bookCraft.coverCenter, 1, { y: 15, rotationZ:90,
								ease: Strong.easeOut} );
			 
			TweenLite.to( _bookCraft, 1, { 	x: 500, 
							ease: Strong.easeOut} );

			TweenLite.to( _view.camera, 0.75, { y: 50, z:-1250, ease: Strong.easeIn,
								onComplete: onAnimateOutComplete } );

			TweenLite.to( _dummyCam, 0.5, { z:-2000, ease: Strong.easeIn, onUpdate:lookAtDummy } );
		}
		
		public function onAnimateOutComplete():void
		{
 			_isLoadingImage = false;
			bookClearedSignal.dispatch();

			dispose();
		}

		/* XXXXXXXXXX pages management XXXXXXXXX*/
		public function loadBookContent():void
 		{
 			_xmlLoader = new XMLLoader();
 			var date:Date = new Date();
			var cacheAnnihilator:String = "?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() );
 
			_xmlLoader.loadAsset( "/book-packaged/samples/samples_thumbs.xml" + cacheAnnihilator, buildBookDefaultContent );
 		}

 		public function buildBookDefaultContent(xml:XML):void
 		{
 			//collecting/parsing the data
 			_layout.parseXml(xml);

 			// data is parsed, we build the default required content
 			_pagesCount = _layout.getPageCount();
 			var rectoMaterial:TextureMaterial;
 			var versoMaterial:TextureMaterial;
 			var pageIndex:uint = 0;

 			for(var i:uint = 0;i<_pagesCount;i++){
 				rectoMaterial = _layout.generateDefaultPageMaterial(pageIndex);
 				pageIndex++;
 				versoMaterial = _layout.generateDefaultPageMaterial(pageIndex);
 				pageIndex++;
 				_pagesManager.addPage(i, _pagesCount, rectoMaterial, versoMaterial);	
 			}

 			initPagesInteraction();

 			_xmlLoader = null;

 			// receiver pages data is ready, we can load the data
 			_layout.loadContent();
 		}
 
 		public function buildBookCraft():void
 		{
 			_bookCraft = new BookCraft(_layout.pageMaterialsManager.craftMaterial);
 			_bookCraft.visible = false;
 			_bookCraft.setClosedState();

 			_pagesManager = new PagesManager(_bookCraft);
 			_regionManager = new RegionManager(_view, _pagesManager);

 			_regionManager.regionZoffset = _bookCraft.z;
 			_layout.regionSignal.add(_regionManager.addRegion);
 		}

 		public function get pagesManager():PagesManager
 		{
 			return _pagesManager;
 		}

 		//if book is ready for mouse browsing
 		public function get ready():Boolean
 		{
 			return _bookReady;
 		}

 		//dispose all resources made since init
 		public function dispose():void
 		{
 			// if the book cleaned itself earlyer
 			if(!_bookCraft) return;

 			_view.scene.removeChild(_bookCraft);
 			if(_dummyCam)_dummyCam = null;
 			_bookCraft.disposeContent();

 			if(_pagesManager){
 				_pagesManager.dispose();
 				_pagesManager = null;
 			}

 			_bookReady = false;

 			if(_regionManager){
 				_regionManager.dispose();
 				_regionManager = null;
 			}
 		}
 
		public function initPagesInteraction():void
 		{
 			_percent = 0;
 			_step = 1/_pagesCount;
 		}

 		public function updatePages(time:Number):void
 		{
 			_percent = time;
 			var pageid:uint;
			_currentPage = _percent/_step;

			for(var i:uint = 0;i<_pagesCount;++i){
				pageid = i;
				if(pageid<_currentPage){
					pagesManager.rotatePage(i, 180 );

				} else if(pageid>_currentPage){
					pagesManager.rotatePage(i, 0);

				} else {
					var inPercent:Number = 1- Math.abs( ( ((_currentPage+1)*_step) - _percent) /_step);
					_nearestTime = (inPercent <.5)? _currentPage*_step : (_currentPage+1)*_step;
					var rotZ:Number = inPercent*180;
					pagesManager.rotatePage(_currentPage, rotZ );
				}
			}

			if(_nearestTime>1) _nearestTime = 1;
 		}

 		//mouse is loose, goes back to the full openned page and returns the destination time
 		public function snapToNearestTime():Number
 		{
 			if(_percent == _nearestTime || _isLoadingImage) return _nearestTime;

 			TweenLite.to( this, .25, { 	_percent:_nearestTime, ease: Strong.easeOut,
							onUpdate:updateToNearestTime,
							onComplete:updateToNearestTime } );
 			return _nearestTime;
 		}

 		public function get isLoadingImage():Boolean
 		{
 			return _isLoadingImage;
 		}

 		public function killSnapTween():void
 		{
 			if(!_isLoadingImage) TweenLite.killTweensOf(this);	
 		}

 		public function updateToNearestTime():void
 		{
 			if(_isLoadingImage) {
 				killSnapTween();
 				return;
 			}

 			updatePages(_percent);
 		}

 		// image picking
 		public function hitTestRegions(mouseX:Number, mouseY:Number):Boolean
 		{
 			var fileName:String = _regionManager.hitTestRegions(mouseX, mouseY, _currentPage);
 			if(fileName != ""){
 				loadFullImage(_layout.originalsPath+fileName);
 				return true;
 			}
 
 			return false;
 		}

 		private function loadFullImage( url:String ):void
 		{
 			_isLoadingImage = true;
			_imageLoader = new BitmapLoader();
			_imageLoader.loadAsset( url, onFullSizeImageLoaded );
		}

		private function onFullSizeImageLoaded( bmd:BitmapData ):void
		{
			imagePickedSignal.dispatch( bmd );
			clearLoader();
		}

		private function clearLoader():void
		{
			_imageLoader.dispose();
			_imageLoader = null;
		}
		
 	}
 } 