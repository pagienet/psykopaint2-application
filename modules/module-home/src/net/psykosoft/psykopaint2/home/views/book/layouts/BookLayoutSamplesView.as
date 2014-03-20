package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	
	public class BookLayoutSamplesView extends BookLayoutAbstractView
	{
		public static const COLUMNS:int=2;
		public static const ROWS:int=3;
		
		private var _data:SourceImageCollection;
		private var _pageThumbnailViews:Vector.<BookLayoutSampleThumbView>;
		
		private var _pageIndex:int;
		
		
		public function BookLayoutSamplesView()
		{
			_pageThumbnailViews = new Vector.<BookLayoutSampleThumbView>(LENGTH);
			
		}
		
		public function setData(data:SourceImageCollection):void{
			this._data = data;
						
			var currentSourceImageProxy:FileSourceImageProxy;
			var currentPageThumbnailView:BookLayoutSampleThumbView; 

			for (var i:int = 0; i < _data.images.length; i++) 
			{
				currentSourceImageProxy = FileSourceImageProxy(_data.images[i]);
				
				//CREATE
				if(_pageThumbnailViews[i]==null){
					
					currentPageThumbnailView = new BookLayoutSampleThumbView();
					currentPageThumbnailView.setData(currentSourceImageProxy);
					_pageThumbnailViews[i]=currentPageThumbnailView;
					this.addChild(currentPageThumbnailView);
					currentPageThumbnailView.addEventListener(MouseEvent3D.CLICK,onClickDownThumbnail);
				}else {
				//UPDATE
					//trace("update thumbnail:: "+i)
					currentPageThumbnailView = _pageThumbnailViews[i] ;
					currentPageThumbnailView.setData(currentSourceImageProxy);
					
				}
				
				
				currentPageThumbnailView.x = 50+(i%COLUMNS)*(currentPageThumbnailView.width +15);
				currentPageThumbnailView.z = 5+ Math.floor(i/COLUMNS)*-(currentPageThumbnailView.height +10)+50;
				//newPageThumbnailView.y = -1;
				//newPageThumbnailView.rotationY= Math.random()*5-2.5;
				
				
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
			//trace("BookLayoutSamplesView::dispose");
			for (var i:int = 0; i < _pageThumbnailViews.length; i++) 
			{
				_pageThumbnailViews[i].removeEventListener(MouseEvent3D.MOUSE_DOWN,onClickDownThumbnail);
				_pageThumbnailViews[i].dispose();
				if(_pageThumbnailViews[i].parent) _pageThumbnailViews[i].parent.removeChild(_pageThumbnailViews[i]);
				
				_pageThumbnailViews[i]=null;
			}
			_pageThumbnailViews = new Vector.<BookLayoutSampleThumbView>();

			super.dispose();
		}
		
		static public  function get LENGTH():int{
			return  COLUMNS*ROWS;
		}
	}
}