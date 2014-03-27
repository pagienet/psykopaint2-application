package net.psykosoft.psykopaint2.home.views.book
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.LightBase;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutGalleryView;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutRings;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutSamplesView;
	
	import org.osflash.signals.Signal;

	public class BookView extends Sprite
	{
		public var switchedToNormalMode:Signal = new Signal();
		public var switchedToHiddenMode:Signal = new Signal();

		private static var  SIMULTANEOUS_PAGES:uint = 10;
		public static const TYPE_GALLERY_VIEW:String = "TYPE_GALLERY_VIEW";
		public static const TYPE_FILE_VIEW:String = "TYPE_FILE_VEW";

		private static const COVER_WIDTH:Number=373;
		private static const COVER_HEIGHT:Number=214;

		public var galleryImageSelected:Signal = new Signal(GalleryImageProxy);
		public var sourceImageSelected:Signal = new Signal(SourceImageProxy);

		private var _viewType:String;

		private var _grabThrowController:GrabThrowController;
		private var _view:View3D;
		private var _stage3DProxy:Stage3DProxy;
		private var _light:LightBase;
		private var _container:ObjectContainer3D;
		private var _pages:Vector.<BookPageView>;

		private var _ringTextureMaterial:TextureMaterial;
		private var _rings:BookLayoutRings;
		
		private var _pageBrowsingSpeed:Number=5;
		private var _galleryImageCollection:GalleryImageCollection;
		private var _sourceImageCollection:SourceImageCollection;
		private var _doublePageIndex:Number=0;

		private var _maxNumberOfPages:uint;

		private var _coverBook:Mesh;
		private var _showing:Boolean;

		private var _swipeMode : int;
		private var _hidingEnabled : Boolean;

		private static const UNDECIDED : int = 0;
		private static const PAGE_SWIPE : int = 1;
		private static const HIDE_SWIPE : int = 2;
		private var _bookEnabled:Boolean;
		private var _startMouseX:Number;
		private var _startMouseY:Number;
		private var _hiddenOffset : Number = -185;
		private var _basePosition:Vector3D = new Vector3D();
		private var _hiddenRatio:Number = 0.0;
		private var _consideredHidden:Boolean;

		public function BookView(view:View3D, light:LightBase, stage3dProxy:Stage3DProxy)
		{
			_view = view;
			_view.camera.addEventListener(Object3DEvent.POSITION_CHANGED, onCameraPositionChanged);
			_stage3DProxy = stage3dProxy;
			_light = light;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onCameraPositionChanged(event:Object3DEvent):void
		{
			updateInteractionRect();
		}

		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_grabThrowController = new GrabThrowController(stage);
		}

		public function get bookEnabled():Boolean
		{
			return _bookEnabled;
		}

		public function set bookEnabled(value:Boolean):void
		{
			_bookEnabled = value;
			_view.mouseEnabled = value;
		}

		public function get hidingEnabled():Boolean
		{
			return _hidingEnabled;
		}

		public function set hidingEnabled(value:Boolean):void
		{
			_hidingEnabled = value;
			updateInteractionRect();
		}

		public function init():void
		{
			_container = new ObjectContainer3D();
			//ROTATE CONTAINER TO FACE THE CAMERA
			_container.rotationX = 90;
			_container.rotationY = 0;
			_container.rotationZ = 180;
			_container.z=200;
			_container.mouseEnabled = true;

			//CREATE BACKGROUND COVER
			var coverGeometry:Geometry = new PlaneGeometry(COVER_WIDTH, COVER_HEIGHT);
			var coverMaterial:ColorMaterial = new ColorMaterial(0xAAAAAA);
			_coverBook = new Mesh(coverGeometry,coverMaterial);
			_container.addChild(_coverBook);
			_coverBook.y = -10;
			_coverBook.mouseEnabled=true;

			_ringTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.RING);
			_rings = new BookLayoutRings(_ringTextureMaterial);
			_container.addChild(_rings);
			_rings.scaleZ=_rings.scaleX=_rings.scaleY=0.191;

			_pages = new Vector.<BookPageView>();
		}


		public function show():void
		{
			// TODO: animations?
			if (!_showing) {
				_showing = true;
				_view.scene.addChild(_container);
				startGrabController();
			}
		}

		public function remove():void{
			if (_showing) {
				_view.scene.removeChild(_container);
				stopGrabController();
				_showing = false;
			}
		}
		
		public function dispose():void
		{
			removePages();

			_ringTextureMaterial = null;
			stopGrabController();

			_container.dispose();
			_coverBook.geometry.dispose();
			_coverBook.material.dispose();
			_coverBook.dispose();
			_container = null;
			_coverBook = null;
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
				newBookLayoutSamplesView.imageSelected.add(sourceImageSelected.dispatch);	// simply forward the signal
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
				var newBookLayoutGalleryView:BookLayoutGalleryView = new BookLayoutGalleryView(_view.stage3DProxy);
				
				//ADD THE LAYOUT WITH THE LIST OF IMAGES TO THE PAGE WHICH IS A SUBCOLLECTION
				newBookLayoutGalleryView.setData(currentSubCollection);
				newBookLayoutGalleryView.imageSelected.add(galleryImageSelected.dispatch);	// simply forward the signal
				currentBookPageView.addLayout(newBookLayoutGalleryView);
			}
			
		}

		public function updateImageCollection():void
		{
			
			//WE TAKE THE PREVIOUS INVISIBLE PAGES AND APPLY THE NEXT ASSETS TO THOSE			
			//FILL LAYOUTS WITH NEW DATA 
			//WE FILL THE 2 PREVIOUS PAGES TOO
			for (var i:int = Math.floor(_doublePageIndex*2)-2; i < Math.floor(_doublePageIndex*2)+PAGES_CREATED-2; i++) 
			{
				
				if(i<0)i=PAGES_CREATED+i;
				var iModulo:int= i%PAGES_CREATED;
				var currentBookPageView:BookPageView = _pages[iModulo];
				var firstPageToLoad:int = Math.max((Math.floor(_doublePageIndex)*2+i)-1,0);
				
				if(_viewType==  TYPE_GALLERY_VIEW){
					var currentGalleryImageCollection:GalleryImageCollection = GalleryImageCollection.getSubCollection(i*BookLayoutGalleryView.LENGTH,BookLayoutGalleryView.LENGTH,_galleryImageCollection);
					BookLayoutGalleryView(currentBookPageView.getLayout()).setData(currentGalleryImageCollection);
				}else if(_viewType == TYPE_FILE_VIEW) {
					var currentSourcePageCollection:SourceImageCollection = SourceImageCollection.getSubCollection(i*BookLayoutSamplesView.LENGTH,BookLayoutSamplesView.LENGTH,_sourceImageCollection);
					BookLayoutSamplesView(currentBookPageView.getLayout()).setData(currentSourcePageCollection);
				}
				
				//SET PAGE NUMBER
				currentBookPageView.setPageNumber(i);
				
			}
			
		}
		
		
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PRIVATE FUNCTIONS /////////////////////
		/////////////////////////////////////////////////////////////////
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
						
			var firstPageIndex:int = Math.floor(_doublePageIndex)*2%PAGES_CREATED;
			
			
			
		//	trace("updatePages _doublePageIndex = "+_doublePageIndex+"  firstPageIndex="+firstPageIndex);
			for (var p:int = 0; p < _pages.length; p++) 
			{
				
				var pageIndex:uint=Math.floor(_doublePageIndex*2)+p;
				//i IS THE pageIndex MODULO SIMULTANEOUS_PAGES
				//THE LAST ONES GOES BACK TO THE BEGINNING OF THE PILE, ETC...
				var i:int =(pageIndex)%PAGES_CREATED;
				var page:BookPageView = _pages[i];
				
				var nextDoublePageIndex:int= Math.ceil(i/2);
				var pageIndexProgress:Number = (_doublePageIndex-nextDoublePageIndex+2)%(PAGES_CREATED/2)-1;
				
				//EASING IS THE VALUE FROM 0 TO 1 USED TO EASE THE TRANSITION
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
					firstVisiblePage = (_doublePageIndex*2)%(PAGES_CREATED);
					page.visible = false;
					//SHOW 2 PAGES ONLY
					if(i%PAGES_CREATED == firstVisiblePage%PAGES_CREATED ){page.visible = true;}
					if(i%PAGES_CREATED == (firstVisiblePage+1)%PAGES_CREATED){page.visible = true;}
					
					
				}else {
					//OTHERWISE WE SHOW THE 4 PAGES CONCERNED
					firstVisiblePage = (Math.floor(_doublePageIndex)*2)%PAGES_CREATED;
					
					page.visible = false;
					// 1ST PAGE
					if(i%PAGES_CREATED == firstVisiblePage%PAGES_CREATED)
					{
						page.visible = true;
						
						if(easing>0.75 ){
							page.visible= false;
						}
						
					}
					
					// 2ND PAGE
					if(i%PAGES_CREATED == (firstVisiblePage+1)%PAGES_CREATED){
						page.visible = true;
						
						
						if(easing>0.5 ){
							page.visible= false;
						}
					}
					
					// 3RD PAGE
					if(i%PAGES_CREATED == (firstVisiblePage+2)%PAGES_CREATED){
						page.visible = true;
						
						if(easing<0.5 ){
							page.visible= false;
						}
					}
					
					// 4TH PAGE
					if(i%PAGES_CREATED == (firstVisiblePage+3)%PAGES_CREATED)
					{
							
						page.visible = true;
					
						//TO AVOID OVERLAPS WITH PAGES BEHIND WE GIVE A BIT OF BIAS TO SHOWING THE PAGES BEHIND
						//SINCE THE FLIP OF THE PAGES HIDE THE PAGES BEHIND AT THE BEGINNING OF THE MOVEMENT ANYWAY
//						
						if(easing<0.25 ){
							page.visible= false;
						}
					}
				}
			}
		}

		private function startGrabController():void{
			_grabThrowController.start(50000, true);
			_grabThrowController.addEventListener(GrabThrowEvent.DRAG_STARTED,onDragStarted);
			_grabThrowController.addEventListener(GrabThrowEvent.DRAG_UPDATE,onDragUpdate);
			_grabThrowController.addEventListener(GrabThrowEvent.RELEASE,onRelease);
		}

		private function stopGrabController():void{
			_grabThrowController.stop();
			_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_STARTED,onDragStarted);
			_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_UPDATE,onDragUpdate);
			_grabThrowController.removeEventListener(GrabThrowEvent.RELEASE,onRelease);
		}
		
		
		
		public function set doublePageIndex(value:Number):void{
	
			var maxValue:int = Math.ceil(_maxNumberOfPages/2) -1;
			
			//IF WE ARE CHANGING PAGE INDEX FROM 1 TO 2 WE LOAD NEXT SET OF PAGES
			if(value>=0&&value<=maxValue&&Math.floor(_doublePageIndex)*2 %PAGES_CREATED != Math.floor(value)*2 %PAGES_CREATED){
				updateImageCollection();
				//trace("_doublePageIndex = "+_doublePageIndex+" value = "+value);
			}
			
			//VALUE CAN'T BE NEGATIVE
			value = Math.max(value,0);
			
			//NOT ANYMORE// USE NUMBER OF PAGES AS MAX
			//_doublePageIndex = Math.min(Math.max(value,0),(_pages.length/2-1));
			
			
			//NOW USING NUMBER OF PAGES ACCORDING TO TOTAL NUMBER OF IMAGES FROM SOURCE COLLECTION
			_doublePageIndex = value;
			//MAKE SURE THE DOUBLE PAGE INDEX CAN'T BE HIGHER THAN  MAXIMUM NUMBER OF PAGES 
			_doublePageIndex = Math.min(_doublePageIndex,Math.ceil(_maxNumberOfPages/2) -1);
			_doublePageIndex = Math.max(_doublePageIndex,0);
			
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
			_startMouseX = stage.mouseX;
			_startMouseY = stage.mouseY;
			_swipeMode = UNDECIDED;
		}
		
		protected function onDragUpdate(event:GrabThrowEvent):void
		{
			updateSwipeMode();

			if (_swipeMode == PAGE_SWIPE)
				doublePageIndex -= _pageBrowsingSpeed*event.velocityX/1500;
			else if (_swipeMode == HIDE_SWIPE) {
				updateHideSwipe(event.velocityY);
			}
		}

		private function updateHideSwipe(velocity : Number):void
		{
			var bookVelocity : Number = unprojectVelocity(velocity) / Math.abs(_hiddenOffset);
			var ratio : Number = _hiddenRatio + bookVelocity;
			if (ratio < 0.0) ratio = 0.0;
			else if (ratio > 1.0) ratio = 1.0;
			hiddenRatio = ratio;
		}

		private function releaseHideSwipe(velocity:Number):void
		{
			var bookVelocity : Number = unprojectVelocity(velocity) / Math.abs(_hiddenOffset);
			var target : Number;

			if (Math.abs(velocity) * CoreSettings.GLOBAL_SCALING < 3) {
				target = _hiddenRatio + bookVelocity;
				target = target < 0.5? 0.0 : 1.0;
			}
			else if (bookVelocity > 0.0)
				target = 1.0;
			else
				target = 0.0;

			TweenLite.to(this,.5,
			{	hiddenRatio: target,
				ease:Quad.easeOut
			});
		}

		private function unprojectVelocity(screenSpaceVelocity:Number):Number
		{
			var matrix:Vector.<Number> = _view.camera.lens.matrix.rawData;
			var z:Number = _view.camera.z - _container.z;
			return screenSpaceVelocity / CoreSettings.STAGE_WIDTH * 2 * z / matrix[0];
		}

		private function updateSwipeMode() : void
		{
			if (_swipeMode == UNDECIDED) {
				if (!_bookEnabled) {
					_swipeMode = HIDE_SWIPE;
					return;
				}

				if (!_hidingEnabled) {
					_swipeMode = PAGE_SWIPE;
					return;
				}

				var dx : Number = Math.abs(_startMouseX - stage.mouseX) * CoreSettings.GLOBAL_SCALING;
				var dy : Number = Math.abs(_startMouseY - stage.mouseY) * CoreSettings.GLOBAL_SCALING;

				if (dx > 20 && dy < 20) {
					_swipeMode = PAGE_SWIPE;
				}
				else if (dy > 20 && dx < 20) {
					_swipeMode = HIDE_SWIPE;
				}
			}
		}

		protected function onRelease(event:GrabThrowEvent):void
		{
			if (_swipeMode == PAGE_SWIPE)
				//ON RELEASE SNAP TO THE CURRENTLY OPENED PAGE
				TweenLite.to(this,0.5,{doublePageIndex:Math.round(doublePageIndex),ease:Sine.easeOut});
			else if (_swipeMode == HIDE_SWIPE)
				releaseHideSwipe(event.velocityY);
		}

		public function setBookPosition(value:Vector3D):void
		{
			_basePosition = value.clone();
			updatePosition();
		}

		public function get hiddenRatio():Number
		{
			return _hiddenRatio;
		}

		public function set hiddenRatio(value:Number):void
		{
			_hiddenRatio = value;
			updatePosition();

			if (!_hidingEnabled) return;

			if (value < .01 && _consideredHidden) {
				_consideredHidden = false;
				switchedToNormalMode.dispatch();
			}
			else if (value > .99 && !_consideredHidden) {
				_consideredHidden = true;
				switchedToHiddenMode.dispatch();
			}
		}

		private function updateInteractionRect():void
		{
			if (_hidingEnabled)
				_grabThrowController.interactionRect = getBookScreenBounds();
			else
				_grabThrowController.interactionRect = null;
		}

		private function getBookScreenBounds():Rectangle
		{
			// figure out projected bounds of book, use cover as guidance
			var matrix : Matrix3D = _coverBook.sceneTransform;

			var topLeft : Vector3D = new Vector3D(-COVER_WIDTH * .5, 0, COVER_HEIGHT * .5);
			var bottomRight : Vector3D = new Vector3D(COVER_WIDTH * .5, 0, -COVER_HEIGHT * .5);

			topLeft = _view.project(matrix.transformVector(topLeft));
			bottomRight = _view.project(matrix.transformVector(bottomRight));

			return new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
		}

		private function updatePosition():void
		{
			_container.x = _basePosition.x;
			_container.y = _basePosition.y + 20 + _hiddenOffset * _hiddenRatio;
			_container.z = _basePosition.z - 250;
			updateInteractionRect();
		}

		override public function set mouseEnabled(enabled:Boolean):void
		{
			super.mouseEnabled = enabled;
			_view.mouseEnabled = enabled;
		}
		
		public function get PAGES_CREATED():int{
			//return Math.min(_pages.length,SIMULTANEOUS_PAGES);
			return _pages.length;
		}
		
	}
}