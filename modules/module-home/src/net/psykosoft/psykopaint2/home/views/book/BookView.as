package net.psykosoft.psykopaint2.home.views.book
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.events.Object3DEvent;
	import away3d.lights.LightBase;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutSamplesView;

	public class BookView  extends Sprite
	{
		
		
		private var _grabThrowController:GrabThrowController;
		private var _view:View3D;
		private var _stage3DProxy:Stage3DProxy;
		private var _light:LightBase;
		private var _container:ObjectContainer3D;
		private var _pages:Vector.<BookPageView>;
		private var _pagesLayouts:Vector.<BookLayoutAbstractView>;
		private var _cover:Mesh;
		
		private var _pageCount:uint=4;
		private var _pageBrowsingSpeed:Number=5;
		private var _galleryImageCollection:GalleryImageCollection;
		private var _sourceImageCollection:SourceImageCollection;
		private var _pageIndex:Number=0;
		private var _bookMaterialProxy:BookMaterialsProxy;
		
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
			_container.x=-250;
			_container.z=200;
			_container.mouseEnabled = true;
			
			init();
			
			
			
			//EVENTS
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			_container.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			_container.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown3d);
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraMoved);
			
		}
		
		
		public function dispose():void
		{
			BookMaterialsProxy.dispose();
			stopGrabController();
			_container.removeEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			_container.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown3d);
			_view.camera.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraMoved);
		}
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PUBLIC FUNCTIONS //////////////////////
		/////////////////////////////////////////////////////////////////
		public function setGalleryImageCollection(galleryImageCollection : GalleryImageCollection):void
		{
			//CLEAR PREVIOUS LAYOUT
			
			
			_galleryImageCollection = galleryImageCollection; 
			
			// TODO
		}
		
		
		public function setSourceImages(sourceImageCollection : SourceImageCollection):void
		{
			//CLEAR PREVIOUS LAYOUT
			removePages();
			
			//ASSIGN DATA
			_sourceImageCollection = sourceImageCollection;
			
			//NUMBER OF PAGES DEPEND ON THE NUMBER OF IMAGES SENT IN AND NEEDS TO BE PAIR
			var numberOfPages:uint = Math.ceil((_sourceImageCollection.images.length/BookLayoutSamplesView.LENGTH)/2)*2;
			
			//CREATE PAGES
			createPages(numberOfPages);
			
			
			//CREATE SAMPLES LAYOUTS VIEWS
			for (var i:int = 0; i < numberOfPages; i++) 
			{
				var currentPageCollection:SourceImageCollection = SourceImageCollection.getSubCollection(i*BookLayoutSamplesView.LENGTH,BookLayoutSamplesView.LENGTH,_sourceImageCollection);
				var currentBookPageView:BookPageView = _pages[i];
				var newBookLayoutSamplesView:BookLayoutSamplesView = new BookLayoutSamplesView();
				
				newBookLayoutSamplesView.setData(currentPageCollection);
				currentBookPageView.addlayout(newBookLayoutSamplesView);
			}
			
			
		}
		
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PRIVATE FUNCTIONS /////////////////////
		/////////////////////////////////////////////////////////////////
		private function init():void
		{
			//SHOW RED TEST CUBE FOR ORIGIN
//			var testCubeGeometry:Geometry = new CubeGeometry(2,2,2);
//			var testCubeMaterial:ColorMaterial = new ColorMaterial(0xFF0000);
//			var testCube:Mesh = new Mesh(testCubeGeometry,testCubeMaterial);
//			_container.addChild(testCube);
//			testCube.mouseEnabled=true;
//			testCube.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown3d);
//			
			
			//CREATE BACKGROUND COVER
			var coverGeometry:Geometry = new PlaneGeometry(380,220);
			var coverMaterial:ColorMaterial = new ColorMaterial(0x333333);
			var coverBook:Mesh = new Mesh(coverGeometry,coverMaterial);
			_container.addChild(coverBook);
			coverBook.y=-10;
			
			//LOAD PAGES ASSETS
			trace("BookView::init");
			BookMaterialsProxy.launch(function ():void
			{
				trace("BookView::materials loaded");
				//LOAD DATAS AS SOON AS THE BOOK ASSETS ARE READY
				loadDummySourceImageCollection();
			});
			
		
		}	
		 
		
		
		private function removePages():void{
			//CLEAR PREVIOUS LAYOUT
			for (var i:int = 0; i < _pages.length; i++) 
			{
				_pages[i].parent.removeChild(_pages[i]);
				_pages[i].dispose();
				_pages[i] = null;
			}
			_pages = new Vector.<BookPageView>();
		}
		
		
		
		private function createPages(pageCount:uint=2):void
		{
			
			trace("BookView::createPages");
			
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
			
			
			//trace("_pageIndex = "+_pageIndex);
			
			//trace("on Mouse move position = "+ position+" t = "+t);
			for (var i:int = 0; i < _pages.length; i++) 
			{
				var page:BookPageView = _pages[i];
				var pageIndexProgress:Number = _pageIndex+1-Math.ceil(i/2);
				//var pageIndexProgress:Number = t+1-Math.ceil(+0.5+i)/2-0.5;
				
				//EASING IS THE VALUE FROM 0 TO 1 TO EASE THE TRANSITION
				var easing:Number = pageIndexProgress-Math.floor(pageIndexProgress);
				
				//trace("pageIndexProgress "+i+" =  " + pageIndexProgress);
				
				if(i%2==0){
					//PAIR = LEFT PAGES 0,2,4,6
					
					//page.rotationZ = -180+Math.min(180*(Math.floor(pageIndexProgress)+Cubic.easeInOut(easing,0,1,1)),180-1);
					page.rotationZ = -180+Math.min(180*(Math.floor(pageIndexProgress)+easing),180);
					page.rotationZ = Math.max(page.rotationZ,-180);
				}else {
					//IMPAIR = RIGHT PAGES 1,3,5
					
					//page.rotationZ = Math.min(180*(Math.floor(pageIndexProgress)+Cubic.easeInOut(easing,0,1,1)),180-1);
					page.rotationZ = Math.min(180*(Math.floor(pageIndexProgress)+easing),180);
					page.rotationZ = Math.max(page.rotationZ,0);
				}
				
				//UPDATE VISIBILITY
				// IF WE'RE ON A PRECISE INDEX WE JUST SHOW 2 PAGES
				if(_pageIndex == int(_pageIndex) ){
					
					page.visible= (i<=_pageIndex*2+1 && i>=_pageIndex*2)?true:false;
				}else {
					//OTHERWISE WE SHOW THE 4 PAGES CONCERNED
					var minIndexVisible:int = Math.floor(_pageIndex)*2;
					page.visible= (i<=minIndexVisible+4 &&i>=minIndexVisible)?true:false;
				}
				
			}
			
			
			
			//FIRST AND LAST PAGES NEVER MOVE
			if (_pages.length>0){
				_pages[0].rotationZ = 0;
				_pages[_pages.length-1].rotationZ = 0;
			}
			
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
		
		
		
		public function set pageIndex(value:Number):void{
			_pageIndex = Math.max(value,0);
			updatePages();
		}
		
		public function get pageIndex():Number{
			return _pageIndex;
		}
	
		
	
		
		/////////////////////////////////////////////////////////////////
		/////////////////////////   EVENTS	/////////////////////////////
		/////////////////////////////////////////////////////////////////
		private function onObjectMouseOver( event:MouseEvent3D ):void {
			trace("onObjectMouseOver");
		}
		
		protected function onMouseDown3d(event:MouseEvent3D):void
		{
			trace("on mouse down 3d");
			
		}		
		
		
		protected function onAdded(event:Event):void
		{
			
			startGrabController();
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
		}		
		
		
		
		
		
		
		protected function onDragStarted(event:GrabThrowEvent):void
		{
			//NOTHING
		}
		
		protected function onDragUpdate(event:GrabThrowEvent):void
		{
			
			//!!PageIndex is a SETTER
			pageIndex += _pageBrowsingSpeed*event.velocityX/1000;
			
		}	
		
		protected function onRelease(event:GrabThrowEvent):void
		{
			
			//ON RELEASE SNAP TO THE CURRENTLY OPENED PAGE
			TweenLite.to(this,0.5,{pageIndex:Math.round(pageIndex),ease:Back.easeOut});
			
		}
		
		
		
		
		private function loadDummySourceImageCollection():void
		{
			
			////////////////////////////
			///////// DUMMY DATA  //////
			////////////////////////////
			//TEST DUMMY COLLECTION
			var testSourceImageCollection:SourceImageCollection = new SourceImageCollection();
			var fileSourceImageProxys :Vector.<SourceImageProxy>= new Vector.<SourceImageProxy>();
			for (var i:int = 0; i < 41; i++) 
			{
				var newImage:FileSourceImageProxy = new FileSourceImageProxy();
				newImage.id=i;
				newImage.lowResThumbnailFilename = "book-packaged/samples/thumbs_lowres/"+i+".jpg";
				newImage.highResThumbnailFilename = "book-packaged/samples/thumbs/"+i+".jpg";
				fileSourceImageProxys.push(newImage);
			}
			testSourceImageCollection.images = fileSourceImageProxys;
			
			setSourceImages(testSourceImageCollection);
		}
		
		private function onCameraMoved(event:Object3DEvent):void
		{
			//UPDATE BOOK POSITION
		}
		
		public function get container():ObjectContainer3D
		{
			return _container;
		}
		
		
	}
}