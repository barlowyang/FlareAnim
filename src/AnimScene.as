package
{
	import flash.display.DisplayObjectContainer;
	
	import flare.basic.Viewer3D;
	import flare.core.Pivot3D;
	
	public class AnimScene extends Viewer3D
	{
		private var _anim:Pivot3D;
		
		public function AnimScene(container:DisplayObjectContainer, file:String="", smooth:Number=1, speedFactor:Number=0.5)
		{
			super(container, file, smooth, speedFactor);
			
			this.antialias = 4;
			this.skipFrames = true;
		}
		
		public function set anim(val:Pivot3D):void
		{
			_anim = val;
			
			addChild(_anim);
		}
	}
}