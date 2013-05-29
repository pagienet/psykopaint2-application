package net.psykosoft.psykopaint2.base.ui.components
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
 
    public class TouchSheet extends Sprite
    {
		private var _minimumRotation:Number = NaN;
		private var _maximumRotation:Number = NaN;
		private var _minimumScale:Number = NaN;
		private var _maximumScale:Number = NaN;
		private var _limitsRect:Rectangle = null;
		
		private var _contentsWidth:Number = NaN;
		private var _contentsHeight:Number = NaN;
		
	//	private var pivotX:Number;
	//	private var pivotY:Number;
		
		private var _lastX:Number;
		private var _lastY:Number;
		private var _lastStageX:Number;
		private var _lastStageY:Number;
	/*
		private var _newX:Number;
		private var _newY:Number;
		private var _newPivotX:Number;
		private var _newPivotY:Number;
		private var _newScale:Number;
		private var _newRotation:Number;
		*/
		private const _tmpPoint:Point = new Point();
		private const _tmpMatrix:Matrix = new Matrix();
		private var _stepRadians:Number = Math.PI * 0.5;
		private var _snapRadians:Number = Math.PI * 1.5 / 180;
		
		private var content:Bitmap;
		private var transformer:Sprite;
		
		private var _newMatrix:Matrix;
		
        public function TouchSheet(map:BitmapData)
        {
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
          	
            useHandCursor = true;
			transformer = new Sprite();
			addChild( transformer );
			
			//updateInternalProperties();
            
			content = new Bitmap();
			transformer.addChild(content);
			
			content.bitmapData = map;
			content.smoothing = true;
            content.x = int((_contentsWidth = map.width) / -2);
            content.y = int((_contentsHeight = map.height) / -2);
			
			_newMatrix = transformer.transform.matrix.clone();
			//pivotX = -_contentsWidth* 0.5;
			//pivotY = -_contentsHeight* 0.5;
            
        }
		
		protected function onAddedToStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
			addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
			
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_newMatrix = transformer.transform.matrix.clone();
			_lastStageX = event.stageX;
			_lastStageY = event.stageY;
			_lastX = transformer.x;
			_lastY = transformer.y;
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			/*
			_newX = _lastX + event.stageX - _lastStageX;
			_newY = _lastY + event.stageY - _lastStageY;
			_lastStageX = event.stageX;
			_lastStageY = event.stageY;
			_newPivotX = pivotX;
			_newPivotY = pivotY;
			_newScale = transformer.scaleX;
			_newRotation = transformer.rotation;
			*/
			_newMatrix.translate(event.stageX - _lastStageX,event.stageY - _lastStageY);
			_lastStageX = event.stageX;
			_lastStageY = event.stageY;
			clampToLimitRect(false);	
			_lastX = transformer.x;
			_lastY = transformer.y;
			
		}
		
		protected function onRotate(event:TransformGestureEvent):void
		{
			onMouseUp(null);
			
			_newMatrix.translate( -event.localX, -event.localY );
			_newMatrix.rotate(event.rotation / 180 * Math.PI);
			_newMatrix.translate( event.localX, event.localY );
			
			/*
			_newX = transformer.x ;
			_newY = transformer.y ;
			_newPivotX = pivotX;
			_newPivotY = pivotY;
			_newScale = transformer.scaleX;
			_newRotation = transformer.rotation + event.rotation / 180 * Math.PI;
			*/
			clampToLimitRect(false);	
			_lastX = transformer.x;
			_lastY = transformer.y;
		}
		
		protected function onZoom(event:TransformGestureEvent):void
		{
			onMouseUp(null);
			_newMatrix.translate( -event.localX, -event.localY );
			_newMatrix.scale(event.scaleX, event.scaleY );
			_newMatrix.translate( event.localX, event.localY );
			
			/*
			_newX = transformer.x ;
			_newY = transformer.y ;
			_newPivotX = pivotX;
			_newPivotY = pivotY;
			_newScale = scaleX * event.scaleX;
			_newRotation = transformer.rotation
				*/
			clampToLimitRect(false);	
			_lastX = transformer.x;
			_lastY = transformer.y;
		}
		
		protected function onPan(event:TransformGestureEvent):void
		{
			onMouseUp(null);
			_newMatrix.translate( event.offsetX,event.offsetY );
			/*
			_newX = transformer.x + event.offsetX;
			_newY = transformer.y + event.offsetY;
			_newPivotX = pivotX;
			_newPivotY = pivotY;
			_newScale = transformer.scaleX;
			_newRotation = transformer.rotation;
			*/
			clampToLimitRect(false);			
			_lastX = transformer.x;
			_lastY = transformer.y;
		}
		
	/*
		private function updateInternalProperties():void
		{
			_newX = transformer.x;
			_newY = transformer.y;
			_newPivotX = pivotX;
			_newPivotY = pivotY;
			_newScale = transformer.scaleX;
			_newRotation = transformer.rotation;
		}
		*/
		
		public function setRotationSnap( stepDegrees:Number = 90, snapAngle:Number = 1.5 ):void
		{
			_stepRadians = stepDegrees / 180 * Math.PI;
			_snapRadians = snapAngle / 180 * Math.PI;
			//updateInternalProperties();
			clampRotation();
		}
		
		public function set minimumRotation( value:Number ):void
		{
			_minimumRotation = ( value % ( Math.PI * 2 ) + Math.PI * 2 ) % (Math.PI * 2);
			//updateInternalProperties();
			clampRotation();
		}
		
		public function set maximumRotation( value:Number ):void
		{
			_maximumRotation = ( value % ( Math.PI * 2 ) + Math.PI * 2 ) % (Math.PI * 2);
			//updateInternalProperties();
			clampRotation();
		}
		
		public function set minimumScale( value:Number ):void
		{
			_minimumScale = value;
			//updateInternalProperties();
			clampScale();
		}
		
		public function set maximumScale( value:Number ):void
		{
			_maximumScale = value;
			//updateInternalProperties();
			clampScale();
		}
		
		public function set limitsRect( value:Rectangle ):void
		{
			//_limitsRect = value;
			//updateInternalProperties();
			clampToLimitRect(false);
		}
        
		/*
        private function onTouch(event:TouchEvent):void
        {
			
            var touches:Vector.<Touch> = event.getTouches(this, TouchPhase.MOVED);
            
            if (touches.length == 1)
            {
                // one finger touching -> move
                var delta:Point = touches[0].getMovement(parent);
				_newX = x + delta.x;
				_newY = y + delta.y;
				_newPivotX = pivotX;
				_newPivotY = pivotY;
				_newScale = scaleX;
				_newRotation = rotation;
				
              //  x += delta.x;
              //  y += delta.y;
				clampToLimitRect(false);
            }            
            else if (touches.length == 2)
            {
				
                // two fingers touching -> rotate and scale
                var touchA:Touch = touches[0];
                var touchB:Touch = touches[1];
                
                var currentPosA:Point  = touchA.getLocation(parent);
                var previousPosA:Point = touchA.getPreviousLocation(parent);
                var currentPosB:Point  = touchB.getLocation(parent);
                var previousPosB:Point = touchB.getPreviousLocation(parent);
                
                var currentVector:Point  = currentPosA.subtract(currentPosB);
                var previousVector:Point = previousPosA.subtract(previousPosB);
                
                var currentAngle:Number  = Math.atan2(currentVector.y, currentVector.x);
                var previousAngle:Number = Math.atan2(previousVector.y, previousVector.x);
                var deltaAngle:Number = currentAngle - previousAngle;
                
				// update pivot point based on previous center
				var previousLocalA:Point  = touchA.getPreviousLocation(this);
				var previousLocalB:Point  = touchB.getPreviousLocation(this);
				//pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
				//pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				_newPivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
				_newPivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				// update location based on the current center
				//x = (currentPosA.x + currentPosB.x) * 0.5;
				//y = (currentPosA.y + currentPosB.y) * 0.5;
				_newX = (currentPosA.x + currentPosB.x) * 0.5;
				_newY = (currentPosA.y + currentPosB.y) * 0.5;
				
				
				// rotate
               _newRotation = rotation + deltaAngle;
				
				 // scale
                var sizeDiff:Number = currentVector.length / previousVector.length;
				_newScale = scaleX * sizeDiff;
				
				clampRotation();
				clampScale();
				clampToLimitRect( deltaAngle != 0 || sizeDiff != 1);
			 }
            
           
        }
        */
		protected function clampToLimitRect( scaleToFit:Boolean ):void
		{
			var p:Point = _tmpPoint;
			var m:Matrix = _newMatrix.clone();//_tmpMatrix;
			//var difference:Point = new Point( x, y);
			if ( _limitsRect != null )
			{
				/*
				var cos:Number = Math.cos(_newRotation);
				var sin:Number = Math.sin(_newRotation);
				var a:Number   = _newScale *  cos;
				var b:Number   = _newScale *  sin;
				var c:Number   = _newScale * -sin;
				var d:Number   = _newScale *  cos;
				
				m.a = a;
				m.b = b;
				m.c = c;
				m.d = d;
				m.tx =  _newX - _newPivotX * a - _newPivotY * c;
				m.ty =  _newY - _newPivotX * b - _newPivotY * d;
				*/
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
				if ( minX < -_contentsWidth * 0.5 )
				{
					p.x += minX + _contentsWidth * 0.5
				} else if ( maxX > _contentsWidth * 0.5 )
				{
					p.x += maxX - _contentsWidth * 0.5
				}
				
				if ( minY < -_contentsHeight * 0.5 )
				{
					p.y += minY + _contentsHeight * 0.5
				} else if ( maxY > _contentsHeight * 0.5 )
				{
					p.y += maxY - _contentsHeight * 0.5
				}
				
				m = _newMatrix.clone();
				/*
				m.a = a;
				m.b = b;
				m.c = c;
				m.d = d;
				*/
				m.tx = m.ty = 0;
				p = m.transformPoint(p);
				
				//_newX += p.x;
				//_newY += p.y;
				
				_newMatrix.translate( p.x,p.y);
				
				
				if (scaleToFit )
				{
					m = _newMatrix.clone();
					/*
					m.a = a;
					m.b = b;
					m.c = c;
					m.d = d;
					m.tx =_newX - _newPivotX * a - _newPivotY * c;
					m.ty = _newY - _newPivotX * b - _newPivotY * d;
					*/
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
					
					_newMatrix.scale(deltaScale,deltaScale);
					//_newScale *= deltaScale;
					
					if ( deltaScale != 1 )
					{
						/*
						a   = _newScale *  cos;
						b   = _newScale *  sin;
						c   = _newScale * -sin;
						d   = _newScale *  cos;
						
						m.a = a;
						m.b = b;
						m.c = c;
						m.d = d;
						m.tx =  _newX - _newPivotX * a - _newPivotY * c;
						m.ty =  _newY - _newPivotX * b - _newPivotY * d;
						*/
						m = _newMatrix.clone();
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
						if ( minX < -_contentsWidth * 0.5 )
						{
							p.x += minX + _contentsWidth * 0.5
						} else if ( maxX > _contentsWidth * 0.5 )
						{
							p.x += maxX - _contentsWidth * 0.5
						}
						
						if ( minY < -_contentsHeight * 0.5 )
						{
							p.y += minY + _contentsHeight * 0.5
						} else if ( maxY > _contentsHeight * 0.5 )
						{
							p.y += maxY - _contentsHeight * 0.5
						}
						
						m.tx = m.ty = 0;
						p = m.transformPoint(p);
						_newMatrix.translate( p.x,p.y);
						/*
						m.a = a;
						m.b = b;
						m.c = c;
						m.d = d;
						m.tx = m.ty = 0;
						p = m.transformPoint(p);
						
						_newX += p.x;
						_newY += p.y;
						*/
					}
				}
				
			}
			
			transformer.transform.matrix = _newMatrix;
			/*
			pivotX = _newPivotX;
			pivotY = _newPivotY;
			
			transformer.x = _newX;
			transformer.y = _newY;
			
			transformer.rotation = _newRotation;
			transformer.scaleX = transformer.scaleY = _newScale;
			*/
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
			//if ( !isNaN(_minimumScale) && _newScale < _minimumScale ) _newScale = _minimumScale;
			//if ( !isNaN(_maximumScale) && _newScale > _maximumScale ) _newScale = _maximumScale;
		}
		
        public function dispose():void
        {
			if ( stage )
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			removeEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
			removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			removeEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
           
        }
    }
}