package net.psykosoft.psykopaint2.home.views.book
{
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
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.book.views.models.Rings;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	
	public class BookPageView extends ObjectContainer3D
	{
		public static const  WIDTH:int = 175;
		public static const  HEIGHT:int = 200;
		
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		
		private var _layoutView:BookLayoutAbstractView;
		private var _flipped:Boolean;
		private var _pageTextureMaterial:MaterialBase;
		private var _ringTextureMaterial:TextureMaterial; 
		private var _pageNumber_txt:TextField;
		private var _pageNumber:int;
		private var _textMesh:Mesh;
		private var _rings:Rings;
		 

		
		public function BookPageView()
		{
			//THE BOOK IS FIRST POPULATED WITH A COLORED MATERIAL UNTIL IT RECIEVES ITS FINAL TEXTURE
			//if(material==null)
			//_pageTextureMaterial = new ColorMaterial(0xEEEEEE);
			//else 
			_pageTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.PAGE_PAPER);
			_ringTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.RING);
			
			
			//ADD PAPER TEXTURE
			_geometry = new PlaneGeometry(WIDTH,HEIGHT,1,1,true,true);
			_pageMesh = new Mesh(_geometry,_pageTextureMaterial);
			this.addChild(_pageMesh);
			
			
			//ADD RING
			_rings = new Rings(_ringTextureMaterial);
			addChild(_rings);
			_rings.scaleZ=_rings.scaleX=_rings.scaleY=0.19;
			
			update();
			
			_pageMesh.pickingCollider = PickingColliderType.PB_BEST_HIT
			_pageMesh.mouseEnabled=true;
			_pageMesh.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			_pageMesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown3d);
		}
		
		
		
		
		public function setPageNumber(value:int):void{
			
			var textureMaterial:TextureMaterial;
			var geometry:PlaneGeometry;
			
			if(value!=_pageNumber){
				if(!_pageNumber_txt){
					_pageNumber = value;
					var textFormat:TextFormat = PsykoFonts.BookFontSmall;
					textFormat.color = 0x333333;
					textFormat.size = 10;
					textFormat.align = TextFieldAutoSize.LEFT;
					
					_pageNumber_txt = new TextField();
					_pageNumber_txt.antiAliasType = AntiAliasType.ADVANCED;
					_pageNumber_txt.embedFonts = true;
					_pageNumber_txt.width = 20;
					_pageNumber_txt.height = 15;
					_pageNumber_txt.defaultTextFormat = textFormat;
					_pageNumber_txt.text = String(value);
					
					textureMaterial = TextureUtil.displayObjectToTextureMaterial(_pageNumber_txt);
					textureMaterial.alphaBlending = true;
					
					geometry =  new PlaneGeometry(6,6,1,1,true,false);
					_textMesh = new Mesh(geometry,textureMaterial);
					_textMesh.y=1;
					_textMesh.x=(!_flipped)?WIDTH-10:-WIDTH+10;
					_textMesh.z=-HEIGHT/2+10;
					this.addChild(_textMesh);
				}else {
					//REMOVE PREVIOUS TEXTFIELD
					_textMesh.parent.removeChild(_textMesh);
					_textMesh.dispose();
					
					_pageNumber_txt.text = String(value);
					
					textureMaterial = TextureUtil.displayObjectToTextureMaterial(_pageNumber_txt);
					textureMaterial.alphaBlending=true;
					
					geometry =  new PlaneGeometry(6,6,1,1,true,false);
					_textMesh = new Mesh(geometry,textureMaterial);
					
				}
			}else {
				
				//DO NOTHING
				//NUMBER ALREADY BEEN SET TO THIS
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