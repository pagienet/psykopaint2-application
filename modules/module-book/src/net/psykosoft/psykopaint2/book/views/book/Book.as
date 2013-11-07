package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;

	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.model.SourceImageCollection;
	import net.psykosoft.psykopaint2.book.views.book.data.PagesManager;
	import net.psykosoft.psykopaint2.book.views.book.data.RegionManager;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.psykopaint2.book.views.book.layout.NativeSamplesLayout;
	import net.psykosoft.psykopaint2.book.views.book.layout.CameraSamplesLayout;
	import net.psykosoft.psykopaint2.book.views.book.layout.GalleryLayout;
	import net.psykosoft.psykopaint2.book.views.models.BookCraft;
	import net.psykosoft.psykopaint2.book.views.models.BookThumbnailData;
	import net.psykosoft.psykopaint2.book.views.models.BookGalleryData;
	import net.psykosoft.psykopaint2.book.views.models.BookData;
	import net.psykosoft.psykopaint2.book.views.models.BookPage;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;

	import org.osflash.signals.Signal;
 
 	public class Book
 	{
 		public var _percent:Number;
 		public var bookReadySignal:Signal;
 		public var imagePickedSignal:Signal;
 		public var galleryImagePickedSignal:Signal;
 		public var bookClearedSignal:Signal;
 		public var collectionRequestedSignal:Signal;

 		private const MAX_REQUESTED_PAGE_SIDES:uint = 5;

 		private var _bookCraft:BookCraft;
 		private var _view:View3D;
 		private var _layout:LayoutBase;
 		private var _dummyCam:Object3D;
 		private var _pagesManager:PagesManager;
 		private var _bookReady:Boolean;
 		private var _pagesCount:uint;
 		private var _stage:Stage;
 		private var _nearestTime:Number;
		private var _step:Number;
		private var _currentPage:uint;
		private var _currentPageSide:uint;
		private var _isRecto:Boolean;
		private var _regionManager:RegionManager;
 		
 		private var _isLoadingImage:Boolean;
 		private var _currentDegrees:Number = 0;
 		private var _firstPage:BookPage;
 		public var _foldRotation:Number = 0;

 		private var _currentDataType:String = "";
 		private var _isBookUpdate:Boolean;
 		private var _pageIndex:uint;
 		private var _previousIndex:int;
 		private var _mayRequestPrevious:Boolean;
 		private var _mayRequestNext:Boolean;
 		private var _requestedForNewCollection:Boolean;
 		private var _currentLayoutInsertCount:uint;
 		private var _vo:Object;
		private var _position : Vector3D;

     	public function Book(view:View3D, stage:Stage)
 		{
 			_view = view;
 			_stage = stage;
 			_percent = _nearestTime = _currentPage = 0;

 			bookReadySignal = new Signal();
 			imagePickedSignal = new Signal();
 			galleryImagePickedSignal = new Signal();
 			bookClearedSignal = new Signal();
 			collectionRequestedSignal = new Signal();
 		}
 
 		public function setSourceImages(collection : SourceImageCollection):void
 		{
 			_vo = collection;

 			_isBookUpdate = (_layout) ? true : false;
 			
			var type : String = collection.source;
			var previousLayout:LayoutBase;
			var insertCount:uint;
			var requiredContentIsReady:Boolean;
 
			if(_layout){
				requiredContentIsReady = true;
				var newPageCount:uint;
				
				switch(type){
	 				case BookImageSource.SAMPLE_IMAGES:
	 				 	insertCount = NativeSamplesLayout.INSERTS_COUNT;
	 					newPageCount = Math.round(collection.images.length/(insertCount * 2) );
	 					break;

	 				case BookImageSource.CAMERAROLL_IMAGES:
	 					insertCount = CameraSamplesLayout.INSERTS_COUNT;
	 					newPageCount = Math.round(collection.images.length/(insertCount * 2) );
	 					break;
	 			}
				//same type, it's a paging case, we need update the numbering
				if(_currentDataType == type){
 
					_pageIndex = uint(Math.floor(collection.index/insertCount) );
					clearCurrentLayout(newPageCount, (_previousIndex > collection.index)? 1 : 0);	
				
 				} else {
 					_pageIndex = 0;
 					clearCurrentLayout(newPageCount, 0);
 					previousLayout = _layout;
 					removeLayoutSignals();
 					_layout.clearData();
 					_layout = null;
					
 				}
			}

			if(!_layout){
 
				switch(type){

	 				case BookImageSource.SAMPLE_IMAGES:
	 					insertCount = NativeSamplesLayout.INSERTS_COUNT;
	 					_layout = new NativeSamplesLayout(_stage, previousLayout);
	 					break;

	 				case BookImageSource.CAMERAROLL_IMAGES:
	 					insertCount = CameraSamplesLayout.INSERTS_COUNT;
	 					_layout = new CameraSamplesLayout(_stage, previousLayout);
	 					break;

	 				default:
	 					insertCount = CameraSamplesLayout.INSERTS_COUNT;
	 					_layout = new NativeSamplesLayout(_stage, previousLayout);

	 			}

	 			_currentLayoutInsertCount = insertCount;

	 			if(previousLayout) previousLayout = null;

	 			setLayoutSignals();
			}

			_currentDataType = type;
			_previousIndex = collection.index;
			
 			_layout.collection = collection;

 			//lock or not the request mechanism during page turn
			_mayRequestPrevious = (collection.index == 0)? false : true;
		 	_mayRequestNext = (collection.index+(insertCount*2) >= collection.numTotalImages)? false : true;

		 	if(requiredContentIsReady) loadBookContent();
 		}


 		public function setGalleryImageCollection(galleryCollection : GalleryImageCollection):void
 		{
 			var previousLayout:LayoutBase;
			var insertCount:uint;
			var requiredContentIsReady:Boolean;
 			_isBookUpdate = (_layout) ? true : false;

 			_vo = galleryCollection;
 		  
 			if(_layout){
				requiredContentIsReady = true;
			 	insertCount = NativeSamplesLayout.INSERTS_COUNT;
				var newPageCount:uint = Math.round(galleryCollection.images.length/(insertCount * 2) );
	 				 
				//same type, it's a paging case, we need update the numbering
				if(_currentDataType == BookImageSource.GALLERY_IMAGES){
					_pageIndex = uint(Math.floor(galleryCollection.index/insertCount) );
					clearCurrentLayout(newPageCount, (_previousIndex > galleryCollection.index)? 1 : 0);

 				} else {
 					_pageIndex = 0;
 					clearCurrentLayout(newPageCount, 0);
 					previousLayout = _layout;
 					removeLayoutSignals();
 					_layout.clearData();
 					_layout = null;
 				}
			}
 			
 			if(!_layout){
				_layout = new GalleryLayout(_stage, previousLayout);
				_currentLayoutInsertCount = insertCount;

	 			if(previousLayout) previousLayout = null;

	 			setLayoutSignals();
			}

			_currentDataType = BookImageSource.GALLERY_IMAGES;
			_previousIndex = galleryCollection.index;

 			_layout.galleryCollection = galleryCollection;

			_mayRequestPrevious = (galleryCollection.index == 0)? false : true;
		 	_mayRequestNext = (galleryCollection.index+(insertCount*2) >= galleryCollection.numTotalPaintings)? false : true;

		 	if(requiredContentIsReady) loadBookContent();
 			 
 		}

 		//paging & clearing of an exiting book
 		public function clearCurrentLayout(newPageCount:uint, collectionTime:uint):void
 		{
 			updatePages(collectionTime);
 			
 			_pagesManager.removePages(newPageCount);
 			_layout.pageMaterialsManager.adjustMaterialCount();
 			
 			_regionManager.clearCurrentRegions(true);
 		}
 		//end paging & clearing

 		public function initOpenAnimation(bitmapdata:BitmapData):void
 		{
 			buildBookCraft();
 			_view.scene.addChild(_bookCraft);
			animateIn();
// 			setTimeout(animateIn, 250);
 		}
 
 		private function setLayoutSignals():void
 		{
 			_layout.requiredCraftSignal.add(initOpenAnimation);
 			_layout.requiredAssetsReadySignal.add(loadBookContent);
 		}
 		private function removeLayoutSignals():void
 		{
 			_layout.requiredCraftSignal.remove(initOpenAnimation);
 			_layout.requiredAssetsReadySignal.remove(loadBookContent);
 		}

 		private function animateIn():void
 		{	
 			_dummyCam = new Object3D();
 			_dummyCam.z = 2000;
			if (_position)
				_bookCraft.offset = _position;
 			_bookCraft.show();

 			lookAtDummy();

 			var duration:Number = 1.5;

			TweenLite.to( _dummyCam, duration, { 	z:1, 
									ease: Strong.easeOut} );
			
			TweenLite.to( _bookCraft, duration, { 		rotationY:0} );
			
			TweenLite.to( _view.camera, duration, {  	z:-50,y: 1300,
									ease: Strong.easeIn,
									onUpdate:lookAtDummy,
									onComplete: onAnimateInComplete } );
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
			var duration:Number = 1;
 
			var destY:Number = -25;
			TweenLite.to( _bookCraft.coverRight, duration, { 	y: destY, x:0, rotationZ:180,
										ease: Strong.easeOut} );

			TweenLite.to( _bookCraft, duration, { 			x: _position.x, ease: Strong.easeOut,
															onUpdate:updateFirstPageRotation,
															onComplete: onAnimateOpenComplete} );
		}

		public function updateFirstPageRotation():void
		{
			if(_firstPage) _firstPage.rotation = Math.abs(_bookCraft.coverRight.rotationZ);
		}
			

		public function onAnimateOpenComplete():void
		{
			if(_firstPage) _firstPage.rotation = 180;
			_bookReady = true;
			_layout.loadContent();
			bookReadySignal.dispatch();
		}
		
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
			 
			TweenLite.to( _view.camera, 0.75, { y: 50, z:-1250, ease: Strong.easeIn} );

			TweenLite.to( _dummyCam, 0.5, { z:-2000, ease: Strong.easeIn, onUpdate:lookAtDummy } );

			TweenLite.to( _bookCraft, 1, { 	x: _position.x + 500, ease: Strong.easeOut, onComplete: onAnimateOutComplete } );
		}
		
		public function onAnimateOutComplete():void
		{
 			_isLoadingImage = false;
			bookClearedSignal.dispatch();
		}

		/* XXXXXXXXXX pages management XXXXXXXXX*/
		public function loadBookContent():void
 		{
 			_layout.loadBookContent(buildBookDefaultContent);
 		}

 		public function buildBookDefaultContent():void
 		{
 			_pagesCount = _layout.getPageCount()+1;
 			var rectoMaterial:TextureMaterial;
 			var versoMaterial:TextureMaterial;
 			var marginRectoMaterial:TextureMaterial;
 			var marginVersoMaterial:TextureMaterial;
 			var i:uint;

 			if(_isBookUpdate){
 				var page:BookPage;

 				_layout.pageMaterialsManager.resetPages(_pageIndex);
 				
 				//in case we miss pages
 				for(i = 0;i<_pagesCount;i++){
 					page = _pagesManager.getPage(i);
 					 
 					if(!page){
 						rectoMaterial = _layout.generateEmptyPageMaterial(_pageIndex);
		 				marginRectoMaterial = _layout.generateNumberedPageMaterial(_pageIndex);
		 				_pageIndex++;

		 				versoMaterial = _layout.generateEmptyPageMaterial(_pageIndex);
		 				marginVersoMaterial = _layout.generateNumberedPageMaterial(_pageIndex);
		 				_pageIndex++;
		 				_pagesManager.addPage(i, _pagesCount, rectoMaterial, marginRectoMaterial, versoMaterial, marginVersoMaterial);
 					}
 				}

 				_layout.loadContent();

 			//new book content	
 			} else {
	 			_pageIndex = 0;

	 			for(i = 0 ;i<_pagesCount;i++){

	 				if(i>0){
		 				rectoMaterial = _layout.generateEmptyPageMaterial(_pageIndex);
		 				marginRectoMaterial = _layout.generateNumberedPageMaterial(_pageIndex);
		 				_pageIndex++;
	 				}

	 				versoMaterial = _layout.generateEmptyPageMaterial(_pageIndex);
	 				marginVersoMaterial = _layout.generateNumberedPageMaterial(_pageIndex);
	 				_pageIndex++;

	 				if(i == 0){
	 					_firstPage = _pagesManager.addPage(0, _pagesCount, null, null, versoMaterial, marginVersoMaterial, true);
 					} else {
 						_pagesManager.addPage(i, _pagesCount, rectoMaterial, marginRectoMaterial, versoMaterial, marginVersoMaterial);
 					}
		 			
	 			}

			}

			_requestedForNewCollection = false;

 			initPagesInteraction();
 		}
 
 		public function buildBookCraft():void
 		{
 			_bookCraft = new BookCraft(_layout.pageMaterialsManager.craftMaterial, _layout.pageMaterialsManager.ringsMaterial);
 			_bookCraft.setClosedState();
 			
 			_pagesManager = new PagesManager(_bookCraft);
 			_regionManager = new RegionManager(_view, _pagesManager);

 			_regionManager.regionZoffset = _bookCraft.z + _position.z;
 			_layout.regionSignal.add(_regionManager.addRegion);
 		}

 		public function get pagesManager():PagesManager
 		{
 			return _pagesManager;
 		}

 		public function get regionManager():RegionManager
 		{
 			return _regionManager;
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
			
			if ( _layout )
			{
				_layout.dispose();
			}
			
 		}
 
		public function initPagesInteraction():void
 		{
 			_step = 1/_pagesCount;
 			_percent = _nearestTime = _step;
 			_currentDegrees = _currentPageSide = 0;

 			updatePages(_percent);
 		}

 		public function get currentDegrees():Number
 		{
 			return _currentDegrees;
 		}

 		public function get pagesCount():uint
 		{
 			return _pagesCount;
 		}

 		public function get currentPageIndex():uint
 		{
 			_isRecto = (_stage.mouseX > (_stage.stageWidth * .5) )? true : false;
 			return  _isRecto? _currentPage : _currentPage-1;
 		}
 
 		public function get currentPageSide():uint
 		{
 			var currentPage:uint = currentPageIndex;
 			if(currentPage == 0){
 				_currentPageSide = 0;
 			} else {
 				_currentPageSide = currentPage * 2;
 				if(_isRecto) _currentPageSide -= 1;
 			}
 
 			return _currentPageSide;
 		}

 		public function get minTime():Number
 		{
 			return _step;
 		}

 		public function updatePages(time:Number):void
 		{	
 			if(_requestedForNewCollection) return;

 			_percent = time;
 			var pageid:uint;
			

			//if(_pagesCount> 1){

				_currentPage = _percent/_step;

				for(var i:uint = 1;i<_pagesCount;++i){
					pageid = i;
	 
					if(pageid < _currentPage){
						pagesManager.rotatePage(i, 180, 0);
 
					} else if(pageid>_currentPage){
						pagesManager.rotatePage(i, 0, 0);

					} else {
						var inPercent:Number = 1 - Math.abs( ( ((_currentPage+1)*_step) - _percent) /_step);
						_nearestTime = (inPercent <.5)? _currentPage*_step : (_currentPage+1)*_step;
						var rotZ:Number = inPercent*180;
						pagesManager.rotatePage(_currentPage, rotZ, _foldRotation );
						_currentDegrees = rotZ;
					}

					if(pageid >= _currentPage+2 || pageid <= _currentPage-2){
						pagesManager.hidePage(pageid);
					} else {
						pagesManager.showPage(pageid);
					}
				}

			//} else {
				
			//	_currentPage = 0;
			//}

			//if(_currentPage>1){
			//		pagesManager.shadeScale(_currentPage-1, rotZ/180);
			//}

			if( _mayRequestPrevious && _percent<_step )  requestPreviousCollection();

			if( _mayRequestNext && _percent > 1 )  requestNextCollection();

			if(_nearestTime>1) _nearestTime = 1;
 		}

 		//trigger the paging requests
 		public function requestPreviousCollection():void
 		{
 			if(!_requestedForNewCollection && !_isLoadingImage ){
 				_requestedForNewCollection = true;
 				collectionRequestedSignal.dispatch(_vo, _previousIndex - (_currentLayoutInsertCount*MAX_REQUESTED_PAGE_SIDES), _previousIndex);
 			}
 		}
 		public function requestNextCollection():void
 		{
 			if(!_requestedForNewCollection && !_isLoadingImage ){
 				_requestedForNewCollection = true;
 				collectionRequestedSignal.dispatch(_vo, _previousIndex, _currentLayoutInsertCount*MAX_REQUESTED_PAGE_SIDES);
 			}
 		}
 	
 		//fold -1/1 range
 		public function rotateFold(fold:Number):void
 		{
 			_foldRotation = fold * 45;
 		}

 		//mouse is loose, goes back to the full openned page and returns the destination time
 		public function snapToNearestTime():Number
 		{
 			if(_percent == _nearestTime || _isLoadingImage || !_bookReady) return _nearestTime;

 			var duration:Number = (Math.abs(_nearestTime -_percent) / _step) * .7;

 			TweenLite.to( this, duration, { 	_percent:_nearestTime, 
 							_foldRotation:0, 
 							ease: Strong.easeIn,
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
 			updatePages(_percent);
 		}

 		// image picking
 		public function hitTestRegions(mouseX:Number, mouseY:Number, pageIndexOnMouseDown:uint, pageSideIndexOnMouseDown:uint):Boolean
 		{
 			if(_isLoadingImage) return false;

 			var data:BookData = _regionManager.hitTestRegions(mouseX, mouseY, pageIndexOnMouseDown, pageSideIndexOnMouseDown);

 			if(data){
 				_isLoadingImage = true;

 				//trace(">>>> loading "+data.originalFilename);

 				if(data is BookThumbnailData){
 					BookThumbnailData(data).imageVO.loadFullSized(onFullSizeImageLoaded, onFullSizeImageError);
 				} else {
 					galleryImagePickedSignal.dispatch(BookGalleryData(data).imageVO);
 				}
				

 				return true;
 			}
 
 			return false;
 		}

		private function onFullSizeImageError() : void
		{
			//throw new Error("Failed to load fullsize image");
			trace(">>>> Failed to load fullsize image");
		}
 
		private function onFullSizeImageLoaded( bmd:BitmapData ):void
		{
			imagePickedSignal.dispatch( bmd );
		}

		public function get position() : Vector3D
		{
			return _bookCraft.offset;
		}

		public function set position(value : Vector3D) : void
		{
			_position = value;
			if (_bookCraft)
				_bookCraft.offset = value;
		}
	}
 } 