package net.psykosoft.psykopaint2.home.views.book
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.filters.DepthOfFieldFilter3D;
	import away3d.lights.LightBase;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;
	import net.psykosoft.psykopaint2.core.models.FileGalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutGalleryView;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutRings;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutSamplesView;

	public class BookView  extends Sprite
	{
		
		private  const SIMULTANEOUS_PAGES:uint= 8;
		public static const TYPE_GALLERY_VIEW:String = "TYPE_GALLERY_VIEW";
		public static const TYPE_FILE_VIEW:String = "TYPE_FILE_VEW";
		private var _viewType:String;
		
		private var _grabThrowController:GrabThrowController;
		private var _view:View3D;
		private var _stage3DProxy:Stage3DProxy;
		private var _light:LightBase;
		private var _container:ObjectContainer3D;
		private var _pages:Vector.<BookPageView>;
		private var _pagesLayouts:Vector.<BookLayoutAbstractView>;
		private var _cover:Mesh;
		
		private var _ringTextureMaterial:TextureMaterial;
		private var _rings:BookLayoutRings;
		
		private var _pageCount:uint=4;
		private var _pageBrowsingSpeed:Number=5;
		private var _galleryImageCollection:GalleryImageCollection;
		private var _sourceImageCollection:SourceImageCollection;
		private var _doublePageIndex:Number=0;
		private var _bookMaterialProxy:BookMaterialsProxy;
		
		private var _maxNumberOfPages:uint;
		
		
		private var _benchmarkStartTime:Date;
		private var _benchmarkFinishTime:Date;
		private var _coverBook:Mesh;
		private var _bloomFilter:DepthOfFieldFilter3D;
		
		public function BookView(view:View3D, light:LightBase, stage3dProxy:Stage3DProxy)
		{
			_view = view;
			_stage3DProxy = stage3dProxy;
			_light = light; 
			_container = new ObjectContainer3D();
			_pages = new Vector.<BookPageView>();
			
			_view.scene.addChild(_container);
			
			//ROTATE CONTAINER TO FACE THE CAMERA
			_container.rotationX = 90;
			_container.rotationY = 0;
			_container.rotationZ = 180;
			_container.x=-270;
			_container.z=200;
			_container.mouseEnabled = true;
			
			init();
			
			
		//	_bloomFilter = new DepthOfFieldFilter3D( 10,10,100 );
			//_view.filters3d = [ _bloomFilter ];
			

			//var _bloomFilter:MotionBlurFilter3D = new MotionBlurFilter3D(  );
			//_view.filters3d = [ _bloomFilter ];
			
			
			
			
	
		}
		
		
		public function dispose():void
		{
			BookMaterialsProxy.dispose();
			_ringTextureMaterial = null;
			stopGrabController();
		}
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PUBLIC FUNCTIONS //////////////////////
		/////////////////////////////////////////////////////////////////
		
		
		public function setSourceImages(sourceImageCollection : SourceImageCollection):void
		{
			// TYPE FILE
			_viewType = TYPE_FILE_VIEW;
			
			//ASSIGN DATA
			_sourceImageCollection = sourceImageCollection;
			
			//CLEAR PREVIOUS LAYOUT
			removePages();
			
			//NUMBER OF PAGES DEPEND ON THE NUMBER OF IMAGES SENT IN AND NEEDS TO BE PAIR
			//var numberOfPages:uint = Math.ceil((_sourceImageCollection.images.length/BookLayoutSamplesView.LENGTH)/2)*2;
			//NUMBER OF PAGES DEPEND ON THE NUMBER OF IMAGES SENT IN AND NEEDS TO BE PAIR...
			var numberOfPages:uint = Math.ceil((_sourceImageCollection.images.length/BookLayoutSamplesView.LENGTH)/2)*2;
			//... AND IT CAN'T BE HIGHER THAN 
			numberOfPages = Math.min(SIMULTANEOUS_PAGES,numberOfPages);
			
			//DEFINE MAX NUMBER OF PAGES IN THE BOOK
			_maxNumberOfPages = (_sourceImageCollection.numTotalImages/BookLayoutSamplesView.LENGTH);
			
			
			//CREATE PAGES
			createPages(numberOfPages);
			
			
			//CREATE SAMPLES LAYOUTS VIEWS
			for (var i:int = 0; i < numberOfPages; i++) 
			{
				var currentPageCollection:SourceImageCollection = SourceImageCollection.getSubCollection(i*BookLayoutSamplesView.LENGTH,BookLayoutSamplesView.LENGTH,_sourceImageCollection);
				var currentBookPageView:BookPageView = _pages[i];
				var newBookLayoutSamplesView:BookLayoutSamplesView = new BookLayoutSamplesView();
				
				newBookLayoutSamplesView.setData(currentPageCollection);
				currentBookPageView.addLayout(newBookLayoutSamplesView);
			}
			
		}
		
		public function setGalleryImageCollection(galleryImageCollection : GalleryImageCollection):void
		{
			//TYPE GALLERY
			_viewType = TYPE_GALLERY_VIEW;
			
			// ASSIGN DATA
			_galleryImageCollection = galleryImageCollection; 
			
			//CLEAR PREVIOUS LAYOUT
			removePages();
			
			//NUMBER OF PAGES DEPEND ON THE NUMBER OF IMAGES SENT IN AND NEEDS TO BE PAIR...
			var numberOfPages:uint = Math.ceil((_galleryImageCollection.images.length/BookLayoutGalleryView.LENGTH)/2)*2;
			//... AND IT CAN'T BE HIGHER THAN 
			numberOfPages = Math.min(SIMULTANEOUS_PAGES,numberOfPages);
			
			//MAX NUMBER OF PAGES IS 
			_maxNumberOfPages = (_galleryImageCollection.numTotalPaintings/BookLayoutGalleryView.LENGTH);
			
			//CREATE PAGES
			createPages(numberOfPages);
			
			
			//CREATE GALLERY THUMBS  VIEWS
			for (var i:int = 0; i < numberOfPages; i++) 
			{
				//CREATE A SUB COLLECTION WITH THE AMOUNT OF IMAGES NEEDED
				var currentSubCollection:GalleryImageCollection = GalleryImageCollection.getSubCollection(i*BookLayoutGalleryView.LENGTH,BookLayoutGalleryView.LENGTH,_galleryImageCollection);
				var currentBookPageView:BookPageView = _pages[i];
				var newBookLayoutGalleryView:BookLayoutGalleryView = new BookLayoutGalleryView();
				
				//ADD THE LAYOUT WITH THE LIST OF IMAGES TO THE PAGE WHICH IS A SUBCOLLECTION
				newBookLayoutGalleryView.setData(currentSubCollection);
				currentBookPageView.addLayout(newBookLayoutGalleryView);
			}
			
		}
		
		
		
		public function updateImageCollection():void{
			trace("updateImageCollection");
			//WE TAKE THE PREVIOUS INVISIBLE PAGES AND APPLY THE NEXT ASSETS TO THOSE
			
			
			//FILL LAYOUTS WITH NEW DATA 
			//WE FILL THE 2 PREVIOUS PAGES TOO
			for (var i:int = Math.floor(_doublePageIndex*2); i < Math.floor(_doublePageIndex*2)+SIMULTANEOUS_PAGES; i++) 
			{
				var iModulo:int= i%SIMULTANEOUS_PAGES;
				var currentBookPageView:BookPageView = _pages[iModulo];
				
				var firstPageToLoad:int = (Math.floor(_doublePageIndex)*2+i)-1;
				
				
				if(_viewType==  TYPE_GALLERY_VIEW){
					var currentGalleryImageCollection:GalleryImageCollection = GalleryImageCollection.getSubCollection(i*BookLayoutGalleryView.LENGTH,BookLayoutGalleryView.LENGTH,_galleryImageCollection);
					BookLayoutGalleryView(currentBookPageView.getLayout()).setData(currentGalleryImageCollection);
				}else if(_viewType == TYPE_FILE_VIEW) {
					var currentSourcePageCollection:SourceImageCollection = SourceImageCollection.getSubCollection(i*BookLayoutSamplesView.LENGTH,BookLayoutSamplesView.LENGTH,_sourceImageCollection);
					BookLayoutSamplesView(currentBookPageView.getLayout()).setData(currentSourcePageCollection);
				}
				
				
			}
			
		}
		
		
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PRIVATE FUNCTIONS /////////////////////
		/////////////////////////////////////////////////////////////////
		private function init():void
		{
			
			//CREATE BACKGROUND COVER
			var coverGeometry:Geometry = new PlaneGeometry(373,214);
			var coverMaterial:ColorMaterial = new ColorMaterial(0xAAAAAA);
			_coverBook = new Mesh(coverGeometry,coverMaterial);
			_container.addChild(_coverBook);
			_coverBook.y=-10;
			
			_coverBook.mouseEnabled=true;
			
			
			//LOAD PAGES ASSETS
			BookMaterialsProxy.launch(function ():void
			{
				//LOAD DATAS AS SOON AS THE BOOK ASSETS ARE READY
				//loadDummySourceImageCollection();
				
				
				
				//ADD RING
				_ringTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.RING);
				_rings = new BookLayoutRings(_ringTextureMaterial);
				_container.addChild(_rings);
				_rings.scaleZ=_rings.scaleX=_rings.scaleY=0.191;
				
				
				loadDummyGalleryImageCollection();
				//loadDummySourceImageCollection();
			
				//_bloomFilter.range=500;
				//_bloomFilter.focusDistance = 100;
				//_bloomFilter.focusDistance = 120;
				
				
				//TESTING BOOK CREATED ON CLICK
				_coverBook.addEventListener(MouseEvent3D.CLICK,onClickBook);
			});
			
			
			
		
			//EVENTS
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);	
			function onAdded(event:Event):void
			{
				
				startGrabController();
				removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			}		
			
		}	
		
		 
		private function onClickBook(event:Event):void
		{
			//_coverBook.removeEventListener(MouseEvent3D.CLICK,onClickBook);
			//BENCHMARK HOW LONG IT TAKES TO PARSE FILES
			_benchmarkStartTime = new Date();
			//loadDummySourceImageCollection();
			//loadDummyGalleryImageCollection();
			trace("CLICK BOOK");
			//TweenLite.to(this,1,{ease:Expo.easeInOut ,doublePageIndex:(doublePageIndex+1), onUpdate:function ():void{trace("doublePageIndex + "+doublePageIndex)}});
			
			//loadNextGalleryImageCollection();
			
		}		 
		
		
		private function removePages():void{
			//CLEAR PREVIOUS LAYOUT
			for (var i:int = 0; i < _pages.length; i++) 
			{
				_pages[i].dispose();
				//_pages[i].parent.removeChild(_pages[i]);
				_pages[i] = null;
			}
			_pages = new Vector.<BookPageView>();
		}
		
		
		
		private function createPages(pageCount:uint=2):void
		{
						
			//CREATE PAGES
			_pages = new Vector.<BookPageView>();
			var newPageView:BookPageView;
			
			for (var i:int = 0; i < pageCount; i++) 
			{
				newPageView = new BookPageView();
				_pages.push(newPageView);
				if(i%2==0){newPageView.flip();}
				_container.addChild(newPageView);
				newPageView.setPageNumber(i);
			}
			
			//ALWAYS UPDATE
			updatePages();	
		}
		
		
		private function updatePages():void{
						
			var firstPageIndex:int = Math.floor(_doublePageIndex)*2%SIMULTANEOUS_PAGES;
			
			//trace("updatePages _doublePageIndex = "+_doublePageIndex+"  firstPageIndex="+firstPageIndex);
			for (var p:int = 0; p < _pages.length; p++) 
			{
				var pageIndex:uint=Math.floor(_doublePageIndex*2)+p;
				//i IS THE pageIndex MODULO SIMULTANEOUS_PAGES
				//THE LAST ONES GOES BACK TO THE BEGINNING OF THE PILE, ETC...
				var i:int =(pageIndex)%SIMULTANEOUS_PAGES;
				
				var page:BookPageView = _pages[i];
				
				//SET PAGE NUMBER
				page.setPageNumber(pageIndex);
				
				
				
				//var pageIndexProgress:Number = (_doublePageIndex*2+1-Math.ceil(i/2));
				var nextDoublePageIndex:int= Math.ceil(i/2);
				var pageIndexProgress:Number = (_doublePageIndex-nextDoublePageIndex+2)%(SIMULTANEOUS_PAGES/2)-1;
				
				//EASING IS THE VALUE FROM 0 TO 1 TO EASE THE TRANSITION
				var easing:Number = pageIndexProgress-Math.floor(pageIndexProgress);
								
				if(i%2==0){
					//PAIR = LEFT PAGES 0,2,4,6
					
					page.rotationZ = 180*(Math.floor(pageIndexProgress)+Cubic.easeInOut(easing,0,1,1));
					page.rotationZ = -180+Math.min(page.rotationZ,180);
					page.rotationZ = Math.max(page.rotationZ,-180);
					

				}else {
					//IMPAIR = RIGHT PAGES 1,3,5
					
					page.rotationZ = 180*(Math.floor(pageIndexProgress)+Cubic.easeInOut(easing,0,1,1) )%360;
					page.rotationZ = Math.min(page.rotationZ,180);
					page.rotationZ = Math.max(page.rotationZ,0);

				}
				
				//trace("PAGE "+i+" page = "+page.rotationZ.toFixed(0)+" pageIndex "+pageIndex);
				
		//		trace("UPDATE PAGE "+i+" page = "+page.rotationZ +" easing = "+easing );

				
				//UPDATE VISIBILITY
				// IF WE'RE ON A PRECISE INDEX WE JUST SHOW 2 PAGES
				//
				var firstVisiblePage:int;
				var isRoundPage:Number = (pageIndexProgress) - (int(pageIndexProgress));
				//trace("easing = "+easing )
				//
				if(isRoundPage==0){
					//trace("SHOW 2 PAGES ONLY");
					firstVisiblePage = (_doublePageIndex*2)%(SIMULTANEOUS_PAGES);
					page.visible = false;
					//SHOW 2 PAGES ONLY
					if(i%SIMULTANEOUS_PAGES == firstVisiblePage%SIMULTANEOUS_PAGES ){page.visible = true;}
					if(i%SIMULTANEOUS_PAGES == (firstVisiblePage+1)%SIMULTANEOUS_PAGES){page.visible = true;}
					
					
				}else {
					//OTHERWISE WE SHOW THE 4 PAGES CONCERNED
					firstVisiblePage = (Math.floor(_doublePageIndex)*2)%SIMULTANEOUS_PAGES;
					
					page.visible = false;
					// 1ST PAGE
					if(i%SIMULTANEOUS_PAGES == firstVisiblePage%SIMULTANEOUS_PAGES)
					{
						page.visible = true;
						
						if(easing>0.75 ){
							page.visible= false;
						}
						
					}
					
					// 2ND PAGE
					if(i%SIMULTANEOUS_PAGES == (firstVisiblePage+1)%SIMULTANEOUS_PAGES){
						page.visible = true;
						
						
						if(easing>0.5 ){
							page.visible= false;
						}
					}
					
					// 3RD PAGE
					if(i%SIMULTANEOUS_PAGES == (firstVisiblePage+2)%SIMULTANEOUS_PAGES){
						page.visible = true;
						
						if(easing<0.5 ){
							page.visible= false;
						}
					}
					
					// 4TH PAGE
					if(i%SIMULTANEOUS_PAGES == (firstVisiblePage+3)%SIMULTANEOUS_PAGES)
					{
							
						page.visible = true;
					
						//TO AVOID OVERLAPS WITH PAGES BEHIND WE GIVE A BIT OF BIAS TO SHOWING THE PAGES BEHIND
						//SINCE THE FLIP OF THE PAGES HIDE THE PAGES BEHIND AT THE BEGINNING OF THE MOVEMENT ANYWAY
//						
						if(easing<0.25 ){
							page.visible= false;
						}
						//trace(" i = "+i +" is "+page.visible);
					}
					
				}
				
			
			}
			
			
			
			
			//FIRST PAGE NEVER MOVE
			
			
			// LAST PAGE TOO
			//TODO
			
		
			
		}
		
		
		private function startGrabController():void{
			if(!_grabThrowController)
			{
				_grabThrowController = new GrabThrowController(this.stage);
				_grabThrowController.start();
				_grabThrowController.addEventListener(GrabThrowEvent.DRAG_STARTED,onDragStarted);
				_grabThrowController.addEventListener(GrabThrowEvent.DRAG_UPDATE,onDragUpdate);
				_grabThrowController.addEventListener(GrabThrowEvent.RELEASE,onRelease);
			}
		}
		
		
		private function stopGrabController():void{
			_grabThrowController.stop();
			_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_STARTED,onDragStarted);
			_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_UPDATE,onDragUpdate);
			_grabThrowController.removeEventListener(GrabThrowEvent.RELEASE,onRelease);
			_grabThrowController = null;
		}
		
		
		
		public function set doublePageIndex(value:Number):void{
			
			//IF WE ARE CHANGING PAGE INDEX FROM 1 TO 2 WE LOAD NEXT SET OF PAGES
			if(Math.floor(_doublePageIndex)*2 %SIMULTANEOUS_PAGES != Math.floor(value)*2 %SIMULTANEOUS_PAGES){
				updateImageCollection();
			}
			
			//VALUE CAN'T BE NEGATIVE
			value = Math.max(value,0);
			
			//NOT ANYMORE// USE NUMBER OF PAGES AS MAX
			//_doublePageIndex = Math.min(Math.max(value,0),(_pages.length/2-1));
			
			
			
			//NOW USING NUMBER OF PAGES ACCORDING TO TOTAL NUMBER OF IMAGES FROM SOURCE COLLECTION
			_doublePageIndex = value;
			//MAKE SURE THE DOUBLE PAGE INDEX CAN'T BE HIGHER THAN  MAXIMUM NUMBER OF PAGES 
			_doublePageIndex = Math.min(_doublePageIndex,Math.ceil(_maxNumberOfPages/2) -1);
			
			
			
			
			updatePages();
		}
		
		public function get doublePageIndex():Number{
			return _doublePageIndex;
		}
	
		
	
		
		/////////////////////////////////////////////////////////////////
		/////////////////////////   EVENTS	/////////////////////////////
		/////////////////////////////////////////////////////////////////
		 

		protected function onDragStarted(event:GrabThrowEvent):void
		{
			//NOTHING
		}
		
		protected function onDragUpdate(event:GrabThrowEvent):void
		{
			
			//!!PageIndex is a SETTER
			doublePageIndex -= _pageBrowsingSpeed*event.velocityX/1500;
			
		
		}	
		
		protected function onRelease(event:GrabThrowEvent):void
		{
			
			//ON RELEASE SNAP TO THE CURRENTLY OPENED PAGE
			TweenLite.to(this,0.5,{doublePageIndex:Math.round(doublePageIndex),ease:Sine.easeOut});
			
		}
		
		
		///////////////////////////////////
		///////// TESTING FUNCTIONS //////
		///////////////////////////////////
		//USED FOR TESTING PURPOSES ONLY
		
		private function loadDummySourceImageCollection():void
		{
			
			//TEST DUMMY SOURCEIMAGECOLLECTION
			var testSourceImageCollection:SourceImageCollection = new SourceImageCollection();
			testSourceImageCollection.numTotalImages = 42;
			
			var fileSourceImageProxys :Vector.<SourceImageProxy>= new Vector.<SourceImageProxy>();
			for (var i:int = 0; i < testSourceImageCollection.numTotalImages; i++) 
			{
				var newImage:FileSourceImageProxy = new FileSourceImageProxy();
				newImage.id=i;
				newImage.lowResThumbnailFilename = "book-packaged/samples/thumbs_lowres/"+i+".jpg";
				newImage.highResThumbnailFilename = "book-packaged/samples/thumbs/"+i+".jpg";
				fileSourceImageProxys.push(newImage);
			}
			testSourceImageCollection.images = fileSourceImageProxys;
			
			setSourceImages(testSourceImageCollection);
			
			
			//_benchmarkFinishTime = new Date();
			//var benchmarkLoadingAssets:uint = _benchmarkFinishTime.time - _benchmarkStartTime.time;
			//trace("BENCHMARK BOOK LOADING ASSETS = "+benchmarkLoadingAssets); 
		}
		
		
		
		private function loadDummyGalleryImageCollection():void
		{
			trace("loadDummyGalleryImageCollection");
			////////////////////////////
			///////// DUMMY DATA  //////
			////////////////////////////
			//TEST DUMMY GALLERYIMAGECOLLECTION
			var testGalleryImageCollection:GalleryImageCollection = new GalleryImageCollection();
			testGalleryImageCollection.numTotalPaintings= 200 /* CHANGE NUMBER OF TEST SAMPLES HERE */;
			
			
			var fileGalleryImageProxys :Vector.<GalleryImageProxy>= new Vector.<GalleryImageProxy>();
			for (var i:int = 0; i < testGalleryImageCollection.numTotalPaintings; i++) 
			{
				var newImage:FileGalleryImageProxy = new FileGalleryImageProxy();
				newImage.id=i;
				var startIndex:int = 1035800;
				//ALL VALUES
				newImage.sourceThumbnailURL = "http://images.psykopaint.com/gallery/2014/03/thumbnail200/"+(startIndex+i)+".jpg";
				newImage.thumbnailFilename = "http://images.psykopaint.com/gallery/2014/03/thumbnail200/"+(startIndex+i)+".jpg";
				newImage.isFavorited = (Math.random()>0.5)?true:false;
				newImage.numComments = int(Math.random()*100);
				newImage.numLikes = int(Math.random()*1000);
				newImage.userThumbnailURL = "";
				//trace("loadDummyGalleryImageCollection "+i);
				
				fileGalleryImageProxys.push(newImage);
			}
			testGalleryImageCollection.images = fileGalleryImageProxys;
			
			setGalleryImageCollection(testGalleryImageCollection);
			
			//REMOVE WHEN NOT NEEDED ANYMORE
			//_benchmarkFinishTime = new Date();
			//var benchmarkLoadingAssets:uint = _benchmarkFinishTime.time - _benchmarkStartTime.time;
			// trace("BENCHMARK BOOK LOADING ASSETS = "+benchmarkLoadingAssets); 
		}
		
		
		
		
		public function get container():ObjectContainer3D
		{
			return _container;
		}
		
		
	}
}