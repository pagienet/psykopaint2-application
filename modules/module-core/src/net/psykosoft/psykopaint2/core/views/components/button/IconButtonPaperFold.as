package net.psykosoft.psykopaint2.core.views.components.button
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class IconButtonPaperFold extends MovieClip 
	{
		public var paperFoldMc:MovieClip;
		private var _folded:Boolean = true;
		
		public function IconButtonPaperFold()
		{
			super();
			paperFoldMc.stop();			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
		}
		
		public  function set fold(value:Boolean):void{
			
			
			trace("fold = "+value);
			if(value==true){
				_folded = true;
				/*resetPoints();
				
				
				var upperTy:int = 7;
				var lowerTy:int = -7;
				var compressX:int=6;
				
				distortLeft.tweenTo(new Point(0,0), new Point(leftClip.width-compressX/2, -upperTy), new Point(leftClip.width-compressX/2, leftClip.height+lowerTy), new Point(0,leftClip.height), Exponential.easeOut, .5);
				distortRight.tweenTo(new Point(-compressX/2,-upperTy), new Point(rightClip.width-compressX, 0), new Point(rightClip.width-compressX, rightClip.height), new Point(-compressX/2,rightClip.height+lowerTy), Exponential.easeOut, .5);
				*/
				
				//distortLeft.tweenTo(leftClipPoints[0], leftClipPoints[1], leftClipPoints[2], leftClipPoints[3], Exponential.easeOut, .5);
				//distortRight.tweenTo(rightClipPoints[0], rightClipPoints[1], rightClipPoints[2], rightClipPoints[3], Exponential.easeOut, .5);
				TweenLite.to(paperFoldMc,0.4,{frame:1,ease:Expo.easeOut,onUpdate:function():void{
					
					paperFoldMc.x = -(paperFoldMc.width/2);
				}});
				TweenLite.to(this,0.4,{scaleX:1,scaleY:1,ease:Expo.easeOut});
				
				
				
			}else {
				_folded = false;
				/*
				
				var upperTy:int = 0;
				var lowerTy:int = 0;
				var compressX:int=0;
				
				
				
				distortLeft.tweenTo(new Point(0,0), new Point(leftClip.width-compressX/2, -upperTy), new Point(leftClip.width-compressX/2, leftClip.height+lowerTy), new Point(0,leftClip.height), Exponential.easeOut, .5);
				distortRight.tweenTo(new Point(-compressX/2,-upperTy), new Point(rightClip.width-compressX, 0), new Point(rightClip.width-compressX, rightClip.height), new Point(-compressX/2,rightClip.height+lowerTy), Exponential.easeOut, .5);
				*/
				TweenLite.to(paperFoldMc,0.25,{frame:100,ease:Expo.easeOut,onUpdate:function():void{
					
					paperFoldMc.x = -(paperFoldMc.width/2);
				}});
				TweenLite.to(this,0.25,{scaleX:0.98,scaleY:0.98,ease:Expo.easeOut});

			}
			
			
		}
		
		public function get fold():Boolean{
			return _folded;
		}
		
		
		
	
		
	}
}