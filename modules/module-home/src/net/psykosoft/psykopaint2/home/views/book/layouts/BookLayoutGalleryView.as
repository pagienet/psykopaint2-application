package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	
	import net.psykosoft.psykopaint2.core.models.FileGalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	public class BookLayoutGalleryView  extends BookLayoutAbstractView
	{
		
		public static const COLUMNS:int=2;
		public static const ROWS:int=3;
		
		private var _data:GalleryImageCollection;
		private var _pageThumbnailViews:Vector.<BookLayoutGalleryThumbView>;
		
		private var _pageIndex:int;
		
		public function BookLayoutGalleryView()
		{
			_pageThumbnailViews = new Vector.<BookLayoutGalleryThumbView>(LENGTH);

			
		}
		
		public function setData(data:GalleryImageCollection):void
		{
				//trace("setData :: "+data.index);
			
				this._data = data;
				
				
				var currentSourceImageProxy:GalleryImageProxy;
				for (var i:int = 0; i < _data.images.length; i++) 
				{
					currentSourceImageProxy = _data.images[i];
					var currentPageThumbnailView:BookLayoutGalleryThumbView;
					
					//CREATE
					if(_pageThumbnailViews[i]==null){
						
						currentPageThumbnailView = new BookLayoutGalleryThumbView();
						// CAST GalleryImageProxy => FileGalleryImageProxy
						// IT'S BEEN WRITTEN THIS WAY THAT GalleryImageCollection collects GalleryImageProxys and not FileGalleryImageProxy
						 currentPageThumbnailView.setData(FileGalleryImageProxy(currentSourceImageProxy));
						_pageThumbnailViews[i] = currentPageThumbnailView;
						currentPageThumbnailView.addEventListener(MouseEvent3D.CLICK,onClickDownThumbnail);
						//DOWNLOAD IMAGE STRAIGHT AWAY
						currentPageThumbnailView.load();
						
					}else {
					//UPDATE	
					
						currentPageThumbnailView = _pageThumbnailViews[i] ;
						currentPageThumbnailView.setData(FileGalleryImageProxy(currentSourceImageProxy));
						
						//DOWNLOAD IMAGE STRAIGHT AWAY
						currentPageThumbnailView.load();

					}
					
					
					
					this.addChild(currentPageThumbnailView);
					currentPageThumbnailView.x = 50+(i%COLUMNS)*(currentPageThumbnailView.width +15);
					currentPageThumbnailView.z = 5+ Math.floor(i/COLUMNS)*-(currentPageThumbnailView.height +10)+50;
					
				}
				
				
				
				//LOAD THUMBNAILS 1 BY 1 STARTING WITH FIRST ONE
				//_pageThumbnailViews[0].load();
				//loadThumbnail(0);
			
		}
		
		private function loadThumbnail(index:int,onComplete:Function=null):void{
			
			//trace("loadThumbnail "+index);
			if(index<_pageThumbnailViews.length-1){
				
				_pageThumbnailViews[index].load(function():void{loadThumbnail(index+1)});
			}else {
				_pageThumbnailViews[index].load();
			}
				
		}
		
		
		protected function onClickDownThumbnail(event:MouseEvent3D):void
		{
			TweenLite.to(ObjectContainer3D(event.target),0.25,{ease:Expo.easeOut,y:5,rotationX:2,onComplete:function():void{
				TweenLite.to(ObjectContainer3D(event.target),0.25,{ease:Expo.easeOut,y:0,rotationX:0});
			}});
			
		}		
		
		override public function dispose():void
		{
			_data = null;
			//trace("BookLayoutGalleryView::dispose");
			for (var i:int = 0; i < _pageThumbnailViews.length; i++) 
			{
				_pageThumbnailViews[i].removeEventListener(MouseEvent3D.MOUSE_DOWN,onClickDownThumbnail);
				_pageThumbnailViews[i].dispose();
				if(_pageThumbnailViews[i].parent) _pageThumbnailViews[i].parent.removeChild(_pageThumbnailViews[i]);
				
				_pageThumbnailViews[i]=null;
			}
			_pageThumbnailViews = new Vector.<BookLayoutGalleryThumbView>();
			
			super.dispose();
		}
		
		static public  function get LENGTH():int{
			return  COLUMNS*ROWS;
		}
	}
}