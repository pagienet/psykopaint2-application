package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.book.views.book.data.BookPageSize;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	
	public class BookPageView extends ObjectContainer3D
	{
		private static const LOADED_PAPER_TEXTURE:String="LOADED_PAPER_TEXTURE";
		private static const LOADED_RINGS:String="LOADED_RINGS";
		public static const  WIDTH:int = 175;
		public static const  HEIGHT:int = 200;
		
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		private var _pageTextureMaterial:MaterialBase;

		
		private var _layoutView:BookLayoutAbstractView;
		private var _flipped:Boolean;
		private var _fileLoader:QueuedFileLoader;
		private var _ringTextureMaterial:TextureMaterial; 
		private var _pageNumber_txt:TextField;
		 

		
		public function BookPageView()
		{
			//THE BOOK IS FIRST POPULATED WITH A COLORED MATERIAL UNTIL IT RECIEVES ITS FINAL TEXTURE
			_pageTextureMaterial = new ColorMaterial(0xEEEEEE);
			
			//ADD PAPER TEXTURE
			_geometry = new PlaneGeometry(WIDTH,HEIGHT,1,1,true,true);
			_pageMesh = new Mesh(_geometry,_pageTextureMaterial);
			this.addChild(_pageMesh);
			
			_fileLoader = new QueuedFileLoader();
			
			//RINGS
			_fileLoader.loadImage("book-packaged/images/book/rings.jpg", onImageLoadedComplete, null, {type:LOADED_RINGS});
			
			
			//LOAD PAPER TEXTURE
			_fileLoader.loadImage("home-packaged/away3d/book/paperbook512.jpg", onImageLoadedComplete, null, {type:LOADED_PAPER_TEXTURE});
			
			initTextField();
			
			update();
			_pageMesh.pickingCollider = PickingColliderType.PB_BEST_HIT
			_pageMesh.mouseEnabled=true;
			_pageMesh.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			_pageMesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown3d);
		}
		
		
		private function initTextField():void
		{
			var textFormat:TextFormat = PsykoFonts.BookFontSmall;
			textFormat.color = 0x333333;
			textFormat.size = 10;
			textFormat.align = TextFieldAutoSize.LEFT;
			
			_pageNumber_txt = new TextField();
			_pageNumber_txt.antiAliasType = AntiAliasType.ADVANCED;
			_pageNumber_txt.embedFonts = true;
			_pageNumber_txt.width = 20;
			_pageNumber_txt.height = 15;
			//_pageNumber_txt.x = 10;
			//_pageNumber_txt.y = WIDTH - 20;
			//_pageNumber_txt.border = true; to debug visually
			
			_pageNumber_txt.defaultTextFormat = textFormat;
			_pageNumber_txt.text = "0";
			
			//var pageSprite:Sprite = new Sprite();
			//pageSprite.addChild(_pageNumber_txt);
			
			//displayObjectToBitmapData(pageSprite);
			
			var textureMaterial:TextureMaterial = displayObjectToTextureMaterial(_pageNumber_txt);
			textureMaterial.alphaBlending=true;
			
			//var textureMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,true,0x44444444)));
			//textureMaterial.alphaBlending=true;
			
			
			var geometry:PlaneGeometry =  new PlaneGeometry(10,10,1,1,true,true);
			
			
			
			var textMesh:Mesh = new Mesh(geometry,textureMaterial);
			textMesh.y=1;
			this.addChild(textMesh);
			textMesh.x=WIDTH-10;
			textMesh.z=-HEIGHT/2+10;
		}
		
		private function displayObjectToBitmapData(displayObject:DisplayObject):BitmapData{
			var pageBitmapData:BitmapData = new BitmapData(displayObject.getBounds(displayObject).width, displayObject.getBounds(displayObject).height, true,0x00000000);
			pageBitmapData.draw(displayObject, null, null, "normal", null, true);
			return pageBitmapData;
		}
		
		private function displayObjectToTextureMaterial(displayObject:DisplayObject):TextureMaterial{
			
			var texture:BitmapTexture = new BitmapTexture(BitmapDataUtils.autoResizePowerOf2(displayObjectToBitmapData(displayObject)));
			var textureMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(texture));
			
			return textureMaterial;
		}
		
		
		public function setPageNumber(pageNumber:int):void{
			
			
		}
		
		
		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{	
			
			var type:String = e.customData.type;
			
			switch(type){
				case LOADED_PAPER_TEXTURE:
					var pageTexture:BitmapTexture = new BitmapTexture(BitmapData(e.data).clone());
					//pageTexture.getTextureForStage3D(_stage3DProxy);
					_pageTextureMaterial = new TextureMaterial(Cast.bitmapTexture(pageTexture));
					
					_pageMesh.material = _pageTextureMaterial;
					update();
					
					
					break;
				case LOADED_RINGS:
					var ringTexture:BitmapTexture = new BitmapTexture(BitmapData(e.data).clone());
					//pageTexture.getTextureForStage3D(_stage3DProxy);
					_ringTextureMaterial = new TextureMaterial(Cast.bitmapTexture(pageTexture));
					
					
					
					break;
				
				
				case "TEST":
					//MAKING SURE THE RIGHT BITMAP IS LOADED
					var testBm:Bitmap = new Bitmap(BitmapData(e.data));
					//this.stage.addChild(testBm);
					
					break;
			}
			
			
		}
		
		
		private function onObjectMouseOver( event:MouseEvent3D ):void {
			trace("onObjectMouseOver");
		}
		
		protected function onMouseDown3d(event:MouseEvent3D):void
		{
			trace("on mouse down 3d");
			
		}	
		
		override public function dispose():void{
			if(_layoutView){
				_layoutView.parent.removeChild(_layoutView);
				_layoutView.dispose();
				_layoutView = null;
			}
			
			super.dispose();
		}
		
		
		public function flip():void{
			
			_flipped = true;
			update();
		}
		
		public function update():void{
			
			if(_layoutView){
				
				_layoutView.z=50;
				_layoutView.y=1;
				if(_flipped){
					_layoutView.x=-WIDTH+40;
				}else {
					_layoutView.x=WIDTH/2 -40;
				}
			}
			
			if(_flipped){
				_geometry.scaleUV(-1,1);
				_pageTextureMaterial.repeat=true;
				_pageMesh.x=-WIDTH/2;
			}else {
				_pageMesh.x=WIDTH/2;
				
			}
			
		}
		
		
		
		public function addlayout(layoutView:BookLayoutAbstractView):void
		{
			_layoutView= layoutView;
			this.addChild(layoutView);
			update();
		}
	}
}