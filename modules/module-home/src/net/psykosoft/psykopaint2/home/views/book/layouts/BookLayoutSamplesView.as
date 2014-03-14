package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookThumbnailView;
	
	public class BookLayoutSamplesView extends BookLayoutAbstractView
	{
		public static const COLUMNS:int=2;
		public static const ROWS:int=3;
		
		private var _data:SourceImageCollection;
		private var _pageThumbnailViews:Vector.<BookThumbnailView>;
		
		private var _pageIndex:int;
		
		public function BookLayoutSamplesView()
		{
			//THIS IS THE STANDARD LAYOUT VIEW FOR THE SAMPLES
			
			super();
		}
		
		public function setData(data:SourceImageCollection):void{
			this._data = data;
			
			_pageThumbnailViews = new Vector.<BookThumbnailView>();
			
			var currentSourceImageProxy:SourceImageProxy;
			for (var i:int = 0; i < _data.images.length; i++) 
			{
				currentSourceImageProxy = _data.images[i];
				var newPageThumbnailView:BookThumbnailView = new BookThumbnailView();
				newPageThumbnailView.setData(currentSourceImageProxy);
				
				_pageThumbnailViews.push(newPageThumbnailView);
				
				this.addChild(newPageThumbnailView);
				newPageThumbnailView.x = (i%COLUMNS)*(newPageThumbnailView.width +10);
				newPageThumbnailView.z = Math.floor(i/COLUMNS)*-(newPageThumbnailView.height +10);
				//newPageThumbnailView.rotationY= Math.random()*5-2.5;
				
				newPageThumbnailView.addEventListener(MouseEvent3D.CLICK,onClickDownThumbnail);
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
			trace("BookLayoutSamplesView::dispose");
			for (var i:int = 0; i < _pageThumbnailViews.length; i++) 
			{
				_pageThumbnailViews[i].removeEventListener(MouseEvent3D.MOUSE_DOWN,onClickDownThumbnail);
				_pageThumbnailViews[i].dispose();
				if(_pageThumbnailViews[i].parent) _pageThumbnailViews[i].parent.removeChild(_pageThumbnailViews[i]);
				
				_pageThumbnailViews[i]=null;
			}
			_pageThumbnailViews = new Vector.<BookThumbnailView>();

			super.dispose();
		}
		
		static public  function get LENGTH():int{
			return  COLUMNS*ROWS;
		}
	}
}