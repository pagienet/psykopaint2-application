package net.psykosoft.psykopaint2.home.views.book
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.home.views.book.layouts.BookLayoutAbstractView;
	
	public class BookPageView extends ObjectContainer3D
	{
		public static const  WIDTH:int = 175;
		public static const  HEIGHT:int = 200;
		
		private var _material:MaterialBase;
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		
		private var _layoutView:BookLayoutAbstractView;
		private var _flipped:Boolean;
		
		public function BookPageView(material:MaterialBase=null)
		{
			
			if(material==null)
				_material =  new ColorMaterial(0xEEEEEE);
			else {
				_material = material;
			}
			
		
			_geometry = new PlaneGeometry(WIDTH,HEIGHT,1,1,true,true);
			_pageMesh = new Mesh(_geometry,_material);
			
			
			
			this.addChild(_pageMesh);
			update();
			
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
			_geometry.scaleUV(-1,1);
			_material.repeat=true;
			_flipped = true;
			update();
		}
		
		public function update():void{
			
			if(_layoutView){
				
				_layoutView.z=50;
				_layoutView.y=1;
				if(_flipped){
					
					//_layoutView.scaleX=-1;
					_layoutView.x=-WIDTH+40;
				}else {
					_layoutView.x=WIDTH/2 -40;
				}
			}
			
			if(_flipped){
				_pageMesh.x=-WIDTH/2;
			}else {
				_pageMesh.x=WIDTH/2;
				
			}
			
		}
		
		
		
		public function addlayout(layoutView:BookLayoutAbstractView):void
		{
			_layoutView= layoutView;
			trace("BookPageView::addlayout "+layoutView);
			this.addChild(layoutView);
			update();
		}
	}
}