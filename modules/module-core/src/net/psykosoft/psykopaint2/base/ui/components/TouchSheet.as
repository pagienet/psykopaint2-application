package net.psykosoft.psykopaint2.base.ui.components
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import org.gestouch.events.GestureEvent;
    import org.gestouch.gestures.TransformGesture;
    
 
    public class TouchSheet extends Sprite
    {
		private var _minimumRotation:Number = NaN;
		private var _maximumRotation:Number = NaN;
		private var _minimumScale:Number = NaN;
		private var _maximumScale:Number = NaN;
		private var _limitsRect:Rectangle = null;
		
		private var _contentsWidth:Number = NaN;
		private var _contentsHeight:Number = NaN;
		
		
		private var _stepRadians:Number = Math.PI * 0.5;
		private var _snapRadians:Number = Math.PI * 1.5 / 180;
		
		private var content:Bitmap;
		private var _transformGesture:TransformGesture;
		
        public function TouchSheet(map:BitmapData, initialContentScale:Number = 1)
        {
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
          	
            useHandCursor = true;
			
			content = new Bitmap();
			addChild(content);
			
			content.bitmapData = map;
			content.smoothing = true;
            content.scaleX =  content.scaleY =initialContentScale;
			
			_contentsWidth = map.width;
			_contentsHeight = map.height;
			
			centerContent();
		
		}
		
		protected function onAddedToStage(event:Event):void
		{
			_transformGesture = new TransformGesture(this);
			_transformGesture.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			_transformGesture.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			centerContent();
		}
		
		private function onGesture(event:org.gestouch.events.GestureEvent):void
		{
			const gesture:TransformGesture = event.target as TransformGesture;
			var matrix:Matrix = content.transform.matrix;
			
			// Panning
			matrix.translate(gesture.offsetX, gesture.offsetY);
			content.transform.matrix = matrix;
			
			if (gesture.scale != 1 || gesture.rotation != 0)
			{
				// Scale and rotation.
				var transformPoint:Point = matrix.transformPoint(content.globalToLocal(gesture.location));
				matrix.translate(-transformPoint.x, -transformPoint.y);
				matrix.rotate(gesture.rotation);
				matrix.scale(gesture.scale, gesture.scale);
				matrix.translate(transformPoint.x, transformPoint.y);
				
				content.transform.matrix = matrix;
				
			}
			clampToLimitRect(false);
		}
		
		
		private function centerContent():void
		{
			if ( !stage || !content ) return;
			
			content.x = (scrollRect.width - content.width) >> 1;
			content.y = (scrollRect.height - content.height) >> 1;
		}
		
		
		public function setRotationSnap( stepDegrees:Number = 90, snapAngle:Number = 1.5 ):void
		{
			_stepRadians = stepDegrees / 180 * Math.PI;
			_snapRadians = snapAngle / 180 * Math.PI;
			clampRotation();
		}
		
		public function set minimumRotation( value:Number ):void
		{
			_minimumRotation = ( value % ( Math.PI * 2 ) + Math.PI * 2 ) % (Math.PI * 2);
			clampRotation();
		}
		
		public function set maximumRotation( value:Number ):void
		{
			_maximumRotation = ( value % ( Math.PI * 2 ) + Math.PI * 2 ) % (Math.PI * 2);
			clampRotation();
		}
		
		public function set minimumScale( value:Number ):void
		{
			_minimumScale = value;
			clampScale();
			clampToLimitRect(false);
		}
		
		public function set maximumScale( value:Number ):void
		{
			_maximumScale = value;
			clampScale();
		}
		
		public function set limitsRect( value:Rectangle ):void
		{
			_limitsRect = value;
			clampToLimitRect(false);
		}
        
		
		protected function clampToLimitRect( scaleToFit:Boolean ):void
		{
			var p:Point = new Point();
			var m:Matrix = content.transform.matrix;//_tmpMatrix;
			
			if ( _limitsRect != null )
			{
				m.invert();
				
				p.x = _limitsRect.x;
				p.y = _limitsRect.y;
				var tl:Point = m.transformPoint(p);
				p.x +=_limitsRect.width;
				var tr:Point = m.transformPoint(p);
				p.y += _limitsRect.height;
				var br:Point = m.transformPoint(p);
				p.x -=  _limitsRect.width;
				var bl:Point = m.transformPoint(p);
				var minX:Number = Math.min( tl.x,tr.x,bl.x,br.x);
				var maxX:Number = Math.max( tl.x,tr.x,bl.x,br.x);
				var minY:Number = Math.min( tl.y,tr.y,bl.y,br.y);
				var maxY:Number = Math.max( tl.y,tr.y,bl.y,br.y);
				
				p.x = p.y = 0;
				if ( minX < 0 )
				{
					p.x += minX;
				} else if ( maxX > _contentsWidth )
				{
					p.x -= _contentsWidth - maxX;
				}
				
				if ( minY < 0 )
				{
					p.y += minY;
				} else if ( maxY > _contentsHeight )
				{
					p.y -= _contentsHeight - maxY;
				}
				
				m = content.transform.matrix;
				m.tx = m.ty = 0;
				p = m.transformPoint(p);
				
				if ( p.x != 0 || p.y != 0 )
				{
					m = content.transform.matrix;
					m.translate( p.x,p.y);
					content.transform.matrix = m;
				}
				
				if (scaleToFit )
				{
					m = content.transform.matrix.clone();
					m.invert();
					
					p.x = _limitsRect.x;
					p.y = _limitsRect.y;
					tl = m.transformPoint(p);
					p.x +=_limitsRect.width;
					tr = m.transformPoint(p);
					p.y += _limitsRect.height;
					br = m.transformPoint(p);
					p.x -=  _limitsRect.width;
					bl = m.transformPoint(p);
					
					var deltaScale:Number = 1;
					var w:Number = Math.max( tl.x,tr.x,bl.x,br.x) - Math.min( tl.x,tr.x,bl.x,br.x);
					if ( w > _contentsWidth )
					{
						deltaScale = w / _contentsWidth;
					}
					var h:Number = Math.max( tl.y,tr.y,bl.y,br.y) -  Math.min( tl.y,tr.y,bl.y,br.y);
					if ( h > _contentsHeight )
					{
						deltaScale =  Math.max(deltaScale,h / _contentsHeight);
					}
					m = content.transform.matrix;
					m.scale(deltaScale,deltaScale);
					content.transform.matrix = m;
					
					if ( deltaScale != 1 )
					{
						m = content.transform.matrix.clone();
						m.invert();
						
						p.x = _limitsRect.x;
						p.y = _limitsRect.y;
						tl = m.transformPoint(p);
						p.x +=_limitsRect.width;
						tr = m.transformPoint(p);
						p.y += _limitsRect.height;
						br = m.transformPoint(p);
						p.x -=  _limitsRect.width;
						bl = m.transformPoint(p);
						minX = Math.min( tl.x,tr.x,bl.x,br.x);
						maxX = Math.max( tl.x,tr.x,bl.x,br.x);
						minY = Math.min( tl.y,tr.y,bl.y,br.y);
						maxY = Math.max( tl.y,tr.y,bl.y,br.y);
						
						p.x = p.y = 0;
						if ( minX < 0 )
						{
							p.x += minX;
						} else if ( maxX > _contentsWidth )
						{
							p.x -= _contentsWidth - maxX;
						}
						
						if ( minY < 0 )
						{
							p.y += minY;
						} else if ( maxY > _contentsHeight )
						{
							p.y -= _contentsHeight - maxY;
						}
						
						m.tx = m.ty = 0;
						p = m.transformPoint(p);
						m = content.transform.matrix;
						m.translate( p.x,p.y);
						content.transform.matrix = m;
						
					}
				}
				
			}
		}
		
		protected function clampRotation():void
		{
			/*
			_newRotation = ( _newRotation % ( Math.PI * 2 ) + Math.PI * 2 ) % (Math.PI * 2);
			var testSnap:Number = _newRotation % _stepRadians;
			if ( testSnap < _snapRadians ) _newRotation-=testSnap;
			else if ( testSnap > _stepRadians - _snapRadians )_newRotation += _stepRadians - testSnap;
			if ( !isNaN(_maximumRotation) && _newRotation > _maximumRotation ) _newRotation = _maximumRotation;
			if ( !isNaN(_minimumRotation) && _newRotation < _minimumRotation ) _newRotation = _minimumRotation;
			*/
		}
			
		protected function clampScale():void
		{
			var m:Matrix = content.transform.matrix;
			var currentScale:Number = Math.sqrt( m.a*m.a + m.b*m.b );
			var scaleDelta:Number = 1;
			if ( !isNaN(_minimumScale) && currentScale < _minimumScale ) scaleDelta = _minimumScale / currentScale;
			if ( !isNaN(_maximumScale) && currentScale > _maximumScale ) scaleDelta = _maximumScale / currentScale;
			if ( scaleDelta != 1 )
			{
				m.scale( scaleDelta, scaleDelta );
				content.transform.matrix = m;
			}
			
		}
		
        public function dispose():void
        {
			if (_transformGesture)
			{
				_transformGesture.dispose();
				_transformGesture = null;
			}
           
        }
    }
}