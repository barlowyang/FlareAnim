package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flare.core.Label3D;
	
	public class AnimItem extends Panel
	{
		public static const DELETE:String = "AnimItem_del";
		public static const PLAY:String = "AnimItem_play";
		
		private var _name_txt:InputText;
		private var _first_frame:NumericStepper;
		private var _end_frame:NumericStepper;
		
		private var _removeBtn:PushButton;
		private var _playBtn:PushButton;
		
		public function AnimItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		override protected function addChildren():void
		{
			super.addChildren();
			var xPos:int = 0;
			var yPos:int = 0;
			
			const Num_Step:Number = 1;
			
			new Label(this, xPos=5, yPos=5,   "标签:");
			_name_txt = new InputText(this, xPos += 70, yPos);
			new Label(this, xPos=5, yPos+=25,   "起始帧:");
			_first_frame = CreateNumericStepper(xPos += 70, yPos, 20, 70, Num_Step, 2, onUpdateNum);
			new Label(this, xPos=5, yPos+=25,   "结束帧:");
			_end_frame = CreateNumericStepper(xPos += 70, yPos, 20, 70, Num_Step, 2, onUpdateNum);
			
			_removeBtn = new PushButton(this, xPos = 5, yPos += 25, "删除");
			_removeBtn.setSize(60, 20);
			_removeBtn.addEventListener(MouseEvent.CLICK, onRemoveItem);
			
			_playBtn = new PushButton(this, xPos += 70, yPos, "播放");
			_playBtn.setSize(60, 20);
			_playBtn.addEventListener(MouseEvent.CLICK, onPlayItem);
		}
		
		private function onRemoveItem(evt:MouseEvent):void
		{
			dispatchEvent(new Event(DELETE));
		}
		
		private function onPlayItem(evt:MouseEvent):void
		{
			dispatchEvent(new Event(PLAY));
		}
		
		private function onUpdateNum(evt:Event):void
		{
			
		}
		
		private function CreateNumericStepper(x:int, y:int, height:int, width:int, step:Number, labelPrecision:int, handle:Function):NumericStepper
		{
			var ns:NumericStepper = new NumericStepper(this, x, y);
			ns.addEventListener(Event.CHANGE, handle);
			ns.setSize(width, height);
			ns.labelPrecision = labelPrecision;
			ns.step = step;
			ns.minimum = 0;
			return ns;
		}
		
		public function get label_name():String
		{
			return _name_txt.text;
		}
		
		public function get start_frame():uint
		{
			return _first_frame.value;
		}
		
		public function get end_frame():uint
		{
			return _end_frame.value;
		}
		
		public function get label3d():Label3D
		{
			return new Label3D(label_name, start_frame, end_frame);
		}
		
		public function set label3d(val:Label3D):void
		{
			if (val)
			{
				_name_txt.text = val.name;
				_first_frame.value = val.from;
				_end_frame.value = val.to;
			}
		}
	}
}