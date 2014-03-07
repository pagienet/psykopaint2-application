package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
	import away3d.lights.LightBase;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutSamplesView;

	public class BookView  extends Sprite
	{
		
		private static const LOADED_PAPER_TEXTURE:String="LOADED_PAPER_TEXTURE";
		
		private var _view:View3D;
		private var _stage3DProxy:Stage3DProxy;
		private var _light:LightBase;
		private var _container:ObjectContainer3D;
		private var _pages:Vector.<BookPageView>;
		private var _pagesLayouts:Vector.<BookLayoutAbstractView>;
		private var _fileLoader:QueuedFileLoader;
		
		private var _pageCount:uint=4;
		private var _galleryImageCollection:GalleryImageCollection;
		private var _sourceImageCollection:SourceImageCollection;
		private var _pageTextureMaterial:TextureMaterial;
		
		public function BookView(view:View3D, light:LightBase, stage3dProxy:Stage3DProxy)
		{
			_view = view;
			_stage3DProxy = stage3dProxy;
			_light = light; 
			_container = new ObjectContainer3D();
			_fileLoader = new QueuedFileLoader();
			_pages = new Vector.<BookPageView>();
			_view.scene.addChild(_container);
			
			//ROTATE CONTAINER TO FACE THE CAMERA
			_container.rotationX = 90;
			_container.rotationY = 0;
			_container.rotationZ = 180;
			_container.x=-100;
			_container.z=200;
			init();
			
			
			//LOAD PAPER TEXTURE
			_fileLoader.loadImage("home-packaged/away3d/book/paperbook512.jpg", onImageLoadedComplete, null, {type:LOADED_PAPER_TEXTURE});
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraMoved);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		

		protected function onAdded(event:Event):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
		}		
		
		/////////////////////////////////////////////////////////////////
		///////////////////////// PUBLIC FUNCTIONS //////////////////////
		/////////////////////////////////////////////////////////////////
		public function setGalleryImageCollection(galleryImageCollection : GalleryImageCollection):void
		{
			//CLEAR PREVIOUS LAYOUT
			
			//TODO
			_galleryImageCollection = galleryImageCollection; 
		}
		
		
		public function setSourceImages(sourceImageCollection : SourceImageCollection):void
		{
			//CLEAR PREVIOUS LAYOUT
			removePages();
			
			//ASSIGN DATA
			_sourceImageCollection = sourceImageCollection;
			
			//NUMBER OF PAGES DEPEND ON THE NUMBER OF IMAGES SENT IN AND NEEDS TO BE PAIR
			var numberOfPages:uint = Math.ceil((_sourceImageCollection.images.length/BookLayoutSamplesView.LENGTH)/2)*2;
			
			createPages(_pageTextureMaterial,numberOfPages);
			
			
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
			/*var testCubeGeometry:Geometry = new CubeGeometry(10,10,10);
			var testCubeMaterial:ColorMaterial = new ColorMaterial(0xFF0000);
			var testCube:Mesh = new Mesh(testCubeGeometry,testCubeMaterial);
			_container.addChild(testCube);*/
			
		}	
		
		private function createPages(material:MaterialBase,pageCount:uint=2):void
		{
			
			
			//CREATE PAGES
			_pages = new Vector.<BookPageView>();
			var newPageView:BookPageView;
			
			for (var i:int = 0; i < pageCount; i++) 
			{
				newPageView = new BookPageView(material);
				_pages.push(newPageView);
				newPageView.x = BookPageView.WIDTH;
				if(i%2==0){newPageView.flip();}
				_container.addChild(newPageView);
				
			}
			
		}
		
		
		private function updatePages(position:Number):void{
			
			//
			var t:Number = position*4;
			
			//trace("on Mouse move position = "+ position+" t = "+t);
			for (var i:int = 0; i < _pages.length; i++) 
			{
				var page:BookPageView = _pages[i];
				page.x=BookPageView.WIDTH;
				var t2:Number = t+1-Math.ceil(i/2);
				
				//trace("page "+i+" t2="+t2);
				
				if(i%2==0){
					//PAIR = LEFT PAGES 0, 2,4,6
					
					page.rotationZ = -180+Math.min(180*(t2),180-i);
					page.rotationZ = Math.max(page.rotationZ,-180);
				}else {
					//IMPAIR = RIGHT PAGES 1,3,5
					
					page.rotationZ = Math.min(180*(t2),180+i);
					page.rotationZ = Math.max(page.rotationZ,0);
				}
			}
			
			
			
			/*
			
			if(_pages.length>2){
				_pages[0].x=BookPageView.WIDTH;
				_pages[0].rotationZ = -180+Math.min(180*(t+1),180);
				_pages[0].rotationZ = Math.max(_pages[0].rotationZ,-180);
				
				_pages[1].x=BookPageView.WIDTH;
				_pages[1].rotationZ = Math.min(180*(t),180);
				_pages[1].rotationZ = Math.max(_pages[1].rotationZ,0);
				trace("_pages[1].rotationZ = "+ _pages[1].rotationZ);
				
				_pages[2].x=BookPageView.WIDTH;
				_pages[2].rotationZ = -180+Math.min(180*(t),180);
				_pages[2].rotationZ = Math.max(_pages[2].rotationZ,-180);
				trace("_pages[2].rotationZ = "+ _pages[2].rotationZ);
				
				
				_pages[3].x=BookPageView.WIDTH;
				_pages[3].rotationZ = Math.min(180*(t-1),180);
				_pages[3].rotationZ = Math.max(_pages[3].rotationZ,0);
				trace("_pages[1].rotationZ = "+ _pages[3].rotationZ);
				
				
				_pages[4].x=BookPageView.WIDTH;
				_pages[4].rotationZ = -180+Math.min(180*(t-1),180);
				_pages[4].rotationZ = Math.max(_pages[4].rotationZ,-180);
				trace("_pages[2].rotationZ = "+ _pages[4].rotationZ);
				
				
				_pages[5].x=BookPageView.WIDTH;
				_pages[5].rotationZ = Math.min(180*(t-2),180);
				_pages[5].rotationZ = Math.max(_pages[5].rotationZ,0);
				trace("_pages[1].rotationZ = "+ _pages[5].rotationZ);
				
				_pages[6].x=BookPageView.WIDTH;
				_pages[6].rotationZ = -180+Math.min(180*(t-2),180);
				_pages[6].rotationZ = Math.max(_pages[6].rotationZ,-180);
				trace("_pages[2].rotationZ = "+ _pages[6].rotationZ);
				
				_pages[7].x=BookPageView.WIDTH;
				_pages[7].rotationZ = Math.min(180*(t-3),180);
				_pages[7].rotationZ = Math.max(_pages[7].rotationZ,0);
				trace("_pages[1].rotationZ = "+ _pages[7].rotationZ);
			}*/
			
			
			
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
		
		/////////////////////////////////////////////////////////////////
		/////////////////////////   EVENTS	/////////////////////////////
		/////////////////////////////////////////////////////////////////
		
		protected function onMouseMove(event:MouseEvent):void
		{
			
			updatePages(this.stage.mouseX/this.stage.stageWidth);
		}		
		
		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{	
			
			var type:String = e.customData.type;
			
			switch(type){
				case LOADED_PAPER_TEXTURE:
					var pageTexture:BitmapTexture = new BitmapTexture(BitmapData(e.data).clone());
					pageTexture.getTextureForStage3D(_stage3DProxy);
					_pageTextureMaterial = new TextureMaterial(Cast.bitmapTexture(pageTexture));
					
					//createPages(_pageTextureMaterial);
					loadDummySourceImageCollection();
					
					
					break;
				
				case "TEST":
					//MAKING SURE THE RIGHT BITMAP IS LOADED
					var testBm:Bitmap = new Bitmap(BitmapData(e.data));
					this.stage.addChild(testBm);
					
					break;
			}
			
			
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