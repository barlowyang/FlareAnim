package
{
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.bit101.components.VScrollBar;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import flare.core.Label3D;
	import flare.core.Pivot3D;
	
	public class AnimPanel extends Panel
	{
		public static const WIDTH:uint = 300;
		
		private var FScrollbar:VScrollBar;
		private var FContainer:Panel;
		private var FContent:VBox;
		private var _animItemList:Vector.<AnimItem>;
		
		private var _anim:Pivot3D;
		
		public function AnimPanel(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
			
			width = WIDTH;
		}
		
		override protected function addChildren():void
		{
			super.addChildren();
			
			FScrollbar = new VScrollBar(this);
			FScrollbar.addEventListener(Event.CHANGE, DragScroll);
			FScrollbar.lineSize = 50;
			FContainer = new Panel(this);
			
			FContent = new VBox(FContainer.content);
			FContent.spacing = 3;
			FContainer.width = WIDTH;
			FContent.addEventListener(MouseEvent.MOUSE_WHEEL, MouseWheelHandle);
			FContainer.y = 5;
			FScrollbar.y = 5;
			
			_animItemList = new Vector.<AnimItem>();
			
			var btn:PushButton = new PushButton(FContent);
			btn.label = "增加";
			btn.addEventListener(MouseEvent.CLICK, onAddItem);
		}
		
		private function onAddItem(evt:MouseEvent):void
		{
			addItem();
		}
		
		public function addItem(label3d:Label3D = null):void
		{
			var animItem:AnimItem = new AnimItem(FContent);
			//			animItem.width = WIDTH;
			animItem.setSize(WIDTH, 120);
			animItem.addEventListener(AnimItem.DELETE, onDeleteItem);
			animItem.addEventListener(AnimItem.PLAY, onPlayItem);
			animItem.label3d = label3d;
			_animItemList.push(animItem);
		}
		
		private function onPlayItem(evt:Event):void
		{
			if (_anim)
			{
				var animItem:AnimItem = evt.currentTarget as AnimItem;
				
				if (!animItem.label_name)
				{
					FlareAnim.inst.showInfo("请输入标签名！");
				}
				else
				{
					_anim.addLabel(animItem.label3d);
					
					setTimeout(function ():void
					{
						_anim.gotoAndPlay(animItem.label_name);
					}, 100);
				}
			}
		}
		
		private function onDeleteItem(evt:Event):void
		{
			var animItem:AnimItem = evt.currentTarget as AnimItem;
			var idx:int = _animItemList.indexOf(animItem);
			if (idx != -1)
			{
				animItem.removeEventListener(AnimItem.DELETE, onDeleteItem);
				animItem.removeEventListener(AnimItem.PLAY, onPlayItem);
				_animItemList.splice(idx, 1);
				animItem.parent.removeChild(animItem);
			}
		}
		
		private function MouseWheelHandle(e:MouseEvent):void
		{
			FContent.y += e.delta * 10;
			UpdateScroll();
		}
		
		private function UpdateScroll():void
		{
			var maxValue:int = Math.max(FContent.height - FContainer.height, 0)
			var percent:Number =  Math.min(1, FContainer.height/FContent.height);
			
			if(FContent.y > 0)
			{
				FContent.y = 0;
			}
			if(FContent.y < -maxValue)
			{
				FContent.y = -maxValue;
			}
			
			var currValue:int = -FContent.y;
			if(isNaN(percent))
			{
				percent = 0;
			}
			
			FScrollbar.setSliderParams(0, maxValue, currValue);
			FScrollbar.setThumbPercent(percent);
			FScrollbar.pageSize = 225;
		}
		
		private function DragScroll(e:Event):void
		{
			FContent.y = -FScrollbar.value;
		}
		
		override public function draw():void
		{
			super.draw();
			
			FContainer.setSize(_width - 10 - FScrollbar.width, FScrollbar.height = _height - 10);
			
			FContainer.x = 5;
			FScrollbar.x = FContainer.width + 5;
			
			//			updateItem();
		}
		
		private function updateItem():void
		{
			var pw:int = FContainer.width;
			var len:int = _animItemList.length;
			for(var i:int = 0; i < len; i++)
			{
				_animItemList[i].width = pw;
			}
		}
		
		public function reset():void
		{
			for each (var item:AnimItem in _animItemList)
			{
				item.parent.removeChild(item);
			}
//			_animItemList.length = 0;
			updateItem();
		}
		
		public function get anim():Pivot3D
		{
			return _anim;
		}
		
		public function set anim(value:Pivot3D):void
		{
			_anim = value;
		}
		
		public function get itemList():Array
		{
			var arr:Array = new Array();
			for each (var item:AnimItem in _animItemList)
			{
				if (item.label_name)
				{
					arr.push(item.label3d);
				}
			}
			return arr;
		}
	}
}