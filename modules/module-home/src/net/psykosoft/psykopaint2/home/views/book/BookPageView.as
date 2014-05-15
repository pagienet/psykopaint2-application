package net.psykosoft.psykopaint2.home.views.book
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import away3d.animators.ModifierAnimator;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.modifiers.gpu.PageBender;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
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
		private var _pageNumber_txt:TextField;
		private var _pageNumber:int = -1;
		private var _textMesh:Mesh;
		private var _pageNumbertextureMaterial:TextureMaterial;
		private var _bend:PageBender;
		private var _pageAnimator:ModifierAnimator;
		
		 

		
		public function BookPageView()
		{
			//THE BOOK IS FIRST POPULATED WITH A COLORED MATERIAL UNTIL IT RECIEVES ITS FINAL TEXTURE
			//if(material==null)
			//_pageTextureMaterial = new ColorMaterial(0xEEEEEE);
			//else 
			_pageTextureMaterial = HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.PAGE_PAPER);
			
			//_pageTextureMaterial  = new ColorMaterial(0xEEEEEE);
			
			
			//ADD PAPER TEXTURE
			_geometry = new PlaneGeometry(WIDTH,HEIGHT,15,15,true,false);
			_pageMesh = new Mesh(_geometry,_pageTextureMaterial);
			this.addChild(_pageMesh);
			
			
			 
			_bend = new PageBender(WIDTH, 1, 1, 1);
			
			_pageAnimator = new ModifierAnimator(_bend); 
			//_pageMesh.animator = _pageAnimator;
			
			//_bend.foldRotation = 30;
			
			update();
			
		}
		
		
		public function get flipped():Boolean
		{
			return _flipped;
		}

		public function setPageNumber(value:int):void{
			
			var geometry:PlaneGeometry;
			
			//trace(" _pageNumber = "+_pageNumber+" "+value);
			
			//ONLY CHANGE PAGE NUMBER IF IT DOES CHANGE
//			if(value!=_pageNumber){
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
					_pageNumber_txt.text = (value).toFixed(0);
					
					_pageNumbertextureMaterial = TextureUtil.displayObjectToTextureMaterial(_pageNumber_txt);
					_pageNumbertextureMaterial.alphaBlending = true;
					
					geometry =  new PlaneGeometry(6,6,1,1,true,false); 
					_textMesh = new Mesh(geometry,_pageNumbertextureMaterial);
					_textMesh.y=1;
					_textMesh.x=(!_flipped)?WIDTH-10:-WIDTH+10;
					_textMesh.z=-HEIGHT/2+10;
					this.addChild(_textMesh);
					
					
					
				}else {
					//REMOVE PREVIOUS TEXTFIELD
					//if (_textMesh.parent) _textMesh.parent.removeChild(_textMesh);
					//_textMesh.dispose();
					
					_pageNumber_txt.text = String(value);
					
					//_pageNumbertextureMaterial = ;
					//_pageNumbertextureMaterial.alphaBlending=true;
					//ASSIGN NEW DRAWING OF THE UPDATED TEXTFIELD
					
					BitmapTexture(TextureMaterial(_textMesh.material).texture).bitmapData = TextureUtil.autoResizePowerOf2(TextureUtil.displayObjectToBitmapData(_pageNumber_txt)) ;
					
				}
//			}else { 
//				
//				//DO NOTHING
//				//NUMBER ALREADY BEEN SET TO THIS
//			}
		}
		

		override public function dispose():void{
			
			//REMOVE LAYOUT
			if(_layoutView){
				
				_layoutView.dispose();
				if(_layoutView.parent) _layoutView.parent.removeChild(_layoutView);

				_layoutView = null;
			}
			
			//REMOVE TEXTFIELD IF STILL EXIST
			if(_pageNumber_txt)_pageNumber_txt = null;
			if (_textMesh.parent) _textMesh.parent.removeChild(_textMesh);
			if (_textMesh)_textMesh.dispose();
			
			
			//WE DON'T DISPOSE OF THE MATERIALS HERE, SINCE WE WANT TO KEEP THEM IN MEMORY
			// BUT WE REMOVE THOSE WHEN DISPOSING THE BOOKVIEW ALONG WITH BookMaterialsProxy
			//_pageTextureMaterial.dispose();
			//_ringTextureMaterial.dispose();
			if (_pageNumbertextureMaterial) {
				_pageNumbertextureMaterial.texture.dispose();
				_pageNumbertextureMaterial.dispose();
			}
			_pageNumbertextureMaterial = null;
			_pageTextureMaterial = null;
			
			
			
			super.dispose();
		}
		
		
		public function flip():void{
			
			_flipped = true;
			update();
		}
		
		public function update():void{
			
			if(_layoutView){
				
				//_layoutView.z=50;
				
				if(_flipped){
					//_layoutView.x=-WIDTH+40;
				}else {
					//_layoutView.x=WIDTH/2 -40;
				}
				_layoutView.x = -WIDTH/2;
				_layoutView.y=1;
			}
			
			
			if(_flipped){
				_geometry.scaleUV(-1,1);
				_pageTextureMaterial.repeat=true;
				_pageMesh.x=-WIDTH/2;
			}else {
				_pageMesh.x=WIDTH/2;
				
			}
			
		}
		
		
		public function addLayout(layoutView:BookLayoutAbstractView):void
		{
			_layoutView= layoutView;
			_pageMesh.addChild(layoutView);
			update();
		}
		
		public function getLayout():BookLayoutAbstractView
		{
			return _layoutView;
		}
	}
}